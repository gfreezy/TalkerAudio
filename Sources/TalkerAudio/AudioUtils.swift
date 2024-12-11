//
//  AudioUtils.swift
//  iOS
//
//  Created by feichao on 2023/4/13.
//

import AVFoundation
import Foundation
import TalkerCommon

public func pcmBytesToAVAudioPCMBuffer(pcmData: Data, sampleRate: Double, channels: UInt32 = 1)
    -> AVAudioPCMBuffer?
{
    // Create an AVAudioFormat object with the desired PCM format
    guard
        let format = AVAudioFormat(
            commonFormat: .pcmFormatInt16, sampleRate: sampleRate, channels: channels,
            interleaved: true)
    else {
        return nil
    }

    // Calculate the number of frames in the PCM data
    let frameCount = UInt32(pcmData.count) / format.streamDescription.pointee.mBytesPerFrame

    // Create an AVAudioPCMBuffer with the given format and frame count
    guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
        errorLog("Error creating AVAudioPCMBuffer.")
        return nil
    }

    // Fill the PCM buffer with the PCM data
    pcmData.withUnsafeBytes { (bufferPointer: UnsafeRawBufferPointer) -> Void in
        guard let sourceAddress = bufferPointer.baseAddress else { return }
        pcmBuffer.frameLength = frameCount
        pcmBuffer.int16ChannelData?.pointee.update(
            from: sourceAddress.assumingMemoryBound(to: Int16.self),
            count: Int(frameCount * channels))
    }

    return pcmBuffer
}

public func talkerAudioFormat() -> AVAudioFormat {
    AVAudioFormat(
        commonFormat: .pcmFormatInt16, sampleRate: 16000, channels: 1, interleaved: true
    )!
}

public func listOfPCMBytesToSingleAVAudioPCMBuffer(
    pcmDataList: [Data], format: AVAudioFormat = talkerAudioFormat()
) throws -> AVAudioPCMBuffer {
    // Calculate the total number of frames in all PCM data arrays
    let totalFrameCount = try pcmDataList.reduce(UInt32(0)) {
        let nFrames = Double($1.count) / Double(format.streamDescription.pointee.mBytesPerFrame)
        if nFrames.rounded() != nFrames {
            throw MessageError("Invalid pcm data")
        }
        return $0 + UInt32(nFrames)
    }

    guard totalFrameCount > 0 else {
        errorLog("pcmdatalist is 0")
        throw MessageError("Pcm data has 0 frames")
    }

    // Create an AVAudioPCMBuffer with the given format and total frame count
    guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: totalFrameCount) else {
        errorLog("Error creating AVAudioPCMBuffer.")
        throw MessageError("Create AVAudioPCMBuffer error")
    }

    // Fill the PCM buffer with the PCM data arrays
    var currentFramePosition = 0
    for pcmData in pcmDataList {
        let frameCount = UInt32(pcmData.count) / format.streamDescription.pointee.mBytesPerFrame

        pcmData.withUnsafeBytes { (bufferPointer: UnsafeRawBufferPointer) -> Void in
            guard let sourceAddress = bufferPointer.baseAddress else { return }
            pcmBuffer.int16ChannelData?.pointee.advanced(by: currentFramePosition).update(
                from: sourceAddress.assumingMemoryBound(to: Int16.self),
                count: Int(frameCount * format.channelCount))
        }

        currentFramePosition += Int(frameCount * format.channelCount)
    }
    pcmBuffer.frameLength = totalFrameCount

    return pcmBuffer
}

public enum NormalizeVolumeError: String, LocalizedError {
    case frameLengthZero
    case peakAmplitudeZero

    public var errorDescription: String? {
        self.rawValue
    }
}

public func normalizeVolume(audioBuffer: AVAudioPCMBuffer) throws {
    // Find the peak amplitude
    let frameLength = audioBuffer.frameLength

    guard frameLength > 0, let channelData = audioBuffer.int16ChannelData else {
        throw NormalizeVolumeError.frameLengthZero
    }
    // Find the peak amplitude
    var peakAmplitude: Int16 = 0
    for frame in 0..<frameLength {
        let raw = channelData.pointee[Int(frame)]
        let amplitude = abs(raw == Int16.min ? raw + 1 : raw)
        peakAmplitude = max(amplitude, peakAmplitude)
    }
    if peakAmplitude == 0 {
        throw NormalizeVolumeError.peakAmplitudeZero
    }
    // Calculate the normalization factor
    let normalizationFactor = Float(Int16.max) / Float(peakAmplitude)
    infoLog("normalizationFactor", normalizationFactor)

    // Apply the normalization factor to the audio buffer
    for frame in 0..<frameLength {
        let inputValue = Float(channelData.pointee[Int(frame)])
        channelData.pointee[Int(frame)] = Int16(inputValue * normalizationFactor)
    }
}

public func writeAVAudioPCMBufferToWavFile(buffer: AVAudioPCMBuffer, fileURL: URL) {
    // Create an AVAudioFile with the desired WAV format
    guard
        let wavFileFormat = AVAudioFormat(
            commonFormat: .pcmFormatInt16, sampleRate: buffer.format.sampleRate,
            channels: buffer.format.channelCount, interleaved: true)
    else {
        errorLog("Error invalid format")
        return
    }

    do {
        let audioFile = try AVAudioFile(
            forWriting: fileURL, settings: wavFileFormat.settings,
            commonFormat: wavFileFormat.commonFormat, interleaved: wavFileFormat.isInterleaved)

        // Write the buffer to the audio file
        try audioFile.write(from: buffer)

        infoLog("WAV file successfully written to: \(fileURL.absoluteString)")
    } catch {
        errorLog("Error writing WAV file: \(error.localizedDescription)")
    }
}

public func readAVAudioPCMBufferFromWavFile(fileURL: URL) throws -> AVAudioPCMBuffer{
    let talkerAudioFormat = talkerAudioFormat()
    let audioFile = try AVAudioFile(forReading: fileURL, commonFormat: talkerAudioFormat.commonFormat, interleaved: talkerAudioFormat.isInterleaved)

    let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))!
    try audioFile.read(into: buffer)
    return buffer
}



public func getLangFromVoiceId(_ localeIdentifier: String) -> String? {
    // Split the locale identifier string using the "-" delimiter
    let localeIdentifierComponents = localeIdentifier.split(separator: "-")

    // Check if the split resulted in at least two components
    guard localeIdentifierComponents.count >= 2 else {
        // Handle error, such as incorrect locale format
        return nil
    }

    // Extract the first two components and join them with a "-"
    let languageAndRegion = "\(localeIdentifierComponents[0])-\(localeIdentifierComponents[1])"
    return languageAndRegion
}

public func combineBuffers(buffers: [AVAudioPCMBuffer]) -> AVAudioPCMBuffer? {
    // Calculate the total frame capacity of the combined buffer
    var totalFrames: UInt32 = 0
    for buffer in buffers {
        totalFrames += buffer.frameLength
    }
    
    // Create a new AVAudioPCMBuffer with the combined frame capacity
    guard let format = buffers.first?.format,
          let combinedBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(totalFrames)) else {
        return nil
    }
    
    // Copy the contents of the individual buffers into the combined buffer
    var frameOffset = 0
    for buffer in buffers {
        let framesToCopy = buffer.frameLength
        for channel in 0..<Int(format.channelCount) {
            if let src = buffer.floatChannelData?[channel],
               let dst = combinedBuffer.floatChannelData?[channel] {
                memcpy(dst.advanced(by: Int(frameOffset) * MemoryLayout<Float>.size),
                       src,
                       Int(framesToCopy) * MemoryLayout<Float>.size)
            }
        }
        frameOffset += Int(framesToCopy)
    }
    
    // Set the frame length of the combined buffer
    combinedBuffer.frameLength = AVAudioFrameCount(totalFrames)
    
    return combinedBuffer
}
