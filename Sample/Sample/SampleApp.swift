//
//  SampleApp.swift
//  Sample
//
//  Created by feichao on 2025/3/9.
//

import SwiftUI
import AVKit

@main
struct SampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    try? AVAudioSession.sharedInstance().setCategory(.record, mode: .default, options: [])
                    try? AVAudioSession.sharedInstance().setActive(true)
                }
        }
    }
}
