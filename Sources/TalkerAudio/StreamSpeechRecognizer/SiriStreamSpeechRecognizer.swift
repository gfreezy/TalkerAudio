//
//  StreamSpeechRecognizer.swift
//  iOS
//
//  Created by feichao on 2023/3/19.
//

import AVFoundation
import Foundation
import Speech
import TalkerCommon

public class BaseSiriSpeechRecognizer: NSObject, SFSpeechRecognitionTaskDelegate,
    FileSpeechRecognizer, @unchecked Sendable
{
    var recognitionTask: SFSpeechRecognitionTask?
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var siriRecognitionText: String?
    var speechRecognizer: SFSpeechRecognizer?
    var sessionStopped: OneShotChannel = OneShotChannel()
    var isStopped = false

    private func reset() {
        sessionStopped = OneShotChannel()
    }

    func requestAuthorization() async throws {
        try await withCheckedThrowingContinuation { cont in
            SFSpeechRecognizer.requestAuthorization { status in
                if status == .authorized {
                    cont.resume()
                } else {
                    cont.resume(with: .failure(StreamSpeechRecognizerError.notAuthorized))
                }
            }
        }
    }

    public func startRecognition(
        language: String, reference: String? = nil, pronounceInfoRequired: Bool = false,
        format: RecordFormat
    ) async throws {
        assert(format == .pcm)
        try await requestAuthorization()

        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: language))

        guard let speechRecognizer else {
            return
        }

        reset()

        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest.addsPunctuation = true
        recognitionRequest.requiresOnDeviceRecognition = false
        self.recognitionRequest = recognitionRequest
        let recognitionTask = speechRecognizer.recognitionTask(
            with: recognitionRequest, delegate: self)
        self.recognitionTask = recognitionTask
        infoLog("startRecognition", recognitionTask.state)
    }

    public func recognizedResult() async throws -> SpeechRecognizerResult {
        try await sessionStopped.wait()
        return SpeechRecognizerResult(text: siriRecognitionText ?? "")
    }

    public func stopRecoginition(force: Bool = false) throws {
        recognitionRequest?.endAudio()
        recognitionTask?.finish()
        infoLog("stop Recording")
        isStopped = true
    }

    public func cancelRecoginition() throws {
        if let recognitionTask, recognitionTask.state == .running {
            recognitionTask.cancel()
        }
        recognitionRequest = nil
        recognitionTask = nil
    }

    // Called when the task first detects speech in the source audio
    public func speechRecognitionDidDetectSpeech(_ task: SFSpeechRecognitionTask) {
        infoLog("speechRecognitionDidDetectSpeech")
    }

    // Called for all recognitions, including non-final hypothesis
    public func speechRecognitionTask(
        _ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription
    ) {
        infoLog("didHypothesizeTranscription")
    }

    // Called when the task is no longer accepting new audio but may be finishing final processing
    public func speechRecognitionTaskFinishedReadingAudio(_ task: SFSpeechRecognitionTask) {
        infoLog("speechRecognitionTaskFinishedReadingAudio")
    }

    // Called only for final recognitions of utterances. No more about the utterance will be reported
    public func speechRecognitionTask(
        _ task: SFSpeechRecognitionTask,
        didFinishRecognition recognitionResult: SFSpeechRecognitionResult
    ) {
        let transcription = recognitionResult.bestTranscription
        let spokenText = transcription.formattedString
        self.siriRecognitionText = spokenText
        sessionStopped.finish(())
        infoLog("didFinishRecognition")
    }

    // Called when the task has been cancelled, either by client app, the user, or the system
    public func speechRecognitionTaskWasCancelled(_ task: SFSpeechRecognitionTask) {
        self.siriRecognitionText = ""
        sessionStopped.finish(())
        infoLog("speechRecognitionTaskWasCancelled")
    }

    // Called when recognition of all requested utterances is finished.
    // If successfully is false, the error property of the task will contain error information
    public func speechRecognitionTask(
        _ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool
    ) {
        infoLog("didFinishSuccessfully", successfully)
        if !successfully {
            errorLog("recognitionTask error: ", recognitionTask?.error?.localizedDescription ?? "")
        }
        self.siriRecognitionText = ""
        sessionStopped.finish(())
    }
}

public final class SiriFileSpeechRecognizer: BaseSiriSpeechRecognizer, @unchecked Sendable {
    let audioFile: URL

    public init(audioFile: URL) {
        self.audioFile = audioFile
        super.init()
    }

    override public func startRecognition(
        language: String, reference: String? = nil, pronounceInfoRequired: Bool = false,
        format: RecordFormat
    ) async throws {
        try await super.startRecognition(language: language, reference: reference, format: format)
        let buffer = try readAVAudioPCMBufferFromWavFile(fileURL: audioFile)
        recognitionRequest?.append(buffer)
        try stopRecoginition()
    }
}

public final class SiriStreamSpeechRecognizer: BaseSiriSpeechRecognizer, StreamSpeechRecognizer,
    @unchecked Sendable
{
    private let recorder = StreamAudioRecorder()
    private var streamAudioBuffer = StreamAudioBuffer()
    private var queue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        return q
    }()
    private let uniqueId: String
    public var delegate: (any StreamSpeechRecognizerDelegate)?

    public override init() {
        self.uniqueId = UUID().uuidString
        super.init()
        setup()
    }

    func setup() {
        recorder.audioInputMoreDataBlock = { [weak self] buf in
            guard let self, !buf.isEmpty else {
                return
            }
            guard
                let buffer = pcmBytesToAVAudioPCMBuffer(
                    pcmData: buf, sampleRate: 16000, channels: 1)
            else {
                errorLog("pcmBytesToAVAudioPCMBuffer")
                return
            }
            //            infoLog("frameLength", buffer.frameLength)
            recognitionRequest?.append(buffer)
            streamAudioBuffer.appendBytes(bytes: buf)

            queue.addOperation {
                if self.isStopped {
                    return
                }
                self.delegate?.receiveAudioBuffer(data: buf)
            }
        }
    }

    public func startRecordingAndRecognition(
        language: String, reference: String?, pronounceInfoRequired: Bool, format: RecordFormat
    ) async throws {
        assert(format == .pcm)
        if pronounceInfoRequired {
            throw StreamSpeechRecognizerError.notSupportPronounceInfo
        }
        try await super.startRecognition(language: language, reference: reference, format: format)
        try recorder.start(format: format)
    }

    public func stopRecording(force: Bool = false) throws {
        try recorder.stop()
        try super.stopRecoginition(force: false)
        streamAudioBuffer.finishStream()
        queue.cancelAllOperations()
    }

    public func stopRecordingAndCancelRecoginition() throws {
        try stopRecording()
        try cancelRecoginition()
    }

    public func saveAudioToFile(_ name: String?) throws -> String {
        return try saveAudioBufferToDisk(
            name: name ?? uniqueId, buf: streamAudioBuffer, format: .pcm)
    }
}
