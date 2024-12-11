//
//  StreamAudioRecorder.swift
//  TalkerAudio
//
//  Created by feichao on 2024/12/12.
//

import AVFoundation

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
    private nonisolated(unsafe) var audioBuffers: [AudioQueueBufferRef?] = Array(repeating: nil, count: 3)

    public var isRunning: Bool {
        isRunningValue.value
    }
    
    private func handleInputBuffer(
        inAQ: AudioQueueRef,
        inBuffer: AudioQueueBufferRef,
        inStartTime: UnsafePointer<AudioTimeStamp>,
        inNumPackets: UInt32,
        inPacketDesc: UnsafePointer<AudioStreamPacketDescription>?
    ) {
        guard isRunning else { return }
        
        if let block = audioInputMoreDataBlock {
            let data = Data(bytes: inBuffer.pointee.mAudioData, count: Int(inBuffer.pointee.mAudioDataByteSize))
            block(data)
        }
        
        let result = AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, nil)
        if result != noErr {
            print("Error enqueuing buffer: \(result)")
        }
    }

    private func setup() throws {
        var dataFormat = getStreamDescription()
        let callback: AudioQueueInputCallback = { userData, inAQ, inBuffer, inStartTime, inNumPackets, inPacketDesc in
            let recorder = Unmanaged<StreamAudioRecorder>.fromOpaque(userData!).takeUnretainedValue()
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
        try deriveBufferSize(audioQueue: audioQueue!, dataFormat: &dataFormat, seconds: 0.04, bufferByteSize: &bufferByteSize)

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
    }

    public func start() throws {
        guard !isRunning else {
            throw MessageError("Audio recorder is already running")
        }

        try setup()
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

fileprivate func getStreamDescription() -> AudioStreamBasicDescription {
    return AudioStreamBasicDescription(
        mSampleRate: 16000,
        mFormatID: kAudioFormatLinearPCM,
        mFormatFlags: kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked | kAudioFormatFlagsNativeEndian,
        mBytesPerPacket: 2,
        mFramesPerPacket: 1,
        mBytesPerFrame: 2,
        mChannelsPerFrame: 1,
        mBitsPerChannel: 16,
        mReserved: 0
    )
}


fileprivate func deriveBufferSize(
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
    bufferByteSize = UInt32(numBytesForTime) < maxBufferSize ? UInt32(numBytesForTime) : maxBufferSize
}
