//
//  ChannelService.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

import Foundation

/// Parameters for listing channels
public struct ChannelListParameters: Sendable {
	public let start: Int
	public let count: Int
	public let sort: ChannelSort
	public let isLocal: Bool?
	public let skipCount: Bool

	public init(
		start: Int = 0,
		count: Int = 15,
		sort: ChannelSort = .createdAt,
		isLocal: Bool? = nil,
		skipCount: Bool = false
	) {
		self.start = start
		self.count = count
		self.sort = sort
		self.isLocal = isLocal
		self.skipCount = skipCount
	}
}

/// Parameters for searching channels
public struct ChannelSearchParameters: Sendable {
	public let search: String
	public let start: Int
	public let count: Int
	public let sort: ChannelSort
	public let searchTarget: SearchTarget
	public let isLocal: Bool?
	public let skipCount: Bool

	public init(
		search: String,
		start: Int = 0,
		count: Int = 15,
		sort: ChannelSort = .relevance,
		searchTarget: SearchTarget = .local,
		isLocal: Bool? = nil,
		skipCount: Bool = false
	) {
		self.search = search
		self.start = start
		self.count = count
		self.sort = sort
		self.searchTarget = searchTarget
		self.isLocal = isLocal
		self.skipCount = skipCount
	}
}

/// Channel sorting options
public enum ChannelSort: String, CaseIterable, Sendable {
	case createdAt = "-createdAt"
	case updatedAt = "-updatedAt"
	case name = "name"
	case followersCount = "-followersCount"
	case videosCount = "-videosCount"
	case relevance = "-match"  // For search results only

	public var displayName: String {
		switch self {
		case .createdAt: return "Created Date"
		case .updatedAt: return "Updated Date"
		case .name: return "Name"
		case .followersCount: return "Followers"
		case .videosCount: return "Videos"
		case .relevance: return "Relevance"
		}
	}
}

/// Response wrapper for paginated channel results
public struct ChannelListResponse: Codable, Sendable {
	public let total: Int
	public let data: [VideoChannel]

	public init(total: Int, data: [VideoChannel]) {
		self.total = total
		self.data = data
	}
}

/// Service for video channel-related API operations with Swift 6 concurrency support
@MainActor
public final class ChannelService: Sendable {

	// MARK: - Properties

	private let apiClient: APIClient

	// MARK: - Initialization

	public init(apiClient: APIClient) {
		self.apiClient = apiClient
	}

	// MARK: - Channel Operations

	/// Get a single channel by handle or ID
	/// - Parameter handle: Channel handle (name@host) or numeric ID
	/// - Returns: Detailed channel information
	/// - Throws: PeerTubeAPIError if the request fails
	public func getChannel(handle: String) async throws -> VideoChannel {
		return try await apiClient.get(
			path: "/video-channels/\(handle)",
			authenticated: false
		)
	}

	/// Get a single channel by numeric ID
	/// - Parameter id: Channel numeric ID
	/// - Returns: Detailed channel information
	/// - Throws: PeerTubeAPIError if the request fails
	public func getChannel(id: Int) async throws -> VideoChannel {
		return try await getChannel(handle: String(id))
	}

	/// List channels with filtering and pagination
	/// - Parameter parameters: Filtering and pagination parameters
	/// - Returns: Paginated list of channels
	/// - Throws: PeerTubeAPIError if the request fails
	public func listChannels(parameters: ChannelListParameters = ChannelListParameters())
		async throws
		-> ChannelListResponse
	{
		var queryParams: [String: String] = [
			"start": String(parameters.start),
			"count": String(parameters.count),
			"sort": parameters.sort.rawValue,
			"skipCount": String(parameters.skipCount),
		]

		// Add optional parameters
		if let isLocal = parameters.isLocal {
			queryParams["isLocal"] = String(isLocal)
		}

		return try await apiClient.get(
			path: "/video-channels",
			queryParameters: queryParams,
			authenticated: false
		)
	}

	/// Search channels
	/// - Parameter parameters: Search parameters
	/// - Returns: Paginated search results
	/// - Throws: PeerTubeAPIError if the request fails
	public func searchChannels(parameters: ChannelSearchParameters) async throws
		-> ChannelListResponse
	{
		var queryParams: [String: String] = [
			"search": parameters.search,
			"start": String(parameters.start),
			"count": String(parameters.count),
			"sort": parameters.sort.rawValue,
			"searchTarget": parameters.searchTarget.rawValue,
			"skipCount": String(parameters.skipCount),
		]

		// Add optional parameters
		if let isLocal = parameters.isLocal {
			queryParams["isLocal"] = String(isLocal)
		}

		return try await apiClient.get(
			path: "/search/video-channels",
			queryParameters: queryParams,
			authenticated: false
		)
	}

	/// Get channels owned by a specific account
	/// - Parameters:
	///   - accountHandle: Account handle (name@host) or numeric ID
	///   - parameters: Filtering and pagination parameters
	/// - Returns: Paginated list of channels owned by the account
	/// - Throws: PeerTubeAPIError if the request fails
	public func getAccountChannels(
		accountHandle: String,
		parameters: ChannelListParameters = ChannelListParameters()
	) async throws -> ChannelListResponse {
		var queryParams: [String: String] = [
			"start": String(parameters.start),
			"count": String(parameters.count),
			"sort": parameters.sort.rawValue,
			"skipCount": String(parameters.skipCount),
		]

		return try await apiClient.get(
			path: "/accounts/\(accountHandle)/video-channels",
			queryParameters: queryParams,
			authenticated: false
		)
	}

	/// Get channel videos with pagination
	/// - Parameters:
	///   - channelHandle: Channel handle (name@host) or numeric ID
	///   - videoParameters: Video filtering and pagination parameters
	/// - Returns: Paginated list of videos from the channel
	/// - Throws: PeerTubeAPIError if the request fails
	public func getChannelVideos(
		channelHandle: String,
		videoParameters: VideoListParameters = VideoListParameters()
	) async throws -> VideoListResponse {
		// Delegate to VideoService method for consistency
		// This creates a dependency but maintains separation of concerns
		return try await VideoService(apiClient: apiClient)
			.getChannelVideos(channelHandle: channelHandle, parameters: videoParameters)
	}

	// MARK: - Batch Operations with Structured Concurrency

	/// Get multiple channels concurrently by their handles/IDs
	/// - Parameter handles: Array of channel handles or IDs
	/// - Returns: Array of channel details (may be fewer than requested if some fail)
	/// - Note: Uses structured concurrency to fetch channels in parallel
	public func getChannels(handles: [String]) async -> [VideoChannel] {
		return await withTaskGroup(of: VideoChannel?.self) { group in
			// Add tasks for each channel handle
			for handle in handles {
				group.addTask { [weak self] in
					guard let self = self else { return nil }
					do {
						return try await self.getChannel(handle: handle)
					} catch {
						// Log error in a real implementation
						return nil
					}
				}
			}

			// Collect results
			var results: [VideoChannel] = []
			for await channel in group {
				if let channel = channel {
					results.append(channel)
				}
			}
			return results
		}
	}

	/// Get multiple channels concurrently by numeric IDs
	/// - Parameter ids: Array of numeric channel IDs
	/// - Returns: Array of channel details
	public func getChannels(ids: [Int]) async -> [VideoChannel] {
		return await getChannels(handles: ids.map(String.init))
	}

	/// Get channel with its recent videos in a single operation
	/// - Parameters:
	///   - channelHandle: Channel handle or ID
	///   - videoCount: Number of recent videos to fetch (default: 10)
	/// - Returns: Tuple containing channel details and its recent videos
	/// - Throws: PeerTubeAPIError if either request fails
	public func getChannelWithVideos(
		channelHandle: String,
		videoCount: Int = 10
	) async throws -> (channel: VideoChannel, videos: VideoListResponse) {
		// Use structured concurrency to fetch both concurrently
		return try await withThrowingTaskGroup(of: Void.self) { group in
			var channel: VideoChannel?
			var videos: VideoListResponse?

			// Fetch channel details
			group.addTask {
				channel = try await self.getChannel(handle: channelHandle)
			}

			// Fetch channel videos
			group.addTask {
				let videoParams = VideoListParameters(count: videoCount, sort: .publishedAt)
				videos = try await self.getChannelVideos(
					channelHandle: channelHandle,
					videoParameters: videoParams
				)
			}

			// Wait for both to complete
			try await group.waitForAll()

			// Both should be populated at this point
			guard let finalChannel = channel, let finalVideos = videos else {
				throw PeerTubeAPIError.networkError(.unknown)
			}

			return (channel: finalChannel, videos: finalVideos)
		}
	}
}

// MARK: - Convenience Extensions

extension ChannelService {

	/// Get the most recently created channels
	/// - Parameter count: Number of channels to fetch (default: 15)
	/// - Returns: Recent channels sorted by creation date
	public func getRecentChannels(count: Int = 15) async throws -> ChannelListResponse {
		let parameters = ChannelListParameters(
			start: 0,
			count: count,
			sort: .createdAt
		)
		return try await listChannels(parameters: parameters)
	}

	/// Get the most popular channels by follower count
	/// - Parameter count: Number of channels to fetch (default: 15)
	/// - Returns: Popular channels sorted by follower count
	public func getPopularChannels(count: Int = 15) async throws -> ChannelListResponse {
		let parameters = ChannelListParameters(
			start: 0,
			count: count,
			sort: .followersCount
		)
		return try await listChannels(parameters: parameters)
	}

	/// Get channels with the most videos
	/// - Parameter count: Number of channels to fetch (default: 15)
	/// - Returns: Active channels sorted by video count
	public func getActiveChannels(count: Int = 15) async throws -> ChannelListResponse {
		let parameters = ChannelListParameters(
			start: 0,
			count: count,
			sort: .videosCount
		)
		return try await listChannels(parameters: parameters)
	}

	/// Get local channels only
	/// - Parameter count: Number of channels to fetch (default: 15)
	/// - Returns: Local channels from this instance
	public func getLocalChannels(count: Int = 15) async throws -> ChannelListResponse {
		let parameters = ChannelListParameters(
			start: 0,
			count: count,
			sort: .createdAt,
			isLocal: true
		)
		return try await listChannels(parameters: parameters)
	}

	/// Simple channel search
	/// - Parameters:
	///   - query: Search query string
	///   - count: Number of results to fetch (default: 15)
	/// - Returns: Search results
	public func search(query: String, count: Int = 15) async throws -> ChannelListResponse {
		let parameters = ChannelSearchParameters(
			search: query,
			count: count
		)
		return try await searchChannels(parameters: parameters)
	}

	/// Get channels by account name
	/// - Parameters:
	///   - accountName: Account username (without @host)
	///   - host: Instance hostname (optional, defaults to local)
	/// - Returns: Channels owned by the account
	public func getChannelsByAccount(
		accountName: String,
		host: String? = nil
	) async throws -> ChannelListResponse {
		let handle = host.map { "\(accountName)@\($0)" } ?? accountName
		return try await getAccountChannels(accountHandle: handle)
	}
}

// MARK: - Channel Statistics Extensions

extension ChannelService {

	/// Get aggregated statistics for a channel
	/// - Parameter channelHandle: Channel handle or ID
	/// - Returns: Channel with computed statistics
	/// - Note: This is a computed view of existing data, not a separate API call
	public func getChannelStats(channelHandle: String) async throws -> ChannelStats {
		let channel = try await getChannel(handle: channelHandle)

		// Get first page of videos to compute basic stats
		let videoParams = VideoListParameters(count: 100, skipCount: false)
		let videos = try await getChannelVideos(
			channelHandle: channelHandle, videoParameters: videoParams)

		let totalViews = videos.data.reduce(0) { $0 + $1.views }
		let totalLikes = videos.data.reduce(0) { $0 + $1.likes }
		let averageViews = videos.data.isEmpty ? 0 : totalViews / videos.data.count
		let newestVideo = videos.data.max(by: { $0.createdAt < $1.createdAt })
		let oldestVideo = videos.data.min(by: { $0.createdAt < $1.createdAt })

		return ChannelStats(
			channel: channel,
			videoCount: videos.total,
			totalViews: totalViews,
			totalLikes: totalLikes,
			averageViews: averageViews,
			newestVideoDate: newestVideo?.createdAt,
			oldestVideoDate: oldestVideo?.createdAt
		)
	}
}

/// Channel statistics summary
public struct ChannelStats: Sendable {
	public let channel: VideoChannel
	public let videoCount: Int
	public let totalViews: Int
	public let totalLikes: Int
	public let averageViews: Int
	public let newestVideoDate: Date?
	public let oldestVideoDate: Date?

	public init(
		channel: VideoChannel,
		videoCount: Int,
		totalViews: Int,
		totalLikes: Int,
		averageViews: Int,
		newestVideoDate: Date? = nil,
		oldestVideoDate: Date? = nil
	) {
		self.channel = channel
		self.videoCount = videoCount
		self.totalViews = totalViews
		self.totalLikes = totalLikes
		self.averageViews = averageViews
		self.newestVideoDate = newestVideoDate
		self.oldestVideoDate = oldestVideoDate
	}
}
