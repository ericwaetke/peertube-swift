//
//  Instance.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

import Foundation

/// PeerTube instance information
public struct Instance: Codable, Hashable, Identifiable, Sendable {
	/// Unique identifier
	public let id: UUID

	/// Instance hostname/domain
	public let host: String

	/// Instance display name
	public let name: String?

	/// Short description
	public let shortDescription: String?

	/// Full description
	public let description: String?

	/// Instance version
	public let version: String?

	/// Terms of service
	public let terms: String?

	/// Default NSFW policy
	public let defaultNSFWPolicy: String?

	/// Whether registrations are open
	public let signupAllowed: Bool

	/// User count
	public let totalUsers: Int?

	/// Video count
	public let totalVideos: Int?

	/// Total instance followers
	public let totalInstanceFollowers: Int?

	/// Total instance following
	public let totalInstanceFollowing: Int?

	/// Avatar images
	public let avatars: [ActorImage]

	/// Whether this is the default instance for the app
	public let isDefault: Bool

	/// When this instance was added to the app
	public let addedAt: Date

	/// Last time instance info was updated
	public let lastUpdated: Date?

	/// Whether this instance is reachable
	public let isReachable: Bool

	// MARK: - Computed Properties

	/// Base URL for the instance
	public var baseURL: URL? {
		URL(string: "https://\(host)")
	}

	/// API base URL
	public var apiBaseURL: URL? {
		baseURL?.appendingPathComponent("/api/v1")
	}

	/// Display name or fallback to host
	public var effectiveName: String {
		name?.isEmpty == false ? name! : host
	}

	/// Primary avatar
	public var primaryAvatar: ActorImage? {
		avatars.max { lhs, rhs in
			(lhs.width ?? 0) < (rhs.width ?? 0)
		}
	}

	// MARK: - Initialization

	public init(
		id: UUID = UUID(),
		host: String,
		name: String? = nil,
		shortDescription: String? = nil,
		description: String? = nil,
		version: String? = nil,
		terms: String? = nil,
		defaultNSFWPolicy: String? = nil,
		signupAllowed: Bool = false,
		totalUsers: Int? = nil,
		totalVideos: Int? = nil,
		totalInstanceFollowers: Int? = nil,
		totalInstanceFollowing: Int? = nil,
		avatars: [ActorImage] = [],
		isDefault: Bool = false,
		addedAt: Date = Date(),
		lastUpdated: Date? = nil,
		isReachable: Bool = true
	) {
		self.id = id
		self.host = host
		self.name = name
		self.shortDescription = shortDescription
		self.description = description
		self.version = version
		self.terms = terms
		self.defaultNSFWPolicy = defaultNSFWPolicy
		self.signupAllowed = signupAllowed
		self.totalUsers = totalUsers
		self.totalVideos = totalVideos
		self.totalInstanceFollowers = totalInstanceFollowers
		self.totalInstanceFollowing = totalInstanceFollowing
		self.avatars = avatars
		self.isDefault = isDefault
		self.addedAt = addedAt
		self.lastUpdated = lastUpdated
		self.isReachable = isReachable
	}
}

/// Instance configuration information
public struct InstanceConfig: Codable, Hashable, Sendable {
	/// Instance information
	public let instance: InstanceInfo

	/// Server configuration
	public let serverVersion: String?

	/// Plugin information
	public let plugin: InstancePluginConfig?

	/// Theme information
	public let theme: InstanceThemeConfig?

	/// Email configuration
	public let email: InstanceEmailConfig?

	/// Contact form configuration
	public let contactForm: InstanceContactFormConfig?

	/// Video configuration
	public let video: InstanceVideoConfig?

	/// Avatar configuration
	public let avatar: InstanceAvatarConfig?

	/// Banner configuration
	public let banner: InstanceBannerConfig?

	/// Signup configuration
	public let signup: InstanceSignupConfig?

	/// Transcoding configuration
	public let transcoding: InstanceTranscodingConfig?

	/// Import configuration
	public let `import`: InstanceImportConfig?

	/// Auto blacklist configuration
	public let autoBlacklist: InstanceAutoBlacklistConfig?

	/// Followers configuration
	public let followers: InstanceFollowersConfig?

	/// Following configuration
	public let followings: InstanceFollowingsConfig?

	public init(
		instance: InstanceInfo,
		serverVersion: String? = nil,
		plugin: InstancePluginConfig? = nil,
		theme: InstanceThemeConfig? = nil,
		email: InstanceEmailConfig? = nil,
		contactForm: InstanceContactFormConfig? = nil,
		video: InstanceVideoConfig? = nil,
		avatar: InstanceAvatarConfig? = nil,
		banner: InstanceBannerConfig? = nil,
		signup: InstanceSignupConfig? = nil,
		transcoding: InstanceTranscodingConfig? = nil,
		import importConfig: InstanceImportConfig? = nil,
		autoBlacklist: InstanceAutoBlacklistConfig? = nil,
		followers: InstanceFollowersConfig? = nil,
		followings: InstanceFollowingsConfig? = nil
	) {
		self.instance = instance
		self.serverVersion = serverVersion
		self.plugin = plugin
		self.theme = theme
		self.email = email
		self.contactForm = contactForm
		self.video = video
		self.avatar = avatar
		self.banner = banner
		self.signup = signup
		self.transcoding = transcoding
		self.`import` = importConfig

		self.autoBlacklist = autoBlacklist
		self.followers = followers
		self.followings = followings
	}
}

/// Basic instance information
public struct InstanceInfo: Codable, Hashable, Sendable {
	/// Instance name
	public let name: String

	/// Short description
	public let shortDescription: String

	/// Full description
	public let description: String

	/// Terms of service
	public let terms: String

	/// Default NSFW policy
	public let defaultNSFWPolicy: String

	/// Default client route
	public let defaultClientRoute: String?

	/// Administrator email
	public let administratorEmail: String?

	/// Maintenance lifetime
	public let maintenanceLifetime: Int?

	/// Business model
	public let businessModel: String?

	/// Hardware information
	public let hardwareInformation: String?

	/// Languages supported
	public let languages: [String]

	/// Categories supported
	public let categories: [VideoCategory]

	public init(
		name: String,
		shortDescription: String,
		description: String,
		terms: String,
		defaultNSFWPolicy: String,
		defaultClientRoute: String? = nil,
		administratorEmail: String? = nil,
		maintenanceLifetime: Int? = nil,
		businessModel: String? = nil,
		hardwareInformation: String? = nil,
		languages: [String] = [],
		categories: [VideoCategory] = []
	) {
		self.name = name
		self.shortDescription = shortDescription
		self.description = description
		self.terms = terms
		self.defaultNSFWPolicy = defaultNSFWPolicy
		self.defaultClientRoute = defaultClientRoute
		self.administratorEmail = administratorEmail
		self.maintenanceLifetime = maintenanceLifetime
		self.businessModel = businessModel
		self.hardwareInformation = hardwareInformation
		self.languages = languages
		self.categories = categories
	}
}

// MARK: - Configuration Structs

public struct InstancePluginConfig: Codable, Hashable, Sendable {
	public let registered: [String]

	public init(registered: [String] = []) {
		self.registered = registered
	}
}

public struct InstanceThemeConfig: Codable, Hashable, Sendable {
	public let registered: [String]
	public let `default`: String

	public init(registered: [String] = [], default: String) {
		self.registered = registered
		self.default = `default`
	}
}

public struct InstanceEmailConfig: Codable, Hashable, Sendable {
	public let enabled: Bool

	public init(enabled: Bool = false) {
		self.enabled = enabled
	}
}

public struct InstanceContactFormConfig: Codable, Hashable, Sendable {
	public let enabled: Bool

	public init(enabled: Bool = false) {
		self.enabled = enabled
	}
}

public struct InstanceVideoConfig: Codable, Hashable, Sendable {
	public let librarySize: Int?
	public let file: InstanceVideoFileConfig?

	public init(librarySize: Int? = nil, file: InstanceVideoFileConfig? = nil) {
		self.librarySize = librarySize
		self.file = file
	}
}

public struct InstanceVideoFileConfig: Codable, Hashable, Sendable {
	public let size: InstanceFileSizeConfig?

	public init(size: InstanceFileSizeConfig? = nil) {
		self.size = size
	}
}

public struct InstanceFileSizeConfig: Codable, Hashable, Sendable {
	public let max: Int?

	public init(max: Int? = nil) {
		self.max = max
	}
}

public struct InstanceAvatarConfig: Codable, Hashable, Sendable {
	public let file: InstanceAvatarFileConfig?

	public init(file: InstanceAvatarFileConfig? = nil) {
		self.file = file
	}
}

public struct InstanceAvatarFileConfig: Codable, Hashable, Sendable {
	public let size: InstanceFileSizeConfig?

	public init(size: InstanceFileSizeConfig? = nil) {
		self.size = size
	}
}

public struct InstanceBannerConfig: Codable, Hashable, Sendable {
	public let file: InstanceBannerFileConfig?

	public init(file: InstanceBannerFileConfig? = nil) {
		self.file = file
	}
}

public struct InstanceBannerFileConfig: Codable, Hashable, Sendable {
	public let size: InstanceFileSizeConfig?

	public init(size: InstanceFileSizeConfig? = nil) {
		self.size = size
	}
}

public struct InstanceSignupConfig: Codable, Hashable, Sendable {
	public let allowed: Bool
	public let allowedForCurrentIP: Bool?
	public let requiresEmailVerification: Bool?

	public init(
		allowed: Bool = false,
		allowedForCurrentIP: Bool? = nil,
		requiresEmailVerification: Bool? = nil
	) {
		self.allowed = allowed
		self.allowedForCurrentIP = allowedForCurrentIP
		self.requiresEmailVerification = requiresEmailVerification
	}
}

public struct InstanceTranscodingConfig: Codable, Hashable, Sendable {
	public let hls: InstanceTranscodingHLSConfig?
	public let webtorrent: InstanceTranscodingWebTorrentConfig?
	public let enabledResolutions: [Int]

	public init(
		hls: InstanceTranscodingHLSConfig? = nil,
		webtorrent: InstanceTranscodingWebTorrentConfig? = nil,
		enabledResolutions: [Int] = []
	) {
		self.hls = hls
		self.webtorrent = webtorrent
		self.enabledResolutions = enabledResolutions
	}
}

public struct InstanceTranscodingHLSConfig: Codable, Hashable, Sendable {
	public let enabled: Bool

	public init(enabled: Bool = false) {
		self.enabled = enabled
	}
}

public struct InstanceTranscodingWebTorrentConfig: Codable, Hashable, Sendable {
	public let enabled: Bool

	public init(enabled: Bool = false) {
		self.enabled = enabled
	}
}

public struct InstanceImportConfig: Codable, Hashable, Sendable {
	public let videos: InstanceImportVideosConfig?

	public init(videos: InstanceImportVideosConfig? = nil) {
		self.videos = videos
	}
}

public struct InstanceImportVideosConfig: Codable, Hashable, Sendable {
	public let http: InstanceImportHTTPConfig?
	public let torrent: InstanceImportTorrentConfig?

	public init(
		http: InstanceImportHTTPConfig? = nil,
		torrent: InstanceImportTorrentConfig? = nil
	) {
		self.http = http
		self.torrent = torrent
	}
}

public struct InstanceImportHTTPConfig: Codable, Hashable, Sendable {
	public let enabled: Bool

	public init(enabled: Bool = false) {
		self.enabled = enabled
	}
}

public struct InstanceImportTorrentConfig: Codable, Hashable, Sendable {
	public let enabled: Bool

	public init(enabled: Bool = false) {
		self.enabled = enabled
	}
}

public struct InstanceAutoBlacklistConfig: Codable, Hashable, Sendable {
	public let videos: InstanceAutoBlacklistVideosConfig?

	public init(videos: InstanceAutoBlacklistVideosConfig? = nil) {
		self.videos = videos
	}
}

public struct InstanceAutoBlacklistVideosConfig: Codable, Hashable, Sendable {
	public let ofUsers: InstanceAutoBlacklistOfUsersConfig?

	public init(ofUsers: InstanceAutoBlacklistOfUsersConfig? = nil) {
		self.ofUsers = ofUsers
	}
}

public struct InstanceAutoBlacklistOfUsersConfig: Codable, Hashable, Sendable {
	public let enabled: Bool

	public init(enabled: Bool = false) {
		self.enabled = enabled
	}
}

public struct InstanceFollowersConfig: Codable, Hashable, Sendable {
	public let instance: InstanceFollowersInstanceConfig?

	public init(instance: InstanceFollowersInstanceConfig? = nil) {
		self.instance = instance
	}
}

public struct InstanceFollowersInstanceConfig: Codable, Hashable, Sendable {
	public let enabled: Bool
	public let manualApproval: Bool?

	public init(enabled: Bool = false, manualApproval: Bool? = nil) {
		self.enabled = enabled
		self.manualApproval = manualApproval
	}
}

public struct InstanceFollowingsConfig: Codable, Hashable, Sendable {
	public let instance: InstanceFollowingsInstanceConfig?

	public init(instance: InstanceFollowingsInstanceConfig? = nil) {
		self.instance = instance
	}
}

public struct InstanceFollowingsInstanceConfig: Codable, Hashable, Sendable {
	public let autoFollowBack: InstanceAutoFollowBackConfig?
	public let autoFollowIndex: InstanceAutoFollowIndexConfig?

	public init(
		autoFollowBack: InstanceAutoFollowBackConfig? = nil,
		autoFollowIndex: InstanceAutoFollowIndexConfig? = nil
	) {
		self.autoFollowBack = autoFollowBack
		self.autoFollowIndex = autoFollowIndex
	}
}

public struct InstanceAutoFollowBackConfig: Codable, Hashable, Sendable {
	public let enabled: Bool

	public init(enabled: Bool = false) {
		self.enabled = enabled
	}
}

public struct InstanceAutoFollowIndexConfig: Codable, Hashable, Sendable {
	public let enabled: Bool
	public let indexUrl: String?

	public init(enabled: Bool = false, indexUrl: String? = nil) {
		self.enabled = enabled
		self.indexUrl = indexUrl
	}
}

// MARK: - Extensions

extension Instance {
	/// Summary version for lists and references
	public var summary: InstanceSummary {
		InstanceSummary(
			id: id,
			host: host,
			name: effectiveName,
			avatar: primaryAvatar,
			isDefault: isDefault
		)
	}
}

/// Lightweight summary of an Instance for list views and references
public struct InstanceSummary: Codable, Hashable, Identifiable, Sendable {
	/// Unique identifier
	public let id: UUID

	/// Instance hostname
	public let host: String

	/// Display name
	public let name: String

	/// Primary avatar
	public let avatar: ActorImage?

	/// Whether this is the default instance
	public let isDefault: Bool

	/// Base URL
	public var baseURL: URL? {
		URL(string: "https://\(host)")
	}

	public init(
		id: UUID,
		host: String,
		name: String,
		avatar: ActorImage? = nil,
		isDefault: Bool = false
	) {
		self.id = id
		self.host = host
		self.name = name
		self.avatar = avatar
		self.isDefault = isDefault
	}
}
