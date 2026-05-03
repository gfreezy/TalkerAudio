//
//  StreamSynthesizerProtocol.swift
//  iOS
//
//  Created by feichao on 2023/4/27.
//

import Foundation

/// A long-lived synthesizer bound to a specific voice configuration. Owns
/// whatever can be reused across utterances (e.g. an open SDK connection).
///
/// Single-borrow: `makeSession` suspends if a previous session still holds the
/// borrow. Once `session.waitForLoadFinished` resolves, the engine is free
/// again and the session may continue independently (`play`, `cachePath`).
public protocol StreamSynthesizerEngine: Sendable {
    /// Borrow the engine and start synthesizing `text`. Suspends if the engine
    /// is currently borrowed by another session.
    func makeSession(text: String) async throws -> any StreamSynthesizerSession & Sendable

    /// Release any long-lived resources (open connections, SDK handles).
    /// Engines outlive a single `streamSynthesize` call; the caller decides
    /// when to shut down.
    func shutdown()
}

/// One synthesis utterance. Holds the per-text audio cache file and signals
/// load / play completion.
public protocol StreamSynthesizerSession {
    func play() async throws

    func stop() throws

    func waitForPlayStopped() async throws

    func waitForLoadFinished() async throws

    var isPlaying: Bool { get }

    func cachePath() -> URL
}
