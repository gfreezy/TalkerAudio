//
//  AudioEncoder.swift
//  TalkerAudio
//
//  Created by feichao on 2025/3/23.
//
import AVFoundation
import Foundation

public protocol AudioEncoderProtocol {
    func encode(inputBuffer pcmBuffer: AVAudioPCMBuffer) throws
        -> Data
    func finish() throws -> Data
}
