//
//  PeerTubeSwiftApp.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 18.12.25.
//

import BackgroundTasks
import Combine
import ComposableArchitecture
import Dependencies
@_spi(Experimental) import PostHog
import SwiftUI
import TubeSDK
import UserNotifications

import OSLog
import SQLiteData

enum Configuration {
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }

    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            throw Error.missingKey
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
}

@main
struct PeerTubeSwiftApp: App {
    @Environment(\.scenePhase) var scenePhase

    static let store = Store(initialState: AppFeature.State(), reducer: {
        AppFeature()
    })

    init() {
        guard let apiKey: String = try? Configuration.value(for: "POSTHOG_PROJECT_TOKEN") else {
            fatalError("Set POSTHOG_PROJECT_TOKEN in the Xcode scheme environment variables.")
        }
        guard let host: String = try? Configuration.value(for: "POSTHOG_HOST") else {
            fatalError("Set POSTHOG_HOST in the Xcode scheme environment variables.")
        }
        guard let url = URL(string: "https://" + host) else {
            fatalError("Set POSTHOG_HOST in the Xcode scheme environment variables.")
        }
        print(apiKey)
        print(url.absoluteString)
        let config = PostHogConfig(apiKey: apiKey, host: url.absoluteString)
        config.captureApplicationLifecycleEvents = true
        config.errorTrackingConfig.autoCapture = true
        print(config)
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
        .onChange(of: scenePhase) { _, newPhase in
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
                              let channelName = video.channel?.displayName ?? video.channel?.name
                        else {
                            continue
                        }

                        // Try to insert video - if duplicate, it already exists so skip notification
                        do {
                            _ = try await database.write { db in
                                try Video.insert {
                                    Video(
                                        id: videoId,
                                        channelID: channelId,
                                        instanceID: channel.instanceID,
                                        name: videoName,
                                        publishDate: video.publishedAt ?? Date()
                                    )
                                }
                                .execute(db)
                            }

                            // Insert succeeded - video is new, trigger notification
                            let content = UNMutableNotificationContent()
                            content.title = "New Video from \(channelName)"
                            content.body = videoName
                            content.sound = .default

                            let request = UNNotificationRequest(identifier: videoId.uuidString, content: content, trigger: nil)
                            try? await UNUserNotificationCenter.current().add(request)
                        } catch {
                            // Video already exists - no notification needed
                            print("Video \(videoId) already exists, skipping notification")
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
