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
import BackgroundTasks
import UserNotifications
import TubeSDK

import OSLog
import SQLiteData

@main
struct PeerTubeSwiftApp: App {
    @Environment(\.scenePhase) var scenePhase

    static let store = Store(initialState: AppFeature.State(), reducer: {
        AppFeature()
    })

    init() {
      prepareDependencies {
          try! $0.bootstrapDatabase()
      }
    }

	var body: some Scene {
		WindowGroup {
            ContentView(store: PeerTubeSwiftApp.store)
		}
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                scheduleAppRefresh()
            }
        }
        .backgroundTask(.appRefresh("com.peertubeswift.refresh")) {
            await handleAppRefresh()
        }
	}
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.peertubeswift.refresh")
        // Fetch somewhat frequently, but let the system decide
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Successfully scheduled background task")
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    func handleAppRefresh() async {
        scheduleAppRefresh()
        
        @Dependency(\.defaultDatabase) var database
        
        // 1. Get all subscriptions that have notifyOnNewVideo == true
        do {
            let subscriptionsToNotify = try await database.read { db in
                try PeertubeSubscription
                    .where { $0.notifyOnNewVideo == true }
                    .fetchAll(db)
            }
            
            if subscriptionsToNotify.isEmpty {
                return
            }
            
            let client = try! TubeSDKClient(scheme: "https", host: "peertube.wtf")
            
            for sub in subscriptionsToNotify {
                let channelId = sub.channelID
                // Get latest videos for this channel
                if let videos = try? await client.getVideos(channelIdentifier: channelId) {
                    for video in videos {
                        guard let videoId = video.uuid,
                              let videoName = video.name,
                              let channelName = video.channel?.displayName ?? video.channel?.name else {
                            continue
                        }
                        
                        // Check if we already have this video
                        let isNew = try await database.read { db in
                            try Video.find(videoId).fetchOne(db) == nil
                        }
                        
                        if isNew {
                            // Trigger local notification
                            let content = UNMutableNotificationContent()
                            content.title = "New Video from \(channelName)"
                            content.body = videoName
                            content.sound = .default
                            
                            let request = UNNotificationRequest(identifier: videoId.uuidString, content: content, trigger: nil)
                            try? await UNUserNotificationCenter.current().add(request)
                            
                            // We do not save it here so the app will download it and save it properly
                            // when the user opens the feed again.
                        }
                    }
                }
            }
        } catch {
            print("Background fetch failed: \(error)")
        }
    }
}
