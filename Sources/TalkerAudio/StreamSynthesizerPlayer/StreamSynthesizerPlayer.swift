//
//  StreamSynthesizerPlayer.swift
//  iOS
//
//  Created by feichao on 2023/3/16.
//

import AsyncAlgorithms
import Foundation
import OSLog
import SwiftUI
import TalkerCommon

public enum StreamSynthesizerPlayerError: String, LocalizedError {
    case notSetup
    case noSynthesizerPlayer
    case writeToWavFile
    case unfinishedStreamBuffer

    public var errorDescription: String? {
        self.rawValue
    }
}

@MainActor
public class StreamSynthesizerPlayer {
//    private var synthesizerPlayers: [StreamSynthesizerProtocol] = []
    private let finished = OneShotChannel()
    private var allPlayers: [any StreamSynthesizerProtocol & Sendable] = []
    private var task: Task<(), Error>? = nil
    private let newPlayerFunc: @Sendable (_ text: String, _ voiceId: String, _ style: String, _ role: String) -> any StreamSynthesizerProtocol & Sendable
    public private(set) var isPlaying: Bool = false

    public init(newPlayer: @Sendable @escaping (_ text: String, _ voiceId: String, _ style: String, _ role: String) -> StreamSynthesizerProtocol) {
        self.newPlayerFunc = newPlayer
    }
 
    @MainActor
    public func synthesize(text: String, saveTo: String?, voiceId: String, style: String, role: String) async throws {
        let tokenizor = Tokenizor()
        let sentences = tokenizor.splitToSentences(text, maxChars: 200)
        let stream = AsyncThrowingStream { cont in
            for s in sentences {
                cont.yield(s)
            }
            cont.finish()
        }
        try await streamSynthesize(textStream: stream, saveTo: saveTo, voiceId: voiceId, style: style, role: role)
    }

    @MainActor
    public func streamSynthesize(
        textStream: AsyncThrowingStream<String, Error>,
        saveTo: String?,
        voiceId: String,
        style: String,
        role: String
    ) async throws {
        let finished = finished
        isPlaying = true
        task = Task { [unowned self] in
            defer {
                infoLog("finished.")
                finished.finish(())
                isPlaying = false
            }

            let channel = AsyncChannel<(String, any StreamSynthesizerProtocol & Sendable)>()
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask { @Sendable in
                    defer {
                        infoLog("all player finished load.")
                        channel.finish()
                    }

                    for try await text in textStream {
                        try Task.checkCancellation()
                        infoLog("load for: \(text)")
                        let player = self.newPlayerFunc(text, voiceId, style, role)
                        try player.load()
                        try await player.waitForLoadFinished()
                        infoLog("load finished for: \(text)")
                        await channel.send((text, player))
                    }
                }

                for await (text, player) in channel.buffer(policy: .bounded(5)) {
                    try Task.checkCancellation()
                    allPlayers.append(player)
                    infoLog("start play for: \(text)")
                    try await player.play()
                    infoLog("wait for player to stop")
                    try await player.waitForPlayStopped()
                    infoLog("play stopped for: \(text)")
                }
            }

            try Task.checkCancellation()

            infoLog("players count: \(self.allPlayers.count)")
            guard let saveTo, !allPlayers.isEmpty else {
                return
            }

            let mp3Files = allPlayers.map { player in
                player.cachePath()
            }
            let outputMp3File = buildURLForFile(named: saveTo, inDirectory: "audio")
            infoLog("will save to \(outputMp3File)")
            do {
                try FileManager.default.createDirectory(
                    at: outputMp3File.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            } catch {
                errorLog("Error creating directory: \(error.localizedDescription)")
                throw error
            }

            do {
                try await mergeMP3Files(audioFileUrls: mp3Files, outputUrl: outputMp3File)
            } catch {
                errorLog("mergeMP3Files: \(error.localizedDescription)")
                throw error
            }
        }

        if let task {
            try await task.value
        }
    }

    @MainActor
    public func waitForPlayerToStop() async throws {
        try await finished.wait()
    }

    public func stopPlaying() throws {
        infoLog("stop Playing")
        guard let task else {
            return
        }
        if !task.isCancelled {
            task.cancel()
        }
        for player in allPlayers {
            infoLog("stop player inner")
            if player.isPlaying {
                try? player.stop()
            }
        }
    }

    public func stopPlayingAndSynthesizing() throws {
        infoLog("stopPlayingAndSynthesizing")
        try stopPlaying()
    }
}
