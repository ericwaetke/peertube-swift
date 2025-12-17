//
//  VideoPlayerUtils.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

import AVFoundation
import Foundation

/// Utilities for video player functionality
public enum VideoPlayerUtils {

	// MARK: - Format Detection

	/// Check if a URL is an HLS playlist
	/// - Parameter url: URL to check
	/// - Returns: True if URL appears to be HLS
	public static func isHLSURL(_ url: URL) -> Bool {
		let urlString = url.absoluteString.lowercased()
		return urlString.contains(".m3u8") || urlString.contains("hls")
	}

	/// Check if a URL is a DASH manifest
	/// - Parameter url: URL to check
	/// - Returns: True if URL appears to be DASH
	public static func isDASHURL(_ url: URL) -> Bool {
		let urlString = url.absoluteString.lowercased()
		return urlString.contains(".mpd") || urlString.contains("dash")
	}

	/// Check if a video format is supported by AVPlayer
	/// - Parameter url: Video URL to check
	/// - Returns: True if format is supported
	public static func isFormatSupported(_ url: URL) -> Bool {
		let pathExtension = url.pathExtension.lowercased()
		let supportedExtensions = [
			"mp4", "m4v", "mov", "avi", "mkv", "webm",
			"m3u8", "mpd", "ts", "flv",
		]
		return supportedExtensions.contains(pathExtension) || isHLSURL(url) || isDASHURL(url)
	}

	/// Get the preferred video format from available options
	/// - Parameter urls: Array of video URLs
	/// - Returns: Best URL for playback, or nil if none suitable
	public static func getPreferredVideoURL(from urls: [URL]) -> URL? {
		// Priority: HLS > MP4 > other formats
		if let hlsURL = urls.first(where: { isHLSURL($0) }) {
			return hlsURL
		}

		if let mp4URL = urls.first(where: { $0.pathExtension.lowercased() == "mp4" }) {
			return mp4URL
		}

		return urls.first(where: { isFormatSupported($0) })
	}

	// MARK: - Quality Selection

	/// Extract quality information from VideoDetails
	/// - Parameter video: VideoDetails containing streaming information
	/// - Returns: Array of available quality options
	public static func extractQualityOptions(from video: VideoDetails) -> [VideoQualityOption] {
		var options: [VideoQualityOption] = []

		// Add HLS streaming options
		for playlist in video.streamingPlaylists where playlist.type == 1 {
			if let url = URL(string: playlist.playlistUrl) {
				// HLS playlists often contain multiple qualities
				options.append(
					VideoQualityOption(
						label: "Auto (HLS)",
						resolution: 9999,  // Highest priority
						url: url,
						isHLS: true
					))

				// Add individual quality options if available
				for file in playlist.files {
					options.append(
						VideoQualityOption(
							label: file.resolution.label,
							resolution: file.resolution.id,
							url: url,
							isHLS: true
						))
				}
			}
		}

		// Add direct file options
		for file in video.files {
			if let downloadUrl = file.fileDownloadUrl,
				let url = URL(string: downloadUrl)
			{
				options.append(
					VideoQualityOption(
						label: file.resolution.label,
						resolution: file.resolution.id,
						url: url,
						isHLS: false
					))
			}
		}

		// Remove duplicates and sort by resolution (highest first)
		let uniqueOptions = Array(Set(options))
		return uniqueOptions.sorted { $0.resolution > $1.resolution }
	}

	/// Get the best quality URL from VideoDetails
	/// - Parameter video: VideoDetails containing streaming information
	/// - Returns: Best quality URL available
	public static func getBestQualityURL(from video: VideoDetails) -> URL? {
		let options = extractQualityOptions(from: video)
		return options.first?.url
	}

	/// Get a specific quality URL from VideoDetails
	/// - Parameters:
	///   - video: VideoDetails containing streaming information
	///   - targetResolution: Desired resolution height (e.g., 720, 1080)
	/// - Returns: URL for the specified quality, or best available
	public static func getQualityURL(from video: VideoDetails, targetResolution: Int) -> URL? {
		let options = extractQualityOptions(from: video)

		// Find exact match
		if let exactMatch = options.first(where: { $0.resolution == targetResolution }) {
			return exactMatch.url
		}

		// Find closest lower resolution
		let lowerOptions = options.filter { $0.resolution <= targetResolution }
		if let closestLower = lowerOptions.first {
			return closestLower.url
		}

		// Fallback to best available
		return options.first?.url
	}

	// MARK: - URL Building

	/// Build a complete streaming URL for a PeerTube instance
	/// - Parameters:
	///   - instanceURL: Base URL of the PeerTube instance
	///   - path: Relative path to the video resource
	/// - Returns: Complete URL, or nil if invalid
	public static func buildStreamingURL(instanceURL: URL, path: String) -> URL? {
		guard !path.isEmpty else { return nil }

		// Handle absolute URLs
		if path.hasPrefix("http://") || path.hasPrefix("https://") {
			return URL(string: path)
		}

		// Build relative URL
		let cleanPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
		return instanceURL.appendingPathComponent(cleanPath)
	}

	/// Extract thumbnail URL from VideoDetails
	/// - Parameters:
	///   - video: VideoDetails containing thumbnail information
	///   - instanceURL: Base URL of the PeerTube instance
	/// - Returns: Complete thumbnail URL, or nil if not available
	public static func getThumbnailURL(from video: VideoDetails, instanceURL: URL) -> URL? {
		guard let thumbnailPath = video.thumbnailPath else { return nil }
		return buildStreamingURL(instanceURL: instanceURL, path: thumbnailPath)
	}

	/// Extract preview image URL from VideoDetails
	/// - Parameters:
	///   - video: VideoDetails containing preview information
	///   - instanceURL: Base URL of the PeerTube instance
	/// - Returns: Complete preview URL, or nil if not available
	public static func getPreviewURL(from video: VideoDetails, instanceURL: URL) -> URL? {
		guard let previewPath = video.previewPath else { return nil }
		return buildStreamingURL(instanceURL: instanceURL, path: previewPath)
	}

	// MARK: - Playback Utilities

	/// Calculate optimal buffer size based on connection quality
	/// - Parameter connectionType: Type of network connection
	/// - Returns: Recommended buffer duration in seconds
	public static func getRecommendedBufferDuration(for connectionType: NetworkConnectionType)
		-> TimeInterval
	{
		switch connectionType {
		case .wifi:
			return 30.0
		case .cellular4G, .cellular5G:
			return 15.0
		case .cellular3G:
			return 10.0
		case .cellular2G:
			return 5.0
		case .unknown:
			return 20.0
		}
	}

	/// Get recommended quality based on device and connection
	/// - Parameters:
	///   - deviceType: Type of device (iPhone, iPad, etc.)
	///   - connectionType: Network connection type
	/// - Returns: Recommended maximum resolution
	public static func getRecommendedQuality(
		for deviceType: DeviceType,
		connectionType: NetworkConnectionType
	) -> Int {
		switch (deviceType, connectionType) {
		case (.iphone, .wifi), (.iphone, .cellular5G):
			return 1080
		case (.iphone, .cellular4G):
			return 720
		case (.iphone, _):
			return 480
		case (.ipad, .wifi), (.ipad, .cellular5G):
			return 1440
		case (.ipad, .cellular4G):
			return 1080
		case (.ipad, _):
			return 720
		case (.mac, .wifi):
			return 2160
		case (.mac, _):
			return 1080
		case (.unknown, _):
			return 720
		}
	}

	/// Format duration for display
	/// - Parameter duration: Duration in seconds
	/// - Returns: Formatted string (e.g., "1:23", "1:23:45")
	public static func formatDuration(_ duration: TimeInterval) -> String {
		guard duration.isFinite && duration >= 0 else { return "0:00" }

		let totalSeconds = Int(duration)
		let hours = totalSeconds / 3600
		let minutes = (totalSeconds % 3600) / 60
		let seconds = totalSeconds % 60

		if hours > 0 {
			return String(format: "%d:%02d:%02d", hours, minutes, seconds)
		} else {
			return String(format: "%d:%02d", minutes, seconds)
		}
	}

	/// Format file size for display
	/// - Parameter sizeInBytes: Size in bytes
	/// - Returns: Formatted string (e.g., "1.2 MB", "850 KB")
	public static func formatFileSize(_ sizeInBytes: Int) -> String {
		let formatter = ByteCountFormatter()
		formatter.allowedUnits = [.useKB, .useMB, .useGB]
		formatter.countStyle = .file
		return formatter.string(fromByteCount: Int64(sizeInBytes))
	}

	/// Get playback speed options
	/// - Returns: Array of playback speed options
	public static func getPlaybackSpeedOptions() -> [PlaybackSpeedOption] {
		return [
			PlaybackSpeedOption(speed: 0.25, label: "0.25x"),
			PlaybackSpeedOption(speed: 0.5, label: "0.5x"),
			PlaybackSpeedOption(speed: 0.75, label: "0.75x"),
			PlaybackSpeedOption(speed: 1.0, label: "Normal"),
			PlaybackSpeedOption(speed: 1.25, label: "1.25x"),
			PlaybackSpeedOption(speed: 1.5, label: "1.5x"),
			PlaybackSpeedOption(speed: 1.75, label: "1.75x"),
			PlaybackSpeedOption(speed: 2.0, label: "2x"),
		]
	}
}

// MARK: - Supporting Types

/// Network connection types for quality recommendations
public enum NetworkConnectionType: CaseIterable, Sendable {
	case wifi
	case cellular5G
	case cellular4G
	case cellular3G
	case cellular2G
	case unknown

	public var displayName: String {
		switch self {
		case .wifi: return "Wi-Fi"
		case .cellular5G: return "5G"
		case .cellular4G: return "4G"
		case .cellular3G: return "3G"
		case .cellular2G: return "2G"
		case .unknown: return "Unknown"
		}
	}
}

/// Device types for quality recommendations
public enum DeviceType: CaseIterable, Sendable {
	case iphone
	case ipad
	case mac
	case unknown

	public var displayName: String {
		switch self {
		case .iphone: return "iPhone"
		case .ipad: return "iPad"
		case .mac: return "Mac"
		case .unknown: return "Unknown"
		}
	}

	/// Detect current device type
	public static var current: DeviceType {
		#if os(iOS)
			if UIDevice.current.userInterfaceIdiom == .pad {
				return .ipad
			} else {
				return .iphone
			}
		#elseif os(macOS)
			return .mac
		#else
			return .unknown
		#endif
	}
}

/// Playback speed option
public struct PlaybackSpeedOption: Sendable, Identifiable, Hashable {
	public let id = UUID()
	public let speed: Float
	public let label: String

	public init(speed: Float, label: String) {
		self.speed = speed
		self.label = label
	}
}

// MARK: - Extensions

extension VideoQualityOption {
	/// Create quality option from VideoFile
	/// - Parameters:
	///   - file: VideoFile containing quality information
	///   - baseURL: Base URL for building complete URLs
	///   - isHLS: Whether this is an HLS stream
	/// - Returns: VideoQualityOption or nil if URL cannot be built
	public static func from(
		file: VideoFile,
		baseURL: URL,
		isHLS: Bool = false
	) -> VideoQualityOption? {
		let urlString =
			isHLS ? file.metadataUrl ?? file.fileDownloadUrl ?? "" : file.fileDownloadUrl ?? ""

		guard !urlString.isEmpty else { return nil }

		let url = VideoPlayerUtils.buildStreamingURL(
			instanceURL: baseURL,
			path: urlString
		)

		return VideoQualityOption(
			label: file.resolution.label,
			resolution: file.resolution.id,
			url: url,
			isHLS: isHLS
		)
	}
}

extension VideoStreamingPlaylist {
	/// Extract quality options from streaming playlist
	/// - Parameter baseURL: Base URL for building complete URLs
	/// - Returns: Array of quality options
	public func getQualityOptions(baseURL: URL) -> [VideoQualityOption] {
		var options: [VideoQualityOption] = []

		// Add the main playlist URL as "Auto" quality
		if let playlistURL = URL(string: playlistUrl) {
			options.append(
				VideoQualityOption(
					label: "Auto",
					resolution: 9999,
					url: playlistURL,
					isHLS: type == 1
				))
		}

		// Add individual quality options from files
		for file in files {
			if let option = VideoQualityOption.from(
				file: file,
				baseURL: baseURL,
				isHLS: type == 1
			) {
				options.append(option)
			}
		}

		return options
	}
}
