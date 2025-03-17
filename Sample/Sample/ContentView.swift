//
//  ContentView.swift
//  Sample
//
//  Created by feichao on 2025/3/9.
//

import AVKit
import SwiftUI
import TalkerAudio

struct ContentView: View {
    @State var recorder = StreamAudioRecorder()
    @State var isRunning = false
    @State var buf = StreamAudioBuffer()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)

            if !isRunning {
                Button("Start Recording") {
                    start()
                }
            } else {
                Button("Stop Recording") {
                    do {
                        try recorder.stop()
                        saveToFile()
                        isRunning = false
                    } catch {
                        print("Failed to stop recording: \(error)")
                    }
                }
            }

            if !buf.isEmpty {
                Button("Save to File") {
                    saveToFile()
                }
            }
        }
        .padding()
        .onAppear {
            recorder.audioInputMoreDataBlock = onRecordingData(_:)
        }
    }

    func saveToFile() {
//        do {
//            let path = try saveAudioBufferToDisk(name: UUID().uuidString, buf: buf)
//            print("Saved audio buffer to: \(path)")
//        } catch {
//            print("Failed to save audio buffer: \(error)")
//        }

        let url = buildURLForAudio(named: UUID().uuidString, extension: "aac")
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(), withIntermediateDirectories: true,
                attributes: nil)
        } catch {
            print("Error creating directory: \(error.localizedDescription)")
        }
        let path = url.path()
        print("path: \(path)")
        // 创建文件
        FileManager.default.createFile(atPath: path, contents: nil)

        // 打开文件
        guard let fileHandle = FileHandle(forWritingAtPath: path) else {
            print("Failed to open file")
            return
        }

        defer {
            // 确保文件最后被关闭
            try? fileHandle.close()
        }

        do {
            for data in buf.datas {
                // 写入数据
                try fileHandle.write(contentsOf: data)
            }
        } catch {
            print("write error: \(error)")
        }
    }

    func start() {
        do {
            try recorder.start(format: .aac(bitRate: 16000))
            isRunning = true
        } catch {
            print("Failed to start recording: \(error)")
        }
    }

    func onRecordingData(_ data: Data) {
        print("onRecordingData: \(data.count)")
        buf.appendBytes(bytes: data)
    }
}

#Preview {
    ContentView()
}
