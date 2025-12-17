//
//  AppState.swift
//  PeerTubeApp
//
//  Created on 2024-12-17.
//

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

	// MARK: - Private Properties

	private let userDefaults = UserDefaults.standard
	private static let currentInstanceKey = "CurrentInstance"
	private static let defaultInstanceURL = "https://framatube.org"

	// MARK: - Initialization

	init() {
		AppStateProvider.shared.setAppState(self)
		loadSavedInstance()
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
		self.currentInstance = instance
		self.services = PeerTubeServices(instanceURL: instance.url)
		saveCurrentInstance()
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
}
