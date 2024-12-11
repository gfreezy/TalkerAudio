//
//  AliyunStreamSynthesizer.swift
//  iOS
//
//  Created by feichao on 2023/4/27.
//

import AVFoundation
import AsyncAlgorithms
import Foundation
import OSLog
import StreamAudio
import TalkerCommon

public final class AliyunStreamSynthesizer: StreamSynthesizerProtocol, Sendable {

    private let format: String
    private let text: String
    private let sampleRate: Int
    private let appKey: String
    private let host = "nls-gateway-cn-shanghai.aliyuncs.com"
    private let tokenizer = Tokenizor()
    private let player: URLAudioPlayer = {
        var cachePath = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        cachePath.appendPathExtension("mp3")
        return URLAudioPlayer(cachePath: cachePath)
    }()
    private nonisolated(unsafe) var task: Task<(), Error>? = nil
    private let getTokenFunc: @Sendable () async throws -> String

    public init(text: String, appKey: String, getToken: @Sendable @escaping () async throws -> String, format: String = "mp3", sampleRate: Int = 16000) {
        self.text = text
        self.appKey = appKey
        self.format = format
        self.sampleRate = sampleRate
        self.getTokenFunc = getToken
    }

    private func buildAudioUrl() async throws -> URL {
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

    public func load() throws {
        guard task == nil else {
            return
        }
        task = Task { @Sendable [self] in
            let url = try await self.buildAudioUrl()
            player.load(url)
        }
    }

    public func waitForLoadFinished() async throws {
        try await player.waitForLoadFinished()
    }

    public func waitForPlayStopped() async throws {
        try await player.waitForStop()
    }

    public var isPlaying: Bool {
        return player.runningState == .playing
    }

    public func play() async throws {
        try load()
        try await waitForLoadFinished()
        try await player.play()
    }

    public func stop() throws {
        try player.stop()
        task?.cancel()
    }

    func waitForStop() async throws {
        try await player.waitForStop()
    }

    public func cachePath() -> URL {
        player.cacheFilePath()
    }
}
