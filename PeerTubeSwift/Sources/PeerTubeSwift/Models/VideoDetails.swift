//
//  VideoDetails.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

import Foundation

/// Extended video information with full details
public struct VideoDetails: Codable, Hashable, Identifiable, Sendable {
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

	/// Full description (not truncated)
	public let description: String?

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

	/// Full channel information
	public let channel: VideoChannel

	/// Full account information
	public let account: Account

	/// User's viewing history for this video
	public let userHistory: UserVideoHistory?

	/// Available video files and streams
	public let files: [VideoFile]

	/// Available streaming playlists (HLS, etc.)
	public let streamingPlaylists: [VideoStreamingPlaylist]

	/// Video tags
	public let tags: [String]

	/// Support text for donations
	public let support: String?

	/// Download enabled flag
	public let downloadEnabled: Bool

	/// Comments enabled flag
	public let commentsEnabled: Bool

	/// Pluggable data (extensions)
	public let pluginData: [String: String]?

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

	/// Best quality video file available
	public var bestQualityFile: VideoFile? {
		files.max { lhs, rhs in
			lhs.resolution.id < rhs.resolution.id
		}
	}

	/// Lowest quality video file available
	public var lowestQualityFile: VideoFile? {
		files.min { lhs, rhs in
			lhs.resolution.id < rhs.resolution.id
		}
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
		description: String? = nil,
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
		channel: VideoChannel,
		account: Account,
		userHistory: UserVideoHistory? = nil,
		files: [VideoFile] = [],
		streamingPlaylists: [VideoStreamingPlaylist] = [],
		tags: [String] = [],
		support: String? = nil,
		downloadEnabled: Bool = true,
		commentsEnabled: Bool = true,
		pluginData: [String: String]? = nil
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
		self.description = description
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
		self.channel = channel
		self.account = account
		self.userHistory = userHistory
		self.files = files
		self.streamingPlaylists = streamingPlaylists
		self.tags = tags
		self.support = support
		self.downloadEnabled = downloadEnabled
		self.commentsEnabled = commentsEnabled
		self.pluginData = pluginData
	}
}

/// Video file information for different qualities/formats
public struct VideoFile: Codable, Hashable, Sendable {
	/// File identifier
	public let id: Int?

	/// Video resolution information
	public let resolution: VideoResolution

	/// File size in bytes
	public let size: Int?

	/// Video fps (frames per second)
	public let fps: Int?

	/// File extension
	public let fileExtension: String

	/// Download URL
	public let fileDownloadUrl: String?

	/// Torrent download URL
	public let torrentDownloadUrl: String?

	/// Torrent file URL
	public let torrentUrl: String?

	/// Magnet URI for P2P
	public let magnetUri: String?

	/// File metadata URL
	public let metadataUrl: String?

	public init(
		id: Int? = nil,
		resolution: VideoResolution,
		size: Int? = nil,
		fps: Int? = nil,
		fileExtension: String,
		fileDownloadUrl: String? = nil,
		torrentDownloadUrl: String? = nil,
		torrentUrl: String? = nil,
		magnetUri: String? = nil,
		metadataUrl: String? = nil
	) {
		self.id = id
		self.resolution = resolution
		self.size = size
		self.fps = fps
		self.fileExtension = fileExtension
		self.fileDownloadUrl = fileDownloadUrl
		self.torrentDownloadUrl = torrentDownloadUrl
		self.torrentUrl = torrentUrl
		self.magnetUri = magnetUri
		self.metadataUrl = metadataUrl
	}
}

/// Video resolution information
public struct VideoResolution: Codable, Hashable, Sendable {
	/// Resolution identifier (height in pixels)
	public let id: Int

	/// Human-readable label
	public let label: String

	public init(id: Int, label: String) {
		self.id = id
		self.label = label
	}
}

/// Video streaming playlist (HLS, DASH, etc.)
public struct VideoStreamingPlaylist: Codable, Hashable, Sendable {
	/// Playlist identifier
	public let id: Int

	/// Playlist type (1 = HLS)
	public let type: Int

	/// Playlist URL
	public let playlistUrl: String

	/// Segment SHA256 URL
	public let segmentsSha256Url: String

	/// Available files in this playlist
	public let files: [VideoFile]

	/// Redundancy information
	public let redundancies: [VideoStreamingPlaylistRedundancy]?

	public init(
		id: Int,
		type: Int,
		playlistUrl: String,
		segmentsSha256Url: String,
		files: [VideoFile] = [],
		redundancies: [VideoStreamingPlaylistRedundancy]? = nil
	) {
		self.id = id
		self.type = type
		self.playlistUrl = playlistUrl
		self.segmentsSha256Url = segmentsSha256Url
		self.files = files
		self.redundancies = redundancies
	}
}

/// Streaming playlist redundancy information
public struct VideoStreamingPlaylistRedundancy: Codable, Hashable, Sendable {
	/// Base URL for redundant files
	public let baseUrl: String

	public init(baseUrl: String) {
		self.baseUrl = baseUrl
	}
}

// MARK: - Extensions

extension VideoDetails {
	/// Convert to basic Video model
	public var video: Video {
		Video(
			id: id,
			uuid: uuid,
			shortUUID: shortUUID,
			isLive: isLive,
			liveSchedules: liveSchedules,
			createdAt: createdAt,
			publishedAt: publishedAt,
			updatedAt: updatedAt,
			originallyPublishedAt: originallyPublishedAt,
			category: category,
			licence: licence,
			language: language,
			privacy: privacy,
			truncatedDescription: description?.prefix(250).description,
			duration: duration,
			aspectRatio: aspectRatio,
			isLocal: isLocal,
			name: name,
			thumbnailPath: thumbnailPath,
			previewPath: previewPath,
			embedPath: embedPath,
			views: views,
			likes: likes,
			dislikes: dislikes,
			comments: comments,
			nsfw: nsfw,
			nsfwFlags: nsfwFlags,
			nsfwSummary: nsfwSummary,
			waitTranscoding: waitTranscoding,
			state: state,
			scheduledUpdate: scheduledUpdate,
			blacklisted: blacklisted,
			blacklistedReason: blacklistedReason,
			account: account.summary,
			channel: channel.summary,
			userHistory: userHistory
		)
	}

	/// Summary version for lists
	public var summary: VideoSummary {
		VideoSummary(
			id: id,
			uuid: uuid,
			name: name,
			duration: duration,
			thumbnailPath: thumbnailPath,
			views: views,
			createdAt: createdAt,
			channel: channel.summary
		)
	}
}

// MARK: - Codable Conformance

extension VideoDetails {
	private enum CodingKeys: String, CodingKey {
		case id, uuid, shortUUID, isLive, liveSchedules
		case createdAt, publishedAt, updatedAt, originallyPublishedAt
		case category, licence, language, privacy, description
		case duration, aspectRatio, isLocal, name
		case thumbnailPath, previewPath, embedPath
		case views, likes, dislikes, comments
		case nsfw, nsfwFlags, nsfwSummary
		case waitTranscoding, state, scheduledUpdate
		case blacklisted, blacklistedReason
		case channel, account, userHistory
		case files, streamingPlaylists, tags, support
		case downloadEnabled, commentsEnabled, pluginData
	}
}
