//
//  AppState.swift
//  PeerTubeApp
//
//  Created on 2024-12-17.
//

import Combine
import Foundation
import PeerTubeSwift
import SwiftUI

// MARK: - Navigation Destination

enum NavigationDestination: Hashable {
	case instanceSelection
	case videoDetail(videoId: String)
	case channelDetail(channelId: String)
	case videoPlayer(video: VideoDetails)
	case search
	case settings
	case about
	case subscriptionManagement
}

// MARK: - App State

@MainActor
final class AppState: ObservableObject {
	// MARK: - Published Properties

	@Published var currentInstance: Instance?
	@Published var services: PeerTubeServices?
	@Published var navigationPath = NavigationPath()
	@Published var selectedTab: Tab = .browse
	@Published var isLoading = false
	@Published var error: Error?

	/// Subscription service for managing local channel subscriptions
	@Published var subscriptionService: SubscriptionService

	// MARK: - User Settings

	/// Auto-play videos when opened
	@Published var autoPlayVideos = true

	/// Default video quality preference
	@Published var defaultVideoQuality: VideoQuality = .auto

	/// Use WiFi only for streaming
	@Published var useWiFiOnly = false

	/// Enable notifications for subscriptions
	@Published var enableNotifications = true

	/// Color scheme preference
	@Published var colorScheme: ColorScheme?

	// MARK: - Private Properties

	private let userDefaults = UserDefaults.standard
	private static let currentInstanceKey = "CurrentInstance"
	private static let defaultInstanceURL = "https://framatube.org"

	// MARK: - Initialization

	init() {
		// Initialize subscription service
		subscriptionService = SubscriptionService()

		AppStateProvider.shared.setAppState(self)
		loadSettings()
		loadSavedInstance()

		// Set up subscription service reference
		subscriptionService.setAppState(self)
	}

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
		case browse = "Browse"
		case subscriptions = "Subscriptions"
		case settings = "Settings"

		var systemImage: String {
			switch self {
			case .browse:
				return "play.tv"
			case .subscriptions:
				return "heart"
			case .settings:
				return "gear"
			}
		}
	}

	func selectTab(_ tab: Tab) {
		selectedTab = tab
		// Reset navigation when switching tabs
		resetNavigation()
	}

	// MARK: - Instance Management

	func setInstance(_ instance: Instance) {
		currentInstance = instance
		services = PeerTubeServices(instanceURL: instance.url)
		saveCurrentInstance()

		// Update subscription service with new services
		subscriptionService.setAppState(self)
	}

	func setInstanceURL(_ urlString: String) async throws {
		guard let url = URL(string: urlString) else {
			throw AppError.invalidURL
		}

		isLoading = true
		error = nil

		do {
			let services = PeerTubeServices(instanceURL: url)
			let instanceInfo = try await services.instance.getBasicInfo()

			// Create Instance object from basic info
			let instance = Instance(
				host: url.host ?? url.absoluteString,
				name: instanceInfo.name,
				shortDescription: instanceInfo.description,
				version: instanceInfo.version,
				signupAllowed: instanceInfo.isSignupAllowed,
				totalUsers: instanceInfo.userCount,
				totalVideos: instanceInfo.videoCount
			)

			await MainActor.run {
				self.currentInstance = instance
				self.services = services
				self.isLoading = false
				saveCurrentInstance()

				// Update subscription service with new services
				subscriptionService.setAppState(self)
			}
		} catch {
			await MainActor.run {
				self.error = error
				self.isLoading = false
			}
			throw error
		}
	}

	private func loadSavedInstance() {
		if let savedURLString = userDefaults.string(forKey: Self.currentInstanceKey),
			let url = URL(string: savedURLString)
		{
			// Try to load the saved instance
			Task {
				try? await setInstanceURL(savedURLString)
			}
		} else {
			// Load default instance
			Task {
				try? await setInstanceURL(Self.defaultInstanceURL)
			}
		}
	}

	private func saveCurrentInstance() {
		if let instance = currentInstance {
			userDefaults.set(instance.baseURL?.absoluteString, forKey: Self.currentInstanceKey)
		}
	}

	// MARK: - Error Handling

	func clearError() {
		error = nil
	}

	func handleError(_ error: Error) {
		self.error = error
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
	var hasServices: Bool {
		services != nil
	}

	/// Convenience method to get the current instance name
	var instanceName: String {
		currentInstance?.name ?? "Unknown Instance"
	}

	/// Convenience method to get the current instance URL
	var instanceURL: String {
		currentInstance?.baseURL?.absoluteString ?? ""
	}

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
