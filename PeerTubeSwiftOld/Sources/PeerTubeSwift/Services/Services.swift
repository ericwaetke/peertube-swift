//
//  Services.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

import Foundation

/// Main service manager that provides centralized access to all PeerTube API services
@MainActor
public final class PeerTubeServices: Sendable {
	// MARK: - Properties

	private let apiClient: APIClient

	/// Video-related operations service
	public lazy var videos: VideoService = .init(apiClient: apiClient)

	/// Channel-related operations service
	public lazy var channels: ChannelService = .init(apiClient: apiClient)

	/// Instance-related operations service
	public lazy var instance: InstanceService = .init(apiClient: apiClient)

	// MARK: - Initialization

	/// Initialize services with an API client
	/// - Parameter apiClient: Configured APIClient for the target instance
	public init(apiClient: APIClient) {
		self.apiClient = apiClient
	}

	/// Convenience initializer with instance URL
	/// - Parameter instanceURL: URL of the PeerTube instance
	public convenience init(instanceURL: URL) {
		let apiClient = APIClient(instanceURL: instanceURL)
		self.init(apiClient: apiClient)
	}

	/// Convenience initializer with instance URL string
	/// - Parameter instanceURLString: URL string of the PeerTube instance
	/// - Returns: nil if URL string is invalid
	public convenience init?(instanceURLString: String) {
		guard let url = URL(string: instanceURLString) else { return nil }
		self.init(instanceURL: url)
	}
}

// MARK: - Authentication Convenience

extension PeerTubeServices {
	/// Set authentication token for all services
	/// - Parameter token: Authentication token to use
	public func setAuthToken(_ token: AuthToken?) async {
		await apiClient.setAuthToken(token)
	}

	/// Get current authentication token
	/// - Returns: Current authentication token, if any
	public func getAuthToken() async -> AuthToken? {
		return await apiClient.getAuthToken()
	}

	/// Check if services are authenticated
	/// - Returns: True if authentication token is present and valid
	public func isAuthenticated() async -> Bool {
		return await apiClient.isAuthenticated()
	}

	/// Clear authentication for all services
	public func clearAuthentication() async {
		await apiClient.clearAuthentication()
	}
}

// MARK: - Instance Information Convenience

extension PeerTubeServices {
	/// Get the instance hostname this service manager is connected to
	public var instanceHost: String {
		apiClient.instanceHost
	}

	/// Check if this service manager is for a specific instance
	/// - Parameter url: Instance URL to check
	/// - Returns: True if this service manager is for the given instance
	public func isForInstance(_ url: URL) -> Bool {
		return apiClient.isForInstance(url)
	}
}

// MARK: - Health Check Convenience

extension PeerTubeServices {
	/// Perform a quick health check on the connected instance
	/// - Returns: True if instance is reachable and responding
	public func checkHealth() async -> Bool {
		return await instance.checkHealth()
	}

	/// Test connectivity with custom timeout
	/// - Parameter timeout: Timeout in seconds (default: 10)
	/// - Returns: True if instance responds within timeout
	public func testConnectivity(timeout: TimeInterval = 10.0) async -> Bool {
		return await instance.testConnectivity(timeout: timeout)
	}
}

// MARK: - Commonly Used Operations

extension PeerTubeServices {
	/// Quick search across videos and channels
	/// - Parameters:
	///   - query: Search query string
	///   - videoCount: Number of video results (default: 10)
	///   - channelCount: Number of channel results (default: 5)
	/// - Returns: Combined search results
	public func quickSearch(
		query: String,
		videoCount: Int = 10,
		channelCount: Int = 5
	) async throws -> QuickSearchResults {
		// Use structured concurrency to search videos and channels in parallel
		return try await withThrowingTaskGroup(of: Void.self) { group in
			var videoResults: VideoListResponse?
			var channelResults: ChannelListResponse?

			// Search videos
			group.addTask {
				videoResults = try await self.videos.search(query: query, count: videoCount)
			}

			// Search channels
			group.addTask {
				channelResults = try await self.channels.search(query: query, count: channelCount)
			}

			// Wait for both searches to complete
			try await group.waitForAll()

			// Both should be populated at this point
			guard let videos = videoResults, let channels = channelResults else {
				throw PeerTubeAPIError.networkError(
					.unknown(
						NSError(
							domain: "PeerTubeSwift", code: -1,
							userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])))
			}

			return QuickSearchResults(
				query: query,
				videos: videos,
				channels: channels
			)
		}
	}

	/// Get homepage content (trending videos + popular channels)
	/// - Parameters:
	///   - videoCount: Number of trending videos (default: 15)
	///   - channelCount: Number of popular channels (default: 10)
	/// - Returns: Homepage content
	public func getHomepageContent(
		videoCount: Int = 15,
		channelCount: Int = 10
	) async throws -> HomepageContent {
		return try await withThrowingTaskGroup(of: Void.self) { group in
			var trendingVideos: VideoListResponse?
			var popularChannels: ChannelListResponse?
			var instanceInfo: BasicInstanceInfo?

			// Get trending videos
			group.addTask {
				trendingVideos = try await self.videos.getTrendingVideos(count: videoCount)
			}

			// Get popular channels
			group.addTask {
				popularChannels = try await self.channels.getPopularChannels(count: channelCount)
			}

			// Get basic instance info
			group.addTask {
				instanceInfo = try await self.instance.getBasicInfo()
			}

			// Wait for all to complete
			try await group.waitForAll()

			// All should be populated at this point
			guard let videos = trendingVideos,
				let channels = popularChannels,
				let info = instanceInfo
			else {
				throw PeerTubeAPIError.networkError(
					.unknown(
						NSError(
							domain: "PeerTubeSwift", code: -1,
							userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])))
			}

			return HomepageContent(
				trendingVideos: videos,
				popularChannels: channels,
				instanceInfo: info
			)
		}
	}
}

// MARK: - Result Types

/// Combined search results for videos and channels
public struct QuickSearchResults: Sendable {
	public let query: String
	public let videos: VideoListResponse
	public let channels: ChannelListResponse

	/// Total number of results across both categories
	public var totalResults: Int {
		videos.total + channels.total
	}

	/// Whether there are any results
	public var hasResults: Bool {
		!videos.data.isEmpty || !channels.data.isEmpty
	}

	public init(
		query: String,
		videos: VideoListResponse,
		channels: ChannelListResponse
	) {
		self.query = query
		self.videos = videos
		self.channels = channels
	}
}

/// Homepage content bundle
public struct HomepageContent: Sendable {
	public let trendingVideos: VideoListResponse
	public let popularChannels: ChannelListResponse
	public let instanceInfo: BasicInstanceInfo

	public init(
		trendingVideos: VideoListResponse,
		popularChannels: ChannelListResponse,
		instanceInfo: BasicInstanceInfo
	) {
		self.trendingVideos = trendingVideos
		self.popularChannels = popularChannels
		self.instanceInfo = instanceInfo
	}
}
