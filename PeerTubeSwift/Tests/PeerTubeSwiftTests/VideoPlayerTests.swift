//
//  VideoPlayerTests.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

import AVFoundation
import AVKit
import Foundation
import XCTest

@testable import PeerTubeSwift

@MainActor
final class VideoPlayerTests: XCTestCase {

	// MARK: - Properties

	private var mockVideo: VideoDetails!
	private var mockURL: URL!

	// MARK: - Setup

	override func setUp() async throws {
		try await super.setUp()

		mockURL = URL(string: "https://example.com/video.mp4")!
		mockVideo = createMockVideoDetails()
	}

	override func tearDown() async throws {
		mockVideo = nil
		mockURL = nil
		try await super.tearDown()
	}

	// MARK: - VideoPlayerController Tests

	func testVideoPlayerController_InitializationWithVideo() async throws {
		// Given
		let video = createMockVideoDetails()

		// When
		let controller = VideoPlayerController(video: video)

		// Then
		XCTAssertNotNil(controller)
		XCTAssertFalse(controller.isPlaying)
		XCTAssertFalse(controller.isLoading)
		XCTAssertNil(controller.error)
		XCTAssertEqual(controller.currentTime, 0)
		XCTAssertEqual(controller.playbackRate, 1.0)
		XCTAssertFalse(controller.hasFinished)
	}

	func testVideoPlayerController_InitializationWithURL() async throws {
		// Given
		let url = URL(string: "https://example.com/test.mp4")!

		// When
		let controller = VideoPlayerController(url: url)

		// Then
		XCTAssertNotNil(controller)
		XCTAssertFalse(controller.isPlaying)
		XCTAssertFalse(controller.isLoading)
		XCTAssertNil(controller.error)
	}

	func testVideoPlayerController_GetBestStreamingURL() async throws {
		// Given - Video with HLS playlist
		let hlsVideo = createMockVideoDetailsWithHLS()
		let controller = VideoPlayerController(video: hlsVideo)

		// When
		let url = controller.getBestStreamingURL()

		// Then
		XCTAssertNotNil(url)
		XCTAssertTrue(url!.absoluteString.contains(".m3u8"))
	}

	func testVideoPlayerController_GetBestStreamingURL_FallbackToFile() async throws {
		// Given - Video without HLS, only files
		let fileVideo = createMockVideoDetailsWithFiles()
		let controller = VideoPlayerController(video: fileVideo)

		// When
		let url = controller.getBestStreamingURL()

		// Then
		XCTAssertNotNil(url)
		XCTAssertTrue(url!.absoluteString.contains(".mp4"))
	}

	func testVideoPlayerController_GetQualityOptions() async throws {
		// Given
		let video = createMockVideoDetailsWithMultipleQualities()
		let controller = VideoPlayerController(video: video)

		// When
		let options = controller.getQualityOptions()

		// Then
		XCTAssertFalse(options.isEmpty)
		XCTAssertTrue(options.contains { $0.resolution == 1080 })
		XCTAssertTrue(options.contains { $0.resolution == 720 })
		XCTAssertTrue(options.contains { $0.resolution == 480 })
	}

	func testVideoPlayerController_ControlsMethods() async throws {
		// Given
		let controller = VideoPlayerController(url: mockURL)

		// When - Test control methods
		controller.play()
		XCTAssertTrue(controller.isPlaying)

		controller.pause()
		XCTAssertFalse(controller.isPlaying)

		controller.stop()
		XCTAssertFalse(controller.isPlaying)
		XCTAssertEqual(controller.currentTime, 0)

		controller.setPlaybackRate(1.5)
		XCTAssertEqual(controller.playbackRate, 1.5)
	}

	func testVideoPlayerController_SeekMethods() async throws {
		// Given
		let controller = VideoPlayerController(url: mockURL)

		// When
		controller.seek(to: 30.0)
		// Note: In a real test, we'd need to wait for the seek to complete
		// For now, we just test that the method doesn't crash

		controller.seekForward()
		controller.seekBackward()

		// Then
		// Methods should execute without throwing
		XCTAssertNotNil(controller)
	}

	func testVideoPlayerController_ToggleMethods() async throws {
		// Given
		let controller = VideoPlayerController(url: mockURL)

		// When
		let initialPlaying = controller.isPlaying
		controller.togglePlayback()
		let afterToggle = controller.isPlaying

		let initialControlsVisible = controller.showControls
		controller.toggleControlsVisibility()
		let afterControlsToggle = controller.showControls

		// Then
		XCTAssertNotEqual(initialPlaying, afterToggle)
		XCTAssertNotEqual(initialControlsVisible, afterControlsToggle)
	}

	// MARK: - VideoPlayerUtils Tests

	func testVideoPlayerUtils_FormatDetection() {
		// Given
		let hlsURL = URL(string: "https://example.com/playlist.m3u8")!
		let dashURL = URL(string: "https://example.com/manifest.mpd")!
		let mp4URL = URL(string: "https://example.com/video.mp4")!
		let unsupportedURL = URL(string: "https://example.com/video.unknown")!

		// Then
		XCTAssertTrue(VideoPlayerUtils.isHLSURL(hlsURL))
		XCTAssertFalse(VideoPlayerUtils.isHLSURL(mp4URL))

		XCTAssertTrue(VideoPlayerUtils.isDASHURL(dashURL))
		XCTAssertFalse(VideoPlayerUtils.isDASHURL(mp4URL))

		XCTAssertTrue(VideoPlayerUtils.isFormatSupported(hlsURL))
		XCTAssertTrue(VideoPlayerUtils.isFormatSupported(mp4URL))
		XCTAssertFalse(VideoPlayerUtils.isFormatSupported(unsupportedURL))
	}

	func testVideoPlayerUtils_PreferredURL() {
		// Given
		let mp4URL = URL(string: "https://example.com/video.mp4")!
		let hlsURL = URL(string: "https://example.com/playlist.m3u8")!
		let aviURL = URL(string: "https://example.com/video.avi")!

		let urls = [mp4URL, aviURL, hlsURL]

		// When
		let preferredURL = VideoPlayerUtils.getPreferredVideoURL(from: urls)

		// Then
		XCTAssertEqual(preferredURL, hlsURL)  // HLS should be preferred
	}

	func testVideoPlayerUtils_QualityExtraction() {
		// Given
		let video = createMockVideoDetailsWithMultipleQualities()

		// When
		let options = VideoPlayerUtils.extractQualityOptions(from: video)

		// Then
		XCTAssertFalse(options.isEmpty)

		// Check that options are sorted by resolution (highest first)
		for i in 0..<(options.count - 1) {
			XCTAssertGreaterThanOrEqual(options[i].resolution, options[i + 1].resolution)
		}
	}

	func testVideoPlayerUtils_URLBuilding() {
		// Given
		let instanceURL = URL(string: "https://peertube.example.com")!
		let relativePath = "/static/videos/video.mp4"
		let absolutePath = "https://cdn.example.com/video.mp4"

		// When
		let relativeResult = VideoPlayerUtils.buildStreamingURL(
			instanceURL: instanceURL,
			path: relativePath
		)
		let absoluteResult = VideoPlayerUtils.buildStreamingURL(
			instanceURL: instanceURL,
			path: absolutePath
		)

		// Then
		XCTAssertNotNil(relativeResult)
		XCTAssertTrue(relativeResult!.absoluteString.hasPrefix("https://peertube.example.com"))

		XCTAssertNotNil(absoluteResult)
		XCTAssertEqual(absoluteResult!.absoluteString, absolutePath)
	}

	func testVideoPlayerUtils_ThumbnailURL() {
		// Given
		let instanceURL = URL(string: "https://peertube.example.com")!
		let video = createMockVideoDetailsWithThumbnail()

		// When
		let thumbnailURL = VideoPlayerUtils.getThumbnailURL(
			from: video,
			instanceURL: instanceURL
		)

		// Then
		XCTAssertNotNil(thumbnailURL)
		XCTAssertTrue(thumbnailURL!.absoluteString.contains("thumbnail"))
	}

	func testVideoPlayerUtils_DurationFormatting() {
		// Test cases
		let testCases: [(TimeInterval, String)] = [
			(0, "0:00"),
			(30, "0:30"),
			(90, "1:30"),
			(3661, "1:01:01"),
			(7325, "2:02:05"),
		]

		for (duration, expected) in testCases {
			let formatted = VideoPlayerUtils.formatDuration(duration)
			XCTAssertEqual(formatted, expected, "Duration \(duration) should format to \(expected)")
		}
	}

	func testVideoPlayerUtils_FileSizeFormatting() {
		// Given
		let testCases: [(Int, String)] = [
			(1024, "1 KB"),
			(1_048_576, "1 MB"),
			(1_073_741_824, "1 GB"),
		]

		// When/Then
		for (size, expectedPrefix) in testCases {
			let formatted = VideoPlayerUtils.formatFileSize(size)
			XCTAssertTrue(
				formatted.hasPrefix(expectedPrefix.prefix(1)),
				"Size \(size) should format to something starting with \(expectedPrefix.prefix(1))"
			)
		}
	}

	func testVideoPlayerUtils_PlaybackSpeedOptions() {
		// When
		let options = VideoPlayerUtils.getPlaybackSpeedOptions()

		// Then
		XCTAssertFalse(options.isEmpty)
		XCTAssertTrue(options.contains { $0.speed == 1.0 })
		XCTAssertTrue(options.contains { $0.speed == 0.5 })
		XCTAssertTrue(options.contains { $0.speed == 2.0 })
	}

	func testVideoPlayerUtils_QualityRecommendations() {
		// Test device type detection would require platform-specific testing
		// Test connection-based recommendations
		let wifiQuality = VideoPlayerUtils.getRecommendedQuality(
			for: .iphone,
			connectionType: .wifi
		)
		let cellularQuality = VideoPlayerUtils.getRecommendedQuality(
			for: .iphone,
			connectionType: .cellular3G
		)

		XCTAssertGreaterThan(wifiQuality, cellularQuality)
	}

	// MARK: - VideoPlayerError Tests

	func testVideoPlayerError_LocalizedDescription() {
		let errors: [VideoPlayerError] = [
			.invalidURL,
			.audioSessionError(NSError(domain: "test", code: 1)),
			.playbackError(NSError(domain: "test", code: 2)),
			.networkError,
			.unsupportedFormat,
			.unknown,
		]

		for error in errors {
			XCTAssertNotNil(error.errorDescription)
			XCTAssertNotNil(error.recoverySuggestion)
			XCTAssertFalse(error.errorDescription!.isEmpty)
			XCTAssertFalse(error.recoverySuggestion!.isEmpty)
		}
	}

	// MARK: - Supporting Types Tests

	func testVideoQualityOption_Equality() {
		// Given
		let option1 = VideoQualityOption(
			label: "720p",
			resolution: 720,
			url: URL(string: "https://example.com/720p.mp4"),
			isHLS: false
		)
		let option2 = VideoQualityOption(
			label: "720p",
			resolution: 720,
			url: URL(string: "https://example.com/720p.mp4"),
			isHLS: false
		)
		let option3 = VideoQualityOption(
			label: "1080p",
			resolution: 1080,
			url: URL(string: "https://example.com/1080p.mp4"),
			isHLS: false
		)

		// Then
		XCTAssertEqual(option1, option2)
		XCTAssertNotEqual(option1, option3)
		XCTAssertEqual(option1.displayName, "720p")
	}

	func testPlaybackSpeedOption_Properties() {
		// Given
		let option = PlaybackSpeedOption(speed: 1.5, label: "1.5x")

		// Then
		XCTAssertEqual(option.speed, 1.5)
		XCTAssertEqual(option.label, "1.5x")
		XCTAssertNotNil(option.id)
	}

	func testNetworkConnectionType_DisplayNames() {
		let types: [NetworkConnectionType] = [
			.wifi, .cellular5G, .cellular4G, .cellular3G, .cellular2G, .unknown,
		]

		for type in types {
			XCTAssertFalse(type.displayName.isEmpty)
		}
	}

	func testDeviceType_DisplayNames() {
		let types: [DeviceType] = [.iphone, .ipad, .mac, .unknown]

		for type in types {
			XCTAssertFalse(type.displayName.isEmpty)
		}

		// Test current device detection doesn't crash
		let currentDevice = DeviceType.current
		XCTAssertNotNil(currentDevice)
	}

	// MARK: - CMTime Extension Tests

	func testCMTime_SecondsExtension() {
		// Given
		let validTime = CMTime(seconds: 30.5, preferredTimescale: 600)
		let invalidTime = CMTime.invalid
		let indefiniteTime = CMTime.indefinite

		// Then
		XCTAssertEqual(validTime.seconds, 30.5, accuracy: 0.1)
		XCTAssertEqual(invalidTime.seconds, 0)
		XCTAssertEqual(indefiniteTime.seconds, 0)
	}

	// MARK: - Helper Methods

	private func createMockVideoDetails() -> VideoDetails {
		VideoDetails(
			id: 1,
			uuid: "test-uuid",
			shortUUID: "short",
			createdAt: Date(),
			updatedAt: Date(),
			privacy: .public,
			duration: 300,
			name: "Test Video",
			state: .published,
			channel: VideoChannel(
				id: 1,
				url: "https://example.com/channels/test",
				name: "testchannel",
				host: "example.com",
				createdAt: Date(),
				updatedAt: Date(),
				displayName: "Test Channel",
				ownerAccount: AccountSummary(
					id: 1,
					name: "testuser",
					host: "example.com",
					displayName: "Test User"
				)
			),
			account: Account(
				id: 1,
				url: "https://example.com/accounts/test",
				name: "testuser",
				host: "example.com",
				createdAt: Date(),
				updatedAt: Date(),
				displayName: "Test User"
			)
		)
	}

	private func createMockVideoDetailsWithHLS() -> VideoDetails {
		var video = createMockVideoDetails()
		let hlsPlaylist = VideoStreamingPlaylist(
			id: 1,
			type: 1,
			playlistUrl: "https://example.com/videos/1/playlist.m3u8",
			segmentsSha256Url: "https://example.com/videos/1/segments.sha256"
		)

		return VideoDetails(
			id: video.id,
			uuid: video.uuid,
			shortUUID: video.shortUUID,
			createdAt: video.createdAt,
			updatedAt: video.updatedAt,
			privacy: video.privacy,
			duration: video.duration,
			name: video.name,
			state: video.state,
			channel: video.channel,
			account: video.account,
			streamingPlaylists: [hlsPlaylist]
		)
	}

	private func createMockVideoDetailsWithFiles() -> VideoDetails {
		var video = createMockVideoDetails()
		let videoFile = VideoFile(
			resolution: VideoResolution(id: 720, label: "720p"),
			fileExtension: "mp4",
			fileDownloadUrl: "https://example.com/videos/1/720p.mp4"
		)

		return VideoDetails(
			id: video.id,
			uuid: video.uuid,
			shortUUID: video.shortUUID,
			createdAt: video.createdAt,
			updatedAt: video.updatedAt,
			privacy: video.privacy,
			duration: video.duration,
			name: video.name,
			state: video.state,
			channel: video.channel,
			account: video.account,
			files: [videoFile]
		)
	}

	private func createMockVideoDetailsWithMultipleQualities() -> VideoDetails {
		var video = createMockVideoDetails()

		let files = [
			VideoFile(
				resolution: VideoResolution(id: 1080, label: "1080p"),
				fileExtension: "mp4",
				fileDownloadUrl: "https://example.com/videos/1/1080p.mp4"
			),
			VideoFile(
				resolution: VideoResolution(id: 720, label: "720p"),
				fileExtension: "mp4",
				fileDownloadUrl: "https://example.com/videos/1/720p.mp4"
			),
			VideoFile(
				resolution: VideoResolution(id: 480, label: "480p"),
				fileExtension: "mp4",
				fileDownloadUrl: "https://example.com/videos/1/480p.mp4"
			),
		]

		let hlsFiles = files.map { file in
			VideoFile(
				resolution: file.resolution,
				fileExtension: "ts",
				metadataUrl: "https://example.com/videos/1/hls/\(file.resolution.id)p.m3u8"
			)
		}

		let hlsPlaylist = VideoStreamingPlaylist(
			id: 1,
			type: 1,
			playlistUrl: "https://example.com/videos/1/playlist.m3u8",
			segmentsSha256Url: "https://example.com/videos/1/segments.sha256",
			files: hlsFiles
		)

		return VideoDetails(
			id: video.id,
			uuid: video.uuid,
			shortUUID: video.shortUUID,
			createdAt: video.createdAt,
			updatedAt: video.updatedAt,
			privacy: video.privacy,
			duration: video.duration,
			name: video.name,
			state: video.state,
			channel: video.channel,
			account: video.account,
			files: files,
			streamingPlaylists: [hlsPlaylist]
		)
	}

	private func createMockVideoDetailsWithThumbnail() -> VideoDetails {
		let video = createMockVideoDetails()

		return VideoDetails(
			id: video.id,
			uuid: video.uuid,
			shortUUID: video.shortUUID,
			createdAt: video.createdAt,
			updatedAt: video.updatedAt,
			privacy: video.privacy,
			duration: video.duration,
			name: video.name,
			thumbnailPath: "/static/thumbnails/test-thumbnail.jpg",
			state: video.state,
			channel: video.channel,
			account: video.account
		)
	}
}
