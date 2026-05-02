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
    private let allPlayers: Lock<[any StreamSynthesizerProtocol & Sendable]> = Lock([])
    private var task: Task<(), Error>? = nil
    private let newPlayerFunc:
        @Sendable (_ voiceId: String, _ style: String, _ role: String) ->
            any StreamSynthesizerProtocol & Sendable
    public private(set) var isPlaying: Bool = false

    private struct PreparedInner {
        let player: any StreamSynthesizerProtocol & Sendable
        let voiceId: String
        let style: String
        let role: String
    }
    private var prepared: PreparedInner?

    public init(
        newPlayer: @Sendable @escaping (
            _ voiceId: String, _ style: String, _ role: String
        ) -> StreamSynthesizerProtocol
    ) {
        self.newPlayerFunc = newPlayer
    }

    /// Pre-create an inner synthesizer for the given voice triple so its connection
    /// is opened ahead of time. The first text chunk in `streamSynthesize` consumes
    /// it; if the voice triple doesn't match at that point, the prepared instance is
    /// discarded.
    /// Idempotent for the same triple; calling with a different triple discards the
    /// previous prepared instance.
    public func prepare(voiceId: String, style: String, role: String) {
        if let prepared,
           prepared.voiceId == voiceId,
           prepared.style == style,
           prepared.role == role
        {
            infoLog("[prewarm] StreamSynthesizerPlayer.prepare: same triple, no-op (\(voiceId)/\(style)/\(role))")
            return
        }
        if let prepared {
            infoLog("[prewarm] StreamSynthesizerPlayer.prepare: discard previous (\(prepared.voiceId)/\(prepared.style)/\(prepared.role)) -> (\(voiceId)/\(style)/\(role))")
            try? prepared.player.stop()
        }
        let createStart = Date()
        infoLog("[prewarm] StreamSynthesizerPlayer.prepare: creating inner for \(voiceId)/\(style)/\(role)")
        let inner = newPlayerFunc(voiceId, style, role)
        let elapsedMs = Int(Date().timeIntervalSince(createStart) * 1000)
        infoLog("[prewarm] StreamSynthesizerPlayer.prepare: inner created in \(elapsedMs)ms")
        prepared = PreparedInner(player: inner, voiceId: voiceId, style: style, role: role)
    }

    /// Drop any prepared inner synthesizer without using it. Call when you no longer
    /// expect to speak (e.g. session teardown) so the open connection is released.
    public func discardPrepared() {
        guard let prepared else {
            infoLog("[prewarm] StreamSynthesizerPlayer.discardPrepared: nothing to discard")
            return
        }
        infoLog("[prewarm] StreamSynthesizerPlayer.discardPrepared: dropping (\(prepared.voiceId)/\(prepared.style)/\(prepared.role))")
        try? prepared.player.stop()
        self.prepared = nil
    }

    @MainActor
    public func synthesize(
        text: String, saveTo: String?, voiceId: String, style: String, role: String
    ) async throws {
        let tokenizor = Tokenizor()
        let sentences = tokenizor.splitToSentences(text, maxChars: 200)
        let stream = AsyncThrowingStream { cont in
            for s in sentences {
                cont.yield(s)
            }
            cont.finish()
        }
        try await streamSynthesize(
            textStream: stream, saveTo: saveTo, voiceId: voiceId, style: style, role: role)
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

        let preparedSlot: Lock<(any StreamSynthesizerProtocol & Sendable)?>
        if let prepared,
           prepared.voiceId == voiceId,
           prepared.style == style,
           prepared.role == role
        {
            infoLog("[prewarm] streamSynthesize: matched prepared inner for \(voiceId)/\(style)/\(role)")
            preparedSlot = Lock(prepared.player)
            self.prepared = nil
        } else {
            if let stale = prepared {
                infoLog("[prewarm] streamSynthesize: voice mismatch, discard prepared (\(stale.voiceId)/\(stale.style)/\(stale.role)) requested (\(voiceId)/\(style)/\(role))")
                try? stale.player.stop()
                self.prepared = nil
            } else {
                infoLog("[prewarm] streamSynthesize: no prepared inner, will create fresh per text chunk")
            }
            preparedSlot = Lock(nil)
        }

        task = Task { [unowned self] in
            defer {
                infoLog("finished.")
                finished.finish(())
                isPlaying = false
                // Release any unconsumed prepared inner so its connection can drop.
                preparedSlot.withLock { slot in
                    if let leftover = slot {
                        try? leftover.stop()
                        slot = nil
                    }
                }
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
                        let chunkStart = Date()
                        infoLog("load for: \(text)")
                        let resolved: (any StreamSynthesizerProtocol & Sendable, Bool) = preparedSlot.withLock { slot in
                            if let prepared = slot {
                                slot = nil
                                return (prepared, true)
                            }
                            return (self.newPlayerFunc(voiceId, style, role), false)
                        }
                        let player = resolved.0
                        let usedPrepared = resolved.1
                        infoLog("[prewarm] text chunk using \(usedPrepared ? "PREPARED" : "fresh") inner for: \(text.prefix(30))")
                        let loadStart = Date()
                        try player.load(text: text)
                        let loadElapsed = Int(Date().timeIntervalSince(loadStart) * 1000)
                        infoLog("[prewarm] load(\(usedPrepared ? "PREPARED" : "fresh")): \(loadElapsed)ms")
                        await channel.send((text, player))
                        let waitStart = Date()
                        try await player.waitForLoadFinished()
                        let waitElapsed = Int(Date().timeIntervalSince(waitStart) * 1000)
                        let totalElapsed = Int(Date().timeIntervalSince(chunkStart) * 1000)
                        infoLog("[prewarm] load finished for: \(text), waitForLoadFinished=\(waitElapsed)ms total=\(totalElapsed)ms")
                    }
                }

                group.addTask { @Sendable in
                    for await (text, player) in channel.buffer(policy: .bounded(5)) {
                        try Task.checkCancellation()
                        self.allPlayers.withLock { $0.append(player) }
                        infoLog("start play for: \(text)")
                        try await player.play()
                        infoLog("wait for player to stop")
                        try await player.waitForPlayStopped()
                        infoLog("play stopped for: \(text)")
                    }
                }

                for try await _ in group {
                }
            }

            try Task.checkCancellation()

            infoLog("players count: \(self.allPlayers.withLock { $0.count })")
            guard let saveTo, !allPlayers.withLock({ $0.isEmpty }) else {
                return
            }

            let mp3Files = allPlayers.withLock {
                $0.map { player in
                    player.cachePath()
                }
            }
            let outputMp3File = buildURLForAudio(named: saveTo, format: .pcm)
            infoLog("will save to \(outputMp3File)")
            do {
                try FileManager.default.createDirectory(
                    at: outputMp3File.deletingLastPathComponent(),
                    withIntermediateDirectories: true, attributes: nil)
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
        allPlayers.withLock { players in
            for player in players {
                infoLog("stop player inner")
                if player.isPlaying {
                    try? player.stop()
                }
            }
        }
    }

    public func stopPlayingAndSynthesizing() throws {
        infoLog("stopPlayingAndSynthesizing")
        try stopPlaying()
    }
}
