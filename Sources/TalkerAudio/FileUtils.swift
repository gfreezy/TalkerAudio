import AVFoundation
import Foundation
import TalkerCommon

public func saveData(_ data: Data, toFileNamed fileName: String, inDirectory directoryName: String)
    -> URL?
{
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        .first!
    let directoryURL = documentsDirectory.appendingPathComponent(directoryName)
    do {
        try FileManager.default.createDirectory(
            at: directoryURL, withIntermediateDirectories: true, attributes: nil)
    } catch {
        errorLog("Error creating directory: \(error.localizedDescription)")
        return nil
    }
    let fileURL = directoryURL.appendingPathComponent(fileName)
    do {
        try data.write(to: fileURL)
        infoLog("Data saved to file: \(fileName)")
        return fileURL
    } catch {
        errorLog("Error saving data to file: \(error.localizedDescription)")
        return nil
    }
}

public func buildURLForFile(
    named fileName: String, inDirectory directoryName: String, format: RecordFormat
) -> URL {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        .first!
    let directoryURL = documentsDirectory.appendingPathComponent(directoryName)
    let fileURL = directoryURL.appendingPathComponent("\(fileName).\(format.fileExtension)")
    return fileURL
}

/// build the url for a audio file.
public func buildURLForAudio(named fileName: String, format: RecordFormat) -> URL {
    buildURLForFile(named: fileName, inDirectory: "audio", format: format)
}

enum SaveAudioError: String, LocalizedError {
    case convertToAudioPcmBuffer

    var errorDescription: String? {
        self.rawValue
    }
}

/// save audio buffer to disk and return the id of the file.
/// use `buildURLForAudio(named:)` to get the url of the file
public func saveAudioBufferToDisk(name: String, buf: StreamAudioBuffer, format: RecordFormat) throws
    -> String
{
    switch format {
    case .pcm:
        let buffer = try listOfPCMBytesToSingleAVAudioPCMBuffer(pcmDataList: buf.datas)
        return try saveAudioBufferToDisk(name: name, buf: buffer)
    case .aac, .opus:
        let url = buildURLForAudio(named: name, format: format)
        try createDirectoryForAudio(url: url)
        FileManager.default.createFile(atPath: url.path(), contents: nil)
        let file = try FileHandle(forWritingTo: url)
        defer {
            file.closeFile()
        }
        for data in buf.datas {
            try file.write(contentsOf: data)
        }
        return name
    }
}

private func createDirectoryForAudio(url: URL) throws {
    do {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
    } catch {
        errorLog("Error creating directory: \(error.localizedDescription)")
        throw error
    }
}

/// save audio buffer to disk and return the id of the file.
/// use `buildURLForAudio(named:)` to get the url of the file
public func saveAudioBufferToDisk(name: String, buf: AVAudioPCMBuffer) throws -> String {
    let url = buildURLForAudio(named: name, format: .pcm)
    try createDirectoryForAudio(url: url)
    try normalizeVolume(audioBuffer: buf)
    writeAVAudioPCMBufferToWavFile(buffer: buf, fileURL: url)
    return name
}

public func mergeMP3Files(audioFileUrls: [URL], outputUrl: URL) async throws {
    let composition = AVMutableComposition()
    var currentTime = CMTime.zero

    for fileUrl in audioFileUrls {
        let asset = AVAsset(url: fileUrl)

        //        infoLog("file Url: \(fileUrl)")
        guard let track = try await asset.loadTracks(withMediaType: .audio).first else {
            throw MessageError("Could not get audio track from asset: \(fileUrl)")
        }

        let compositionTrack: AVMutableCompositionTrack
        if let existingTrack = composition.tracks(withMediaType: .audio).first {
            compositionTrack = existingTrack
        } else {
            guard
                let newTrack = composition.addMutableTrack(
                    withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            else {
                throw MessageError("Could not create new composition track")
            }
            compositionTrack = newTrack
        }

        try await compositionTrack.insertTimeRange(
            track.load(.timeRange), of: track, at: currentTime)

        currentTime = await CMTimeAdd(currentTime, try track.load(.timeRange).duration)
    }

    guard
        let exportSession = AVAssetExportSession(
            asset: composition, presetName: AVAssetExportPresetAppleM4A)
    else {
        throw MessageError("Could not create export session")
    }

    exportSession.outputURL = outputUrl
    exportSession.outputFileType = .m4a

    await exportSession.export()
    switch exportSession.status {
    case .completed:
        return
    default:
        throw MessageError("Export error: \(exportSession.error?.localizedDescription ?? "")")
    }
}
