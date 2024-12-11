//
//  EdgeTest.swift
//  iOS
//
//  Created by feichao on 2023/6/27.
//

import AVFoundation
import Foundation
import OSLog
import StreamAudio
import SwiftUI
import CryptoKit
import TalkerCommon


// https://www.xfyun.cn/doc/asr/rtasr/API.html
public final class XfStreamRecognizer: NSObject, StreamSpeechRecognizer, URLSessionWebSocketDelegate, @unchecked Sendable {
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

    public func startRecordingAndRecognition(language: String, reference: String?, pronounceInfoRequired: Bool) async throws {
        if pronounceInfoRequired {
            throw StreamSpeechRecognizerError.notSupportPronounceInfo
        }
        self.language = language
        try recorder.start()
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
    
    public func saveAudioToFile(_ name: String?) throws -> URL {
        return try saveAudioBufferToDisk(name: name ?? UUID().uuidString, buf: streamAudioBuffer)
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
                            self.streamAudioBuffer.advanceStreamIndexOffset(&offset, size: data.count)
                            if data.isEmpty {
//                                infoLog("no more data, sleep")
                                try await Task.sleep(for: .milliseconds(20))
                                continue
                            }
                            debugLog("send audio bytes: \(data.count), offset: \(String(describing: offset))")
                            try await webSocketTask.send(.data(data))
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
        let url = buildUrl(appId: appKey, apiKey: appSecret, lang: "en")
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
            
            switch msg.action {
            case .started:
                fatalError()
            case .error:
                throw MessageError(msg.desc)
            case .result:
                infoLog("read message: \(String(describing: msg.data))")
                let trans = try JSONDecoder().decode(TranscriptionResponse.self, from: msg.data.data(using: .utf8)!)
                // 0 标识最终结果
                
                    let t = trans.cn.st.rt.flatMap {
                        $0.ws
                    }.flatMap {
                        $0.cw
                    }.map {
                        $0.w
                    }.joined()
                infoLog("recognized: \(t), type: \(trans.cn.st.type)")
                if trans.cn.st.type == "0" {
                    text += t
                }
            }
        }
        recognizedFinalText.finish(text)
    }

    private func readMessage() async throws -> XfResponseData? {
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

        let resp = switch message {
        case .string(let data):
            try JSONDecoder().decode(XfResponseData.self, from: data.data(using: .utf8)!)
        case .data(_):
            throw MessageError("Unexpected binary message")
        @unknown default:
            fatalError()
        }
        infoLog("receive new message: \(String(describing: resp))")
        return resp
    }
    
    private func waitForStartedResponse() async throws {
        let message = try await readMessage()
        guard let message, message.action == .started else {
            throw MessageError("Unexpected message")
        }
        infoLog("started message received")
    }
    
    func sendAudioFinish() async throws {
        guard let webSocketTask, webSocketTask.closeCode == .invalid else {
            throw MessageError("Websocket not available")
        }
        try await webSocketTask.send(.data("{\"end\": true}".data(using: .utf8)!))
    }
    
    public func urlSession(
        _ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?
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

fileprivate enum XfResponseAction: String, Decodable {
    case started = "started"
    case result = "result"
    case error = "error"
}

fileprivate struct XfResponseData: Decodable {
    var action: XfResponseAction
    var code: String
    var data: String
    var desc: String
    var sid: String
}


fileprivate func buildUrl(appId: String, apiKey: String, lang: String) -> String {
    let ts = String(Int(Date().timeIntervalSince1970))
    let signa = generateSigna(appId: appId, timestamp: ts, apiKey: apiKey)
    var components = URLComponents()
    components.queryItems = [
        URLQueryItem(name: "appid", value: appId),
        URLQueryItem(name: "lang", value: lang),
        URLQueryItem(name: "ts", value: ts),
        URLQueryItem(name: "signa", value: signa),
    ]
    let url = "wss://rtasr.xfyun.cn/v1/ws"

    let query = components.url?.query ?? ""
    return "\(url)?\(query)"
}

fileprivate func generateSigna(appId: String, timestamp: String, apiKey: String) -> String {
    // 步骤 1: 拼接 appId 和 timestamp
    let baseString = "\(appId)\(timestamp)"

    // 步骤 2: 对 baseString 进行 MD5 加密
    let md5Data = Insecure.MD5.hash(data: Data(baseString.utf8))
    let md5String = md5Data.map { String(format: "%02x", $0) }.joined()

    // 步骤 3: 使用 apiKey 对 MD5 后的字符串进行 HmacSHA1 加密，并进行 base64 编码
    let key = SymmetricKey(data: apiKey.data(using: .utf8)!)
    let hmacData = HMAC<Insecure.SHA1>.authenticationCode(for: md5String.data(using: .utf8)!, using: key)
    let signaData = Data(hmacData)
    
    return signaData.base64EncodedString()
}

// Define the top-level structure
struct TranscriptionResponse: Codable {
    let cn: CN
    let segId: Int

    enum CodingKeys: String, CodingKey {
        case cn
        case segId = "seg_id"
    }
}

// Define the CN structure
struct CN: Codable {
    let st: ST
}

// Define the ST structure
struct ST: Codable {
    let bg: String
    let ed: String
    let rt: [RT]
    let type: String
}

// Define the RT structure
struct RT: Codable {
    let ws: [WS]
}

// Define the WS structure
struct WS: Codable {
    let cw: [CW]
    let wb: Int
    let we: Int
}

// Define the CW structure
struct CW: Codable {
    let w: String
    let wp: String
}
