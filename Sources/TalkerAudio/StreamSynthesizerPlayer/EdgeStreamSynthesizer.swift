//
//  EdgeStreamSynthesizer.swift
//  iOS
//
//  Created by feichao on 2023/6/27.
//

import AsyncObjects
import AVFoundation
import Foundation
import OSLog
import StreamAudio
import SwiftUI
import TalkerCommon
import CryptoKit


fileprivate class EdgeConstants {
    private static let BASE_URL = "speech.platform.bing.com/consumer/speech/synthesize/readaloud"
    private static let TRUSTED_CLIENT_TOKEN = "6A5AA1D4EAFF4E9FB37E23D68491D6F4"

    private static let WSS_URL: String = {
        return "wss://\(BASE_URL)/edge/v1?TrustedClientToken=\(TRUSTED_CLIENT_TOKEN)"
    }()

    private static let VOICE_LIST: String = {
        return "https://\(BASE_URL)/voices/list?trustedclienttoken=\(TRUSTED_CLIENT_TOKEN)"
    }()

    static let DEFAULT_VOICE = "en-US-EmmaMultilingualNeural"

    private static let CHROMIUM_FULL_VERSION = "130.0.2849.68"
    private static let CHROMIUM_MAJOR_VERSION: String = {
        return CHROMIUM_FULL_VERSION.components(separatedBy: ".").first ?? ""
    }()

    private static let SEC_MS_GEC_VERSION: String = {
        return "1-\(CHROMIUM_FULL_VERSION)"
    }()

    private static let BASE_HEADERS: [String: String] = {
        return [
            "User-Agent": """
                Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 \
                (KHTML, like Gecko) Chrome/\(CHROMIUM_MAJOR_VERSION).0.0.0 Safari/537.36 \
                Edg/\(CHROMIUM_MAJOR_VERSION).0.0.0
                """,
            "Accept-Encoding": "gzip, deflate, br",
            "Accept-Language": "en-US,en;q=0.9"
        ]
    }()

    static let WSS_HEADERS: [String: String] = {
        var headers = [
            "Pragma": "no-cache",
            "Cache-Control": "no-cache",
            "Origin": "chrome-extension://jdiccldimpdaibmpdkjnbmckianbfold"
        ]
        headers.merge(BASE_HEADERS) { (_, new) in new }
        return headers
    }()

    static let VOICE_HEADERS: [String: String] = {
        var headers = [
            "Authority": "speech.platform.bing.com",
            "Sec-CH-UA": """
                " Not;A Brand";v="99", "Microsoft Edge";v="\(CHROMIUM_MAJOR_VERSION)", \
                "Chromium";v="\(CHROMIUM_MAJOR_VERSION)"
                """,
            "Sec-CH-UA-Mobile": "?0",
            "Accept": "*/*",
            "Sec-Fetch-Site": "none",
            "Sec-Fetch-Mode": "cors",
            "Sec-Fetch-Dest": "empty"
        ]
        headers.merge(BASE_HEADERS) { (_, new) in new }
        return headers
    }()

    static func generateSecMsGecToken() -> String {
        let now = Date()
        let unixEpoch = now.timeIntervalSince1970
        let windowsEpochOffset: Double = 11644473600
        let windowsTime = (unixEpoch + windowsEpochOffset) * 10_000_000
        var ticks = UInt64(windowsTime)
        ticks -= ticks % 3_000_000_000
        let strToHash = "\(ticks)\(TRUSTED_CLIENT_TOKEN)"
        let dataToHash = strToHash.data(using: .ascii)!
        let hash = SHA256.hash(data: dataToHash)
        let hexString = hash.compactMap { String(format: "%02X", $0) }.joined()
        return hexString
    }

    static func generateSecMsGecVersion() -> String {
        return "1-\(CHROMIUM_FULL_VERSION)"
    }

    static let BINARY_DELIM = Data("Path:audio\r\n".utf8)

    static func wssUrl() -> String {
        "\(Self.WSS_URL)&Sec-MS-GEC=\(EdgeConstants.generateSecMsGecToken())&Sec-MS-GEC-Version=\(EdgeConstants.generateSecMsGecVersion())&ConnectionId=\(UUID().uuidString)"
    }

    static func getVoiceListUrl() -> String {
        "\(Self.VOICE_LIST)&Sec-MS-GEC=\(EdgeConstants.generateSecMsGecToken())&Sec-MS-GEC-Version=\(EdgeConstants.generateSecMsGecVersion())&ConnectionId=\(UUID().uuidString)"
    }
}

public final class EdgeStreamSynthesizerEngine: StreamSynthesizerEngine {
    // All stored properties are `let` + Sendable; no `@unchecked` needed.
    private let voice: String
    private let voiceLocale: String
    private let borrowSemaphore = AsyncSemaphore(value: 1)

    public init(voice: String) {
        self.voice = voice
        self.voiceLocale = getLangFromVoiceId(voice) ?? "en-US"
    }

    public func makeSession(text: String) async throws -> any StreamSynthesizerSession & Sendable {
        try await borrowSemaphore.wait()
        let sem = borrowSemaphore
        return EdgeStreamSynthesizerSession(
            text: text,
            voice: voice,
            voiceLocale: voiceLocale,
            synthUrl: EdgeConstants.wssUrl(),
            releaseBorrow: { sem.signal() }
        )
    }

    public func shutdown() {}
}

public final class EdgeStreamSynthesizerSession: NSObject, URLSessionWebSocketDelegate, StreamSynthesizerSession, Sendable {
    private static let outputFormat = "audio-24khz-48kbitrate-mono-mp3"

    private let synthUrl: String
    private let text: String
    private let voice: String
    private let voiceLocale: String
    private let websocketConnected: OneShotChannel<Void>
    private let player: StreamAudio.StreamAudioPlayer
    private let webSocketTask: URLSessionWebSocketTask
    private let loadTask: Task<Void, Error>

    init(
        text: String,
        voice: String,
        voiceLocale: String,
        synthUrl: String,
        releaseBorrow: @Sendable @escaping () -> Void
    ) {
        self.text = text
        self.voice = voice
        self.voiceLocale = voiceLocale
        self.synthUrl = synthUrl
        let player = StreamAudio.StreamAudioPlayer(
            cachePath: tempAudioCachePath(extension: "mp3"), fileType: kAudioFileMP3Type)
        self.player = player

        var request = URLRequest(url: URL(string: synthUrl)!)
        request.allHTTPHeaderFields = EdgeConstants.WSS_HEADERS
        let webSocketTask = URLSession.shared.webSocketTask(with: request)
        self.webSocketTask = webSocketTask

        let websocketConnected = OneShotChannel<Void>()
        self.websocketConnected = websocketConnected

        let released = Lock(false)
        let releaseOnce: @Sendable () -> Void = {
            let shouldRelease = released.withLock { v -> Bool in
                if v { return false }
                v = true
                return true
            }
            if shouldRelease { releaseBorrow() }
        }

        // Capture locals (not self) so the Task body can be created before
        // super.init — this lets `loadTask` be a true `let`.
        self.loadTask = Task {
            defer { releaseOnce() }
            try await EdgeStreamSynthesizerSession.runLoadFlow(
                text: text,
                synthUrl: synthUrl,
                voice: voice,
                voiceLocale: voiceLocale,
                websocketConnected: websocketConnected,
                webSocketTask: webSocketTask,
                player: player
            )
        }

        super.init()
        webSocketTask.delegate = self
        webSocketTask.resume()
    }

    public var isPlaying: Bool {
        return player.runningState == .playing
    }

    public func play() async throws {
        debugLog("wait for load to finish: \(self.text)")
        do {
            try await waitForLoadFinished()
        } catch {
            errorLog("wait for load error: \(error), \(self.text)")
            throw error
        }
        debugLog("start player: \(self.text)")
        try await player.play()
    }

    public func stop() throws {
        debugLog("stop player: \(self.text)")
        webSocketTask.cancel()
        loadTask.cancel()
        try player.stop()
    }

    public func waitForPlayStopped() async throws {
        try await player.waitForStop()
    }

    public func waitForLoadFinished() async throws {
        try await loadTask.value
    }

    private static func runLoadFlow(
        text: String,
        synthUrl: String,
        voice: String,
        voiceLocale: String,
        websocketConnected: OneShotChannel<Void>,
        webSocketTask: URLSessionWebSocketTask,
        player: StreamAudio.StreamAudioPlayer
    ) async throws {
        infoLog("websocket state: \(webSocketTask.state.rawValue), closeCode: \(webSocketTask.closeCode.rawValue), text: \(text)")

        defer {
            infoLog("player finish data: \(text)")
            do {
                try player.finishData()
            } catch {
                errorLog("finish data error:", error)
            }
        }

        try await websocketConnected.wait()

        infoLog("new task, url: \(synthUrl), text: \(text)")
        try await webSocketTask.send(
            .string(
                """
                Content-Type:application/json; charset=utf-8\r\nPath:speech.config\r\n\r\n{"context": {"synthesis": {"audio": {"metadataoptions": {"sentenceBoundaryEnabled": "false","wordBoundaryEnabled": "false"},"outputFormat": "\(outputFormat)"}}}}\r\n
                """))
        infoLog("send header: \(text)")

        let ssml = """
            <speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="\(voiceLocale)"><voice name="\(voice)">\(text)</voice></speak>
            """
        let requestId = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        let request = "X-RequestId:\(requestId)\r\nContent-Type:application/ssml+xml\r\nPath:ssml\r\n\r\n\(ssml)"
        try await webSocketTask.send(.string(request))

        loop: while true {
            let message = try await webSocketTask.receive()
            switch message {
            case .string(let data):
                if data.contains("Path:turn.start") {
                    debugLog("Path:turn.start")
                } else if data.contains("Path:turn.end") {
                    debugLog("Path:turn.end")
                    break loop
                } else if data.contains("Path:response") {
                    debugLog("Path:response")
                } else {
                    errorLog("unknown message")
                }
            case .data(let data):
                if data == Data([0x00, 0x67, 0x58]) {
                    debugLog("end empty bytes")
                    break
                } else {
                    guard let range = data.range(of: EdgeConstants.BINARY_DELIM) else {
                        errorLog("no range found")
                        return
                    }
                    let audioData = data.subdata(in: range.upperBound..<data.count)
                    if audioData.isEmpty {
                        continue
                    }
                    try player.writeData(audioData)
                }
            @unknown default:
                fatalError()
            }
        }
        infoLog("close websocket: \(text)")
        webSocketTask.cancel(with: .normalClosure, reason: "Normal close".data(using: .utf8))
        infoLog(
            "websocket after close: \(String(describing: webSocketTask.state)), \(String(describing: webSocketTask.closeCode)), \(String(describing: webSocketTask.closeReason))"
        )
    }

    public func urlSession(
        _ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?
    ) {
        debugLog("websocket connected: \(self.text)")
        websocketConnected.finish(())
    }

    public func urlSession(
        _ session: URLSession, webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?
    ) {
        if websocketConnected.isFinished {
            return
        }
        debugLog("websocket close: \(closeCode.rawValue), \(self.text)")
        if closeCode == .normalClosure {
            websocketConnected.finish(())
        } else {
            websocketConnected.finish(throwing: MessageError(String(describing: closeCode)))
        }
    }

    public func cachePath() -> URL {
        player.cacheFilePath()
    }
}
