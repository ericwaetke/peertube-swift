//
//  Actor.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

import Foundation

/// Actor image (avatar or banner)
public struct ActorImage: Codable, Hashable, Sendable {
	/// Unique identifier for the image
	public let id: Int?

	/// Image filename
	public let filename: String

	/// Image file extension
	public let fileExtension: String?

	/// Image width in pixels
	public let width: Int?

	/// Image height in pixels
	public let height: Int?

	/// Size of the image file in bytes
	public let size: Int?

	/// Creation timestamp
	public let createdAt: Date?

	/// Last update timestamp
	public let updatedAt: Date?

	/// Full URL to the image
	public var url: String? {
		guard !filename.isEmpty else { return nil }
		// URL construction will be handled by the API client based on instance host
		return "/lazy-static/avatars/\(filename)"
	}

	public init(
		id: Int? = nil,
		filename: String,
		fileExtension: String? = nil,
		width: Int? = nil,
		height: Int? = nil,
		size: Int? = nil,
		createdAt: Date? = nil,
		updatedAt: Date? = nil
	) {
		self.id = id
		self.filename = filename
		self.fileExtension = fileExtension
		self.width = width
		self.height = height
		self.size = size
		self.createdAt = createdAt
		self.updatedAt = updatedAt
	}
}

/// Base actor model for Account and VideoChannel
public struct Actor: Codable, Hashable, Identifiable, Sendable {
	/// Unique identifier
	public let id: Int

	/// ActivityPub URL
	public let url: String

	/// Immutable name/username of the actor
	public let name: String

	/// Array of avatar images in different sizes
	public let avatars: [ActorImage]

	/// Host server domain
	public let host: String

	/// Whether this actor's host allows redundancy
	public let hostRedundancyAllowed: Bool?

	/// Number of accounts this actor follows
	public let followingCount: Int

	/// Number of followers this actor has
	public let followersCount: Int

	/// Creation timestamp
	public let createdAt: Date

	/// Last update timestamp
	public let updatedAt: Date

	// MARK: - Computed Properties

	/// Full actor handle (name@host)
	public var handle: String {
		"\(name)@\(host)"
	}

	/// Primary avatar (largest available)
	public var primaryAvatar: ActorImage? {
		avatars.max { lhs, rhs in
			(lhs.width ?? 0) < (rhs.width ?? 0)
		}
	}

	/// Small avatar (for list views)
	public var smallAvatar: ActorImage? {
		avatars.min { lhs, rhs in
			(lhs.width ?? Int.max) < (rhs.width ?? Int.max)
		}
	}

	/// Whether this actor is from the local instance
	public var isLocal: Bool {
		host == "local" || host.isEmpty
	}

	// MARK: - Initialization

	public init(
		id: Int,
		url: String,
		name: String,
		avatars: [ActorImage] = [],
		host: String,
		hostRedundancyAllowed: Bool? = nil,
		followingCount: Int = 0,
		followersCount: Int = 0,
		createdAt: Date,
		updatedAt: Date
	) {
		self.id = id
		self.url = url
		self.name = name
		self.avatars = avatars
		self.host = host
		self.hostRedundancyAllowed = hostRedundancyAllowed
		self.followingCount = followingCount
		self.followersCount = followersCount
		self.createdAt = createdAt
		self.updatedAt = updatedAt
	}
}

// MARK: - Extensions

extension Actor {
	/// Summary version of actor with essential fields only
	public var summary: ActorSummary {
		ActorSummary(
			id: id,
			name: name,
			host: host,
			avatar: primaryAvatar
		)
	}
}

/// Lightweight summary of an Actor for list views and references
public struct ActorSummary: Codable, Hashable, Identifiable, Sendable {
	/// Unique identifier
	public let id: Int

	/// Actor name/username
	public let name: String

	/// Host server domain
	public let host: String

	/// Primary avatar image
	public let avatar: ActorImage?

	/// Full actor handle
	public var handle: String {
		"\(name)@\(host)"
	}

	public init(
		id: Int,
		name: String,
		host: String,
		avatar: ActorImage? = nil
	) {
		self.id = id
		self.name = name
		self.host = host
		self.avatar = avatar
	}
}
