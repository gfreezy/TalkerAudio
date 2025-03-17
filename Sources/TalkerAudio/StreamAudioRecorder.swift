//
//  StreamAudioRecorder.swift
//  TalkerAudio
//
//  Created by feichao on 2024/12/12.
//

import AVFoundation
import TalkerCommon

public enum RecordFormat {
    case aac(bitRate: Int)
    case pcm
}

public final class StreamAudioRecorder: Sendable {

    public var audioInputMoreDataBlock: ((Data) -> Void)? {
        set {
            audioInputMoreDataBlockValue.value = newValue
        }
        get {
            audioInputMoreDataBlockValue.value
        }
    }

    private let audioInputMoreDataBlockValue: Lock<((Data) -> Void)?> = Lock(nil)
    private let isRunningValue: Lock<Bool> = Lock(false)
    private nonisolated(unsafe) var audioQueue: AudioQueueRef?
    private nonisolated(unsafe) var audioBuffers: [AudioQueueBufferRef?] = Array(
        repeating: nil, count: 3)
    private let aacEncoder: Lock<AacAdtsEncoder?> = Lock(nil)
    private let queue = DispatchQueue(label: "StreamAudioRecorder")

    public var isRunning: Bool {
        isRunningValue.value
    }

    public init() {
    }

    private func handleInputBuffer(
        inAQ: AudioQueueRef,
        inBuffer: AudioQueueBufferRef,
        inStartTime: UnsafePointer<AudioTimeStamp>,
        inNumPackets: UInt32,
        inPacketDesc: UnsafePointer<AudioStreamPacketDescription>?
    ) {
        defer {
            if isRunning {
                let result = AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, nil)
                if result != noErr {
                    print("Error enqueuing buffer: \(result)")
                }
            }
        }

        guard isRunning else { return }

        guard
            let pcmBuffer = convertToPCMBuffer(
                inBuffer: inBuffer,
                inStartTime: inStartTime,
                inNumPackets: inNumPackets,
                inPacketDesc: inPacketDesc
            )
        else {
            return
        }
        guard let _block = audioInputMoreDataBlockValue.value else {
            return
        }

        nonisolated(unsafe) let uncheckedPcmBuffer = pcmBuffer
        nonisolated(unsafe) let block = _block

        queue.async {
            do {
                let encoder = self.aacEncoder.value
                let outAudioBuffer: Data

                if let encoder {
//                    infoLog("Encode audio")
                    // 编码PCM缓冲区
                    let buffer = try encoder.encode(
                        inputBuffer: uncheckedPcmBuffer
                    )

                    outAudioBuffer = buffer
                } else {
//                    infoLog("No encoder, use PCM")
                    outAudioBuffer = Data.fromAudioBuffer(uncheckedPcmBuffer)
                }
                
                if !outAudioBuffer.isEmpty {
                    block(outAudioBuffer)
                }
            } catch {
                errorLog("Failed to encode audio: \(error)")
            }
        }
    }

    private func convertToPCMBuffer(
        inBuffer: AudioQueueBufferRef,
        inStartTime: UnsafePointer<AudioTimeStamp>,
        inNumPackets: UInt32,
        inPacketDesc: UnsafePointer<AudioStreamPacketDescription>?
    ) -> AVAudioPCMBuffer? {
        // 创建音频格式
        let format = getRecordingFormat()

        guard
            let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: inNumPackets)
        else {
            print("Failed to create PCM buffer")
            return nil
        }

        // 使用 AudioStreamPacketDescription 来解析数据
        if let packetDescriptions = inPacketDesc {
            var currentOffset: Int = 0
            let audioData = inBuffer.pointee.mAudioData.assumingMemoryBound(to: Int16.self)
            let ptr = UnsafeMutableBufferPointer(
                start: pcmBuffer.int16ChannelData?[0],
                count: Int(inNumPackets))

            // 遍历每个数据包
            for i in 0..<Int(inNumPackets) {
                let packetDesc = packetDescriptions.advanced(by: i).pointee
                let packetOffset = Int(packetDesc.mStartOffset)
                let packetSize = Int(packetDesc.mDataByteSize)

                // 确保不会越界
                guard currentOffset + packetSize <= Int(inBuffer.pointee.mAudioDataByteSize)
                else {
                    errorLog("Packet size exceeds buffer bounds")
                    break
                }

                // 复制这个包的数据
                let source = audioData.advanced(by: packetOffset / 2)  // 除以2因为Int16是2字节
                ptr.baseAddress?.advanced(by: currentOffset / 2)
                    .update(from: source, count: packetSize / 2)

                currentOffset += packetSize
            }
        } else {
            // 如果没有包描述（PCM数据），直接复制整个缓冲区
            let audioData = inBuffer.pointee.mAudioData.assumingMemoryBound(to: Int16.self)
            let ptr = UnsafeMutableBufferPointer(
                start: pcmBuffer.int16ChannelData?[0],
                count: Int(inNumPackets))
            ptr.baseAddress?.update(from: audioData, count: Int(inNumPackets))
        }

        pcmBuffer.frameLength = inNumPackets
        return pcmBuffer
    }

    private func setup(format: RecordFormat) throws {
        var dataFormat = getStreamDescription()
        guard let aacInputFormat = AVAudioFormat(streamDescription: &dataFormat) else {
            throw MessageError("Failed to create AVAudioFormat")
        }
        if case .aac(let bitRate) = format {
            infoLog("Create aac encoder")
            let aacEncoder = AacAdtsEncoder()
            try aacEncoder.setup(inputFormat: aacInputFormat, bitRate: bitRate)
            self.aacEncoder.value = aacEncoder
        }

        let callback: AudioQueueInputCallback = {
            userData, inAQ, inBuffer, inStartTime, inNumPackets, inPacketDesc in
            let recorder = Unmanaged<StreamAudioRecorder>.fromOpaque(userData!)
                .takeUnretainedValue()
            recorder.handleInputBuffer(
                inAQ: inAQ,
                inBuffer: inBuffer,
                inStartTime: inStartTime,
                inNumPackets: inNumPackets,
                inPacketDesc: inPacketDesc
            )
        }

        let userData = Unmanaged.passUnretained(self).toOpaque()
        let result = AudioQueueNewInput(
            &dataFormat,
            callback,
            userData,
            nil,
            CFRunLoopMode.commonModes.rawValue,
            0,
            &audioQueue
        )
        guard result == noErr else {
            throw MessageError("AudioQueueNewInput error: \(result)")
        }

        var bufferByteSize: UInt32 = 0
        try deriveBufferSize(
            audioQueue: audioQueue!, dataFormat: &dataFormat, seconds: 0.04,
            bufferByteSize: &bufferByteSize)

        for i in 0..<audioBuffers.count {
            let result = AudioQueueAllocateBuffer(audioQueue!, bufferByteSize, &audioBuffers[i])
            guard result == noErr else {
                throw MessageError("AudioQueueAllocateBuffer error: \(result)")
            }

            let enqueueResult = AudioQueueEnqueueBuffer(audioQueue!, audioBuffers[i]!, 0, nil)
            guard enqueueResult == noErr else {
                throw MessageError("AudioQueueEnqueueBuffer error: \(enqueueResult)")
            }
        }
        isRunningValue.value = false
    }

    public func start(format: RecordFormat = .pcm) throws {
        guard !isRunning else {
            throw MessageError("Audio recorder is already running")
        }

        try setup(format: format)
        isRunningValue.value = true

        let result = AudioQueueStart(audioQueue!, nil)
        guard result == noErr else {
            throw MessageError("AudioQueueStart error: \(result)")
        }
    }

    public func stop() throws {
        guard isRunning else { return }
        isRunningValue.value = false

        let stopResult = AudioQueueStop(audioQueue!, false)
        guard stopResult == noErr else {
            throw MessageError("AudioQueueStop error: \(stopResult)")
        }

        let disposeResult = AudioQueueDispose(audioQueue!, true)
        guard disposeResult == noErr else {
            throw MessageError("AudioQueueDispose error: \(disposeResult)")
        }
    }
}

private func getStreamDescription() -> AudioStreamBasicDescription {
    return AudioStreamBasicDescription(
        mSampleRate: 16000,
        mFormatID: kAudioFormatLinearPCM,
        mFormatFlags: kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked
            | kAudioFormatFlagsNativeEndian,
        mBytesPerPacket: 2,
        mFramesPerPacket: 1,
        mBytesPerFrame: 2,
        mChannelsPerFrame: 1,
        mBitsPerChannel: 16,
        mReserved: 0
    )
}

private func getRecordingFormat() -> AVAudioFormat {
    var dataFormat = getStreamDescription()
    return AVAudioFormat(streamDescription: &dataFormat)!
}

private func deriveBufferSize(
    audioQueue: AudioQueueRef,
    dataFormat: inout AudioStreamBasicDescription,
    seconds: Float64,
    bufferByteSize: inout UInt32
) throws {
    let maxBufferSize: UInt32 = 0x50000
    var maxPacketSize = dataFormat.mBytesPerPacket

    if maxPacketSize == 0 {
        let maxVBRPacketSize: UInt32 = 0
        var size = UInt32(MemoryLayout.size(ofValue: maxVBRPacketSize))
        let result = AudioQueueGetProperty(
            audioQueue,
            kAudioQueueProperty_MaximumOutputPacketSize,
            &maxPacketSize,
            &size
        )
        guard result == noErr else {
            throw MessageError("AudioQueueGetProperty error: \(result)")
        }
    }

    let numBytesForTime = Float64(dataFormat.mSampleRate) * Float64(maxPacketSize) * seconds
    bufferByteSize =
        UInt32(numBytesForTime) < maxBufferSize ? UInt32(numBytesForTime) : maxBufferSize
}
