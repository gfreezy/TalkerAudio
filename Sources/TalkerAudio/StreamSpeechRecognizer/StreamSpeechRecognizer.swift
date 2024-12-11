//
//  StreamSpeechRecognizerBase.swift
//  iOS
//
//  Created by feichao on 2023/4/8.
//

import Foundation

public enum StreamSpeechRecognizerError: String, LocalizedError {
    case createAudioConfig
    case noSpeechRecoginizer
    case wrongFormat
    case createAudioStream
    case notAuthorized
    case cancelled
    case remoteError
    case notSupportPronounceInfo

    public var errorDescription: String? {
        self.rawValue
    }
}

public protocol StreamSpeechRecognizerDelegate: NSObject {
    func receiveAudioBuffer(data: Data)
}

public struct SpeechRecognizerResult: Sendable {
    
    public let text: String
    public let pronounceInfo: PronounceInfo?
    
    public init(text: String, pronounceInfo: PronounceInfo? = nil) {
        self.text = text
        self.pronounceInfo = pronounceInfo
    }
}

public struct PronounceInfo: Codable, Sendable {
    
    public let textItems: [PronounceInfoTextItem]?
    public let fluencyScore: Double?
    public let prosodyScore: Double?
    public let accuracyScore: Double?
    public let completenessScore: Double?
    public let pronScore: Double?
    public let duration: Int?
    
    enum CodingKeys: String, CodingKey {
        case textItems = "text_items"
        case fluencyScore = "fluency_score"
        case prosodyScore = "prosody_score"
        case accuracyScore = "accuracy_score"
        case completenessScore = "completeness_score"
        case pronScore = "pron_score"
        case duration
    }
    
    public init(textItems: [PronounceInfoTextItem]?, fluencyScore: Double?, prosodyScore: Double?, accuracyScore: Double?, completenessScore: Double?, pronScore: Double?, duration: Int?) {
        self.textItems = textItems
        self.fluencyScore = fluencyScore
        self.prosodyScore = prosodyScore
        self.accuracyScore = accuracyScore
        self.completenessScore = completenessScore
        self.pronScore = pronScore
        self.duration = duration
    }
}

// 文本元素，包含单词大小写以及标点符号、发音等
public struct PronounceInfoTextItem: Codable, Sendable {
    public let wordText: String?
    public let errorType: String?
    public let accuracyScore: Double?
    public let syllables: [PronounceInfoSyllable]?
    public let phonemes: [PronounceInfoPhoneme]?
    
    enum CodingKeys: String, CodingKey {
        case wordText = "word_text"
        case errorType = "error_type"
        case accuracyScore = "accuracy_score"
        case syllables
        case phonemes
    }
    
    public var word: String {
        wordText?.trimmingCharacters(in: .punctuationCharacters).capitalized ?? ""
    }
    
    public init(wordText: String?, errorType: String?, accuracyScore: Double?, syllables: [PronounceInfoSyllable]?, phonemes: [PronounceInfoPhoneme]?) {
        self.wordText = wordText
        self.errorType = errorType
        self.accuracyScore = accuracyScore
        self.syllables = syllables
        self.phonemes = phonemes
    }
}

public struct PronounceInfoSyllable: Codable, Sendable {
    
    public let grapheme: String?
    public let syllable: String?
    public let accuracyScore: Double?
    
    enum CodingKeys: String, CodingKey {
        case grapheme
        case syllable
        case accuracyScore = "accuracy_score"
    }
    
    public init(grapheme: String?, syllable: String?, accuracyScore: Double?) {
        self.grapheme = grapheme
        self.syllable = syllable
        self.accuracyScore = accuracyScore
    }
}

public struct PronounceInfoPhoneme: Codable, Sendable {
    public let phoneme: String?
    public let accuracyScore: Double?
    
    enum CodingKeys: String, CodingKey {
        case phoneme
        case accuracyScore = "accuracy_score"
    }
    
    public init(phoneme: String?, accuracyScore: Double?) {
        self.phoneme = phoneme
        self.accuracyScore = accuracyScore
    }
}


public protocol StreamSpeechRecognizer: Sendable {
    var delegate: StreamSpeechRecognizerDelegate? { get set }

    func startRecordingAndRecognition(language: String, reference: String?, pronounceInfoRequired: Bool) async throws

    func recognizedResult() async throws -> SpeechRecognizerResult

    func stopRecordingAndCancelRecoginition() throws

    func saveAudioToFile(_ name: String?) throws -> URL

    func stopRecording(force: Bool) throws

    func cancelRecoginition() throws
}


public protocol FileSpeechRecognizer: Sendable {
    func startRecognition(language: String, reference: String?, pronounceInfoRequired: Bool) async throws

    func recognizedResult() async throws -> SpeechRecognizerResult

    func cancelRecoginition() throws
}
