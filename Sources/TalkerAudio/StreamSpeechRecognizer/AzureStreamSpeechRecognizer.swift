//
//  AzureStreamSpeechRecognizer.swift
//  iOS
//
//  Created by feichao on 2023/3/19.
//

import AsyncObjects
import Foundation
import TalkerAudioObjC
import TalkerCommon

private class SimpleOperation: Operation, @unchecked Sendable {
    let callback: () -> Void

    init(callback: @escaping () -> Void) {
        self.callback = callback
    }

    override func main() {
        if isCancelled { return }
        callback()
    }
}

final class AzureStreamSpeechRecognizer: StreamSpeechRecognizer, @unchecked Sendable {
    private let recorder = StreamAudioRecorder()
    private var pushAudioStream: SPXPushAudioInputStream?
    private var speechRecoginizer: SPXSpeechRecognizer?
    private var synthesizerConnection: SPXConnection? = nil
    private let sub: String
    private let region: String
    private var streamAudioBuffer = StreamAudioBuffer()
    private var index: StreamIndexOffset = StreamIndexOffset(index: 0, offset: 0)
    private var recognizingStarted = false
    private var sessionStopped: OneShotChannel = OneShotChannel()
    private var sessionId: String?
    private var fullRecognizedText = ""
    private let queue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        return q
    }()
    private var isStopped = false
    private let audioDelegateQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        return q
    }()
    var onRecoginizing: ((String?) -> Void)?
    var onRecoginized: ((String?) -> Void)?
    var onCanceled: (() -> Void)?

    var delegate: (any StreamSpeechRecognizerDelegate)?

    init(sub: String, region: String) {
        self.sub = sub
        self.region = region
    }

    func setup(language: String) throws {
        recorder.audioInputMoreDataBlock = { [weak self] buf in
            guard let self, !buf.isEmpty else {
                return
            }

            streamAudioBuffer.appendBytes(bytes: buf)
            pushAudioInputStreamAsync()
            audioDelegateQueue.addOperation {
                if self.isStopped {
                    return
                }
                self.delegate?.receiveAudioBuffer(data: buf)
            }
        }
        guard
            let format = SPXAudioStreamFormat(
                usingPCMWithSampleRate: 16000, bitsPerSample: 16, channels: 1)
        else {
            throw StreamSpeechRecognizerError.wrongFormat
        }
        guard let pushAudioStream = SPXPushAudioInputStream(audioFormat: format) else {
            throw StreamSpeechRecognizerError.createAudioStream
        }
        self.pushAudioStream = pushAudioStream
        guard let audioConfig = SPXAudioConfiguration(streamInput: pushAudioStream) else {
            throw StreamSpeechRecognizerError.createAudioConfig
        }

        let speechConfig = try SPXSpeechConfiguration(subscription: sub, region: region)
        speechConfig.speechRecognitionLanguage = language
        speechConfig.enableAudioLogging()
        let speechRecoginizer = try SPXSpeechRecognizer(
            speechConfiguration: speechConfig, audioConfiguration: audioConfig)
        speechRecoginizer.addSpeechStartDetectedEventHandler(recognitionStartDetectedHandler)
        speechRecoginizer.addSpeechEndDetectedEventHandler(recognitionEndDetectedHandler)
        speechRecoginizer.addRecognizingEventHandler(recognizingEventHandler)
        speechRecoginizer.addRecognizedEventHandler(recognizedEventHandler)
        speechRecoginizer.addCanceledEventHandler(recognitionCanceledEventHandler)
        speechRecoginizer.addSessionStoppedEventHandler(recognitionSessionStoppedHandler)
        speechRecoginizer.addSessionStartedEventHandler(recognitionSessionStartedHandler)
        let connection = try SPXConnection(from: speechRecoginizer)
        connection.open(true)
        self.speechRecoginizer = speechRecoginizer
        synthesizerConnection = connection
    }

    private func reset(language: String) throws {
        try stopRecordingAndCancelRecoginition()
        streamAudioBuffer.reset()
        index.reset()
        try setup(language: language)
        fullRecognizedText = ""
        sessionId = nil
        sessionStopped = OneShotChannel()
    }

    func startRecordingAndRecognition(
        language: String, reference: String?, pronounceInfoRequired: Bool
    ) async throws {
        if pronounceInfoRequired {
            throw StreamSpeechRecognizerError.notSupportPronounceInfo
        }
        try startRecording(language: language)
        try startRecognition()
    }

    func startRecording(language: String) throws {
        try reset(language: language)
        try recorder.start()
    }

    func startRecognition() throws {
        guard let speechRecoginizer else {
            throw StreamSpeechRecognizerError.noSpeechRecoginizer
        }
        recognizingStarted = true
        try speechRecoginizer.startContinuousRecognition()
        pushAudioInputStreamAsync()
    }

    func recognizedResult() async throws -> SpeechRecognizerResult {
        try await sessionStopped.wait()
        return SpeechRecognizerResult(text: fullRecognizedText)
    }

    func stopRecording(force: Bool = false) throws {
        streamAudioBuffer.finishStream()
        try recorder.stop()
        // when force stop, we drop data imediately
        if !force {
            pushAudioInputStreamAsync()
        } else {
            queue.cancelAllOperations()
        }
        isStopped = true
        audioDelegateQueue.cancelAllOperations()
    }

    func cancelRecoginition() throws {
        queue.addOperation { [weak self] in
            do {
                // stopContinuousRecognition blocks, when connection is poor
                try self?.speechRecoginizer?.stopContinuousRecognition()
            } catch {
                errorLog("stopContinuousRecognition", error)
            }
        }
        recognizingStarted = false
        sessionStopped.finish(throwing: StreamSpeechRecognizerError.cancelled)
    }

    func stopRecordingAndCancelRecoginition() throws {
        infoLog("stopRecordingAndRecoginition: stopRecording")
        try stopRecording(force: true)
        infoLog("stopRecordingAndRecoginition: stopRecoginition")
        try cancelRecoginition()
        infoLog("stopRecordingAndRecoginition: done")
    }

    private func pushAudioInputStreamAsync() {
        queue.addOperation(
            SimpleOperation(callback: { [weak self] in
                guard let self else {
                    return
                }
                // pushAudioInputStream blocks, when connection is poor
                pushAudioInputStream()
            }))
    }

    private func pushAudioInputStream() {
        infoLog("pushAudioInputStream, index: ", index)
        defer {
            infoLog("pushAudioInputStream finished, index: ", index)
        }
        guard recognizingStarted, let pushAudioStream, streamAudioBuffer.count > 0 else {
            return
        }

        var writtenBytes = 0
        while true {
            let size = 32000
            let buf = streamAudioBuffer.subrangeBytes(index, size: size)
            guard let buf else {
                pushAudioStream.close()
                infoLog("total size", streamAudioBuffer.totalBytes, "written bytes", writtenBytes)
                return
            }
            guard buf.count > 0 else {
                infoLog("total size", streamAudioBuffer.totalBytes, "written bytes", writtenBytes)
                return
            }
            pushAudioStream.write(buf)
            streamAudioBuffer.advanceStreamIndexOffset(&index, size: buf.count)
            infoLog(
                "pushAudioInputStreamReadHandler, count: \(buf.count), index: \(index), \(streamAudioBuffer.datas)"
            )
            writtenBytes += buf.count
        }
    }

    func saveAudioToFile(_ name: String?) throws -> String {
        return try saveAudioBufferToDisk(name: name ?? UUID().uuidString, buf: streamAudioBuffer)
    }

    private func recognitionStartDetectedHandler(
        _ recognizer: SPXRecognizer, _ eventArgs: SPXSessionEventArgs
    ) {
        if eventArgs.sessionId != sessionId {
            infoLog("recognitionStartDetectedHandler from previous")
            return
        }
        infoLog("recognitionStartDetectedHandler", sessionId ?? "", eventArgs.sessionId)
    }

    private func recognitionEndDetectedHandler(
        _ recognizer: SPXRecognizer, _ eventArgs: SPXSessionEventArgs
    ) {
        if eventArgs.sessionId != sessionId {
            infoLog("recognitionEndDetectedHandler from previous")
            return
        }
        infoLog("recognitionEndDetectedHandler", sessionId ?? "", eventArgs.sessionId)
    }

    private func recognitionSessionStartedHandler(
        _ recognizer: SPXRecognizer, _ eventArgs: SPXSessionEventArgs
    ) {
        sessionId = eventArgs.sessionId
        infoLog("recognitionSessionStartedHandler", sessionId ?? "", eventArgs.sessionId)
    }

    private func recognitionSessionStoppedHandler(
        _ recognizer: SPXRecognizer, _ eventArgs: SPXSessionEventArgs
    ) {
        if eventArgs.sessionId != sessionId {
            infoLog("recognitionSessionStoppedHandler from previous")
            return
        }
        sessionStopped.finish(())
        infoLog("recognitionSessionStoppedHandler", sessionId ?? "", eventArgs.sessionId)
    }

    private func recognizingEventHandler(
        _ recognizer: SPXSpeechRecognizer, _ eventArgs: SPXSpeechRecognitionEventArgs
    ) {
        if eventArgs.sessionId != sessionId {
            infoLog("recognizingEventHandler from previous")
            return
        }
        infoLog(
            "recognizingEventHandler", eventArgs.result.text ?? "", eventArgs.result.offset,
            sessionId ?? "", eventArgs.sessionId)
        onRecoginizing?(eventArgs.result.text)
    }

    private func recognizedEventHandler(
        _ recognizer: SPXSpeechRecognizer, _ eventArgs: SPXSpeechRecognitionEventArgs
    ) {
        if eventArgs.sessionId != sessionId {
            infoLog("recognizedEventHandler from previous")
            return
        }
        infoLog(
            "recognizedEventHandler", eventArgs.result.text ?? "", eventArgs.result.reason,
            sessionId ?? "", eventArgs.sessionId)
        guard let text = eventArgs.result.text else {
            return
        }
        fullRecognizedText += text
        onRecoginized?(text)
    }

    private func recognitionCanceledEventHandler(
        _ recognizer: SPXSpeechRecognizer, _ eventArgs: SPXSpeechRecognitionCanceledEventArgs
    ) {
        if eventArgs.sessionId != sessionId {
            infoLog("recognitionCanceledEventHandler from previous")
            return
        }
        infoLog(
            "recognitionCanceledEventHandler \(eventArgs.errorDetails ?? "")", sessionId ?? "",
            eventArgs.sessionId)
        onCanceled?()
    }
}
