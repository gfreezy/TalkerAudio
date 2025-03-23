//
//  WavUtils.swift
//  iOS
//
//  Created by feichao on 2023/11/24.
//

import AVFoundation
import Foundation

func getWavHeader(sampleRate: Int, bitsPerSample: Int, numberOfChannels: Int, audioDataLength: Int)
    -> Data
{
    let fileSize = 44 + audioDataLength
    let byteRate = sampleRate * numberOfChannels * (bitsPerSample / 8)
    let blockAlign = numberOfChannels * (bitsPerSample / 8)

    var data = Data()

    // ChunkID
    data.append(contentsOf: "RIFF".utf8)

    // ChunkSize
    data.append(Data(fromInt: fileSize))

    // Format
    data.append(contentsOf: "WAVE".utf8)

    // Subchunk1ID
    data.append(contentsOf: "fmt ".utf8)

    // Subchunk1Size
    data.append(Data(fromInt: 16))

    // AudioFormat
    data.append(Data(fromShort: 1))

    // NumChannels
    data.append(Data(fromShort: Int16(numberOfChannels)))

    // SampleRate
    data.append(Data(fromInt: sampleRate))

    // ByteRate
    data.append(Data(fromInt: byteRate))

    // BlockAlign
    data.append(Data(fromShort: Int16(blockAlign)))

    // BitsPerSample
    data.append(Data(fromShort: Int16(bitsPerSample)))

    // Subchunk2ID
    data.append(contentsOf: "data".utf8)

    // Subchunk2Size
    data.append(Data(fromInt: audioDataLength))

    return data
}

extension Data {
    init(fromInt value: Int) {
        var value = value
        self.init(bytes: &value, count: MemoryLayout<Int>.size)
    }

    init(fromShort value: Int16) {
        var value = value
        self.init(bytes: &value, count: MemoryLayout<Int16>.size)
    }

    static func fromAudioBuffer(_ audioBuffer: AVAudioBuffer) -> Data {
        let audioBufferList = UnsafeMutableAudioBufferListPointer(
            audioBuffer.mutableAudioBufferList)
        let size: UInt32 = audioBufferList.reduce(0) { partialResult, buf in
            buf.mDataByteSize + partialResult
        }
        if size == 0 {
            return Data()
        }
        var data = Data(capacity: Int(size))
        for i in 0..<audioBufferList.count {
            let buffer = audioBufferList[i]
            data.append(
                buffer.mData!.assumingMemoryBound(to: UInt8.self), count: Int(buffer.mDataByteSize))
        }
        return data
    }
}

extension AVAudioPCMBuffer {
    func toData() -> Data {
        return Data.fromAudioBuffer(self)
    }

    func totalBytes() -> Int {
        let audioBufferList = UnsafeMutableAudioBufferListPointer(mutableAudioBufferList)
        let size: UInt32 = audioBufferList.reduce(0) { partialResult, buf in
            buf.mDataByteSize + partialResult
        }
        return Int(size)
    }
}
