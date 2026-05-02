//
//  BaseStreamSynthesizerPlayer.swift
//  iOS
//
//  Created by feichao on 2023/4/27.
//

import Foundation

public protocol StreamSynthesizerProtocol {
    /// Set the text to synthesize. Must be called before `load()`.
    /// Allows callers to construct a synthesizer (and open its connection) before
    /// the text is known, then inject the text once it arrives.
    func setText(_ text: String)

    func play() async throws

    func stop() throws

    func waitForPlayStopped() async throws

    func load() throws

    func waitForLoadFinished() async throws

    var isPlaying: Bool { get }

    func cachePath() -> URL
}
