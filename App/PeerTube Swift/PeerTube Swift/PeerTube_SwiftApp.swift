//
//  PeerTube_SwiftApp.swift
//  PeerTube Swift
//
//  Created by Eric Wätke on 18.12.25.
//

import CoreData
import SwiftUI

@main
struct PeerTube_SwiftApp: App {
	//    let persistenceController = PersistenceController.shared
	//
	//    var body: some Scene {
	//        WindowGroup {
	//            ContentView()
	//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
	//        }
	//    }

	@StateObject private var appState = AppState()

	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(appState)
		}
	}
}
