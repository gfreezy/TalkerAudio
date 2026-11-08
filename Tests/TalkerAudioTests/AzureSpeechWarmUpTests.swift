import Foundation
import TalkerCommonSync
import Testing

@testable import TalkerAudio

@Suite(.timeLimit(.minutes(1)))
struct AzureSpeechWarmUpTests {
    @Test func failedWarmUpReleasesBorrowAndSpeechCanRetry() async {
        let loads = TalkerCommonSync.Lock(0)
        let provider = AzureSpeechTokenProvider {
            loads.withLock { $0 += 1 }
            throw URLError(.notConnectedToInternet)
        }
        let engine = AzureStreamSynthesizerEngine(
            voiceId: "en-US-JennyNeural", style: "", role: "", tokenProvider: provider)
        defer { engine.shutdown() }

        await #expect(throws: URLError.self) { try await engine.warmUp() }
        #expect(loads.withLock { $0 } == 1)
        await #expect(throws: URLError.self) {
            _ = try await engine.makeSession(text: "Retry after preparation failed.")
        }
        #expect(loads.withLock { $0 } == 2)
    }

    @Test func shutdownDuringCredentialLoadDoesNotCreateSDK() async {
        let started = AsyncStream<Void>.makeStream()
        let release = AsyncStream<Void>.makeStream()
        defer {
            started.continuation.finish()
            release.continuation.finish()
        }
        let provider = AzureSpeechTokenProvider {
            started.continuation.yield(())
            for await _ in release.stream { break }
            return AzureSpeechToken(token: "unused-test-token", region: "southeastasia",
                                    expiresAt: Date().addingTimeInterval(600))
        }
        let engine = AzureStreamSynthesizerEngine(
            voiceId: "en-US-JennyNeural", style: "", role: "", tokenProvider: provider)
        let preparation = Task { try await engine.warmUp() }
        for await _ in started.stream { break }
        engine.shutdown()
        release.continuation.yield(())
        await #expect(throws: CancellationError.self) { try await preparation.value }
    }

    @Test func cancellingWarmUpWhileWaitingDoesNotHoldBorrow() async {
        let started = AsyncStream<Void>.makeStream()
        let release = AsyncStream<Void>.makeStream()
        defer {
            started.continuation.finish()
            release.continuation.finish()
        }
        let provider = AzureSpeechTokenProvider {
            started.continuation.yield(())
            for await _ in release.stream { break }
            throw URLError(.notConnectedToInternet)
        }
        let engine = AzureStreamSynthesizerEngine(
            voiceId: "en-US-JennyNeural", style: "", role: "", tokenProvider: provider)
        defer { engine.shutdown() }
        let first = Task { try await engine.warmUp() }
        for await _ in started.stream { break }
        let second = Task { try await engine.warmUp() }
        second.cancel()
        await #expect(throws: CancellationError.self) { try await second.value }
        release.continuation.yield(())
        release.continuation.finish()
        await #expect(throws: URLError.self) { try await first.value }
        await #expect(throws: URLError.self) { try await engine.warmUp() }
    }
}
