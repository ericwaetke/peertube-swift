//
//  PeerTubeApp.swift
//  PeerTubeApp
//
//  Created on 2024-12-17.
//

import SwiftUI

@main
struct PeerTubeApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
