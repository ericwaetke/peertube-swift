//
//  VideoChannel.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

import Foundation

/// VideoChannel model representing a PeerTube video channel
public struct VideoChannel: Codable, Hashable, Identifiable, Sendable {
    /// Unique identifier
    public let id: Int

    /// ActivityPub URL
    public let url: String

    /// Immutable channel name
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

    /// Display name (editable)
    public let displayName: String

    /// Channel description
    public let description: String?

    /// Support text for funding/donations
    public let support: String?

    /// Whether this is a local channel
    public let isLocal: Bool

    /// Banner images for the channel
    public let banners: [ActorImage]

    /// Account that owns this channel
    public let ownerAccount: AccountSummary

    // MARK: - Computed Properties

    /// Full channel handle (name@host)
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

    /// Primary banner (largest available)
    public var primaryBanner: ActorImage? {
        banners.max { lhs, rhs in
            (lhs.width ?? 0) < (rhs.width ?? 0)
        }
    }

    /// Display name or fallback to channel name
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
        displayName: String,
        description: String? = nil,
        support: String? = nil,
        isLocal: Bool = false,
        banners: [ActorImage] = [],
        ownerAccount: AccountSummary
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
        self.displayName = displayName
        self.description = description
        self.support = support
        self.isLocal = isLocal
        self.banners = banners
        self.ownerAccount = ownerAccount
    }
}

// MARK: - Extensions

public extension VideoChannel {
    /// Convert to Actor base type
    var actor: Actor {
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
    var summary: VideoChannelSummary {
        VideoChannelSummary(
            id: id,
            name: name,
            host: host,
            displayName: displayName,
            avatar: primaryAvatar
        )
    }
}

/// Lightweight summary of a VideoChannel for list views and references
public struct VideoChannelSummary: Codable, Hashable, Identifiable, Sendable {
    /// Unique identifier
    public let id: Int

    /// Channel name
    public let name: String

    /// Host server domain
    public let host: String

    /// Display name
    public let displayName: String

    /// Primary avatar image
    public let avatar: ActorImage?

    /// Full channel handle
    public var handle: String {
        "\(name)@\(host)"
    }

    /// Display name or fallback to channel name
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

extension VideoChannel {
    private enum CodingKeys: String, CodingKey {
        case id, url, name, avatars, host
        case hostRedundancyAllowed, followingCount, followersCount
        case createdAt, updatedAt, displayName, description, support
        case isLocal, banners, ownerAccount
    }
}

extension VideoChannelSummary {
    private enum CodingKeys: String, CodingKey {
        case id, name, host, displayName, avatar
    }
}
