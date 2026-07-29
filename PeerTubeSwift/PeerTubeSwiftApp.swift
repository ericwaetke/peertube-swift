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
import FontKit
import OSLog
import SQLiteData
import SwiftUI
import TubeSDK
import UserNotifications

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
  enum AppRefreshTaskIdentifiers {
    static let appRefresh = "design.woven.PeerTubeSwift.refresh"
  }

  private static let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier!, category: "AppRefresh")
  private static var isAppRefreshScheduled = false

  @Environment(\.scenePhase) var scenePhase

  static let store = Store(
    initialState: AppFeature.State(),
    reducer: {
      AppFeature()
    })

  private let notificationDelegate = NotificationDelegate()

  init() {
    UNUserNotificationCenter.current().delegate = notificationDelegate

    prepareDependencies {
      try! $0.bootstrapDatabase()
    }

    BGTaskScheduler.shared.register(
      forTaskWithIdentifier: AppRefreshTaskIdentifiers.appRefresh,
      using: .main
    ) { task in
      let swiftTask = Task { @MainActor in
        PeerTubeSwiftApp.logger.info("Background app refresh started")
        let success = await Self.performSubscriptionRefresh()
        task.setTaskCompleted(success: success)
        task.expirationHandler = nil
      }
      task.expirationHandler = {
        PeerTubeSwiftApp.logger.warning("Background app refresh expired")
        swiftTask.cancel()
      }
    }
  }

  let font = UIFont(name: "FjallaOne-Regular", size: 34)

  var body: some Scene {
    WindowGroup {
      ContentView(store: PeerTubeSwiftApp.store)
        .onAppear {
          CustomFont.registerFonts([
            CustomFont.fjallaOne,
            CustomFont.inclusiveSansRegular,
            CustomFont.inclusiveSansItalic,
            CustomFont.inclusiveSansSemiBold,
            CustomFont.inclusiveSansSemiBoldItalic,
          ])
          UINavigationBar.appearance().largeTitleTextAttributes = [
            .font: UIFont(name: CustomFont.fjallaOne.name, size: 28)
              ?? .preferredFont(forTextStyle: .largeTitle)
          ]
          UINavigationBar.appearance().titleTextAttributes = [
            .font: UIFont(name: CustomFont.fjallaOne.name, size: 20)
              ?? .preferredFont(forTextStyle: .title3)
          ]

          //            TODO: DO NOT Request Notification Permissions here. Only when needed
          //          Task {
          //            let center = UNUserNotificationCenter.current()
          //
          //            do {
          //              try await center.requestAuthorization(options: [.alert, .sound, .badge])
          //            } catch {
          //              // Handle the error here.
          //            }
          //          }
        }
        .task {
          Self.scheduleAppRefresh()
        }
    }
  }

  static func scheduleAppRefresh() {
    guard !isAppRefreshScheduled else {
      logger.info("App refresh already scheduled, skipping")
      return
    }
    let request = BGAppRefreshTaskRequest(identifier: AppRefreshTaskIdentifiers.appRefresh)
    request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
    do {
      try BGTaskScheduler.shared.submit(request)
      isAppRefreshScheduled = true
      logger.info("Scheduled background app refresh")
    } catch {
      logger.error("Could not schedule app refresh: \(error.localizedDescription)")
    }
  }

  @discardableResult
  static func performSubscriptionRefresh() async -> Bool {
    @Dependency(\.defaultDatabase) var database
    logger.info("Subscription refresh starting")

    do {
      let subscriptionsToNotify = try await database.read { db in
        try PeertubeSubscription
          .where { $0.notifyOnNewVideo == true }
          .fetchAll(db)
      }

      if subscriptionsToNotify.isEmpty {
        logger.info("No subscriptions to notify")
        return true
      }

      for sub in subscriptionsToNotify {
        guard !Task.isCancelled else {
          logger.info("Background task cancelled, stopping refresh")
          return false
        }
        let channelId = sub.channelID

        // Fetch the channel to get its instance ID
        guard
          let channel = try? await database.read({ db in
            try VideoChannel.find(channelId).fetchOne(db)
          })
        else {
          logger.warning("Could not find channel \(channelId) in database")
          continue
        }

        guard let client = try? TubeSDKClient(scheme: "https", host: channel.instanceID) else {
          logger.error("Could not initialize client for host \(channel.instanceID)")
          continue
        }

        logger.info("Fetching videos for channel \(channelId) on \(channel.instanceID)")
        // Get latest videos for this channel
        do {
          let videos = try await client.getVideos(channelIdentifier: channelId)
          logger.info("Found \(videos.count) videos for \(channelId)")

          guard !Task.isCancelled else {
            logger.info("Background task cancelled, stopping refresh")
            return false
          }

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

              let request = UNNotificationRequest(
                identifier: videoId.uuidString, content: content, trigger: nil)
              try? await UNUserNotificationCenter.current().add(request)
            } catch {
              // Video already exists - no notification needed
              logger.debug("Video \(videoId) already exists, skipping notification")
            }
          }
        } catch {
          logger.error("Failed to fetch videos for \(channelId): \(error)")
        }
      }
      isAppRefreshScheduled = false
      scheduleAppRefresh()
      return true
    } catch {
      logger.error("Background fetch failed: \(error.localizedDescription)")
      isAppRefreshScheduled = false
      scheduleAppRefresh()
      return false
    }
  }
}

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
  func userNotificationCenter(
    _: UNUserNotificationCenter,
    willPresent _: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .sound, .badge])
  }
}
