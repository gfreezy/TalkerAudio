//
//  StreamAudioBuffer.swift
//  iOS
//
//  Created by feichao on 2023/3/20.
//

import Foundation

struct StreamIndexOffset {
    var index: Int
    var offset: Int

    mutating func reset() {
        index = 0
        offset = 0
    }
}

public class StreamAudioBuffer: @unchecked Sendable {
    private var buffers: [Data] = []
    private let lock = NSRecursiveLock()
    private(set) var finished = false

    public init() {
    }
    
    public var isEmpty: Bool {
        totalBytes == 0
    }

    public var count: Int {
        lock.lock()
        defer {
            lock.unlock()
        }
        return buffers.count
    }

    public var totalBytes: Int {
        lock.lock()
        defer {
            lock.unlock()
        }
        return buffers.map(\.count).reduce(0) { partialResult, val in
            partialResult + val
        }
    }

    var datasInfo: [Int] {
        datas.map { d in
            d.count
        }
    }

    public var hasData: Bool {
        lock.lock()
        defer {
            lock.unlock()
        }
        return !buffers.isEmpty
    }

    public var datas: [Data] {
        lock.lock()
        defer {
            lock.unlock()
        }
        return buffers
    }

    public func appendBytes(bytes: Data) {
        lock.lock()
        defer {
            lock.unlock()
        }
        if bytes.isEmpty {
            return
        }
        buffers.append(bytes)
    }

    public func appendBytesToBuffer(_ index: Int, bytes: Data) {
        lock.lock()
        defer {
            lock.unlock()
        }
        if buffers.count == index {
            buffers.append(bytes)
            return
        } else if buffers.count > index {
            buffers[index].append(bytes)
        } else {
            fatalError("invalid index: \(index), buffer count: \(buffers.count)")
        }
    }

    func recycleConsumedData(_ index: StreamIndexOffset) {
        lock.lock()
        defer {
            lock.unlock()
        }
        for i in 0..<index.index {
            buffers[i] = Data()
        }
    }

    public func reset() {
        lock.lock()
        defer {
            lock.unlock()
        }
        finished = false
        buffers = []
    }

    // return nil when finished
    func subrangeBytes(_ streamIndexOffset: StreamIndexOffset) -> Data? {
        lock.lock()
        defer {
            lock.unlock()
        }
        if finished && isEmpty {
            return nil
        }
        
        if buffers.isEmpty {
            return Data()
        }
        if streamIndexOffset.index >= buffers.count {
            fatalError("invalid index: \(streamIndexOffset.index), buffer count: \(buffers.count)")
        }
        let buf = buffers[streamIndexOffset.index]
        let data = buf.subdata(in: streamIndexOffset.offset..<buf.count)
        if data.count == 0 && streamIndexOffset.index + 1 == buffers.count && finished {
            return nil
        } else {
            return data
        }
    }

    // return nil when finished
    func subrangeBytes(_ streamIndexOffset: StreamIndexOffset, size: Int) -> Data? {
        lock.lock()
        defer {
            lock.unlock()
        }
        
        if buffers.isEmpty {
            return Data()
        }
        
        if streamIndexOffset.index >= buffers.count {
            fatalError("invalid index: \(streamIndexOffset.index), buffer count: \(buffers.count)")
        }
        var leftSize = size
        var index = streamIndexOffset
        var data = Data()
        while leftSize > 0 && index.index < buffers.count {
            let buf = buffers[index.index]
            let endOffset = min(buf.count, index.offset + leftSize)
            let subdata = buf.subdata(in: index.offset..<endOffset)
            leftSize -= subdata.count
            if subdata.count > 0 {
                data.append(subdata)
            } else if subdata.count == 0 && index.index == buffers.count - 1 {
                break
            }
            advanceStreamIndexOffset(&index, size: subdata.count)
        }

        if finished && data.count == 0 {
            return nil
        } else {
            return data
        }
    }

    func advanceStreamIndexOffset(_ streamIndexOffset: inout StreamIndexOffset, size: Int) {
        lock.lock()
        defer {
            lock.unlock()
        }

        // if we have another data after current index, current buf is finished.

//        infoLog("buffer count:", buffers.count)

        var leftSize = size
        while streamIndexOffset.index < buffers.count {
            let currentBuf = buffers[streamIndexOffset.index]
            let subsize = min(currentBuf.count - streamIndexOffset.offset, leftSize)
            leftSize -= subsize
            let offset = streamIndexOffset.offset
            streamIndexOffset.index += (offset + subsize) / currentBuf.count
            streamIndexOffset.offset = (offset + subsize) % currentBuf.count

            if streamIndexOffset.index == buffers.count {
                streamIndexOffset.index -= 1
                streamIndexOffset.offset = currentBuf.count
                break
            }

            if leftSize == 0 {
                break
            }
        }

        if leftSize > 0 {
            fatalError("No enough data")
        }
    }

    public func finishStream() {
        lock.lock()
        defer {
            lock.unlock()
        }
        self.finished = true
    }
}
