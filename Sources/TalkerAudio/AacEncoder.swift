import AVFoundation
import Foundation
import TalkerCommon

public final class AacAdtsEncoder: AudioEncoderProtocol {
    private var converter: AVAudioConverter?
    private var outputFormat: AVAudioFormat = AVAudioFormat()

    public init(inputFormat: AVAudioFormat, bitRate: Int) throws {
        var streamDescription = AudioStreamBasicDescription(
            mSampleRate: inputFormat.sampleRate, mFormatID: kAudioFormatMPEG4AAC,
            mFormatFlags: kAudioFormatFlagsAreAllClear, mBytesPerPacket: 0, mFramesPerPacket: 1024,
            mBytesPerFrame: 0,
            mChannelsPerFrame: 1, mBitsPerChannel: 0, mReserved: 0)
        guard let outputFormat = AVAudioFormat(streamDescription: &streamDescription) else {
            throw AacEncoderError.invalidInputFormat
        }
        self.outputFormat = outputFormat
        guard let converter = AVAudioConverter(from: inputFormat, to: outputFormat) else {
            throw AacEncoderError.converterCreationFailed
        }
        converter.bitRate = bitRate
        self.converter = converter
        //        debugLog("AacAdtsEncoder setup")
    }

    /// Encode the input buffer to AAC ADTS format. Return emtpy Data if no enough data.
    public func encode(inputBuffer pcmBuffer: AVAudioPCMBuffer) throws
        -> Data
    {
        guard let converter else {
            throw AacEncoderError.converterNotSetup
        }

        let outputBuffer = AVAudioCompressedBuffer(
            format: outputFormat, packetCapacity: 8, maximumPacketSize: 1024)
        // Convert PCM to AAC
        var error: NSError?
        //        infoLog("encode frameLength: \(pcmBuffer.frameLength)")
        var inputPcmBuffer: AVAudioPCMBuffer? = pcmBuffer
        let inputBlock: AVAudioConverterInputBlock = { inNumPackets, outStatus in
            if let buf = inputPcmBuffer {
                inputPcmBuffer = nil
                outStatus.pointee = .haveData
                //                debugLog("provide buf: \(buf.frameLength)")
                return buf
            } else {
                outStatus.pointee = .noDataNow
                //                debugLog("no data now")
                return nil
            }
        }

        let status = converter.convert(to: outputBuffer, error: &error, withInputFrom: inputBlock)
        if status == .error, let error = error {
            throw TalkerError("convert error: \(error)")
        }
        //        debugLog("status: \(status)")

        return try convert(compressedBuffer: outputBuffer)
    }

    private func convert(compressedBuffer: AVAudioCompressedBuffer) throws -> Data {
        let adtsHeaderLength = 7
        let outputBufferSize = Int(compressedBuffer.byteLength)
        let packetCount = Int(compressedBuffer.packetCount)
        let dataCapacity = outputBufferSize + adtsHeaderLength * packetCount

        if packetCount == 0 {
            return Data()
        }

        var data = Data(capacity: dataCapacity)

        //        debugLog("packetCount: \(packetCount), outputBufferSize: \(outputBufferSize)")
        guard let packetDescriptions = compressedBuffer.packetDescriptions else {
            throw TalkerError("packetDescriptions is nil")
        }
        for i in 0..<packetCount {
            let desc = packetDescriptions[i]
            compressedBuffer.data.withMemoryRebound(to: UInt8.self, capacity: outputBufferSize) {
                pointer in
                let start = Int(desc.mStartOffset)
                let length = Int(desc.mDataByteSize)
                let frameLength = length + adtsHeaderLength
                let header = createADTSHeader(
                    frameLength: frameLength,
                    sampleRate: outputFormat.sampleRate,
                    channels: outputFormat.channelCount
                )
                data.append(contentsOf: header)
                data.append(pointer.advanced(by: start), count: length)
            }
        }

        return data
    }

    // 创建 ADTS 头
    private func createADTSHeader(frameLength: Int, sampleRate: Float64, channels: UInt32)
        -> [UInt8]
    {
        var header = [UInt8](repeating: 0, count: 7)

        // Sync word (0xFFF)
        header[0] = 0xFF
        header[1] = 0xF1

        // 获取采样率索引
        let sampleRateIndex = getSampleRateIndex(sampleRate)

        // Profile, Sampling Frequency Index, Channel Configuration
        header[2] = (1 << 6) | (UInt8(sampleRateIndex) << 2) | (UInt8(channels >> 2))
        header[3] = (UInt8(channels & 3) << 6) | UInt8((frameLength >> 11) & 0x03)

        // Frame Length
        header[4] = UInt8((frameLength >> 3) & 0xFF)
        header[5] = UInt8((frameLength & 0x07) << 5) | 0x1F
        header[6] = 0xFC

        return header
    }

    // 获取采样率索引
    private func getSampleRateIndex(_ sampleRate: Float64) -> Int {
        let sampleRates = [
            96000, 88200, 64000, 48000, 44100, 32000, 24000, 22050, 16000, 12000, 11025, 8000,
        ]
        return sampleRates.firstIndex(of: Int(sampleRate)) ?? 4  // 默认使用 44100Hz 的索引
    }

    public func finish() throws -> Data {
        guard let converter else {
            throw AacEncoderError.converterNotSetup
        }

        let outputBuffer = AVAudioCompressedBuffer(
            format: outputFormat, packetCapacity: 8, maximumPacketSize: 1024)
        var error: NSError?
        let inputBlock: AVAudioConverterInputBlock = { inNumPackets, outStatus in
            outStatus.pointee = .endOfStream
            return nil
        }

        let status = converter.convert(to: outputBuffer, error: &error, withInputFrom: inputBlock)
        if status == .error, let error = error {
            throw TalkerError("convert error: \(error)")
        }
        return try convert(compressedBuffer: outputBuffer)
    }
}

public enum AacEncoderError: LocalizedError {
    case invalidInputFormat
    case invalidOutputFormat
    case converterCreationFailed
    case outputBufferCreationFailed
    case conversionFailed(Error)
    case invalidChannelData
    case converterNotSetup

    public var errorDescription: String? {
        switch self {
        case .invalidInputFormat:
            return "Invalid input format"
        case .invalidOutputFormat:
            return "Invalid output format"
        case .converterCreationFailed:
            return "Failed to create audio converter"
        case .outputBufferCreationFailed:
            return "Failed to create output buffer"
        case .conversionFailed(let error):
            return "Conversion failed: \(error)"
        case .invalidChannelData:
            return "Invalid channel data"
        case .converterNotSetup:
            return "Converter not setup"
        }
    }
}
