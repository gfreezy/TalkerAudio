import AsyncAlgorithms
import Foundation
import Testing

@testable import TalkerAudio

// Models a legacy producer that advertises Never but throws on cancellation.
// for-await invokes the typed bridge, which aborts instead of entering catch.
private struct LegacyCancellationIterator: AsyncIteratorProtocol {
    typealias Element = Int
    typealias Failure = Never
    var yielded = false

    mutating func next() async throws -> Int? {
        if !yielded {
            yielded = true
            return 42
        }
        throw CancellationError()
    }
}

struct LegacyStreamIteratorTests {
    @Test func bufferedChannelDrainsNormally() async throws {
        let channel = AsyncChannel<Int>()
        let producer = Task {
            await channel.send(1)
            await channel.send(2)
            channel.finish()
        }
        var iterator = channel.buffer(policy: .bounded(5)).makeAsyncIterator()
        var received: [Int] = []
        while let value = try await nextLegacyStreamElement(&iterator) {
            received.append(value)
        }
        await producer.value
        #expect(received == [1, 2])
    }

    @Test func cancellingBufferedChannelWaitDoesNotCrash() async throws {
        let channel = AsyncChannel<Int>()
        let started = AsyncStream<Void>.makeStream()
        let consumer = Task {
            var iterator = channel.buffer(policy: .bounded(5)).makeAsyncIterator()
            started.continuation.yield(())
            do {
                let value = try await nextLegacyStreamElement(&iterator)
                #expect(value == nil)
            } catch {
                #expect(error is CancellationError)
            }
        }
        var readiness = started.stream.makeAsyncIterator()
        _ = await readiness.next()
        consumer.cancel()
        await consumer.value
        channel.finish()
        started.continuation.finish()
    }

    @Test func cancellationFromNeverProducerIsCatchable() async throws {
        var iterator = LegacyCancellationIterator()
        #expect(try await nextLegacyStreamElement(&iterator) == 42)
        do {
            _ = try await nextLegacyStreamElement(&iterator)
            Issue.record("Expected cancellation")
        } catch {
            #expect(error is CancellationError)
        }
    }

    @Test func normalStreamStillEnds() async throws {
        let stream = AsyncStream<Int> { continuation in
            continuation.yield(7)
            continuation.finish()
        }
        var iterator = stream.makeAsyncIterator()
        #expect(try await nextLegacyStreamElement(&iterator) == 7)
        #expect(try await nextLegacyStreamElement(&iterator) == nil)
    }
}
