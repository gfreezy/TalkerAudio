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

public final class StreamSynthesizerPlayer: Sendable {
    private let engine: any StreamSynthesizerEngine & Sendable
    private let finished = OneShotChannel()
    private let allSessions: Lock<[any StreamSynthesizerSession & Sendable]> = Lock([])
    private let taskBox: Lock<Task<Void, Error>?> = Lock(nil)
    private let isPlayingBox: Lock<Bool> = Lock(false)

    public var isPlaying: Bool { isPlayingBox.withLock { $0 } }

    public init(engine: any StreamSynthesizerEngine & Sendable) {
        self.engine = engine
    }

    public func synthesize(text: String, saveTo: String?) async throws {
        let tokenizor = Tokenizor()
        let sentences = tokenizor.splitToSentences(text, maxChars: 200)
        let stream = AsyncThrowingStream { cont in
            for s in sentences {
                cont.yield(s)
            }
            cont.finish()
        }
        try await streamSynthesize(textStream: stream, saveTo: saveTo)
    }

    public func streamSynthesize(
        textStream: AsyncThrowingStream<String, Error>,
        saveTo: String?
    ) async throws {
        let finished = finished
        allSessions.withLock { $0.removeAll() }
        isPlayingBox.withLock { $0 = true }

        let task: Task<Void, Error> = Task { [unowned self] in
            defer {
                infoLog("finished.")
                finished.finish(())
                isPlayingBox.withLock { $0 = false }
            }

            let channel = AsyncChannel<(String, any StreamSynthesizerSession & Sendable)>()
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask { @Sendable in
                    defer {
                        infoLog("all sessions finished load.")
                        channel.finish()
                    }

                    for try await text in textStream {
                        try Task.checkCancellation()
                        infoLog("load for: \(text)")
                        let session = try await self.engine.makeSession(text: text)
                        await channel.send((text, session))
                        try await session.waitForLoadFinished()
                        infoLog("load finished for: \(text)")
                    }
                }

                group.addTask { @Sendable in
                    for await (text, session) in channel.buffer(policy: .bounded(5)) {
                        try Task.checkCancellation()
                        self.allSessions.withLock { $0.append(session) }
                        infoLog("start play for: \(text)")
                        try await session.play()
                        infoLog("wait for player to stop")
                        try await session.waitForPlayStopped()
                        infoLog("play stopped for: \(text)")
                    }
                }

                for try await _ in group {
                }
            }

            try Task.checkCancellation()

            infoLog("sessions count: \(self.allSessions.withLock { $0.count })")
            guard let saveTo, !allSessions.withLock({ $0.isEmpty }) else {
                return
            }

            let mp3Files = allSessions.withLock {
                $0.map { session in
                    session.cachePath()
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
        taskBox.withLock { $0 = task }

        try await task.value
    }

    public func waitForPlayerToStop() async throws {
        try await finished.wait()
    }

    public func stopPlaying() throws {
        infoLog("stop Playing")
        guard let task = taskBox.withLock({ $0 }) else {
            return
        }
        if !task.isCancelled {
            task.cancel()
        }
        allSessions.withLock { sessions in
            for session in sessions {
                infoLog("stop session")
                if session.isPlaying {
                    try? session.stop()
                }
            }
        }
    }

    public func stopPlayingAndSynthesizing() throws {
        infoLog("stopPlayingAndSynthesizing")
        try stopPlaying()
    }
}
