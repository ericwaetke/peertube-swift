//
//  VideoQualityTests.swift
//  PeerTubeSwiftTests
//
//  Created on 2024-12-18.
//

import XCTest

@testable import PeerTubeSwift

final class VideoQualityTests: XCTestCase {

	// MARK: - VideoQualityOption Tests

	func testVideoQualityOption_Creation() {
		// Given
		let url = URL(string: "https://example.com/video.mp4")

		// When
		let quality = VideoQualityOption(
			label: "720p",
			resolution: 720,
			url: url,
			isHLS: false
		)

		// Then
		XCTAssertEqual(quality.label, "720p")
		XCTAssertEqual(quality.resolution, 720)
		XCTAssertEqual(quality.url, url)
		XCTAssertFalse(quality.isHLS)
		XCTAssertNotNil(quality.id)
	}

	func testVideoQualityOption_DisplayName() {
		// Given
		let hlsQuality = VideoQualityOption(
			label: "1080p",
			resolution: 1080,
			url: URL(string: "https://example.com/playlist.m3u8"),
			isHLS: true
		)

		let directQuality = VideoQualityOption(
			label: "720p",
			resolution: 720,
			url: URL(string: "https://example.com/video.mp4"),
			isHLS: false
		)

		// When & Then
		XCTAssertEqual(hlsQuality.displayName, "1080p (HLS)")
		XCTAssertEqual(directQuality.displayName, "720p")
	}

	func testVideoQualityOption_Equality() {
		// Given
		let quality1 = VideoQualityOption(
			label: "720p",
			resolution: 720,
			url: URL(string: "https://example.com/video.mp4"),
			isHLS: false
		)

		let quality2 = VideoQualityOption(
			label: "720p",
			resolution: 720,
			url: URL(string: "https://example.com/video.mp4"),
			isHLS: false
		)

		let quality3 = VideoQualityOption(
			label: "1080p",
			resolution: 1080,
			url: URL(string: "https://example.com/video.mp4"),
			isHLS: false
		)

		// When & Then
		XCTAssertEqual(quality1, quality2)  // Same properties
		XCTAssertNotEqual(quality1, quality3)  // Different properties
		XCTAssertNotEqual(quality1.id, quality2.id)  // Different IDs
	}

	// MARK: - VideoPlayerUtils Quality Extraction Tests

	func testExtractQualityOptions_WithHLSPlaylist() {
		// Given
		let video = createMockVideoWithHLS()

		// When
		let qualities = VideoPlayerUtils.extractQualityOptions(from: video)

		// Then
		XCTAssertFalse(qualities.isEmpty)
		XCTAssertTrue(qualities.contains { $0.isHLS })
		XCTAssertTrue(qualities.contains { $0.label == "Auto (HLS)" })
		XCTAssertEqual(qualities.first { $0.label == "Auto (HLS)" }?.resolution, 9999)
	}

	func testExtractQualityOptions_WithDirectFiles() {
		// Given
		let video = createMockVideoWithDirectFiles()

		// When
		let qualities = VideoPlayerUtils.extractQualityOptions(from: video)

		// Then
		XCTAssertFalse(qualities.isEmpty)
		XCTAssertTrue(qualities.allSatisfy { !$0.isHLS })
		XCTAssertTrue(qualities.contains { $0.resolution == 1080 })
		XCTAssertTrue(qualities.contains { $0.resolution == 720 })
		XCTAssertTrue(qualities.contains { $0.resolution == 480 })
	}

	func testExtractQualityOptions_WithBothHLSAndDirect() {
		// Given
		let video = createMockVideoWithBothFormats()

		// When
		let qualities = VideoPlayerUtils.extractQualityOptions(from: video)

		// Then
		XCTAssertFalse(qualities.isEmpty)
		XCTAssertTrue(qualities.contains { $0.isHLS })
		XCTAssertTrue(qualities.contains { !$0.isHLS })

		let hlsQualities = qualities.filter { $0.isHLS }
		let directQualities = qualities.filter { !$0.isHLS }

		XCTAssertFalse(hlsQualities.isEmpty)
		XCTAssertFalse(directQualities.isEmpty)
	}

	func testExtractQualityOptions_SortedByResolution() {
		// Given
		let video = createMockVideoWithMultipleResolutions()

		// When
		let qualities = VideoPlayerUtils.extractQualityOptions(from: video)
		let sortedQualities = qualities.sorted { $0.resolution > $1.resolution }

		// Then
		XCTAssertFalse(qualities.isEmpty)
		XCTAssertEqual(sortedQualities.first?.resolution, 1080)
		XCTAssertEqual(sortedQualities.last?.resolution, 240)
	}

	// MARK: - Quality Selection Logic Tests

	func testQualitySelection_PreferHLS() {
		// Given
		let video = createMockVideoWithBothFormats()
		let qualities = VideoPlayerUtils.extractQualityOptions(from: video)

		// When
		let bestQuality = VideoPlayerUtils.selectBestQuality(
			from: qualities,
			preferHLS: true,
			maxResolution: 1080
		)

		// Then
		XCTAssertNotNil(bestQuality)
		XCTAssertTrue(bestQuality?.isHLS ?? false)
	}

	func testQualitySelection_WithResolutionLimit() {
		// Given
		let video = createMockVideoWithMultipleResolutions()
		let qualities = VideoPlayerUtils.extractQualityOptions(from: video)

		// When
		let limitedQuality = VideoPlayerUtils.selectBestQuality(
			from: qualities,
			preferHLS: false,
			maxResolution: 720
		)

		// Then
		XCTAssertNotNil(limitedQuality)
		XCTAssertLessThanOrEqual(limitedQuality?.resolution ?? 0, 720)
	}

	func testQualitySelection_FallbackToLowest() {
		// Given
		let video = createMockVideoWithMultipleResolutions()
		let qualities = VideoPlayerUtils.extractQualityOptions(from: video)

		// When
		let fallbackQuality = VideoPlayerUtils.selectBestQuality(
			from: qualities,
			preferHLS: false,
			maxResolution: 100  // Very low limit
		)

		// Then
		XCTAssertNotNil(fallbackQuality)
		XCTAssertEqual(fallbackQuality?.resolution, 240)  // Should fallback to lowest available
	}

	// MARK: - VideoResolution Tests

	func testVideoResolution_Creation() {
		// Given & When
		let resolution = VideoResolution(id: 720, label: "720p")

		// Then
		XCTAssertEqual(resolution.id, 720)
		XCTAssertEqual(resolution.label, "720p")
	}

	func testVideoResolution_Equality() {
		// Given
		let resolution1 = VideoResolution(id: 720, label: "720p")
		let resolution2 = VideoResolution(id: 720, label: "720p")
		let resolution3 = VideoResolution(id: 1080, label: "1080p")

		// When & Then
		XCTAssertEqual(resolution1, resolution2)
		XCTAssertNotEqual(resolution1, resolution3)
	}

	// MARK: - Streaming URL Building Tests

	func testBuildStreamingURL_WithValidPaths() {
		// Given
		let baseURL = URL(string: "https://example.com")!
		let relativePath = "/videos/1/720p.mp4"

		// When
		let streamingURL = VideoPlayerUtils.buildStreamingURL(
			instanceURL: baseURL,
			path: relativePath
		)

		// Then
		XCTAssertNotNil(streamingURL)
		XCTAssertEqual(streamingURL?.absoluteString, "https://example.com/videos/1/720p.mp4")
	}

	func testBuildStreamingURL_WithAbsolutePath() {
		// Given
		let baseURL = URL(string: "https://example.com")!
		let absolutePath = "https://cdn.example.com/video.mp4"

		// When
		let streamingURL = VideoPlayerUtils.buildStreamingURL(
			instanceURL: baseURL,
			path: absolutePath
		)

		// Then
		XCTAssertNotNil(streamingURL)
		XCTAssertEqual(streamingURL?.absoluteString, "https://cdn.example.com/video.mp4")
	}

	// MARK: - Data Usage Estimation Tests

	func testDataUsageEstimation() {
		// Given
		let resolutions = [240, 480, 720, 1080, 1440]

		// When & Then
		for resolution in resolutions {
			let usage = VideoPlayerUtils.estimateDataUsage(
				resolution: resolution,
				durationMinutes: 10
			)

			XCTAssertGreaterThan(usage, 0)

			// Higher resolution should use more data
			if resolution > 240 {
				let lowerUsage = VideoPlayerUtils.estimateDataUsage(
					resolution: 240,
					durationMinutes: 10
				)
				XCTAssertGreaterThan(usage, lowerUsage)
			}
		}
	}

	// MARK: - Quality Recommendation Tests

	func testQualityRecommendation_ForBandwidth() {
		// Given
		let qualities = [
			VideoQualityOption(label: "1080p", resolution: 1080, url: nil, isHLS: true),
			VideoQualityOption(label: "720p", resolution: 720, url: nil, isHLS: true),
			VideoQualityOption(label: "480p", resolution: 480, url: nil, isHLS: false),
			VideoQualityOption(label: "240p", resolution: 240, url: nil, isHLS: false),
		]

		// When & Then
		let highBandwidthRec = VideoPlayerUtils.recommendQuality(
			from: qualities,
			availableBandwidth: 25.0  // High bandwidth
		)
		XCTAssertEqual(highBandwidthRec?.resolution, 1080)

		let mediumBandwidthRec = VideoPlayerUtils.recommendQuality(
			from: qualities,
			availableBandwidth: 5.0  // Medium bandwidth
		)
		XCTAssertEqual(mediumBandwidthRec?.resolution, 720)

		let lowBandwidthRec = VideoPlayerUtils.recommendQuality(
			from: qualities,
			availableBandwidth: 1.0  // Low bandwidth
		)
		XCTAssertEqual(lowBandwidthRec?.resolution, 240)
	}

	// MARK: - Performance Tests

	func testQualityExtractionPerformance() {
		// Given
		let video = createLargeVideoWithManyQualities()

		// When
		measure {
			_ = VideoPlayerUtils.extractQualityOptions(from: video)
		}
	}

	func testQualitySelectionPerformance() {
		// Given
		let qualities = createLargeQualityList()

		// When
		measure {
			_ = VideoPlayerUtils.selectBestQuality(
				from: qualities,
				preferHLS: true,
				maxResolution: 1080
			)
		}
	}

	// MARK: - Helper Methods

	private func createMockVideoWithHLS() -> VideoDetails {
		let playlist = VideoStreamingPlaylist(
			id: 1,
			type: 1,
			playlistUrl: "https://example.com/playlist.m3u8",
			segmentsSha256Url: "",
			files: [
				VideoFile(
					id: 1,
					resolution: VideoResolution(id: 720, label: "720p"),
					fileExtension: "ts",
					metadataUrl: "https://example.com/720p.json"
				)
			]
		)

		return VideoDetails(
			id: 1,
			uuid: "test-uuid",
			shortUUID: "test",
			createdAt: Date(),
			updatedAt: Date(),
			privacy: .public,
			duration: 300,
			name: "Test Video",
			state: .published,
			channel: createMockChannel(),
			account: createMockAccount(),
			streamingPlaylists: [playlist]
		)
	}

	private func createMockVideoWithDirectFiles() -> VideoDetails {
		let files = [
			VideoFile(
				resolution: VideoResolution(id: 1080, label: "1080p"),
				fileExtension: "mp4",
				fileDownloadUrl: "https://example.com/1080p.mp4"
			),
			VideoFile(
				resolution: VideoResolution(id: 720, label: "720p"),
				fileExtension: "mp4",
				fileDownloadUrl: "https://example.com/720p.mp4"
			),
			VideoFile(
				resolution: VideoResolution(id: 480, label: "480p"),
				fileExtension: "mp4",
				fileDownloadUrl: "https://example.com/480p.mp4"
			),
		]

		return VideoDetails(
			id: 1,
			uuid: "test-uuid",
			shortUUID: "test",
			createdAt: Date(),
			updatedAt: Date(),
			privacy: .public,
			duration: 300,
			name: "Test Video",
			state: .published,
			channel: createMockChannel(),
			account: createMockAccount(),
			files: files
		)
	}

	private func createMockVideoWithBothFormats() -> VideoDetails {
		let playlist = VideoStreamingPlaylist(
			id: 1,
			type: 1,
			playlistUrl: "https://example.com/playlist.m3u8",
			segmentsSha256Url: "",
			files: [
				VideoFile(
					resolution: VideoResolution(id: 720, label: "720p"),
					fileExtension: "ts",
					metadataUrl: "https://example.com/hls-720p.json"
				)
			]
		)

		let files = [
			VideoFile(
				resolution: VideoResolution(id: 720, label: "720p"),
				fileExtension: "mp4",
				fileDownloadUrl: "https://example.com/direct-720p.mp4"
			)
		]

		return VideoDetails(
			id: 1,
			uuid: "test-uuid",
			shortUUID: "test",
			createdAt: Date(),
			updatedAt: Date(),
			privacy: .public,
			duration: 300,
			name: "Test Video",
			state: .published,
			channel: createMockChannel(),
			account: createMockAccount(),
			files: files,
			streamingPlaylists: [playlist]
		)
	}

	private func createMockVideoWithMultipleResolutions() -> VideoDetails {
		let files = [
			VideoFile(
				resolution: VideoResolution(id: 1080, label: "1080p"),
				fileExtension: "mp4",
				fileDownloadUrl: "https://example.com/1080p.mp4"
			),
			VideoFile(
				resolution: VideoResolution(id: 720, label: "720p"),
				fileExtension: "mp4",
				fileDownloadUrl: "https://example.com/720p.mp4"
			),
			VideoFile(
				resolution: VideoResolution(id: 480, label: "480p"),
				fileExtension: "mp4",
				fileDownloadUrl: "https://example.com/480p.mp4"
			),
			VideoFile(
				resolution: VideoResolution(id: 240, label: "240p"),
				fileExtension: "mp4",
				fileDownloadUrl: "https://example.com/240p.mp4"
			),
		]

		return VideoDetails(
			id: 1,
			uuid: "test-uuid",
			shortUUID: "test",
			createdAt: Date(),
			updatedAt: Date(),
			privacy: .public,
			duration: 300,
			name: "Test Video",
			state: .published,
			channel: createMockChannel(),
			account: createMockAccount(),
			files: files
		)
	}

	private func createLargeVideoWithManyQualities() -> VideoDetails {
		let resolutions = [240, 360, 480, 720, 1080, 1440, 2160]
		let files = resolutions.map { resolution in
			VideoFile(
				resolution: VideoResolution(id: resolution, label: "\(resolution)p"),
				fileExtension: "mp4",
				fileDownloadUrl: "https://example.com/\(resolution)p.mp4"
			)
		}

		return VideoDetails(
			id: 1,
			uuid: "test-uuid",
			shortUUID: "test",
			createdAt: Date(),
			updatedAt: Date(),
			privacy: .public,
			duration: 300,
			name: "Test Video",
			state: .published,
			channel: createMockChannel(),
			account: createMockAccount(),
			files: files
		)
	}

	private func createLargeQualityList() -> [VideoQualityOption] {
		let resolutions = Array(240...2160).filter { $0 % 120 == 0 }
		return resolutions.map { resolution in
			VideoQualityOption(
				label: "\(resolution)p",
				resolution: resolution,
				url: URL(string: "https://example.com/\(resolution)p.mp4"),
				isHLS: resolution >= 720
			)
		}
	}

	private func createMockChannel() -> VideoChannel {
		return VideoChannel(
			id: 1,
			url: "https://example.com/channels/test",
			name: "test-channel",
			host: "example.com",
			createdAt: Date(),
			updatedAt: Date(),
			displayName: "Test Channel",
			followersCount: 100,
			followingCount: 50,
			videosCount: 25,
			ownerAccount: AccountSummary(
				id: 1,
				name: "test-account",
				host: "example.com",
				displayName: "Test Account"
			)
		)
	}

	private func createMockAccount() -> Account {
		return Account(
			id: 1,
			url: "https://example.com/accounts/test",
			name: "test-account",
			host: "example.com",
			createdAt: Date(),
			updatedAt: Date(),
			displayName: "Test Account"
		)
	}
}

// MARK: - VideoPlayerUtils Extension for Testing

extension VideoPlayerUtils {
	static func selectBestQuality(
		from qualities: [VideoQualityOption],
		preferHLS: Bool,
		maxResolution: Int
	) -> VideoQualityOption? {
		let filtered = qualities.filter { $0.resolution <= maxResolution }

		if preferHLS {
			return filtered.filter { $0.isHLS }.max { $0.resolution < $1.resolution }
				?? filtered.max { $0.resolution < $1.resolution }
		} else {
			return filtered.max { $0.resolution < $1.resolution }
		}
	}

	static func recommendQuality(
		from qualities: [VideoQualityOption],
		availableBandwidth: Double
	) -> VideoQualityOption? {
		let sorted = qualities.sorted { $0.resolution > $1.resolution }

		for quality in sorted {
			let requiredBandwidth = getRequiredBandwidth(for: quality.resolution)
			if availableBandwidth >= requiredBandwidth {
				return quality
			}
		}

		return sorted.last  // Fallback to lowest quality
	}

	static func estimateDataUsage(resolution: Int, durationMinutes: Double) -> Double {
		let mbPerMinute: Double
		switch resolution {
		case 0..<360:
			mbPerMinute = 5.0
		case 360..<540:
			mbPerMinute = 15.0
		case 540..<900:
			mbPerMinute = 25.0
		case 900..<1440:
			mbPerMinute = 45.0
		default:
			mbPerMinute = 80.0
		}

		return mbPerMinute * durationMinutes
	}

	private static func getRequiredBandwidth(for resolution: Int) -> Double {
		switch resolution {
		case 0..<360:
			return 1.0  // 1 Mbps for 240p
		case 360..<540:
			return 2.5  // 2.5 Mbps for 480p
		case 540..<900:
			return 5.0  // 5 Mbps for 720p
		case 900..<1440:
			return 8.0  // 8 Mbps for 1080p
		default:
			return 15.0  // 15 Mbps for 1440p+
		}
	}
}
