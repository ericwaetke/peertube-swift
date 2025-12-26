//
//  PeerTubeSwiftApp.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 18.12.25.
//

import Dependencies
import Combine
import SwiftUI

import OSLog
import SQLiteData

@main
struct PeerTubeSwiftApp: App {
    let appState = AppState()
    
    init() {
      prepareDependencies {
          try! $0.bootstrapDatabase()
      }
    }

	var body: some Scene {
		WindowGroup {
			ContentViewOld()
				.environment(appState)
		}
	}
}
