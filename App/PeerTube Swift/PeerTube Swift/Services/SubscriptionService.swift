//
//  SubscriptionService.swift
//  PeerTubeApp
//
//  Created on 2024-12-17.
//

import Combine
import Foundation
import PeerTubeSwift

/// App-level subscription service that coordinates local subscriptions with PeerTube API
@MainActor
public final class SubscriptionService: ObservableObject {
	// MARK: - Properties

	private let repository: SubscriptionRepository
	private weak var appState: AppState?

	/// Published subscriptions for UI binding
	@Published public var subscriptions: [ChannelSubscription] = []

	/// Published subscription count
	@Published public var subscriptionCount: Int = 0

	/// Published loading state for UI feedback
	@Published public var isLoading = false

	/// Published error state
	@Published public var error: Error?

	// MARK: - Initialization

	public init(repository: SubscriptionRepository? = nil) {
		self.repository = repository ?? SubscriptionRepository()
		self.subscriptions = self.repository.getAllSubscriptions()
		self.subscriptionCount = self.repository.getSubscriptionCount()

		// Observe repository changes
		self.repository.$subscriptions
			.assign(to: &$subscriptions)

		self.repository.$subscriptionCount
			.assign(to: &$subscriptionCount)
	}

	/// Set the app state reference for API access
	public func setAppState(_ appState: AppState) {
		self.appState = appState
	}

	// MARK: - Subscription Management

	/// Subscribe to a channel
	/// - Parameter channel: The channel to subscribe to
	public func subscribe(to channel: VideoChannel) async {
		isLoading = true
		error = nil

		do {
			_ = try await repository.subscribe(to: channel)

			// Optionally update channel info from API if we have services
			if let services = appState?.services {
				await updateChannelInfo(channel.name, services: services)
			}

			print("Successfully subscribed to \(channel.effectiveDisplayName)")
		} catch {
			self.error = error
			print("Failed to subscribe to channel: \(error)")
		}

		isLoading = false
	}

	/// Unsubscribe from a channel
	/// - Parameter channelName: The channel name/handle
	public func unsubscribe(from channelName: String) async {
		isLoading = true
		error = nil

		do {
			try await repository.unsubscribe(from: channelName)
			print("Successfully unsubscribed from \(channelName)")
		} catch {
			self.error = error
			print("Failed to unsubscribe from channel: \(error)")
		}

		isLoading = false
	}

	/// Toggle subscription status
	/// - Parameter subscription: The subscription to toggle
	public func toggleSubscription(_ subscription: ChannelSubscription) async {
		do {
			try await repository.toggleSubscription(subscription.id)
		} catch {
			self.error = error
			print("Failed to toggle subscription: \(error)")
		}
	}

	// MARK: - Subscription Queries

	/// Check if subscribed to a channel
	/// - Parameter channelName: The channel name/handle
	/// - Returns: True if subscribed and enabled
	public func isSubscribed(to channelName: String) -> Bool {
		return repository.isSubscribed(to: channelName)
	}

	/// Get subscription for a channel
	/// - Parameter channelName: The channel name/handle
	/// - Returns: The subscription if it exists
	public func getSubscription(for channelName: String) -> ChannelSubscription? {
		return try? repository.getSubscription(for: channelName)
	}

	/// Get enabled subscriptions only
	/// - Returns: Array of enabled subscriptions
	public func getEnabledSubscriptions() -> [ChannelSubscription] {
		return repository.getEnabledSubscriptions()
	}

	// MARK: - Subscription Feed

	/// Get recent videos from all subscribed channels
	/// - Parameters:
	///   - limit: Maximum number of videos per channel (default: 5)
	///   - maxAge: Maximum age of videos in hours (default: 168 = 1 week)
	/// - Returns: Array of videos sorted by publication date
	public func getSubscriptionFeed(limit: Int = 5, maxAge: TimeInterval = 168 * 3600) async
		-> [Video]
	{
		guard let services = appState?.services else {
			print("No PeerTube services available for subscription feed")
			return []
		}

		let enabledSubscriptions = getEnabledSubscriptions()
		guard !enabledSubscriptions.isEmpty else {
			return []
		}

		isLoading = true
		var allVideos: [Video] = []

		// Fetch videos from each subscribed channel
		await withTaskGroup(of: [Video].self) { group in
			for subscription in enabledSubscriptions {
				group.addTask {
					do {
						let parameters = VideoListParameters(
							start: 0,
							count: limit,
							sort: .publishedAt
						)
						let response = try await services.videos.getChannelVideos(
							channelHandle: subscription.channel.name,
							parameters: parameters
						)

						// Filter by age
						let cutoffDate = Date().addingTimeInterval(-maxAge)
						return response.data.filter { video in
							(video.publishedAt ?? video.createdAt) > cutoffDate
						}
					} catch {
						print("Failed to fetch videos for \(subscription.channel.name): \(error)")
						return []
					}
				}
			}

			for await videos in group {
				allVideos.append(contentsOf: videos)
			}
		}

		// Sort by publication date (newest first)
		allVideos.sort { lhs, rhs in
			let lhsDate = lhs.publishedAt ?? lhs.createdAt
			let rhsDate = rhs.publishedAt ?? rhs.createdAt
			return lhsDate > rhsDate
		}

		// Cache video metadata for faster future loading
		await cacheVideoMetadata(allVideos)

		isLoading = false
		return allVideos
	}

	/// Refresh all subscription data from API
	public func refreshAllSubscriptions() async {
		guard let services = appState?.services else {
			print("No PeerTube services available for refresh")
			return
		}

		isLoading = true
		error = nil

		let enabledSubscriptions = getEnabledSubscriptions()

		await withTaskGroup(of: Void.self) { group in
			for subscription in enabledSubscriptions {
				group.addTask {
					await self.updateChannelInfo(subscription.channel.name, services: services)
				}
			}
		}

		isLoading = false
	}

	// MARK: - Data Management

	/// Clear error state
	public func clearError() {
		error = nil
	}

	/// Import subscriptions from a list (for migration/backup restore)
	/// - Parameter channels: Array of channels to subscribe to
	public func importSubscriptions(_ channels: [VideoChannel]) async {
		isLoading = true

		for channel in channels {
			do {
				_ = try await repository.subscribe(to: channel)
			} catch {
				print("Failed to import subscription for \(channel.name): \(error)")
			}
		}

		isLoading = false
	}

	/// Export subscriptions for backup
	/// - Returns: Array of subscribed channels
	public func exportSubscriptions() -> [VideoChannel] {
		return subscriptions.map { $0.channel }
	}

	/// Clear all subscriptions (for testing or reset)
	public func clearAllSubscriptions() async {
		do {
			try await repository.clearAllSubscriptions()
		} catch {
			self.error = error
			print("Failed to clear subscriptions: \(error)")
		}
	}

	// MARK: - Private Methods

	private func updateChannelInfo(_ channelName: String, services: PeerTubeServices) async {
		do {
			let updatedChannel = try await services.channels.getChannel(handle: channelName)
			try await repository.updateChannel(updatedChannel)
		} catch {
			print("Failed to update channel info for \(channelName): \(error)")
		}
	}

	private func cacheVideoMetadata(_ videos: [Video]) async {
		// Group videos by channel
		let videosByChannel = Dictionary(grouping: videos) { $0.channel.name }

		for (channelName, channelVideos) in videosByChannel {
			do {
				try await repository.cacheVideos(channelVideos, for: channelName)
			} catch {
				print("Failed to cache videos for \(channelName): \(error)")
			}
		}
	}
}

// MARK: - Convenience Extensions

extension SubscriptionService {
	/// Subscribe to a channel by name (fetches channel info first)
	/// - Parameter channelName: The channel name/handle
	public func subscribe(to channelName: String) async {
		guard let services = appState?.services else {
			error = SubscriptionServiceError.noServicesAvailable
			return
		}

		isLoading = true
		error = nil

		do {
			let channel = try await services.channels.getChannel(handle: channelName)
			await subscribe(to: channel)
		} catch {
			self.error = error
			print("Failed to fetch channel info for \(channelName): \(error)")
		}

		isLoading = false
	}

	/// Get subscription status for UI binding
	/// - Parameter channelName: The channel name
	/// - Returns: Subscription status
	public func getSubscriptionStatus(for channelName: String) -> SubscriptionStatus {
		if let subscription = getSubscription(for: channelName) {
			return subscription.isNotificationEnabled ? .subscribed : .disabled
		}
		return .notSubscribed
	}
}

// MARK: - Supporting Types

/// Subscription status for UI
public enum SubscriptionStatus {
	case notSubscribed
	case subscribed
	case disabled

	public var isSubscribed: Bool {
		switch self {
		case .subscribed, .disabled:
			return true
		case .notSubscribed:
			return false
		}
	}

	public var isEnabled: Bool {
		return self == .subscribed
	}
}

/// Subscription service errors
public enum SubscriptionServiceError: LocalizedError {
	case noServicesAvailable
	case channelNotFound
	case networkError(Error)

	public var errorDescription: String? {
		switch self {
		case .noServicesAvailable:
			return "PeerTube services are not available"
		case .channelNotFound:
			return "Channel not found"
		case .networkError(let error):
			return "Network error: \(error.localizedDescription)"
		}
	}
}
