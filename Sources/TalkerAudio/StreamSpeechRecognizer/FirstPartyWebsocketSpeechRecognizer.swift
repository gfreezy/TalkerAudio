//
//  EdgeTest.swift
//  iOS
//
//  Created by feichao on 2023/6/27.
//

import AVFoundation
import AsyncObjects
import CryptoKit
import Foundation
import OSLog
import StreamAudio
import SwiftUI
import TalkerCommon

public class BaseFirstPartyWebsocketRecognizer: NSObject, URLSessionWebSocketDelegate, @unchecked
    Sendable
{
    let language: Lock<String> = Lock("en-US")
    let reference: Lock<String?> = Lock(nil)
    let pronounceInfoRequired: Lock<Bool> = Lock(false)
    nonisolated(unsafe) var webSocketTask: URLSessionWebSocketTask?
    nonisolated(unsafe) var sendAudioTask: Task<(), Error>?
    let recognizedFinalResult: OneShotChannel<ResponseData> = OneShotChannel(ResponseData.self)
    let websocketConnected = OneShotChannel()
    let websocketClosed = Lock(false)
    let url: String
    let extraHeaders: [String: String]
    let uniqueId: String

    public init(url: String, extraHeaders: [String: String] = [:]) {
        self.url = url
        self.extraHeaders = extraHeaders
        self.uniqueId = UUID().uuidString
        super.init()
    }

    public func recognizedResult() async throws -> SpeechRecognizerResult {
        let response = try await recognizedFinalResult.wait()
        return SpeechRecognizerResult(text: response.data, pronounceInfo: response.accuracy)
    }

    public func startRecognition(language: String, reference: String?, pronounceInfoRequired: Bool)
        async throws
    {
        self.language.value = language
        self.reference.value = reference
        self.pronounceInfoRequired.value = pronounceInfoRequired
        try await startSendAudioTask()
    }

    public func cancelRecoginition() throws {
        sendAudioTask?.cancel()
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
    }

    /// websocket reads data from this function, nil means no more data, empty data means sleep and retry.
    func readData() -> Data? {
        return nil
    }

    func startSendAudioTask() async throws {
        connectWebsocket()
        try await websocketConnected.wait()

        sendAudioTask = Task {
            defer {
                if !self.recognizedFinalResult.isFinished {
                    self.recognizedFinalResult.finish(
                        throwing: MessageError(
                            "Audio task unknown error exit, uniqueId: \(uniqueId)"))
                }
            }

            do {
                try await withThrowingTaskGroup(of: Void.self) { group in
                    infoLog("wait for started response, uniqueId: \(uniqueId)")
                    try await self.waitForStartedResponse()

                    group.addTask {
                        try await self.readResultFromWebSocket()
                    }

                    group.addTask { [self] in
                        while !Task.isCancelled {
                            guard let webSocketTask else {
                                throw MessageError("No websocket, uniqueId: \(uniqueId)")
                            }

                            if let data = readData() {
                                if data.isEmpty {
                                    //                                infoLog("no more data, sleep")
                                    try await Task.sleep(for: .milliseconds(20))
                                    continue
                                }
                                //                                debugLog("send audio bytes: \(data.count), offset: \(String(describing: offset))")
                                try await webSocketTask.send(.data(data))
                            } else {
                                try await sendAudioFinish()
                                infoLog("send audo finish data, uniqueId: \(uniqueId)")
                                return
                            }
                        }
                    }

                    for try await _ in group {

                    }
                }
            } catch {
                if !self.recognizedFinalResult.isFinished {
                    self.recognizedFinalResult.finish(throwing: error)
                }
            }
        }
    }

    func connectWebsocket() {
        guard webSocketTask == nil else {
            return
        }
        let url = buildUrl(
            url: url, lang: language.value, reference: reference.value, uniqueId: self.uniqueId,
            pronounceInfoRequired: pronounceInfoRequired.value)
        var request = URLRequest(url: URL(string: url)!)

        for (key, value) in extraHeaders {
            request.addValue(value, forHTTPHeaderField: key)
        }
        let webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask.delegate = self
        self.webSocketTask = webSocketTask
        webSocketTask.resume()
    }

    func readResultFromWebSocket() async throws {
        guard let webSocketTask else {
            return
        }

        do {
            while webSocketTask.closeCode == .invalid && !Task.isCancelled {
                guard let msg = try await readMessage() else {
                    recognizedFinalResult.finish(
                        throwing: MessageError("Connection closed, uniqueId: \(uniqueId)"))
                    break
                }

                switch msg.action {
                case .started:
                    fatalError()
                case .error:
                    infoLog(
                        "read recognization error: \(String(describing: msg.desc)), uniqueId: \(uniqueId)"
                    )
                    throw MessageError(msg.desc ?? "")
                case .result:
                    infoLog(
                        "read final recognization message: \(String(describing: msg.data)), uniqueId: \(uniqueId)"
                    )
                    recognizedFinalResult.finish(msg)
                }
            }
        } catch {
            recognizedFinalResult.finish(throwing: error)
        }
    }

    private func readMessage() async throws -> ResponseData? {
        guard let webSocketTask, webSocketTask.closeCode == .invalid, !websocketClosed.value else {
            return nil
        }
        let message: URLSessionWebSocketTask.Message
        do {
            message = try await webSocketTask.receive()
        } catch {
            let e = error as NSError
            if e.domain == NSPOSIXErrorDomain && e.code == 57 {
                infoLog("Connection closed, uniqueId: \(uniqueId)")
            } else {
                errorLog("receive message error: \(error), uniqueId: \(uniqueId)")
            }
            websocketClosed.value = true
            return nil
        }

        let resp: ResponseData
        switch message {
        case .string(let data):
            infoLog("Received data: \(data), uniqueId: \(uniqueId)")
            resp = try JSONDecoder().decode(ResponseData.self, from: data.data(using: .utf8)!)
        case .data(_):
            throw MessageError("Unexpected binary message, uniqueId: \(uniqueId)")
        @unknown default:
            fatalError()
        }
        infoLog("receive new message: \(String(describing: resp)), uniqueId: \(uniqueId)")
        return resp
    }

    private func waitForStartedResponse() async throws {
        let message = try await readMessage()
        guard let message, message.action == .started else {
            throw MessageError("Unexpected message, uniqueId: \(uniqueId)")
        }
        infoLog("started message received, uniqueId: \(uniqueId)")
    }

    func sendAudioFinish() async throws {
        guard let webSocketTask, webSocketTask.closeCode == .invalid else {
            throw MessageError("Websocket not available, uniqueId: \(uniqueId)")
        }
        try await webSocketTask.send(.data("{\"end\": true}".data(using: .utf8)!))
    }

    public func urlSession(
        _ session: URLSession, webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        websocketConnected.finish(())
        infoLog("websocket connected, uniqueId: \(uniqueId)")
    }

    public func urlSession(
        _ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?
    ) {
        if !websocketConnected.isFinished {
            websocketConnected.finish(
                throwing: MessageError(
                    "error connect: \(error.debugDescription), uniqueId: \(uniqueId)"))
        }
    }

    public func urlSession(
        _ session: URLSession, webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?
    ) {
        if !websocketConnected.isFinished {
            websocketConnected.finish(
                throwing: MessageError("error connect, uniqueId: \(uniqueId)"))
        }
        websocketClosed.value = true
        infoLog("websocket close: \(closeCode.rawValue), uniqueId: \(uniqueId) reason: \(reason)")
    }

    deinit {
        self.webSocketTask?.cancel()
        self.sendAudioTask?.cancel()
    }
}

public final class FirstPartyWebsocketAudioFileRecognizer: BaseFirstPartyWebsocketRecognizer,
    FileSpeechRecognizer, @unchecked Sendable
{
    let audioFile: URL
    let isAllDataSent = Lock(false)

    public init(url: String, audioFile: URL, extraHeaders: [String: String] = [:]) {
        self.audioFile = audioFile
        super.init(url: url, extraHeaders: extraHeaders)
    }

    override func readData() -> Data? {
        if isAllDataSent.value {
            return nil
        }
        isAllDataSent.value = true
        do {
            let buffer = try readAVAudioPCMBufferFromWavFile(fileURL: audioFile)
            let data = buffer.int16ChannelData!.pointee.withMemoryRebound(
                to: UInt8.self, capacity: Int(buffer.frameLength) * 2
            ) {
                Data(bytes: $0, count: Int(buffer.frameLength * 2))
            }
            return data
        } catch {
            errorLog("read audio file error: \(error), uniqueId: \(uniqueId)")
        }

        return nil
    }
}

public final class FirstPartyWebsocketStreamRecognizer: BaseFirstPartyWebsocketRecognizer,
    StreamSpeechRecognizer, @unchecked Sendable
{
    private let recorder = StreamAudioRecorder()
    private let streamAudioBuffer = StreamAudioBuffer()
    private let totalSentBytes: Lock<Int> = Lock(0)
    private let isRecordingStopped = Lock(true)
    private let queue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        return q
    }()
    public nonisolated(unsafe) var delegate: (any StreamSpeechRecognizerDelegate)?
    private nonisolated(unsafe) var offset = StreamIndexOffset(index: 0, offset: 0)

    public override init(url: String, extraHeaders: [String: String] = [:]) {
        super.init(url: url, extraHeaders: extraHeaders)
        setup()
    }

    func setup() {
        recorder.audioInputMoreDataBlock = { [weak self] buf in
            guard let self, !buf.isEmpty else {
                return
            }
            streamAudioBuffer.appendBytes(bytes: buf)

            queue.addOperation {
                if self.isRecordingStopped.value {
                    return
                }
                self.delegate?.receiveAudioBuffer(data: buf)
            }
        }
    }

    public func startRecordingAndRecognition(
        language: String, reference: String?, pronounceInfoRequired: Bool
    ) async throws {
        try recorder.start()
        try await super.startRecognition(
            language: language, reference: reference, pronounceInfoRequired: pronounceInfoRequired)
    }

    public func stopRecordingAndCancelRecoginition() throws {
        try stopRecording()
        try cancelRecoginition()
    }

    public func stopRecording(force: Bool = false) throws {
        try recorder.stop()
        streamAudioBuffer.finishStream()
        if !isRecordingStopped.value {
            infoLog(
                "stop Recording, recorded bytes: \(streamAudioBuffer.totalBytes), uniqueId: \(uniqueId)"
            )
        }
        isRecordingStopped.value = true
        queue.cancelAllOperations()
    }

    public func saveAudioToFile(_ name: String?) throws -> URL {
        return try saveAudioBufferToDisk(name: name ?? uniqueId, buf: streamAudioBuffer)
    }

    override func readData() -> Data? {
        let data = streamAudioBuffer.subrangeBytes(offset)
        if let data {
            self.streamAudioBuffer.advanceStreamIndexOffset(&offset, size: data.count)
        }
        return data
    }
}

enum ResponseAction: String, Decodable {
    case started = "started"
    case result = "result"
    case error = "error"
}

struct ResponseData: Decodable {
    var action: ResponseAction
    var data: String
    var desc: String?
    var accuracy: PronounceInfo?

    static func createEmpty() -> Self {
        return ResponseData(action: .error, data: "")
    }
}

private func buildUrl(
    url: String, lang: String, reference: String?, uniqueId: String, pronounceInfoRequired: Bool
) -> String {
    let ts = String(Int(Date().timeIntervalSince1970))
    var components = URLComponents()
    var queryItems: [URLQueryItem] = [
        URLQueryItem(name: "lang", value: lang),
        URLQueryItem(name: "ts", value: ts),
        URLQueryItem(name: "unique_id", value: uniqueId),
        URLQueryItem(
            name: "pronounce_info_required", value: pronounceInfoRequired ? "true" : "false"),
    ]

    if let reference, !reference.isEmpty {
        queryItems.append(URLQueryItem(name: "reference", value: reference))
    }
    components.queryItems = queryItems
    let url = "\(url)/speechtotext"
    let query = components.url?.query ?? ""
    let fullUrl = "\(url)?\(query)"
    infoLog("websocket url: \(fullUrl)")
    return fullUrl
}
