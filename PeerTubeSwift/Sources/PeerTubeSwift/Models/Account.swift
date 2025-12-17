//
//  Account.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

import Foundation

/// Account model representing a PeerTube user account
public struct Account: Codable, Hashable, Identifiable, Sendable {
	/// Unique identifier
	public let id: Int

	/// ActivityPub URL
	public let url: String

	/// Immutable username
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

	/// User ID if this is a local account
	public let userId: Int?

	/// Display name (editable)
	public let displayName: String

	/// Account description/bio
	public let description: String?

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

	/// Whether this account is from the local instance
	public var isLocal: Bool {
		userId != nil
	}

	/// Display name or fallback to username
	public var effectiveDisplayName: String {
		displayName.isEmpty ? name : displayName
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
		updatedAt: Date,
		userId: Int? = nil,
		displayName: String,
		description: String? = nil
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
		self.userId = userId
		self.displayName = displayName
		self.description = description
	}
}

// MARK: - Extensions

extension Account {
	/// Convert to Actor base type
	public var actor: Actor {
		Actor(
			id: id,
			url: url,
			name: name,
			avatars: avatars,
			host: host,
			hostRedundancyAllowed: hostRedundancyAllowed,
			followingCount: followingCount,
			followersCount: followersCount,
			createdAt: createdAt,
			updatedAt: updatedAt
		)
	}

	/// Summary version for references and lists
	public var summary: AccountSummary {
		AccountSummary(
			id: id,
			name: name,
			host: host,
			displayName: displayName,
			avatar: primaryAvatar
		)
	}
}

/// Lightweight summary of an Account for list views and references
public struct AccountSummary: Codable, Hashable, Identifiable, Sendable {
	/// Unique identifier
	public let id: Int

	/// Username
	public let name: String

	/// Host server domain
	public let host: String

	/// Display name
	public let displayName: String

	/// Primary avatar image
	public let avatar: ActorImage?

	/// Full actor handle
	public var handle: String {
		"\(name)@\(host)"
	}

	/// Display name or fallback to username
	public var effectiveDisplayName: String {
		displayName.isEmpty ? name : displayName
	}

	public init(
		id: Int,
		name: String,
		host: String,
		displayName: String,
		avatar: ActorImage? = nil
	) {
		self.id = id
		self.name = name
		self.host = host
		self.displayName = displayName
		self.avatar = avatar
	}
}

// MARK: - Codable Conformance

extension Account {
	private enum CodingKeys: String, CodingKey {
		case id, url, name, avatars, host
		case hostRedundancyAllowed, followingCount, followersCount
		case createdAt, updatedAt, userId, displayName, description
	}
}

extension AccountSummary {
	private enum CodingKeys: String, CodingKey {
		case id, name, host, displayName, avatar
	}
}
