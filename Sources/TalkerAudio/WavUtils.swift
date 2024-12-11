//
//  WavUtils.swift
//  iOS
//
//  Created by feichao on 2023/11/24.
//

import Foundation

func getWavHeader(sampleRate: Int, bitsPerSample: Int, numberOfChannels: Int, audioDataLength: Int) -> Data {
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
}
