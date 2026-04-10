//
//  NotificationHelpers.swift
//  PeerTubeSwift
//
//  Shared notification permission and persistence logic
//

import ComposableArchitecture
import Foundation
import SQLiteData
import UserNotifications

/// Result of checking notification permission
enum NotificationPermissionStatus {
    case allowed // Toggle allowed
    case denied // Show alert + link to settings
    case notDetermined // First time - request permission
}

/// Check notification permission status
func checkNotificationPermission() async -> NotificationPermissionStatus {
    let center = UNUserNotificationCenter.current()
    let settings = await center.notificationSettings()

    switch settings.authorizationStatus {
    case .notDetermined:
        return .notDetermined
    case .authorized, .provisional:
        return .allowed
    case .denied, .ephemeral:
        return .denied
    @unknown default:
        return .denied
    }
}

/// Request notification permission
func requestNotificationPermission() async -> Bool {
    (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])) != nil
}

/// Save notification preference to DB
@Sendable
func saveNotificationPreference(channelId: String, notify: Bool) async throws {
    @Dependency(\.defaultDatabase) var database
    try await database.write { db in
        try PeertubeSubscription
            .where { $0.channelID == channelId }
            .update { $0.notifyOnNewVideo = notify }
            .execute(db)
    }
}
