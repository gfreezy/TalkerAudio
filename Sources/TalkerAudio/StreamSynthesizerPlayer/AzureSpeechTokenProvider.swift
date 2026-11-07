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
    private let refreshMargin: TimeInterval = 60

    public init(loadToken: @escaping @Sendable () async throws -> AzureSpeechToken) {
        self.loadToken = loadToken
        self.now = { Date() }
    }

    init(now: @escaping @Sendable () -> Date,
         loadToken: @escaping @Sendable () async throws -> AzureSpeechToken) {
        self.now = now
        self.loadToken = loadToken
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
