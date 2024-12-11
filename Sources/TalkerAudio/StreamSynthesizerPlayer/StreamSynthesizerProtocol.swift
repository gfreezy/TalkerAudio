//
//  BaseStreamSynthesizerPlayer.swift
//  iOS
//
//  Created by feichao on 2023/4/27.
//

import Foundation

public protocol StreamSynthesizerProtocol {
    func play() async throws

    func stop() throws

    func waitForPlayStopped() async throws

    func load() throws

    func waitForLoadFinished() async throws

    var isPlaying: Bool { get }

    func cachePath() -> URL
}
