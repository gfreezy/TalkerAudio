//
//  AudioPlayer.swift
//  iOS
//
//  Created by feichao on 2023/3/11.
//

import AVKit
import Foundation
import SwiftUI
import TalkerCommon

import Foundation

public struct MessageError: Error {
    let description: String
    let file: String
    let line: Int
    let column: Int

    public init(_ localizedDescription: String, file: String = #file, line: Int = #line, column: Int = #column) {
        self.description = localizedDescription
        self.file = file
        self.line = line
        self.column = column
    }
}

extension MessageError: LocalizedError {
    public var errorDescription: String? { return "\(file):\(line) \(description)" }
}

public class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    public private(set) var currentPlayingURL: URL?

    var myAudioPlayer: AVAudioPlayer?
    var fileURL: URL?
    public var onPlayerStopped: (() -> Void)?

    public init(onPlayerStopped: (() -> Void)? = nil) {
        self.onPlayerStopped = onPlayerStopped
    }

    public func play(url: URL) throws {
        stop()
        let exists = try url.checkResourceIsReachable()
        if !exists {
            throw MessageError("Url not exists")
        }
        myAudioPlayer = try AVAudioPlayer(contentsOf: url)
        myAudioPlayer?.delegate = self
        myAudioPlayer?.play()
        currentPlayingURL = url
    }

    public func stop() {
        myAudioPlayer?.stop()
        currentPlayingURL = nil
    }

    public func playOrStop(url: URL) throws {
        stop()
        if currentPlayingURL != url {
            try play(url: url)
        }
    }

    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        infoLog("Did finish Playing successfully", flag)
        currentPlayingURL = nil
        onPlayerStopped?()
    }
}
