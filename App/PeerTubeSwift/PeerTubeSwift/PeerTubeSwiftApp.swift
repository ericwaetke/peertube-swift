//
//  PeerTubeSwiftApp.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 18.12.25.
//

import Combine
import SwiftUI

@main
struct PeerTubeSwiftApp: App {
//	@StateObject private var appState = AppState()
    let appState = AppState()

	var body: some Scene {
		WindowGroup {
			ContentView()
				.environment(appState)
		}
	}
}
