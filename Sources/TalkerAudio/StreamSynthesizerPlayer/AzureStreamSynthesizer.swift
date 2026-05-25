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
import TalkerAudioObjC
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
/// SDK objects are `let` and never reassigned (shutdown only calls
/// `stopSpeaking`; the SDK objects are released when the engine is dropped).
/// SDK callbacks capture the `Lock` and `AsyncSemaphore` directly, not `self`.
public final class AzureStreamSynthesizerEngine: StreamSynthesizerEngine, @unchecked Sendable {

    private let voiceId: String
    private let style: String
    private let role: String

    private let speechSynthesizer: SPXSpeechSynthesizer?
    private let synthesizerConnection: SPXConnection?
    private let currentSession: Lock<AzureStreamSynthesizerSession?>
    private let borrowSemaphore: AsyncSemaphore
    /// True between `makeSession` acquiring the semaphore and the next
    /// `releaseBorrow` call. Lets release be idempotent — the SDK callback and
    /// `makeSession`'s catch can both fire (e.g. when `startSpeakingSsml`
    /// returns sync `.canceled` AND triggers the canceled handler), but only
    /// the first one signals the semaphore.
    private let borrowHeld: Lock<Bool>

    public init(voiceId: String, style: String, role: String, sub: String, region: String) {
        infoLog("[azure-engine-reuse] init voiceId=\(voiceId) style=\(style) role=\(role)")
        self.voiceId = voiceId
        self.style = style
        self.role = role
        let currentSession = Lock<AzureStreamSynthesizerSession?>(nil)
        let borrowSemaphore = AsyncSemaphore(value: 1)
        let borrowHeld = Lock(false)
        let releaseBorrow: @Sendable () -> Void = {
            let shouldSignal = borrowHeld.withLock { v -> Bool in
                guard v else { return false }
                v = false
                return true
            }
            if shouldSignal { borrowSemaphore.signal() }
        }
        self.currentSession = currentSession
        self.borrowSemaphore = borrowSemaphore
        self.borrowHeld = borrowHeld

        var synth: SPXSpeechSynthesizer? = nil
        var conn: SPXConnection? = nil
        do {
            let speechConfig = try SPXSpeechConfiguration(subscription: sub, region: region)
            speechConfig.setSpeechSynthesisOutputFormat(.audio16Khz32KBitRateMonoMp3)
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
                speechConfiguration: speechConfig, audioConfiguration: audioConfiguration)
            speechSynthesizer.addSynthesisCompletedEventHandler({ _synth, arg in
                infoLog("finish load for result: \(arg.result.resultId)")
                let session = currentSession.withLock { slot -> AzureStreamSynthesizerSession? in
                    let value = slot
                    slot = nil
                    return value
                }
                session?.finishLoad()
                releaseBorrow()
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
                session?.cancelLoad(error: StreamSynthesizerError.synthesizeCancelled)
                releaseBorrow()
            })
            let connection = try SPXConnection(from: speechSynthesizer)
            connection.open(true)
            synth = speechSynthesizer
            conn = connection
        } catch {
            errorLog("setup error: \(error)")
        }

        self.speechSynthesizer = synth
        self.synthesizerConnection = conn
    }

    public func makeSession(text: String) async throws -> any StreamSynthesizerSession & Sendable {
        infoLog("[azure-engine-reuse] makeSession voiceId=\(voiceId) text.count=\(text.count)")
        try await borrowSemaphore.wait()
        // Mark the borrow held so any release path (the catch below or the
        // SDK callback) is idempotent.
        borrowHeld.withLock { $0 = true }
        do {
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
        guard let speechSynthesizer = speechSynthesizer else {
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
        try? speechSynthesizer?.stopSpeaking()
    }

    public func shutdown() {
        infoLog("[azure-engine-reuse] shutdown voiceId=\(voiceId)")
        try? speechSynthesizer?.stopSpeaking()
        // SDK objects are `let`; they are released when this engine is deinit'd.
    }

    func listVoice() throws -> [SPXVoiceInfo] {
        guard let speechSynthesizer else {
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
