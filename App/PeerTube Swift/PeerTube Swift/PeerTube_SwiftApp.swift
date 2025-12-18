//
//  PeerTube_SwiftApp.swift
//  PeerTube Swift
//
//  Created by Eric Wätke on 18.12.25.
//

import SwiftUI
import CoreData

@main
struct PeerTube_SwiftApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
