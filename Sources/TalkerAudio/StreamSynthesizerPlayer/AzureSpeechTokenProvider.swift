import Foundation

/// A short-lived Azure Speech credential issued by your backend.
public struct AzureSpeechToken: Sendable {
    public let token: String
    public let region: String
    public let expiresAt: Date

    public init(token: String, region: String, expiresAt: Date) {
        self.token = token
        self.region = region
        self.expiresAt = expiresAt
    }
}

/// Share one provider across engines to cache credentials and coalesce refreshes.
public actor AzureSpeechTokenProvider {
    private let loadToken: @Sendable () async throws -> AzureSpeechToken
    private let now: @Sendable () -> Date
    private var cached: AzureSpeechToken?
    private var inFlight: (id: UUID, task: Task<AzureSpeechToken, Error>)?
    private let refreshMargin: TimeInterval

    public init(loadToken: @escaping @Sendable () async throws -> AzureSpeechToken) {
        self.loadToken = loadToken
        self.now = { Date() }
        self.refreshMargin = 3 * 60
    }

    /// Override the refresh window for issuers with a different lifetime or short-lived tests.
    public init(refreshBeforeExpiry: TimeInterval,
                loadToken: @escaping @Sendable () async throws -> AzureSpeechToken) {
        precondition(refreshBeforeExpiry.isFinite && refreshBeforeExpiry >= 0)
        self.loadToken = loadToken
        self.now = { Date() }
        self.refreshMargin = refreshBeforeExpiry
    }

    init(now: @escaping @Sendable () -> Date,
         refreshBeforeExpiry: TimeInterval = 3 * 60,
         loadToken: @escaping @Sendable () async throws -> AzureSpeechToken) {
        precondition(refreshBeforeExpiry.isFinite && refreshBeforeExpiry >= 0)
        self.now = now
        self.loadToken = loadToken
        self.refreshMargin = refreshBeforeExpiry
    }

    public func token(forceRefresh: Bool = false) async throws -> AzureSpeechToken {
        try Task.checkCancellation()
        if !forceRefresh, let cached, cached.expiresAt.timeIntervalSince(now()) > refreshMargin {
            return cached
        }

        let pending: (id: UUID, task: Task<AzureSpeechToken, Error>)
        if let inFlight {
            pending = inFlight
        } else {
            let loadToken = self.loadToken
            let now = self.now
            let margin = refreshMargin
            pending = (UUID(), Task {
                let token = try await loadToken()
                guard !token.token.isEmpty, !token.region.isEmpty,
                      token.expiresAt.timeIntervalSince(now()) > margin else {
                    throw AzureSpeechTokenError.invalidCredential
                }
                return token
            })
            inFlight = pending
        }

        do {
            let token = try await pending.task.value
            if inFlight?.id == pending.id {
                cached = token
                inFlight = nil
            }
            try Task.checkCancellation()
            return token
        } catch {
            if inFlight?.id == pending.id {
                inFlight = nil
            }
            throw error
        }
    }
}

enum AzureSpeechTokenError: Error {
    case invalidCredential
}
