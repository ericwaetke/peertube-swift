//
//  PeerTubeSwiftApp.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 18.12.25.
//

import ComposableArchitecture
import Dependencies
import Combine
import SwiftUI

import OSLog
import SQLiteData

@main
struct PeerTubeSwiftApp: App {
    init() {
      prepareDependencies {
          try! $0.bootstrapDatabase()
      }
    }

	var body: some Scene {
		WindowGroup {
            ContentView(store: Store(initialState: AppFeature.State(), reducer: {
                AppFeature()
            }))
		}
	}
}
