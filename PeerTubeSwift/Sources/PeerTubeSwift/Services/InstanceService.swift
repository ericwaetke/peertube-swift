//
//  InstanceService.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

import Foundation

/// Instance server statistics
public struct InstanceStats: Codable, Sendable {
	public let totalUsers: Int
	public let totalLocalVideos: Int
	public let totalLocalVideoViews: Int
	public let totalLocalVideoComments: Int
	public let totalVideos: Int

	public init(
		totalUsers: Int,
		totalLocalVideos: Int,
		totalLocalVideoViews: Int,
		totalLocalVideoComments: Int,
		totalVideos: Int
	) {
		self.totalUsers = totalUsers
		self.totalLocalVideos = totalLocalVideos
		self.totalLocalVideoViews = totalLocalVideoViews
		self.totalLocalVideoComments = totalLocalVideoComments
		self.totalVideos = totalVideos
	}
}

/// Instance about information
public struct InstanceAbout: Codable, Sendable {
	public let instance: InstanceInfo
	public let administrator: Administrator?
	public let createdAt: Date

	public init(
		instance: InstanceInfo,
		administrator: Administrator? = nil,
		createdAt: Date
	) {
		self.instance = instance
		self.administrator = administrator
		self.createdAt = createdAt
	}
}

/// Instance administrator information
public struct Administrator: Codable, Sendable {
	public let name: String
	public let email: String?
	public let description: String?

	public init(
		name: String,
		email: String? = nil,
		description: String? = nil
	) {
		self.name = name
		self.email = email
		self.description = description
	}
}

/// Service for instance-related API operations with Swift 6 concurrency support
@MainActor
public final class InstanceService: Sendable {

	// MARK: - Properties

	private let apiClient: APIClient

	// MARK: - Initialization

	public init(apiClient: APIClient) {
		self.apiClient = apiClient
	}

	// MARK: - Instance Information

	/// Get instance configuration and settings
	/// - Returns: Complete instance configuration
	/// - Throws: PeerTubeAPIError if the request fails
	public func getConfig() async throws -> InstanceConfig {
		return try await apiClient.get(
			path: "/config",
			authenticated: false
		)
	}

	/// Get instance about information
	/// - Returns: Instance about details including administrator info
	/// - Throws: PeerTubeAPIError if the request fails
	public func getAbout() async throws -> InstanceAbout {
		return try await apiClient.get(
			path: "/config/about",
			authenticated: false
		)
	}

	/// Get instance statistics
	/// - Returns: Instance usage statistics
	/// - Throws: PeerTubeAPIError if the request fails
	public func getStats() async throws -> InstanceStats {
		return try await apiClient.get(
			path: "/server/stats",
			authenticated: false
		)
	}

	/// Get server debug information (requires admin privileges)
	/// - Returns: Server debug information
	/// - Throws: PeerTubeAPIError if the request fails or user lacks permissions
	public func getServerDebug() async throws -> [String: Any] {
		return try await apiClient.get(
			path: "/server/debug",
			authenticated: true
		)
	}

	// MARK: - Instance Discovery

	/// Get list of known instances following this instance
	/// - Parameters:
	///   - start: Pagination start (default: 0)
	///   - count: Number of results (default: 15)
	/// - Returns: List of following instances
	/// - Throws: PeerTubeAPIError if the request fails
	public func getInstanceFollowers(
		start: Int = 0,
		count: Int = 15
	) async throws -> InstanceFollowersList {
		let queryParams = [
			"start": String(start),
			"count": String(count),
		]

		return try await apiClient.get(
			path: "/server/followers",
			queryParameters: queryParams,
			authenticated: false
		)
	}

	/// Get list of instances that this instance follows
	/// - Parameters:
	///   - start: Pagination start (default: 0)
	///   - count: Number of results (default: 15)
	/// - Returns: List of followed instances
	/// - Throws: PeerTubeAPIError if the request fails
	public func getInstanceFollowing(
		start: Int = 0,
		count: Int = 15
	) async throws -> InstanceFollowingList {
		let queryParams = [
			"start": String(start),
			"count": String(count),
		]

		return try await apiClient.get(
			path: "/server/following",
			queryParameters: queryParams,
			authenticated: false
		)
	}

	// MARK: - Content Categories & Metadata

	/// Get available video categories on this instance
	/// - Returns: Dictionary of category ID to category info
	/// - Throws: PeerTubeAPIError if the request fails
	public func getVideoCategories() async throws -> [String: String] {
		return try await apiClient.get(
			path: "/videos/categories",
			authenticated: false
		)
	}

	/// Get available video licences on this instance
	/// - Returns: Dictionary of licence ID to licence info
	/// - Throws: PeerTubeAPIError if the request fails
	public func getVideoLicences() async throws -> [String: String] {
		return try await apiClient.get(
			path: "/videos/licences",
			authenticated: false
		)
	}

	/// Get available video languages on this instance
	/// - Returns: Dictionary of language ID to language info
	/// - Throws: PeerTubeAPIError if the request fails
	public func getVideoLanguages() async throws -> [String: String] {
		return try await apiClient.get(
			path: "/videos/languages",
			authenticated: false
		)
	}

	/// Get available video privacy settings
	/// - Returns: Dictionary of privacy ID to privacy info
	/// - Throws: PeerTubeAPIError if the request fails
	public func getVideoPrivacyPolicies() async throws -> [String: String] {
		return try await apiClient.get(
			path: "/videos/privacies",
			authenticated: false
		)
	}

	// MARK: - Batch Operations with Structured Concurrency

	/// Get complete instance information (config + about + stats) concurrently
	/// - Returns: Tuple with all instance information
	/// - Throws: PeerTubeAPIError if any request fails
	public func getCompleteInstanceInfo() async throws -> (
		config: InstanceConfig,
		about: InstanceAbout,
		stats: InstanceStats
	) {
		return try await withThrowingTaskGroup(of: Void.self) { group in
			var config: InstanceConfig?
			var about: InstanceAbout?
			var stats: InstanceStats?

			// Fetch config
			group.addTask {
				config = try await self.getConfig()
			}

			// Fetch about
			group.addTask {
				about = try await self.getAbout()
			}

			// Fetch stats
			group.addTask {
				stats = try await self.getStats()
			}

			// Wait for all to complete
			try await group.waitForAll()

			// All should be populated at this point
			guard let finalConfig = config,
				let finalAbout = about,
				let finalStats = stats
			else {
				throw PeerTubeAPIError.networkError(.unknown)
			}

			return (config: finalConfig, about: finalAbout, stats: finalStats)
		}
	}

	/// Get all metadata (categories, licences, languages, privacies) concurrently
	/// - Returns: Tuple with all metadata dictionaries
	/// - Throws: PeerTubeAPIError if any request fails
	public func getAllMetadata() async throws -> (
		categories: [String: String],
		licences: [String: String],
		languages: [String: String],
		privacies: [String: String]
	) {
		return try await withThrowingTaskGroup(of: Void.self) { group in
			var categories: [String: String]?
			var licences: [String: String]?
			var languages: [String: String]?
			var privacies: [String: String]?

			// Fetch categories
			group.addTask {
				categories = try await self.getVideoCategories()
			}

			// Fetch licences
			group.addTask {
				licences = try await self.getVideoLicences()
			}

			// Fetch languages
			group.addTask {
				languages = try await self.getVideoLanguages()
			}

			// Fetch privacy policies
			group.addTask {
				privacies = try await self.getVideoPrivacyPolicies()
			}

			// Wait for all to complete
			try await group.waitForAll()

			// All should be populated at this point
			guard let finalCategories = categories,
				let finalLicences = licences,
				let finalLanguages = languages,
				let finalPrivacies = privacies
			else {
				throw PeerTubeAPIError.networkError(.unknown)
			}

			return (
				categories: finalCategories,
				licences: finalLicences,
				languages: finalLanguages,
				privacies: finalPrivacies
			)
		}
	}

	// MARK: - Health & Connectivity

	/// Check if the instance is reachable and responding
	/// - Returns: True if instance is healthy, false otherwise
	/// - Note: This method doesn't throw - it returns false for any error
	public func checkHealth() async -> Bool {
		do {
			// Try to fetch basic config as a health check
			_ = try await getConfig()
			return true
		} catch {
			return false
		}
	}

	/// Get instance version information
	/// - Returns: Instance version string
	/// - Throws: PeerTubeAPIError if the request fails
	public func getVersion() async throws -> String {
		let config = try await getConfig()
		return config.serverVersion ?? "Unknown"
	}

	/// Test instance connectivity with timeout
	/// - Parameter timeout: Timeout in seconds (default: 10)
	/// - Returns: True if instance responds within timeout
	public func testConnectivity(timeout: TimeInterval = 10.0) async -> Bool {
		do {
			// Create a task with timeout
			return try await withThrowingTimeout(seconds: timeout) {
				return await self.checkHealth()
			}
		} catch {
			return false
		}
	}
}

// MARK: - Response Models

/// Instance followers list response
public struct InstanceFollowersList: Codable, Sendable {
	public let total: Int
	public let data: [InstanceFollower]

	public init(total: Int, data: [InstanceFollower]) {
		self.total = total
		self.data = data
	}
}

/// Instance following list response
public struct InstanceFollowingList: Codable, Sendable {
	public let total: Int
	public let data: [InstanceFollowing]

	public init(total: Int, data: [InstanceFollowing]) {
		self.total = total
		self.data = data
	}
}

/// Instance follower information
public struct InstanceFollower: Codable, Sendable {
	public let id: Int
	public let follower: InstanceFollowerActor
	public let following: InstanceFollowingActor
	public let score: Int?
	public let state: FollowState
	public let createdAt: Date
	public let updatedAt: Date

	public init(
		id: Int,
		follower: InstanceFollowerActor,
		following: InstanceFollowingActor,
		score: Int? = nil,
		state: FollowState,
		createdAt: Date,
		updatedAt: Date
	) {
		self.id = id
		self.follower = follower
		self.following = following
		self.score = score
		self.state = state
		self.createdAt = createdAt
		self.updatedAt = updatedAt
	}
}

/// Instance following information
public struct InstanceFollowing: Codable, Sendable {
	public let id: Int
	public let follower: InstanceFollowerActor
	public let following: InstanceFollowingActor
	public let score: Int?
	public let state: FollowState
	public let createdAt: Date
	public let updatedAt: Date

	public init(
		id: Int,
		follower: InstanceFollowerActor,
		following: InstanceFollowingActor,
		score: Int? = nil,
		state: FollowState,
		createdAt: Date,
		updatedAt: Date
	) {
		self.id = id
		self.follower = follower
		self.following = following
		self.score = score
		self.state = state
		self.createdAt = createdAt
		self.updatedAt = updatedAt
	}
}

/// Instance follower actor
public struct InstanceFollowerActor: Codable, Sendable {
	public let id: Int
	public let name: String
	public let host: String
	public let followingCount: Int?
	public let followersCount: Int?
	public let createdAt: Date
	public let updatedAt: Date

	public init(
		id: Int,
		name: String,
		host: String,
		followingCount: Int? = nil,
		followersCount: Int? = nil,
		createdAt: Date,
		updatedAt: Date
	) {
		self.id = id
		self.name = name
		self.host = host
		self.followingCount = followingCount
		self.followersCount = followersCount
		self.createdAt = createdAt
		self.updatedAt = updatedAt
	}
}

/// Instance following actor
public struct InstanceFollowingActor: Codable, Sendable {
	public let id: Int
	public let name: String
	public let host: String
	public let followingCount: Int?
	public let followersCount: Int?
	public let createdAt: Date
	public let updatedAt: Date

	public init(
		id: Int,
		name: String,
		host: String,
		followingCount: Int? = nil,
		followersCount: Int? = nil,
		createdAt: Date,
		updatedAt: Date
	) {
		self.id = id
		self.name = name
		self.host = host
		self.followingCount = followingCount
		self.followersCount = followersCount
		self.createdAt = createdAt
		self.updatedAt = updatedAt
	}
}

/// Follow relationship state
public enum FollowState: String, Codable, CaseIterable, Sendable {
	case pending = "pending"
	case accepted = "accepted"
	case rejected = "rejected"

	public var displayName: String {
		switch self {
		case .pending: return "Pending"
		case .accepted: return "Accepted"
		case .rejected: return "Rejected"
		}
	}
}

// MARK: - Convenience Extensions

extension InstanceService {

	/// Get basic instance information for display
	/// - Returns: Simplified instance information
	public func getBasicInfo() async throws -> BasicInstanceInfo {
		let (config, about, stats) = try await getCompleteInstanceInfo()

		return BasicInstanceInfo(
			name: config.instance.name,
			description: config.instance.shortDescription,
			version: config.serverVersion,
			userCount: stats.totalUsers,
			videoCount: stats.totalVideos,
			isSignupAllowed: config.signup?.allowed ?? false,
			administratorEmail: config.instance.administratorEmail,
			createdAt: about.createdAt
		)
	}

	/// Check if instance supports a specific feature
	/// - Parameter feature: Feature to check
	/// - Returns: True if feature is supported
	public func supportsFeature(_ feature: InstanceFeature) async throws -> Bool {
		let config = try await getConfig()

		switch feature {
		case .hls:
			return config.transcoding?.hls?.enabled ?? false
		case .webtorrent:
			return config.transcoding?.webtorrent?.enabled ?? false
		case .liveStreaming:
			// Check if live streaming is configured (this is a simplified check)
			return config.transcoding != nil
		case .signup:
			return config.signup?.allowed ?? false
		case .emailVerification:
			return config.signup?.requiresEmailVerification ?? false
		case .contactForm:
			return config.contactForm?.enabled ?? false
		}
	}
}

/// Simplified instance information for basic display
public struct BasicInstanceInfo: Sendable {
	public let name: String
	public let description: String
	public let version: String?
	public let userCount: Int
	public let videoCount: Int
	public let isSignupAllowed: Bool
	public let administratorEmail: String?
	public let createdAt: Date

	public init(
		name: String,
		description: String,
		version: String? = nil,
		userCount: Int,
		videoCount: Int,
		isSignupAllowed: Bool,
		administratorEmail: String? = nil,
		createdAt: Date
	) {
		self.name = name
		self.description = description
		self.version = version
		self.userCount = userCount
		self.videoCount = videoCount
		self.isSignupAllowed = isSignupAllowed
		self.administratorEmail = administratorEmail
		self.createdAt = createdAt
	}
}

/// Instance features that can be checked
public enum InstanceFeature: CaseIterable, Sendable {
	case hls
	case webtorrent
	case liveStreaming
	case signup
	case emailVerification
	case contactForm

	public var displayName: String {
		switch self {
		case .hls: return "HLS Streaming"
		case .webtorrent: return "WebTorrent"
		case .liveStreaming: return "Live Streaming"
		case .signup: return "User Registration"
		case .emailVerification: return "Email Verification"
		case .contactForm: return "Contact Form"
		}
	}
}

// MARK: - Timeout Helper

/// Helper function to add timeout to async operations
private func withThrowingTimeout<T>(
	seconds: TimeInterval,
	operation: @escaping () async throws -> T
) async throws -> T {
	return try await withThrowingTaskGroup(of: T.self) { group in
		// Add the operation task
		group.addTask {
			try await operation()
		}

		// Add timeout task
		group.addTask {
			try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
			throw TimeoutError()
		}

		// Return the first to complete
		let result = try await group.next()!
		group.cancelAll()
		return result
	}
}

/// Timeout error for connectivity testing
private struct TimeoutError: Error {}
