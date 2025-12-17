//
//  PeerTubeApp.swift
//  PeerTubeApp
//
//  Created on 2024-12-17.
//

import PeerTubeSwift
import SwiftUI

@main
struct PeerTubeApp: App {

	// MARK: - Properties

	@StateObject private var appState = AppState()

	// MARK: - Body

	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(appState)
				.preferredColorScheme(appState.colorScheme)
				.onAppear {
					setupApp()
				}
		}
	}

	// MARK: - Setup

	private func setupApp() {
		// Configure default instance if none selected
		if appState.currentInstance == nil {
			Task {
				await appState.setDefaultInstance()
			}
		}
	}
}

/// Global app state management
@MainActor
final class AppState: ObservableObject {

	// MARK: - Published Properties

	@Published var currentInstance: InstanceSummary?
	@Published var services: PeerTubeServices?
	@Published var isAuthenticated = false
	@Published var colorScheme: ColorScheme?
	@Published var selectedTab: MainTab = .browse
	@Published var isLoading = false
	@Published var error: Error?

	// MARK: - Navigation State

	@Published var navigationPath = NavigationPath()

	// MARK: - Settings

	@Published var autoPlayVideos = true
	@Published var useWiFiOnly = false
	@Published var defaultVideoQuality: VideoQuality = .auto
	@Published var enableNotifications = true

	// MARK: - Initialization

	init() {
		loadSettings()
	}

	// MARK: - Instance Management

	func setCurrentInstance(_ instance: InstanceSummary) async {
		currentInstance = instance

		// Create services for this instance
		if let instanceURL = instance.baseURL {
			services = PeerTubeServices(instanceURL: instanceURL)
		}

		// Save to UserDefaults
		saveCurrentInstance()

		// Check authentication status
		await checkAuthenticationStatus()
	}

	func setDefaultInstance() async {
		// Set a default PeerTube instance for testing/demo
		let defaultInstance = InstanceSummary(
			id: UUID(),
			host: "framatube.org",
			name: "Framatube",
			isDefault: true
		)

		await setCurrentInstance(defaultInstance)
	}

	func checkAuthenticationStatus() async {
		guard let services = services else {
			isAuthenticated = false
			return
		}

		isAuthenticated = await services.isAuthenticated()
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

	// MARK: - Settings Management

	private func loadSettings() {
		autoPlayVideos = UserDefaults.standard.bool(forKey: "autoPlayVideos")
		useWiFiOnly = UserDefaults.standard.bool(forKey: "useWiFiOnly")
		enableNotifications = UserDefaults.standard.bool(forKey: "enableNotifications")

		if let qualityRaw = UserDefaults.standard.object(forKey: "defaultVideoQuality") as? String,
			let quality = VideoQuality(rawValue: qualityRaw)
		{
			defaultVideoQuality = quality
		}

		if let schemeRaw = UserDefaults.standard.object(forKey: "colorScheme") as? String {
			switch schemeRaw {
			case "light":
				colorScheme = .light
			case "dark":
				colorScheme = .dark
			default:
				colorScheme = nil
			}
		}

		loadCurrentInstance()
	}

	func saveSettings() {
		UserDefaults.standard.set(autoPlayVideos, forKey: "autoPlayVideos")
		UserDefaults.standard.set(useWiFiOnly, forKey: "useWiFiOnly")
		UserDefaults.standard.set(enableNotifications, forKey: "enableNotifications")
		UserDefaults.standard.set(defaultVideoQuality.rawValue, forKey: "defaultVideoQuality")

		let schemeString: String
		switch colorScheme {
		case .light:
			schemeString = "light"
		case .dark:
			schemeString = "dark"
		case nil:
			schemeString = "auto"
		}
		UserDefaults.standard.set(schemeString, forKey: "colorScheme")
	}

	private func loadCurrentInstance() {
		guard let data = UserDefaults.standard.data(forKey: "currentInstance"),
			let instance = try? JSONDecoder().decode(InstanceSummary.self, from: data)
		else {
			return
		}

		Task {
			await setCurrentInstance(instance)
		}
	}

	private func saveCurrentInstance() {
		guard let instance = currentInstance,
			let data = try? JSONEncoder().encode(instance)
		else {
			return
		}

		UserDefaults.standard.set(data, forKey: "currentInstance")
	}
}

// MARK: - Supporting Types

enum MainTab: String, CaseIterable {
	case browse = "Browse"
	case subscriptions = "Subscriptions"
	case settings = "Settings"

	var systemImage: String {
		switch self {
		case .browse:
			return "globe"
		case .subscriptions:
			return "heart"
		case .settings:
			return "gear"
		}
	}

	var title: String {
		return rawValue
	}
}

enum NavigationDestination: Hashable {
	case videoDetail(videoId: String)
	case channelDetail(channelId: String)
	case instanceSelection
	case about
	case videoPlayer(video: VideoDetails)

	var title: String {
		switch self {
		case .videoDetail:
			return "Video"
		case .channelDetail:
			return "Channel"
		case .instanceSelection:
			return "Select Instance"
		case .about:
			return "About"
		case .videoPlayer:
			return "Player"
		}
	}
}

enum VideoQuality: String, CaseIterable {
	case auto = "auto"
	case low = "480"
	case medium = "720"
	case high = "1080"
	case ultra = "2160"

	var displayName: String {
		switch self {
		case .auto:
			return "Auto"
		case .low:
			return "480p"
		case .medium:
			return "720p"
		case .high:
			return "1080p"
		case .ultra:
			return "4K"
		}
	}

	var resolution: Int? {
		switch self {
		case .auto:
			return nil
		case .low:
			return 480
		case .medium:
			return 720
		case .high:
			return 1080
		case .ultra:
			return 2160
		}
	}
}
