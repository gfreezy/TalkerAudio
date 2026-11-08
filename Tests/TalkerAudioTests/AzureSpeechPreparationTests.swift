import Foundation
import TalkerCommonSync
import Testing

@testable import TalkerAudio

@Suite(.timeLimit(.minutes(1)))
struct AzureSpeechPreparationTests {
    @Test func initializerStartsCredentialLoadBeforeSpeech() async {
        let started = AsyncStream<Void>.makeStream()
        let release = AsyncStream<Void>.makeStream()
        let loads = TalkerCommonSync.Lock(0)
        defer {
            started.continuation.finish()
            release.continuation.finish()
        }
        let provider = AzureSpeechTokenProvider {
            loads.withLock { $0 += 1 }
            started.continuation.yield(())
            for await _ in release.stream { break }
            throw URLError(.notConnectedToInternet)
        }
        let engine = AzureStreamSynthesizerEngine(
            voiceId: "en-US-JennyNeural", style: "", role: "", tokenProvider: provider)
        defer { engine.shutdown() }
        // Construction alone must start loading. No makeSession() has run.
        for await _ in started.stream { break }
        #expect(loads.withLock { $0 } == 1)
        release.continuation.finish()
        await #expect(throws: URLError.self) {
            _ = try await engine.makeSession(text: "Retry the failed initial preparation.")
        }
        #expect(loads.withLock { $0 } == 2)
    }

    @Test func initializerRefreshesExpiringCredentialBeforeSpeech() async throws {
        let clock = TalkerCommonSync.Lock(Date(timeIntervalSince1970: 1_000))
        let loads = TalkerCommonSync.Lock(0)
        let started = AsyncStream<Void>.makeStream()
        let release = AsyncStream<Void>.makeStream()
        defer {
            started.continuation.finish()
            release.continuation.finish()
        }
        let provider = AzureSpeechTokenProvider(now: { clock.withLock { $0 } }) {
            let attempt = loads.withLock { $0 += 1; return $0 }
            if attempt == 1 {
                return AzureSpeechToken(token: "unused-test-token", region: "southeastasia",
                                        expiresAt: Date(timeIntervalSince1970: 1_600))
            }
            started.continuation.yield(())
            for await _ in release.stream { break }
            throw URLError(.notConnectedToInternet)
        }
        _ = try await provider.token()
        clock.withLock { $0 = Date(timeIntervalSince1970: 1_420) }
        let engine = AzureStreamSynthesizerEngine(
            voiceId: "en-US-JennyNeural", style: "", role: "", tokenProvider: provider)
        defer { engine.shutdown() }
        for await _ in started.stream { break }
        #expect(loads.withLock { $0 } == 2)
        release.continuation.finish()
        await #expect(throws: URLError.self) {
            _ = try await engine.makeSession(text: "Retry the failed initial refresh.")
        }
        #expect(loads.withLock { $0 } == 3)
    }

    @Test func failedPreparationAndSpeechReleaseBorrowForRetry() async {
        let loads = TalkerCommonSync.Lock(0)
        let provider = AzureSpeechTokenProvider {
            loads.withLock { $0 += 1 }
            throw URLError(.notConnectedToInternet)
        }
        let engine = AzureStreamSynthesizerEngine(
            voiceId: "en-US-JennyNeural", style: "", role: "", tokenProvider: provider)
        defer { engine.shutdown() }

        await #expect(throws: URLError.self) {
            _ = try await engine.makeSession(text: "Retry the failed initial preparation.")
        }
        #expect(loads.withLock { $0 } == 2)
        await #expect(throws: URLError.self) {
            _ = try await engine.makeSession(text: "Retry after preparation failed.")
        }
        #expect(loads.withLock { $0 } == 3)
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
        let preparation = Task { _ = try await engine.makeSession(text: "Preparation check.") }
        for await _ in started.stream { break }
        engine.shutdown()
        release.continuation.yield(())
        await #expect(throws: CancellationError.self) { try await preparation.value }
    }

    @Test func cancellingSpeechWaitDoesNotCancelSharedPreparation() async {
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
        let first = Task { _ = try await engine.makeSession(text: "Preparation check.") }
        for await _ in started.stream { break }
        let second = Task { _ = try await engine.makeSession(text: "Preparation check.") }
        second.cancel()
        await #expect(throws: CancellationError.self) { try await second.value }
        release.continuation.yield(())
        release.continuation.finish()
        await #expect(throws: URLError.self) { try await first.value }
        await #expect(throws: URLError.self) { _ = try await engine.makeSession(text: "Preparation check.") }
    }
}
