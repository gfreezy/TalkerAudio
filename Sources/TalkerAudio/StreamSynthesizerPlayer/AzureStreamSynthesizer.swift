//
//  AzureStreamSynthesizer.swift
//  iOS
//
//  Created by feichao on 2023/3/16.
//
import AudioToolbox
import OSLog
import StreamAudio
import SwiftUI
import MicrosoftCognitiveServicesSpeech
import TalkerCommonLogging
import AsyncAlgorithms
import TalkerCommonSync

enum StreamSynthesizerError: String, LocalizedError {
    case speechSynthesizerNotExist
    case synthesizeCancelled
    case allocBuffer
    case engineNotReady

    var errorDescription: String? {
        self.rawValue
    }
}

/// `@unchecked Sendable` because `SPXSpeechSynthesizer`/`SPXConnection` are
/// Obj-C SDK types not declared Sendable. Our own state is fully synchronized:
/// `currentSession` is a `Lock<...>` slot, `borrowSemaphore` is an actor, the
/// SDK state is protected by `sdkState`; token refreshes happen between borrows.
/// SDK callbacks capture the `Lock` and `AsyncSemaphore` directly, not `self`.
public final class AzureStreamSynthesizerEngine: StreamSynthesizerEngine, @unchecked Sendable {

    private let voiceId: String
    private let style: String
    private let role: String

    private struct SDKState {
        let synthesizer: SPXSpeechSynthesizer
        let connection: SPXConnection
        let region: String
        var authorizationToken: String?
    }
    private let sdkState = Lock<SDKState?>(nil)
    private struct InitialPreparation: Sendable {
        let ready: OneShotChannel<Void>
        let task: Task<Void, Never>
    }
    private let initialPreparation = Lock<InitialPreparation?>(nil)
    private let isShutdown = Lock(false)
    private let tokenProvider: AzureSpeechTokenProvider?
    private let currentSession: Lock<AzureStreamSynthesizerSession?>
    private let borrowSemaphore: AsyncSemaphore
    /// True between `makeSession` acquiring the semaphore and the next
    /// `releaseBorrow` call. Lets release be idempotent — the SDK callback and
    /// `makeSession`'s catch can both fire (e.g. when `startSpeakingSsml`
    /// returns sync `.canceled` AND triggers the canceled handler), but only
    /// the first one signals the semaphore.
    private let borrowHeld: Lock<Bool>

    /// Existing subscription-key API remains available for trusted callers.
    public convenience init(voiceId: String, style: String, role: String, sub: String, region: String) {
        self.init(voiceId: voiceId, style: style, role: role, credentialProvider: nil)
        do {
            let configuration = try SPXSpeechConfiguration(subscription: sub, region: region)
            try sdkState.withLock { $0 = try makeSDK(configuration: configuration, region: region) }
        } catch {
            errorLog("setup error: \(error)")
        }
    }

    /// Starts preparing credentials and opening the reusable connection immediately.
    /// Fresh cached credentials are applied inline; otherwise preparation continues
    /// asynchronously without requiring a later makeSession() call.
    public convenience init(voiceId: String, style: String, role: String,
                            tokenProvider: AzureSpeechTokenProvider) {
        self.init(voiceId: voiceId, style: style, role: role, credentialProvider: tokenProvider)
        // Match the subscription-key path: a prefetched credential can initialize
        // the SDK and start its connection before this initializer returns.
        if let credential = tokenProvider.cachedToken() {
            do {
                try applyCredential(credential)
                debugLog("[tts-warmup] cached credential prepared inline")
                return
            } catch {
                errorLog("speech preconnection setup failed: \(error)")
            }
        }
        let ready = OneShotChannel<Void>()
        debugLog("[tts-warmup] initializer requesting credential")
        let task = Task { [weak self] in
            do {
                let credential = try await tokenProvider.token()
                try Task.checkCancellation()
                guard let self else { throw CancellationError() }
                try self.applyCredential(credential)
                debugLog("[tts-warmup] initializer prepared connection")
                ready.finish(())
            } catch {
                if !(error is CancellationError) {
                    errorLog("speech initial preparation failed: \(error)")
                }
                ready.finish(throwing: error)
            }
        }
        initialPreparation.withLock { $0 = InitialPreparation(ready: ready, task: task) }
    }

    private init(voiceId: String, style: String, role: String,
                 credentialProvider: AzureSpeechTokenProvider?) {
        self.voiceId = voiceId
        self.style = style
        self.role = role
        self.tokenProvider = credentialProvider
        self.currentSession = Lock(nil)
        self.borrowSemaphore = AsyncSemaphore(value: 1)
        self.borrowHeld = Lock(false)
    }

    private func makeSDK(configuration: SPXSpeechConfiguration, region: String,
                         authorizationToken: String? = nil) throws -> SDKState {
        let currentSession = self.currentSession
        let borrowSemaphore = self.borrowSemaphore
        let borrowHeld = self.borrowHeld
        let releaseBorrow: @Sendable () -> Void = {
            let shouldSignal = borrowHeld.withLock { value -> Bool in
                guard value else { return false }
                value = false
                return true
            }
            if shouldSignal { borrowSemaphore.signal() }
        }
        configuration.setSpeechSynthesisOutputFormat(.audio16Khz32KBitRateMonoMp3)
        // Capture the Lock, Semaphore, and releaseBorrow closure — never
        // `self` — so the SDK callbacks don't pull a non-Sendable type
        // into a non-isolated context. (They run on internal SDK threads.)
        let writeHandler: (Data) -> UInt = { data in
            if let session = currentSession.withLock({ $0 }) {
                session.feed(data: data)
            }
            return UInt(data.count)
        }
        let audioOutputStream = SPXPushAudioOutputStream(
            writeHandler: writeHandler, closeHandler: {})
        let audioConfiguration = try SPXAudioConfiguration(streamOutput: audioOutputStream!)
        let speechSynthesizer = try SPXSpeechSynthesizer(
            speechConfiguration: configuration, audioConfiguration: audioConfiguration)
        speechSynthesizer.addSynthesisCompletedEventHandler({ _synth, arg in
            infoLog("finish load for result: \(arg.result.resultId)")
            let session = currentSession.withLock { slot -> AzureStreamSynthesizerSession? in
                let value = slot
                slot = nil
                return value
            }
            if let session {
                session.finishLoad()
                releaseBorrow()
            }
        })
        speechSynthesizer.addSynthesisCanceledEventHandler({ _synth, arg in
            let cancellationDetails: SPXSpeechSynthesisCancellationDetails?
            do {
                cancellationDetails = try SPXSpeechSynthesisCancellationDetails(
                    fromCanceledSynthesisResult: arg.result)
                debugLog(
                    "cancelled, error code: \(String(describing: cancellationDetails?.errorCode)), detail: \(String(describing: cancellationDetails?.errorDetails))"
                )
            } catch {
                cancellationDetails = nil
                errorLog("\(error)")
            }
            infoLog("cancel speaking for result: \(arg.result.resultId)")
            let session = currentSession.withLock { slot -> AzureStreamSynthesizerSession? in
                let value = slot
                slot = nil
                return value
            }
            if let session {
                session.cancelLoad(error: StreamSynthesizerError.synthesizeCancelled)
                releaseBorrow()
            }
        })
        let connection = try SPXConnection(from: speechSynthesizer)
        let connectionStartedAt = ProcessInfo.processInfo.systemUptime
        connection.addConnectedEventHandler { _, _ in
            let elapsedMs = Int((ProcessInfo.processInfo.systemUptime - connectionStartedAt) * 1000)
            debugLog("[tts-warmup] connection established elapsedMs=\(elapsedMs)")
        }
        debugLog("[tts-warmup] connection opening")
        connection.open(true)
        return SDKState(synthesizer: speechSynthesizer, connection: connection, region: region,
                        authorizationToken: authorizationToken)
    }

    private func refreshAuthorizationIfNeeded() async throws {
        guard let tokenProvider else { return }
        let credential: AzureSpeechToken
        if let cached = tokenProvider.cachedToken() {
            credential = cached
        } else {
            credential = try await tokenProvider.token()
        }
        try applyCredential(credential)
    }

    private func applyCredential(_ credential: AzureSpeechToken) throws {
        try Task.checkCancellation()
        guard !isShutdown.withLock({ $0 }) else { throw CancellationError() }
        try sdkState.withLock { state in
            guard !isShutdown.withLock({ $0 }) else { throw CancellationError() }
            if var existing = state, existing.region == credential.region {
                guard existing.authorizationToken != credential.token else { return }
                // SpeechConfiguration is copied by the SDK, so refresh the live synthesizer.
                existing.synthesizer.authorizationToken = credential.token
                existing.authorizationToken = credential.token
                state = existing
            } else {
                let configuration = try SPXSpeechConfiguration(
                    authorizationToken: credential.token, region: credential.region)
                state = try makeSDK(configuration: configuration, region: credential.region,
                                    authorizationToken: credential.token)
            }
        }
    }

    private func waitForInitialPreparation() async throws {
        guard let preparation = initialPreparation.withLock({ $0 }) else { return }
        defer {
            // A cancelled waiter leaves the shared preparation running for other callers.
            // Completed failures are removed so the next operation can retry normally.
            if preparation.ready.isFinished {
                initialPreparation.withLock { $0 = nil }
            }
        }
        do {
            try await preparation.ready.wait()
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            // The initializer already logged the failure. Let the first utterance
            // retry normal credential loading instead of failing on an earlier attempt.
        }
    }

    public func makeSession(text: String) async throws -> any StreamSynthesizerSession & Sendable {
        infoLog("[azure-engine-reuse] makeSession voiceId=\(voiceId) text.count=\(text.count)")
        try await waitForInitialPreparation()
        try await borrowSemaphore.wait()
        // Mark the borrow held so any release path (the catch below or the
        // SDK callback) is idempotent.
        borrowHeld.withLock { $0 = true }
        do {
            try Task.checkCancellation()
            guard !isShutdown.withLock({ $0 }) else { throw CancellationError() }
            try await refreshAuthorizationIfNeeded()
            return try installAndStart(text: text)
        } catch {
            releaseBorrow()
            throw error
        }
    }

    private func releaseBorrow() {
        let shouldSignal = borrowHeld.withLock { v -> Bool in
            guard v else { return false }
            v = false
            return true
        }
        if shouldSignal { borrowSemaphore.signal() }
    }

    private func installAndStart(text: String) throws -> AzureStreamSynthesizerSession {
        return try sdkState.withLock { state in
            guard !isShutdown.withLock({ $0 }),
                  let speechSynthesizer = state?.synthesizer else {
                throw StreamSynthesizerError.engineNotReady
            }
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: .punctuationCharacters)
            let ssml = buildSsmlText(text: trimmed)
            let session = AzureStreamSynthesizerSession(
                text: trimmed, voiceId: voiceId, engine: self)
            currentSession.withLock { $0 = session }
            do {
                let result = try speechSynthesizer.startSpeakingSsml(ssml)
                if result.reason == SPXResultReason.canceled {
                    let cancellationDetails = try SPXSpeechSynthesisCancellationDetails(
                        fromCanceledSynthesisResult: result)
                    errorLog(
                        "cancelled, error code: \(cancellationDetails.errorCode.rawValue) detail: \(cancellationDetails.errorDetails!) "
                    )
                    currentSession.withLock { $0 = nil }
                    throw StreamSynthesizerError.synthesizeCancelled
                }
                return session
            } catch {
                currentSession.withLock { $0 = nil }
                throw error
            }
        }
    }

    private func buildSsmlText(text: String) -> String {
        let lang = getLangFromVoiceId(voiceId) ?? "en-US"

        return """
            <speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="\(lang)">
                <voice name="\(voiceId)">
                    <mstts:express-as role="\(role)" style="\(style)">
                        \(text)
                    </mstts:express-as>
                </voice>
            </speak>
            """
    }

    /// Called by a session's `stop()`. Aborts the SDK speak only if this
    /// session still holds the borrow (otherwise the engine has moved on and
    /// stopping would interrupt the next session).
    func stopCurrent(session: AzureStreamSynthesizerSession) {
        let isCurrent = currentSession.withLock { $0 === session }
        guard isCurrent else { return }
        try? sdkState.withLock({ $0?.synthesizer })?.stopSpeaking()
    }

    public func shutdown() {
        infoLog("[azure-engine-reuse] shutdown voiceId=\(voiceId)")
        isShutdown.withLock { $0 = true }
        if let preparation = initialPreparation.withLock({ $0 }) {
            preparation.task.cancel()
            preparation.ready.finish(throwing: CancellationError())
        }
        try? sdkState.withLock({ $0?.synthesizer })?.stopSpeaking()
    }

    func listVoice() throws -> [SPXVoiceInfo] {
        guard let speechSynthesizer = sdkState.withLock({ $0?.synthesizer }) else {
            throw StreamSynthesizerError.speechSynthesizerNotExist
        }
        let result = try speechSynthesizer.getVoices()
        return result.voices
    }
}

public final class AzureStreamSynthesizerSession: StreamSynthesizerSession, Sendable {

    private let player: StreamAudio.StreamAudioPlayer
    private let sentenceFinishSignal = OneShotChannel()
    private let text: String
    private let voiceId: String
    // Strong ref: engine never retains sessions (only holds the active one in
    // its currentSession slot, cleared on completion), so no retain cycle.
    private let engine: AzureStreamSynthesizerEngine

    init(text: String, voiceId: String, engine: AzureStreamSynthesizerEngine) {
        self.text = text
        self.voiceId = voiceId
        self.engine = engine
        self.player = StreamAudio.StreamAudioPlayer(
            cachePath: tempAudioCachePath(extension: "mp3"), fileType: kAudioFileMP3Type)
    }

    fileprivate func feed(data: Data) {
        do {
            try player.writeData(data)
        } catch {
            errorLog("Feed data to player error: \(error)")
        }
    }

    fileprivate func finishLoad() {
        try? player.finishData()
        sentenceFinishSignal.finish(())
    }

    fileprivate func cancelLoad(error: Error) {
        try? player.finishData()
        sentenceFinishSignal.finish(throwing: error)
    }

    public var isPlaying: Bool {
        return player.runningState == .playing
    }

    public func play() async throws {
        try await waitForLoadFinished()
        infoLog("finish load:", text)
        try await player.play()
        infoLog("start play:", text)
    }

    public func stop() throws {
        try player.stop()
        engine.stopCurrent(session: self)
    }

    public func waitForPlayStopped() async throws {
        try await player.waitForStop()
        infoLog("play finished:", text)
    }

    public func waitForLoadFinished() async throws {
        try await sentenceFinishSignal.wait()
    }

    public func cachePath() -> URL {
        player.cacheFilePath()
    }
}
