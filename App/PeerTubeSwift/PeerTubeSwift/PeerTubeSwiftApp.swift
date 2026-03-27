//
//  PeerTubeSwiftApp.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 18.12.25.
//

import ComposableArchitecture
import Dependencies
import Combine
import PostHog
import SwiftUI
import BackgroundTasks
import UserNotifications
import TubeSDK

import OSLog
import SQLiteData

enum PostHogEnv: String {
    case apiKey = "POSTHOG_PROJECT_TOKEN"
    case host = "POSTHOG_HOST"
    var value: String {
        guard let value = ProcessInfo.processInfo.environment[rawValue] else {
            fatalError("Set \(rawValue) in the Xcode scheme environment variables.")
        }
        return value
    }
}

@main
struct PeerTubeSwiftApp: App {
    @Environment(\.scenePhase) var scenePhase

    static let store = Store(initialState: AppFeature.State(), reducer: {
        AppFeature()
    })

    init() {
      let config = PostHogConfig(apiKey: PostHogEnv.apiKey.value, host: PostHogEnv.host.value)
      config.captureApplicationLifecycleEvents = true
      PostHogSDK.shared.setup(config)

      prepareDependencies {
          try! $0.bootstrapDatabase()
      }
      
      BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.peertubeswift.refresh", using: nil) { task in
          let refreshTask = Task {
              await Self.handleAppRefresh()
              task.setTaskCompleted(success: true)
          }
          task.expirationHandler = {
              refreshTask.cancel()
          }
      }
    }

	var body: some Scene {
		WindowGroup {
            ContentView(store: PeerTubeSwiftApp.store)
		}
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                Self.scheduleAppRefresh()
            }
        }
	}
    
    static func scheduleAppRefresh() {
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
    
    static func handleAppRefresh() async {
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
            
            for sub in subscriptionsToNotify {
                let channelId = sub.channelID
                
                // Fetch the channel to get its instance ID
                guard let channel = try? await database.read({ db in
                    try VideoChannel.find(channelId).fetchOne(db)
                }) else {
                    print("Could not find channel \(channelId) in database")
                    continue
                }
                
                guard let client = try? TubeSDKClient(scheme: "https", host: channel.instanceID) else {
                    print("Could not initialize client for host \(channel.instanceID)")
                    continue
                }
                
                print("Fetching videos for channel \(channelId) on \(channel.instanceID)")
                // Get latest videos for this channel
                do {
                    let videos = try await client.getVideos(channelIdentifier: channelId)
                    print("Found \(videos.count) videos for \(channelId)")
                    
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
                        
                        print("Video \(videoId) (\(videoName)) - isNew: \(isNew)")
                        
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
                } catch {
                    print("Failed to fetch videos for \(channelId): \(error)")
                }
            }
        } catch {
            print("Background fetch failed: \(error)")
        }
    }
}
