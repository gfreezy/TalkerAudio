//
//  EdgeTest.swift
//  iOS
//
//  Created by feichao on 2023/6/27.
//

import AVFoundation
import CryptoKit
import Foundation
import OSLog
import StreamAudio
import SwiftUI
import TalkerCommon

public final class YoudaoStreamRecognizer: NSObject, StreamSpeechRecognizer,
    URLSessionWebSocketDelegate, @unchecked Sendable
{
    private let recorder = StreamAudioRecorder()
    private var streamAudioBuffer = StreamAudioBuffer()
    private var language: String = "en-US"
    private var isRecordingStopped = false
    private let queue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        return q
    }()
    private var webSocketTask: URLSessionWebSocketTask?
    private var sendAudioTask: Task<(), Error>? = nil
    private let recognizedFinalText: OneShotChannel<String> = OneShotChannel(String.self)
    private let websocketConnected = OneShotChannel()
    private var websocketClosed = false
    private let appKey: String
    private let appSecret: String
    public var delegate: (any StreamSpeechRecognizerDelegate)?

    init(appKey: String, appSecret: String) {
        self.appKey = appKey
        self.appSecret = appSecret
        super.init()
        setup()
    }

    func setup() {
        recorder.audioInputMoreDataBlock = { [weak self] buf in
            guard let self, !buf.isEmpty else {
                return
            }
            streamAudioBuffer.appendBytes(bytes: buf)

            queue.addOperation {
                if self.isRecordingStopped {
                    return
                }
                self.delegate?.receiveAudioBuffer(data: buf)
            }
        }
    }

    public func recognizedResult() async throws -> SpeechRecognizerResult {
        let text = try await recognizedFinalText.wait()
        return SpeechRecognizerResult(text: text)
    }

    public func startRecordingAndRecognition(
        language: String, reference: String?, pronounceInfoRequired: Bool, format: RecordFormat
    ) async throws {
        if pronounceInfoRequired {
            throw StreamSpeechRecognizerError.notSupportPronounceInfo
        }
        self.language = language
        assert(format == .pcm)
        try recorder.start(format: format)
        startSendAudioTask()
    }

    public func stopRecordingAndCancelRecoginition() throws {
        try stopRecording()
        try cancelRecoginition()
    }

    public func stopRecording(force: Bool = false) throws {
        try recorder.stop()
        streamAudioBuffer.finishStream()
        infoLog("stop Recording")
        isRecordingStopped = true
        queue.cancelAllOperations()
    }

    public func cancelRecoginition() throws {
        sendAudioTask?.cancel()
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
    }

    public func saveAudioToFile(_ name: String?) throws -> String {
        return try saveAudioBufferToDisk(
            name: name ?? UUID().uuidString, buf: streamAudioBuffer, format: .pcm)
    }

    func startSendAudioTask() {
        connectWebsocket()

        sendAudioTask = Task {
            defer {
                if !self.recognizedFinalText.isFinished {
                    self.recognizedFinalText.finish(throwing: MessageError("error exit"))
                }
            }

            try await self.websocketConnected.wait()

            try await withThrowingTaskGroup(of: Void.self) { group in
                infoLog("wait for started response")
                try await self.waitForStartedResponse()
                try await self.sendAudioHeader()

                group.addTask {
                    try await self.readResult()
                }

                group.addTask { [self] in
                    var offset = StreamIndexOffset(index: 0, offset: 0)
                    while !Task.isCancelled {
                        guard let webSocketTask else {
                            throw MessageError("No websocket")
                        }

                        if let data = streamAudioBuffer.subrangeBytes(offset) {
                            if data.isEmpty {
                                try await Task.sleep(for: .milliseconds(20))
                            }
                            debugLog(
                                "send audio bytes: \(data.count), offset: \(String(describing: offset))"
                            )
                            try await webSocketTask.send(.data(data))
                            self.streamAudioBuffer.advanceStreamIndexOffset(
                                &offset, size: data.count)
                        } else {
                            try await sendAudioFinish()
                            infoLog("close websocket")
                            return
                        }
                    }
                }

                for try await _ in group {

                }
            }
        }
    }

    func connectWebsocket() {
        guard webSocketTask == nil else {
            return
        }
        let url = YoudaoURLBuilder(appKey: appKey, appSecret: appSecret).build(langType: language)
        let webSocketTask = URLSession.shared.webSocketTask(with: URL(string: url)!)
        webSocketTask.delegate = self
        self.webSocketTask = webSocketTask
        webSocketTask.resume()
    }

    func readResult() async throws {
        guard let webSocketTask else {
            return
        }

        var text = ""
        while webSocketTask.closeCode == .invalid && !Task.isCancelled {
            guard let msg = try await readMessage() else {
                break
            }

            switch msg {
            case .error(let e):
                throw MessageError(e.errorCode)
            case .started(_):
                fatalError()
            case .recognition(let recognition):
                if recognition.errorCode == "304" {
                    break
                }
                infoLog("read message: \(String(describing: recognition))")
                let recognized = recognition.result.filter({ !$0.st.partial }).map(\.st.sentence)
                    .joined(separator: " ")
                text += recognized
            }
        }
        recognizedFinalText.finish(text)
    }

    func readMessage() async throws -> YoudaoResponse? {
        guard let webSocketTask, webSocketTask.closeCode == .invalid else {
            return nil
        }
        let message: URLSessionWebSocketTask.Message
        do {
            message = try await webSocketTask.receive()
        } catch {
            errorLog("receive message error: \(error)")
            return nil
        }
        let resp =
            switch message {
            case .string(let data):
                try JSONDecoder().decode(YoudaoResponse.self, from: data.data(using: .utf8)!)
            case .data(_):
                throw MessageError("Unexpected binary message")
            @unknown default:
                fatalError()
            }
        return resp
    }

    func waitForStartedResponse() async throws {
        let messge = try await readMessage()
        guard case .started(_) = messge else {
            throw MessageError("Unexpected message")
        }
        infoLog("started message received")
    }

    func sendAudioHeader() async throws {
        guard let webSocketTask, webSocketTask.closeCode == .invalid else {
            throw MessageError("Websocket not available")
        }
        let wavHeader = getWavHeader(
            sampleRate: 16000, bitsPerSample: 16, numberOfChannels: 1, audioDataLength: 60000)
        try await webSocketTask.send(.data(wavHeader))
    }

    func sendAudioFinish() async throws {
        guard let webSocketTask, webSocketTask.closeCode == .invalid else {
            throw MessageError("Websocket not available")
        }
        try await webSocketTask.send(.data("{\"end\": \"true\"}".data(using: .utf8)!))
    }

    public func urlSession(
        _ session: URLSession, webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        websocketConnected.finish(())
        debugLog("websocket connected")
    }

    public func urlSession(
        _ session: URLSession, webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?
    ) {
        if !websocketConnected.isFinished {
            websocketConnected.finish(throwing: MessageError("error connect"))
        }
        websocketClosed = true
        debugLog("websocket close: \(closeCode.rawValue)")
    }

    deinit {
        self.webSocketTask?.cancel()
        self.sendAudioTask?.cancel()
    }

}

// 枚举定义不同的响应类型
enum YoudaoResponse: Decodable {
    case error(YoudaoError)
    case started(YoudaoStarted)
    case recognition(YoudaoRecognition)

    enum CodingKeys: String, CodingKey {
        case action
    }

    enum ActionType: String, Decodable {
        case error, started, recognition
    }

    // 自定义解码器以处理不同类型的响应
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let actionType = try container.decode(ActionType.self, forKey: .action)

        switch actionType {
        case .error:
            let value = try YoudaoError(from: decoder)
            self = .error(value)
        case .started:
            let value = try YoudaoStarted(from: decoder)
            self = .started(value)
        case .recognition:
            let value = try YoudaoRecognition(from: decoder)
            self = .recognition(value)
        }
    }
}

// 对于错误响应的结构
struct YoudaoError: Codable {
    let result: String
    let action: String
    let errorCode: String
}

// 对于开始响应的结构
struct YoudaoStarted: Codable {
    let result: [String]
    let action: String
    let errorCode: String
}

// 对于识别响应的结构
struct YoudaoRecognition: Codable {
    struct RecognitionResult: Codable {
        struct Sentence: Codable {
            struct Word: Codable {
                let w: String  // 词
                let wb: Int  // 词开始时间
                let we: Int  // 词结束时间
            }

            let bg: Int  // 句子开始时间
            let ed: Int  // 句子结束时间
            let ws: [Word]  // 词列表
            let partial: Bool
            let type: Int
            let sentence: String
        }

        let st: Sentence
        let seg_id: Int
    }

    let result: [RecognitionResult]
    let action: String
    let errorCode: String
}

class YoudaoURLBuilder {
    private var appKey: String
    private var appSecret: String
    private let format = "wav"
    private let channel = "1"
    private let version = "v1"
    private let rate = "16000"
    private let url = "wss://openapi.youdao.com/stream_asropenapi"

    init(appKey: String, appSecret: String) {
        self.appKey = appKey
        self.appSecret = appSecret
    }

    func build(langType: String) -> String {
        let salt = UUID().uuidString
        let curtime = String(Int(Date().timeIntervalSince1970))
        let input = appKey + salt + curtime + appSecret
        let sign = SHA256.hash(data: Data(input.utf8)).map { String(format: "%02x", $0) }.joined()

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "appKey", value: appKey),
            URLQueryItem(name: "salt", value: salt),
            URLQueryItem(name: "curtime", value: curtime),
            URLQueryItem(name: "sign", value: sign),
            URLQueryItem(name: "signType", value: "v4"),
            URLQueryItem(name: "format", value: format),
            URLQueryItem(name: "langType", value: langType),
            URLQueryItem(name: "channel", value: channel),
            URLQueryItem(name: "version", value: version),
            URLQueryItem(name: "rate", value: rate),
        ]

        let query = components.url?.query ?? ""
        return "\(url)?\(query)"
    }
}
