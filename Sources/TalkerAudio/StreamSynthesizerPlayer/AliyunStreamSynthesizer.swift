//
//  AliyunStreamSynthesizer.swift
//  iOS
//
//  Created by feichao on 2023/4/27.
//

import AsyncObjects
import AVFoundation
import AsyncAlgorithms
import Foundation
import OSLog
import StreamAudio
import TalkerCommon

public final class AliyunStreamSynthesizerEngine: StreamSynthesizerEngine {
    // All stored properties are `let` + Sendable, so the compiler synthesizes
    // Sendable for us — no `@unchecked` needed.

    private let format: String
    private let sampleRate: Int
    private let appKey: String
    private let host = "nls-gateway-cn-shanghai.aliyuncs.com"
    private let getTokenFunc: @Sendable () async throws -> String
    private let borrowSemaphore = AsyncSemaphore(value: 1)

    public init(
        appKey: String,
        getToken: @Sendable @escaping () async throws -> String,
        format: String = "mp3",
        sampleRate: Int = 16000
    ) {
        self.appKey = appKey
        self.format = format
        self.sampleRate = sampleRate
        self.getTokenFunc = getToken
    }

    public func makeSession(text: String) async throws -> any StreamSynthesizerSession & Sendable {
        try await borrowSemaphore.wait()
        return AliyunStreamSynthesizerSession(text: text, engine: self)
    }

    public func shutdown() {}

    fileprivate func buildAudioUrl(text: String) async throws -> URL {
        guard let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else {
            throw MessageError("Unable to encode text")
        }
        let token = try await getTokenFunc()

        let urlString =
            "https://\(host)/stream/v1/tts?appkey=\(appKey)&token=\(token)&text=\(encodedText)&format=\(format)&sample_rate=\(sampleRate)"

        guard let url = URL(string: urlString) else {
            throw MessageError("Invalid URL")
        }
        infoLog("url: \(url)")
        return url
    }

    fileprivate func releaseBorrow() {
        borrowSemaphore.signal()
    }
}

public final class AliyunStreamSynthesizerSession: StreamSynthesizerSession, Sendable {
    // All-let Sendable storage — synthesized Sendable, no escape hatch needed.

    private let player: URLAudioPlayer
    private let loadTask: Task<Void, Error>

    init(text: String, engine: AliyunStreamSynthesizerEngine) {
        let player = URLAudioPlayer(cachePath: tempAudioCachePath(extension: "mp3"))
        self.player = player

        let released = Lock(false)
        let releaseOnce: @Sendable () -> Void = {
            let shouldRelease = released.withLock { v -> Bool in
                if v { return false }
                v = true
                return true
            }
            if shouldRelease { engine.releaseBorrow() }
        }

        self.loadTask = Task { @Sendable in
            defer { releaseOnce() }
            let url = try await engine.buildAudioUrl(text: text)
            player.load(url)
            try await player.waitForLoadFinished()
        }
    }

    public func play() async throws {
        try await waitForLoadFinished()
        try await player.play()
    }

    public func stop() throws {
        try player.stop()
        loadTask.cancel()
    }

    public func waitForPlayStopped() async throws {
        try await player.waitForStop()
    }

    public func waitForLoadFinished() async throws {
        try await loadTask.value
    }

    public var isPlaying: Bool {
        return player.runningState == .playing
    }

    public func cachePath() -> URL {
        player.cacheFilePath()
    }
}
