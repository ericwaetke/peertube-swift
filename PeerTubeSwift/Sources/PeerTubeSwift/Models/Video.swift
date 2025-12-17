//
//  Video.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

import Foundation

/// Video privacy levels
public enum VideoPrivacy: Int, Codable, CaseIterable {
	case `public` = 1
	case unlisted = 2
	case `private` = 3
	case `internal` = 4
	case passwordProtected = 5
}

/// Video state during processing
public enum VideoState: Int, Codable, CaseIterable {
	case published = 1
	case toTranscode = 2
	case toImport = 3
	case waitingForLive = 4
	case liveEnded = 5
	case toMoveToObjectStorage = 6
	case transcodeError = 7
	case toEdit = 8
	case edited = 9
	case toMoveToObjectStorageFailed = 10
}

/// Video category
public struct VideoCategory: Codable, Hashable {
	public let id: Int
	public let label: String
}

/// Video licence
public struct VideoLicence: Codable, Hashable {
	public let id: Int
	public let label: String
}

/// Video language
public struct VideoLanguage: Codable, Hashable {
	public let id: String
	public let label: String
}

/// NSFW (Not Safe For Work) flags
public struct NSFWFlag: Codable, Hashable {
	public let id: Int
	public let label: String
}

/// Live video schedule
public struct LiveSchedule: Codable, Hashable {
	/// Schedule identifier
	public let id: Int

	/// Planned start time
	public let scheduledStartTime: Date

	/// Planned end time
	public let scheduledEndTime: Date?

	/// Whether the schedule is active
	public let isActive: Bool
}

/// Video scheduled update
public struct VideoScheduledUpdate: Codable, Hashable {
	/// Update timestamp
	public let updateAt: Date

	/// New privacy level
	public let privacy: VideoPrivacy?
}

/// User's viewing history for a video
public struct UserVideoHistory: Codable, Hashable {
	/// Current playback position in seconds
	public let currentTime: Int
}

/// Core Video model representing a PeerTube video
public struct Video: Codable, Hashable, Identifiable {
	/// Unique numeric identifier
	public let id: Int

	/// Universal UUID identifier
	public let uuid: String

	/// Short UUID for URLs
	public let shortUUID: String

	/// Whether this is a live stream
	public let isLive: Bool

	/// Live stream schedules
	public let liveSchedules: [LiveSchedule]

	/// Creation timestamp
	public let createdAt: Date

	/// Publication timestamp
	public let publishedAt: Date?

	/// Last update timestamp
	public let updatedAt: Date

	/// Original publication date (if imported)
	public let originallyPublishedAt: Date?

	/// Video category
	public let category: VideoCategory?

	/// Video licence
	public let licence: VideoLicence?

	/// Primary language
	public let language: VideoLanguage?

	/// Privacy level
	public let privacy: VideoPrivacy

	/// Truncated description (250 chars max)
	public let truncatedDescription: String?

	/// Duration in seconds
	public let duration: Int

	/// Aspect ratio of the video
	public let aspectRatio: Double?

	/// Whether this is a local video
	public let isLocal: Bool

	/// Video title
	public let name: String

	/// Thumbnail image path
	public let thumbnailPath: String?

	/// Preview image path
	public let previewPath: String?

	/// Embed player path
	public let embedPath: String?

	/// View count
	public let views: Int

	/// Like count
	public let likes: Int

	/// Dislike count
	public let dislikes: Int

	/// Comment count
	public let comments: Int?

	/// Whether content is NSFW
	public let nsfw: Bool

	/// NSFW flags (detailed reasons)
	public let nsfwFlags: [NSFWFlag]

	/// NSFW summary description
	public let nsfwSummary: String?

	/// Whether video is waiting for transcoding
	public let waitTranscoding: Bool?

	/// Current processing state
	public let state: VideoState

	/// Scheduled update information
	public let scheduledUpdate: VideoScheduledUpdate?

	/// Whether video is blacklisted
	public let blacklisted: Bool?

	/// Reason for blacklisting
	public let blacklistedReason: String?

	/// Account that uploaded the video
	public let account: AccountSummary

	/// Channel where video was published
	public let channel: VideoChannelSummary

	/// User's viewing history for this video
	public let userHistory: UserVideoHistory?

	// MARK: - Computed Properties

	/// Whether the video is published and available
	public var isPublished: Bool {
		state == .published && privacy != .private
	}

	/// Whether the video is currently live
	public var isCurrentlyLive: Bool {
		isLive && state == .waitingForLive
	}

	/// Duration formatted as MM:SS or HH:MM:SS
	public var formattedDuration: String {
		let hours = duration / 3600
		let minutes = (duration % 3600) / 60
		let seconds = duration % 60

		if hours > 0 {
			return String(format: "%d:%02d:%02d", hours, minutes, seconds)
		} else {
			return String(format: "%d:%02d", minutes, seconds)
		}
	}

	/// Like ratio (0.0 to 1.0)
	public var likeRatio: Double {
		let totalRatings = likes + dislikes
		guard totalRatings > 0 else { return 0.5 }
		return Double(likes) / Double(totalRatings)
	}

	/// Whether this video has any NSFW content
	public var hasNSFWContent: Bool {
		nsfw || !nsfwFlags.isEmpty
	}

	// MARK: - Initialization

	public init(
		id: Int,
		uuid: String,
		shortUUID: String,
		isLive: Bool = false,
		liveSchedules: [LiveSchedule] = [],
		createdAt: Date,
		publishedAt: Date? = nil,
		updatedAt: Date,
		originallyPublishedAt: Date? = nil,
		category: VideoCategory? = nil,
		licence: VideoLicence? = nil,
		language: VideoLanguage? = nil,
		privacy: VideoPrivacy,
		truncatedDescription: String? = nil,
		duration: Int,
		aspectRatio: Double? = nil,
		isLocal: Bool = false,
		name: String,
		thumbnailPath: String? = nil,
		previewPath: String? = nil,
		embedPath: String? = nil,
		views: Int = 0,
		likes: Int = 0,
		dislikes: Int = 0,
		comments: Int? = nil,
		nsfw: Bool = false,
		nsfwFlags: [NSFWFlag] = [],
		nsfwSummary: String? = nil,
		waitTranscoding: Bool? = nil,
		state: VideoState,
		scheduledUpdate: VideoScheduledUpdate? = nil,
		blacklisted: Bool? = nil,
		blacklistedReason: String? = nil,
		account: AccountSummary,
		channel: VideoChannelSummary,
		userHistory: UserVideoHistory? = nil
	) {
		self.id = id
		self.uuid = uuid
		self.shortUUID = shortUUID
		self.isLive = isLive
		self.liveSchedules = liveSchedules
		self.createdAt = createdAt
		self.publishedAt = publishedAt
		self.updatedAt = updatedAt
		self.originallyPublishedAt = originallyPublishedAt
		self.category = category
		self.licence = licence
		self.language = language
		self.privacy = privacy
		self.truncatedDescription = truncatedDescription
		self.duration = duration
		self.aspectRatio = aspectRatio
		self.isLocal = isLocal
		self.name = name
		self.thumbnailPath = thumbnailPath
		self.previewPath = previewPath
		self.embedPath = embedPath
		self.views = views
		self.likes = likes
		self.dislikes = dislikes
		self.comments = comments
		self.nsfw = nsfw
		self.nsfwFlags = nsfwFlags
		self.nsfwSummary = nsfwSummary
		self.waitTranscoding = waitTranscoding
		self.state = state
		self.scheduledUpdate = scheduledUpdate
		self.blacklisted = blacklisted
		self.blacklistedReason = blacklistedReason
		self.account = account
		self.channel = channel
		self.userHistory = userHistory
	}
}

// MARK: - Extensions

extension Video {
	/// Summary version for lists and references
	public var summary: VideoSummary {
		VideoSummary(
			id: id,
			uuid: uuid,
			name: name,
			duration: duration,
			thumbnailPath: thumbnailPath,
			views: views,
			createdAt: createdAt,
			channel: channel
		)
	}
}

/// Lightweight summary of a Video for list views
public struct VideoSummary: Codable, Hashable, Identifiable {
	/// Unique identifier
	public let id: Int

	/// Universal UUID
	public let uuid: String

	/// Video title
	public let name: String

	/// Duration in seconds
	public let duration: Int

	/// Thumbnail path
	public let thumbnailPath: String?

	/// View count
	public let views: Int

	/// Creation date
	public let createdAt: Date

	/// Channel reference
	public let channel: VideoChannelSummary

	/// Duration formatted as MM:SS or HH:MM:SS
	public var formattedDuration: String {
		let hours = duration / 3600
		let minutes = (duration % 3600) / 60
		let seconds = duration % 60

		if hours > 0 {
			return String(format: "%d:%02d:%02d", hours, minutes, seconds)
		} else {
			return String(format: "%d:%02d", minutes, seconds)
		}
	}

	public init(
		id: Int,
		uuid: String,
		name: String,
		duration: Int,
		thumbnailPath: String? = nil,
		views: Int = 0,
		createdAt: Date,
		channel: VideoChannelSummary
	) {
		self.id = id
		self.uuid = uuid
		self.name = name
		self.duration = duration
		self.thumbnailPath = thumbnailPath
		self.views = views
		self.createdAt = createdAt
		self.channel = channel
	}
}

// MARK: - Codable Conformance

extension Video {
	private enum CodingKeys: String, CodingKey {
		case id, uuid, shortUUID, isLive, liveSchedules
		case createdAt, publishedAt, updatedAt, originallyPublishedAt
		case category, licence, language, privacy
		case truncatedDescription, duration, aspectRatio, isLocal, name
		case thumbnailPath, previewPath, embedPath
		case views, likes, dislikes, comments
		case nsfw, nsfwFlags, nsfwSummary
		case waitTranscoding, state, scheduledUpdate
		case blacklisted, blacklistedReason
		case account, channel, userHistory
	}
}

extension VideoSummary {
	private enum CodingKeys: String, CodingKey {
		case id, uuid, name, duration, thumbnailPath, views, createdAt, channel
	}
}

extension VideoPrivacy {
	/// Human-readable description
	public var description: String {
		switch self {
		case .public: return "Public"
		case .unlisted: return "Unlisted"
		case .private: return "Private"
		case .internal: return "Internal"
		case .passwordProtected: return "Password Protected"
		}
	}
}

extension VideoState {
	/// Human-readable description
	public var description: String {
		switch self {
		case .published: return "Published"
		case .toTranscode: return "To Transcode"
		case .toImport: return "To Import"
		case .waitingForLive: return "Waiting for Live"
		case .liveEnded: return "Live Ended"
		case .toMoveToObjectStorage: return "To Move to Object Storage"
		case .transcodeError: return "Transcode Error"
		case .toEdit: return "To Edit"
		case .edited: return "Edited"
		case .toMoveToObjectStorageFailed: return "Move to Object Storage Failed"
		}
	}

	/// Whether this state indicates the video is ready for viewing
	public var isViewable: Bool {
		switch self {
		case .published, .waitingForLive:
			return true
		default:
			return false
		}
	}
}
