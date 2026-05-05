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
import TalkerCommonLogging
import TalkerCommonSync

public class BaseFirstPartyWebsocketRecognizer: NSObject, URLSessionWebSocketDelegate, @unchecked
    Sendable
{
    let language: Lock<String> = Lock("en-US")
    let reference: Lock<String?> = Lock(nil)
    let pronounceInfoRequired: Lock<Bool> = Lock(false)
    nonisolated(unsafe) var webSocketTask: URLSessionWebSocketTask?
    nonisolated(unsafe) var sendAudioTask: Task<(), Error>?
    let recognizedFinalResult: TalkerCommonSync.OneShotChannel<ResponseData> = TalkerCommonSync.OneShotChannel(ResponseData.self)
    let websocketConnected = TalkerCommonSync.OneShotChannel()
    let websocketClosed = Lock(false)
    let url: String
    let extraHeaders: [String: String]
    let uniqueId: String
    var format: RecordFormat = .pcm

    public init(url: String, extraHeaders: [String: String] = [:]) {
        self.url = url
        self.extraHeaders = extraHeaders
        self.uniqueId = UUID().uuidString
        super.init()
    }

    public func recognizedResult() async throws -> SpeechRecognizerResult {
        let response = try await recognizedFinalResult.wait()
        return SpeechRecognizerResult(text: response.data, words: response.words, pronounceInfo: response.accuracy)
    }

    public func startRecognition(
        language: String, reference: String?, pronounceInfoRequired: Bool, format: RecordFormat
    ) async throws {
        self.language.value = language
        self.reference.value = reference
        self.pronounceInfoRequired.value = pronounceInfoRequired
        self.format = format
        try await startSendAudioTask()
    }

    public func cancelRecoginition() throws {
        infoLog(
            "cancelRecoginition: called, sendAudioTask=\(sendAudioTask == nil ? "nil" : "set"), webSocketTask=\(webSocketTask == nil ? "nil" : "set"), webSocketTask.state=\(webSocketTask.map { String(describing: $0.state) } ?? "n/a"), webSocketTask.closeCode=\(webSocketTask.map { String(describing: $0.closeCode.rawValue) } ?? "n/a"), websocketConnected.isFinished=\(websocketConnected.isFinished), websocketClosed=\(websocketClosed.value), recognizedFinalResult.isFinished=\(recognizedFinalResult.isFinished), uniqueId: \(uniqueId)"
        )
        if let sendAudioTask {
            infoLog("cancelRecoginition: cancelling sendAudioTask, uniqueId: \(uniqueId)")
            sendAudioTask.cancel()
        } else {
            infoLog("cancelRecoginition: sendAudioTask is nil, skip cancel (likely still in websocketConnected.wait()), uniqueId: \(uniqueId)")
        }
        if let webSocketTask {
            infoLog("cancelRecoginition: cancelling webSocketTask with .normalClosure, uniqueId: \(uniqueId)")
            webSocketTask.cancel(with: .normalClosure, reason: nil)
        } else {
            infoLog("cancelRecoginition: webSocketTask is nil, skip cancel, uniqueId: \(uniqueId)")
        }
        infoLog("cancelRecoginition: returned, uniqueId: \(uniqueId)")
    }

    /// websocket reads data from this function, nil means no more data, empty data means sleep and retry.
    func readData() -> Data? {
        return nil
    }

    func startSendAudioTask() async throws {
        infoLog("startSendAudioTask: begin, uniqueId: \(uniqueId)")
        connectWebsocket()
        infoLog("startSendAudioTask: connectWebsocket returned, awaiting websocketConnected.wait(), uniqueId: \(uniqueId)")
        try await websocketConnected.wait()
        infoLog("startSendAudioTask: websocketConnected.wait() returned, creating sendAudioTask, uniqueId: \(uniqueId)")

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
                    infoLog("sendAudioTask: wait for started response, uniqueId: \(uniqueId)")
                    try await self.waitForStartedResponse()
                    infoLog("sendAudioTask: started response received, spawning read/send subtasks, uniqueId: \(uniqueId)")

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
            infoLog("connectWebsocket: already has webSocketTask, skipping, uniqueId: \(uniqueId)")
            return
        }
        let url = buildUrl(
            url: url, lang: language.value, reference: reference.value, uniqueId: self.uniqueId,
            pronounceInfoRequired: pronounceInfoRequired.value, format: format)
        var request = URLRequest(url: URL(string: url)!)

        for (key, value) in extraHeaders {
            request.addValue(value, forHTTPHeaderField: key)
        }
        let webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask.delegate = self
        self.webSocketTask = webSocketTask
        webSocketTask.resume()
        infoLog("connectWebsocket: webSocketTask.resume() called, uniqueId: \(uniqueId)")
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
        infoLog("delegate didOpenWithProtocol fired, uniqueId: \(uniqueId)")
        websocketConnected.finish(())
        infoLog("websocket connected, uniqueId: \(uniqueId)")
    }

    public func urlSession(
        _ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?
    ) {
        infoLog("delegate didCompleteWithError fired, error: \(String(describing: error)), websocketConnected.isFinished=\(websocketConnected.isFinished), uniqueId: \(uniqueId)")
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
        infoLog("delegate didCloseWith fired, closeCode: \(closeCode.rawValue), websocketConnected.isFinished=\(websocketConnected.isFinished), uniqueId: \(uniqueId)")
        if !websocketConnected.isFinished {
            websocketConnected.finish(
                throwing: MessageError("error connect, uniqueId: \(uniqueId)"))
        }
        websocketClosed.value = true
        infoLog(
            "websocket close: \(closeCode.rawValue), uniqueId: \(uniqueId) reason: \(String(describing: reason))"
        )
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

    public init(
        url: String, audioFile: URL, extraHeaders: [String: String] = [:]
    ) {
        self.audioFile = audioFile
        super.init(url: url, extraHeaders: extraHeaders)
        self.format = RecordFormat.fromUrl(url: audioFile)
    }

    override func readData() -> Data? {
        if isAllDataSent.value {
            return nil
        }
        isAllDataSent.value = true
        switch format {
        case .pcm:
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
        case .aac, .opus:
            do {
                let data = try Data(contentsOf: audioFile)
                return data
            } catch {
                errorLog("read audio file error: \(error), uniqueId: \(uniqueId)")
            }
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
        recorder.audioInputMoreDataBlock = { [weak self] buf, finish in
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
        language: String, reference: String?, pronounceInfoRequired: Bool, format: RecordFormat
    ) async throws {
        infoLog("startRecordingAndRecognition: begin, uniqueId: \(uniqueId)")
        self.format = format
        try recorder.start(format: format)
        infoLog("startRecordingAndRecognition: recorder.start returned, calling super.startRecognition, uniqueId: \(uniqueId)")
        try await super.startRecognition(
            language: language, reference: reference, pronounceInfoRequired: pronounceInfoRequired,
            format: format)
        infoLog("startRecordingAndRecognition: super.startRecognition returned, uniqueId: \(uniqueId)")
        isRecordingStopped.value = false
    }

    public func stopRecordingAndCancelRecoginition() throws {
        infoLog("stopRecordingAndCancelRecoginition: begin, uniqueId: \(uniqueId)")
        try stopRecording()
        try cancelRecoginition()
        infoLog("stopRecordingAndCancelRecoginition: returned, uniqueId: \(uniqueId)")
    }

    public func stopRecording(force: Bool = false) throws {
        infoLog("stopRecording: begin, force=\(force), isRecordingStopped=\(isRecordingStopped.value), uniqueId: \(uniqueId)")
        try recorder.stop()
        infoLog("stopRecording: recorder.stop returned, uniqueId: \(uniqueId)")
        if !isRecordingStopped.value {
            infoLog(
                "stop Recording, recorded bytes: \(streamAudioBuffer.totalBytes), uniqueId: \(uniqueId)"
            )
        }
        isRecordingStopped.value = true
        queue.cancelAllOperations()
        streamAudioBuffer.finishStream()
        infoLog("stopRecording: returned (queue cancelled, stream finished), uniqueId: \(uniqueId)")
    }

    public func saveAudioToFile(_ name: String?) throws -> String {
        return try saveAudioBufferToDisk(
            name: name ?? uniqueId, buf: streamAudioBuffer, format: format)
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
    var words: [SpeechRecognizerWord]?

    static func createEmpty() -> Self {
        return ResponseData(action: .error, data: "", words: nil)
    }
}

private func buildUrl(
    url: String, lang: String, reference: String?, uniqueId: String, pronounceInfoRequired: Bool,
    format: RecordFormat
) -> String {
    let ts = String(Int(Date().timeIntervalSince1970))
    var components = URLComponents()
    var queryItems: [URLQueryItem] = [
        URLQueryItem(name: "lang", value: lang),
        URLQueryItem(name: "ts", value: ts),
        URLQueryItem(name: "unique_id", value: uniqueId),
        URLQueryItem(
            name: "pronounce_info_required", value: pronounceInfoRequired ? "true" : "false"),
        URLQueryItem(name: "format", value: format.rawValue),
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
