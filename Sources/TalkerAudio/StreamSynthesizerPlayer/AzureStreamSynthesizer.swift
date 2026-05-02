//
//  StreamSynthesizer.swift
//  iOS
//
//  Created by feichao on 2023/3/16.
//
import SwiftUI
import TalkerCommon
import OSLog
import StreamAudio
import TalkerAudioObjC
import AudioToolbox

enum StreamSynthesizerError: String, LocalizedError {
    case speechSynthesizerNotExist
    case synthesizeCancelled
    case allocBuffer

    var errorDescription: String? {
        self.rawValue
    }
}

public class AzureStreamSynthesizer: StreamSynthesizerProtocol {

    private let sub: String
    private let region: String
    private var speechSynthesizer: SPXSpeechSynthesizer? = nil
    private var synthesizerConnection: SPXConnection? = nil
    private var sentenceFinishSignal = OneShotChannel()
    private let player: StreamAudio.StreamAudioPlayer
    private var text: String = ""
    private let voiceId: String
    private let style: String
    private let role: String
    private var isLoaded = false
    private let createdAt: Date = Date()
    private var loadStartedAt: Date?
    private var firstByteLogged = false

    public init(voiceId: String, style: String, role: String, sub: String, region: String) {
        let initStart = Date()
        self.sub = sub
        self.region = region
        self.voiceId = voiceId
        self.style = style
        self.role = role
        var cachePath = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        cachePath.appendPathExtension("mp3")
        self.player = StreamAudio.StreamAudioPlayer(cachePath: cachePath, fileType: kAudioFileMP3Type)
        self.setup()
        let elapsed = Int(Date().timeIntervalSince(initStart) * 1000)
        infoLog("[prewarm] AzureStreamSynthesizer init total: \(elapsed)ms voice=\(voiceId)")
    }

    private func setup() {
        do {
            let speechConfig = try SPXSpeechConfiguration(subscription: sub, region: region)
            speechConfig.setSpeechSynthesisOutputFormat(.audio16Khz32KBitRateMonoMp3)
            let audioOutputStream = SPXPushAudioOutputStream(
                writeHandler: writeHandler, closeHandler: closeHandler)
            let audioConfiguration = try SPXAudioConfiguration(streamOutput: audioOutputStream!)
            let speechSynthesizer = try SPXSpeechSynthesizer(
                speechConfiguration: speechConfig, audioConfiguration: audioConfiguration)
            speechSynthesizer.addSynthesisCompletedEventHandler({ [unowned self] _synth, arg in
                infoLog("finish load for result: \(arg.result.resultId)")
                try? player.finishData()
                sentenceFinishSignal.finish(())
            })
            speechSynthesizer.addSynthesisCanceledEventHandler({ [unowned self] _synth, arg in
                do {
                    try player.finishData()
                    let cancellationDetails = try SPXSpeechSynthesisCancellationDetails(
                        fromCanceledSynthesisResult: arg.result)
                    debugLog(
                        "cancelled, error code: \(String(describing: cancellationDetails.errorCode)), detail: \(cancellationDetails.errorDetails!)"
                    )
                } catch {
                    errorLog("\(error)")
                }
                infoLog("cancel speaking for result: \(arg.result.resultId)")
                sentenceFinishSignal.finish(throwing: StreamSynthesizerError.synthesizeCancelled)
            })
            let openCallStart = Date()
            let connection = try SPXConnection(from: speechSynthesizer)
            connection.open(true)
            let openCallElapsed = Int(Date().timeIntervalSince(openCallStart) * 1000)
            infoLog("[prewarm] Azure setup: connection.open(true) call returned in \(openCallElapsed)ms (handshake continues async)")
            self.synthesizerConnection = connection
            self.speechSynthesizer = speechSynthesizer
        } catch {
            errorLog("setup error: \(error)")
        }
    }

    private func writeHandler(_ data: Data) -> UInt {
        if !firstByteLogged {
            firstByteLogged = true
            let sinceCreate = Int(Date().timeIntervalSince(createdAt) * 1000)
            let sinceLoad = loadStartedAt.map { Int(Date().timeIntervalSince($0) * 1000) } ?? -1
            infoLog("[prewarm] Azure first audio byte: \(data.count) bytes, sinceInit=\(sinceCreate)ms sinceLoad=\(sinceLoad)ms voice=\(voiceId)")
        }
        do {
            try player.writeData(data)
        } catch {
            errorLog("Feed data to player error: \(error)")
        }
        return UInt(data.count)
    }

    private func closeHandler() {

    }

    private func buildSsmlText() -> String {
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
        try speechSynthesizer?.stopSpeaking()
    }

    public func waitForPlayStopped() async throws {
        try await player.waitForStop()
        infoLog("play finished:", text)
    }

    public func waitForLoadFinished() async throws {
        try await sentenceFinishSignal.wait()
    }

    public func load(text: String) throws {
        guard !isLoaded else {
            return
        }
        isLoaded = true
        self.text = text.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(
            in: .punctuationCharacters)
        let loadStart = Date()
        loadStartedAt = loadStart
        let sinceCreate = Int(loadStart.timeIntervalSince(createdAt) * 1000)
        infoLog("[prewarm] Azure load enter: sinceInit=\(sinceCreate)ms voice=\(voiceId)")
        let ssml = buildSsmlText()
        guard let speechSynthesizer = speechSynthesizer else {
            throw StreamSynthesizerError.speechSynthesizerNotExist
        }

        let result = try speechSynthesizer.startSpeakingSsml(ssml)
        let elapsed = Int(Date().timeIntervalSince(loadStart) * 1000)
        infoLog("[prewarm] Azure load: startSpeakingSsml returned in \(elapsed)ms")
        if result.reason == SPXResultReason.canceled {
            let cancellationDetails = try SPXSpeechSynthesisCancellationDetails(
                fromCanceledSynthesisResult: result)
            errorLog(
                "cancelled, error code: \(cancellationDetails.errorCode.rawValue) detail: \(cancellationDetails.errorDetails!) "
            )
            throw StreamSynthesizerError.synthesizeCancelled
        }
    }

    func listVoice() throws -> [SPXVoiceInfo] {
        guard let speechSynthesizer else {
            throw StreamSynthesizerError.speechSynthesizerNotExist
        }
        let result = try speechSynthesizer.getVoices()
        return result.voices
    }

    public func cachePath() -> URL {
        player.cacheFilePath()
    }
}
