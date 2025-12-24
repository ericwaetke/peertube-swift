//
//  AppState.swift
//  PeerTubeApp
//
//  Created on 2024-12-17.
//

import SQLiteData
import Dependencies
import Combine
import Foundation
import SwiftUI
import TubeSDK
import Observation

// MARK: - Navigation Destination

enum NavigationDestination: Hashable {
    case instanceSelection
    case videoDetail(host: String, videoId: String)
    case channelDetail(channelId: String)
    case videoPlayer(video: String)
    case search
    case settings
    case about
    case subscriptionManagement
}

// MARK: - App State

@Observable
final class AppState {
    // MARK: - Published Properties
    
//    var client: TubeSDKClient
    
    //	var currentInstance: Instance?
    var navigationPath = NavigationPath()
    var selectedTab: Tab = .browse
    var isLoading = false
    var error: Error?
    @ObservationIgnored @Dependency(\.defaultDatabase) var database
    
    /// Subscription service for managing local channel subscriptions
    //	var subscriptionService: SubscriptionService
    
    // MARK: - User Settings
    
    /// Auto-play videos when opened
    var autoPlayVideos = true
    
    /// Default video quality preference
    var defaultVideoQuality: VideoQuality = .auto
    
    /// Use WiFi only for streaming
    var useWiFiOnly = false
    
    /// Enable notifications for subscriptions
    var enableNotifications = true
    
    /// Color scheme preference
    var colorScheme: ColorScheme?
    
    // MARK: - Private Properties
    
    private let userDefaults = UserDefaults.standard
    public var instances: [String: TubeSDKClient] = [:]
    private static let currentInstanceKey = "CurrentInstance"
    private static let defaultInstanceURL = "https://peertube.wtf"
    
    // MARK: - Initialization
    
    init() {
    }
    
    // Initialiser for Example State

    
    // MARK: - Navigation
    
    func navigateTo(_ destination: NavigationDestination) {
        navigationPath.append(destination)
    }
    
    func navigateBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    func resetNavigation() {
        navigationPath = NavigationPath()
    }
    
    // MARK: - Tab Selection
    
    enum Tab: String, CaseIterable {
        case browse = "Explore"
        case subscriptions = "Feed"
        case settings = "Settings"
        case search = "Search"
        
        var systemImage: String {
            switch self {
            case .browse:
                return "play.tv"
            case .subscriptions:
                return "heart"
            case .settings:
                return "gear"
            case .search:
                return "magnifyingglass"
            }
        }
    }
    
    func selectTab(_ tab: Tab) {
        selectedTab = tab
        // Reset navigation when switching tabs
        resetNavigation()
    }
    
    
    func addInstance(scheme: String, host: String) async throws {
        instances[host] = try TubeSDKClient(scheme: scheme, host: host)
        
        withErrorReporting {
            try database.write { db in
                try Instance
                    .insert { Instance.Draft(scheme: scheme, host: host) }
                    .execute(db)
            }
        }
    }
    
    public func searchVideo(urlString: String) async throws {
        let url = URL(string: urlString)
        
        guard let url = url else {
            throw URLError(.badURL)
        }
        
        guard let scheme = url.scheme,
              let host = url.host() else {
            throw ClientError.instanceNotFound
        }
        
        try await addInstance(scheme: scheme, host: host)
        
        // Potential URL: https://peertube.wtf/w/18QZB6GTN1DRd1LtkeQm22
        let pathParts = url.pathComponents
        
        if (pathParts.count < 3) {
            print("URL doesnt seem valid, not more than two parts")
            throw URLError(.badURL)
        }
        
        let  videoId = pathParts[2]
        
        if (videoId.count != 22) {
            print("Video ID not the correct length of 22: \(videoId)")
            throw URLError(.badURL)
        }
        
        selectTab(.browse)
        navigateTo(.videoDetail(host: host, videoId: videoId))
    }
}

// MARK: - App Errors

enum AppError: LocalizedError {
    case invalidURL
    case noInstanceSelected
    case servicesUnavailable
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL provided"
        case .noInstanceSelected:
            return "No PeerTube instance selected"
        case .servicesUnavailable:
            return "PeerTube services are not available"
        }
    }
}

// MARK: - Extensions

extension AppState {
    /// Convenience method to check if services are available
    //	var hasServices: Bool {
    //		services != nil
    //	}
    //
    //	/// Convenience method to get the current instance name
    //	var instanceName: String {
    //		currentInstance?.name ?? "Unknown Instance"
    //	}
    //
    //	/// Convenience method to get the current instance URL
    //	var instanceURL: String {
    //		currentInstance?.baseURL?.absoluteString ?? ""
    //	}
    
    // MARK: - Settings Management
    
    /// Save user settings to UserDefaults
    func saveSettings() {
        userDefaults.set(autoPlayVideos, forKey: "autoPlayVideos")
        userDefaults.set(defaultVideoQuality.rawValue, forKey: "defaultVideoQuality")
        userDefaults.set(useWiFiOnly, forKey: "useWiFiOnly")
        userDefaults.set(enableNotifications, forKey: "enableNotifications")
        if let colorScheme = colorScheme {
            userDefaults.set(colorScheme.rawValue, forKey: "colorScheme")
        } else {
            userDefaults.removeObject(forKey: "colorScheme")
        }
    }
    
    /// Load user settings from UserDefaults
    private func loadSettings() {
        autoPlayVideos = userDefaults.bool(forKey: "autoPlayVideos")
        if userDefaults.object(forKey: "autoPlayVideos") == nil {
            autoPlayVideos = true  // Default value
        }
        
        if let qualityRaw = userDefaults.object(forKey: "defaultVideoQuality") as? String,
           let quality = VideoQuality(rawValue: qualityRaw)
        {
            defaultVideoQuality = quality
        }
        
        useWiFiOnly = userDefaults.bool(forKey: "useWiFiOnly")
        enableNotifications = userDefaults.bool(forKey: "enableNotifications")
        
        if let schemeRaw = userDefaults.object(forKey: "colorScheme") as? String,
           let scheme = ColorScheme(rawValue: schemeRaw)
        {
            colorScheme = scheme
        }
    }
}

// MARK: - Supporting Types

/// Video quality preference options
public enum VideoQuality: String, CaseIterable {
    case auto
    case low = "240p"
    case medium = "480p"
    case high = "720p"
    case veryHigh = "1080p"
    
    var displayName: String {
        switch self {
        case .auto:
            return "Auto (Recommended)"
        case .low:
            return "240p (Data Saver)"
        case .medium:
            return "480p (Standard)"
        case .high:
            return "720p (HD)"
        case .veryHigh:
            return "1080p (Full HD)"
        }
    }
    
    /// Get the maximum resolution for this quality preference
    public var maxResolution: Int {
        switch self {
        case .auto: return Int.max
        case .low: return 240
        case .medium: return 480
        case .high: return 720
        case .veryHigh: return 1080
        }
    }
    
    /// Get recommended minimum bandwidth for this quality
    public var recommendedBandwidth: Double {
        switch self {
        case .auto: return 0
        case .low: return 1.5  // 1.5 Mbps for 240p
        case .medium: return 3  // 3 Mbps for 480p
        case .high: return 5  // 5 Mbps for 720p
        case .veryHigh: return 8  // 8 Mbps for 1080p
        }
    }
}

extension ColorScheme {
    var rawValue: String {
        switch self {
        case .light:
            return "light"
        case .dark:
            return "dark"
        @unknown default:
            return "light"
        }
    }
    
    init?(rawValue: String) {
        switch rawValue {
        case "light":
            self = .light
        case "dark":
            self = .dark
        default:
            return nil
        }
    }
}

extension AppState {
//    static var example: AppState = AppState(example: true)
}
