import Foundation
import TalkerCommonSync
import Testing

@testable import TalkerAudio

struct AzureSpeechTokenProviderTests {
    @Test func cachesAndRefreshesBeforeExpiry() async throws {
        let clock = TalkerCommonSync.Lock(Date(timeIntervalSince1970: 1_000))
        let loads = TalkerCommonSync.Lock(0)
        let provider = AzureSpeechTokenProvider(now: { clock.withLock { $0 } }) {
            let count = loads.withLock { $0 += 1; return $0 }
            return AzureSpeechToken(token: "token-\(count)", region: "southeastasia",
                                    expiresAt: clock.withLock { $0 }.addingTimeInterval(600))
        }
        #expect(try await provider.token().token == "token-1")
        clock.withLock { $0 += 539 }
        #expect(try await provider.token().token == "token-1")
        clock.withLock { $0 += 1 }
        #expect(try await provider.token().token == "token-2")
        #expect(loads.withLock { $0 } == 2)
        #expect(try await provider.token(forceRefresh: true).token == "token-3")
    }

    @Test func concurrentCallersShareOneRefresh() async throws {
        let loads = TalkerCommonSync.Lock(0)
        let started = AsyncStream<Void>.makeStream()
        let release = AsyncStream<Void>.makeStream()
        let provider = AzureSpeechTokenProvider {
            loads.withLock { $0 += 1 }
            started.continuation.yield(())
            for await _ in release.stream { break }
            return AzureSpeechToken(token: "shared", region: "southeastasia",
                                    expiresAt: Date().addingTimeInterval(600))
        }
        let first = Task { try await provider.token() }
        for await _ in started.stream { break }
        let second = Task { try await provider.token() }
        release.continuation.yield(())
        #expect(try await first.value.token == "shared")
        #expect(try await second.value.token == "shared")
        #expect(loads.withLock { $0 } == 1)
        started.continuation.finish()
        release.continuation.finish()
    }

    @Test func failedRefreshDoesNotReturnAnExpiringCredentialAndCanRetry() async throws {
        let clock = TalkerCommonSync.Lock(Date(timeIntervalSince1970: 1_000))
        let loads = TalkerCommonSync.Lock(0)
        let provider = AzureSpeechTokenProvider(now: { clock.withLock { $0 } }) {
            let count = loads.withLock { $0 += 1; return $0 }
            if count == 2 { throw URLError(.notConnectedToInternet) }
            return AzureSpeechToken(token: "token-\(count)", region: "southeastasia",
                                    expiresAt: clock.withLock { $0 }.addingTimeInterval(600))
        }
        _ = try await provider.token()
        clock.withLock { $0 += 550 }
        await #expect(throws: URLError.self) { try await provider.token() }
        #expect(try await provider.token().token == "token-3")
    }

    @Test(arguments: ["", "expired"])
    func rejectsInvalidCredentials(token: String) async {
        let provider = AzureSpeechTokenProvider {
            AzureSpeechToken(token: token, region: "southeastasia",
                             expiresAt: token.isEmpty ? Date().addingTimeInterval(600) : .distantPast)
        }
        await #expect(throws: AzureSpeechTokenError.self) { try await provider.token() }
    }
}
