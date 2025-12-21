//
//  ModelsTests.swift
//  PeerTubeSwiftTests
//
//  Created on 2024-12-17.
//

import XCTest

@testable import PeerTubeSwift

final class ModelsTests: XCTestCase {
    // MARK: - ActorImage Tests

    func testActorImageInitialization() {
        let image = ActorImage(
            id: 1,
            filename: "avatar.jpg",
            fileExtension: "jpg",
            width: 120,
            height: 120,
            size: 1024
        )

        XCTAssertEqual(image.id, 1)
        XCTAssertEqual(image.filename, "avatar.jpg")
        XCTAssertEqual(image.fileExtension, "jpg")
        XCTAssertEqual(image.width, 120)
        XCTAssertEqual(image.height, 120)
        XCTAssertEqual(image.size, 1024)
        XCTAssertEqual(image.url, "/lazy-static/avatars/avatar.jpg")
    }

    func testActorImageURLGeneration() {
        let imageWithFilename = ActorImage(filename: "test.png")
        XCTAssertEqual(imageWithFilename.url, "/lazy-static/avatars/test.png")

        let imageWithoutFilename = ActorImage(filename: "")
        XCTAssertNil(imageWithoutFilename.url)
    }

    // MARK: - Actor Tests

    func testActorInitialization() {
        let createdAt = Date()
        let updatedAt = Date()

        let actor = Actor(
            id: 1,
            url: "https://example.com/accounts/testuser",
            name: "testuser",
            host: "example.com",
            followingCount: 10,
            followersCount: 100,
            createdAt: createdAt,
            updatedAt: updatedAt
        )

        XCTAssertEqual(actor.id, 1)
        XCTAssertEqual(actor.url, "https://example.com/accounts/testuser")
        XCTAssertEqual(actor.name, "testuser")
        XCTAssertEqual(actor.host, "example.com")
        XCTAssertEqual(actor.followingCount, 10)
        XCTAssertEqual(actor.followersCount, 100)
        XCTAssertEqual(actor.createdAt, createdAt)
        XCTAssertEqual(actor.updatedAt, updatedAt)
        XCTAssertEqual(actor.handle, "testuser@example.com")
        XCTAssertFalse(actor.isLocal)
    }

    func testActorAvatarSelection() {
        let smallAvatar = ActorImage(filename: "small.jpg", width: 50, height: 50)
        let largeAvatar = ActorImage(filename: "large.jpg", width: 200, height: 200)

        let actor = Actor(
            id: 1,
            url: "https://example.com/accounts/test",
            name: "test",
            avatars: [largeAvatar, smallAvatar],
            host: "example.com",
            createdAt: Date(),
            updatedAt: Date()
        )

        XCTAssertEqual(actor.primaryAvatar, largeAvatar)
        XCTAssertEqual(actor.smallAvatar, smallAvatar)
    }

    func testActorIsLocal() {
        let localActor = Actor(
            id: 1,
            url: "https://local/accounts/test",
            name: "test",
            host: "local",
            createdAt: Date(),
            updatedAt: Date()
        )

        let emptyHostActor = Actor(
            id: 2,
            url: "https://example.com/accounts/test",
            name: "test",
            host: "",
            createdAt: Date(),
            updatedAt: Date()
        )

        let remoteActor = Actor(
            id: 3,
            url: "https://remote.com/accounts/test",
            name: "test",
            host: "remote.com",
            createdAt: Date(),
            updatedAt: Date()
        )

        XCTAssertTrue(localActor.isLocal)
        XCTAssertTrue(emptyHostActor.isLocal)
        XCTAssertFalse(remoteActor.isLocal)
    }

    // MARK: - Account Tests

    func testAccountInitialization() {
        let createdAt = Date()
        let updatedAt = Date()

        let account = Account(
            id: 1,
            url: "https://example.com/accounts/testuser",
            name: "testuser",
            host: "example.com",
            followingCount: 5,
            followersCount: 50,
            createdAt: createdAt,
            updatedAt: updatedAt,
            userId: 123,
            displayName: "Test User",
            description: "This is a test account"
        )

        XCTAssertEqual(account.id, 1)
        XCTAssertEqual(account.name, "testuser")
        XCTAssertEqual(account.displayName, "Test User")
        XCTAssertEqual(account.description, "This is a test account")
        XCTAssertEqual(account.userId, 123)
        XCTAssertEqual(account.handle, "testuser@example.com")
        XCTAssertEqual(account.effectiveDisplayName, "Test User")
        XCTAssertTrue(account.isLocal) // has userId
    }

    func testAccountEffectiveDisplayName() {
        let accountWithDisplayName = Account(
            id: 1,
            url: "https://example.com/accounts/test",
            name: "test",
            host: "example.com",
            createdAt: Date(),
            updatedAt: Date(),
            displayName: "Display Name"
        )

        let accountWithEmptyDisplayName = Account(
            id: 2,
            url: "https://example.com/accounts/test2",
            name: "test2",
            host: "example.com",
            createdAt: Date(),
            updatedAt: Date(),
            displayName: ""
        )

        XCTAssertEqual(accountWithDisplayName.effectiveDisplayName, "Display Name")
        XCTAssertEqual(accountWithEmptyDisplayName.effectiveDisplayName, "test2")
    }

    func testAccountSummaryConversion() {
        let account = Account(
            id: 1,
            url: "https://example.com/accounts/test",
            name: "test",
            host: "example.com",
            createdAt: Date(),
            updatedAt: Date(),
            displayName: "Test Account"
        )

        let summary = account.summary
        XCTAssertEqual(summary.id, account.id)
        XCTAssertEqual(summary.name, account.name)
        XCTAssertEqual(summary.host, account.host)
        XCTAssertEqual(summary.displayName, account.displayName)
    }

    // MARK: - VideoChannel Tests

    func testVideoChannelInitialization() {
        let ownerAccount = AccountSummary(
            id: 1,
            name: "owner",
            host: "example.com",
            displayName: "Owner"
        )

        let channel = VideoChannel(
            id: 10,
            url: "https://example.com/channels/testchannel",
            name: "testchannel",
            host: "example.com",
            createdAt: Date(),
            updatedAt: Date(),
            displayName: "Test Channel",
            description: "A test channel",
            support: "Support me at...",
            isLocal: true,
            ownerAccount: ownerAccount
        )

        XCTAssertEqual(channel.id, 10)
        XCTAssertEqual(channel.name, "testchannel")
        XCTAssertEqual(channel.displayName, "Test Channel")
        XCTAssertEqual(channel.description, "A test channel")
        XCTAssertEqual(channel.support, "Support me at...")
        XCTAssertTrue(channel.isLocal)
        XCTAssertEqual(channel.ownerAccount.id, 1)
        XCTAssertEqual(channel.effectiveDisplayName, "Test Channel")
    }

    func testVideoChannelBannerSelection() {
        let smallBanner = ActorImage(filename: "small_banner.jpg", width: 400, height: 200)
        let largeBanner = ActorImage(filename: "large_banner.jpg", width: 800, height: 400)

        let ownerAccount = AccountSummary(
            id: 1,
            name: "owner",
            host: "example.com",
            displayName: "Owner"
        )

        let channel = VideoChannel(
            id: 1,
            url: "https://example.com/channels/test",
            name: "test",
            host: "example.com",
            createdAt: Date(),
            updatedAt: Date(),
            displayName: "Test",
            banners: [smallBanner, largeBanner],
            ownerAccount: ownerAccount
        )

        XCTAssertEqual(channel.primaryBanner, largeBanner)
    }

    // MARK: - Video Tests

    func testVideoInitialization() {
        let account = AccountSummary(
            id: 1, name: "uploader", host: "example.com", displayName: "Uploader"
        )
        let channel = VideoChannelSummary(
            id: 10, name: "channel", host: "example.com", displayName: "Channel"
        )

        let video = Video(
            id: 100,
            uuid: "550e8400-e29b-41d4-a716-446655440000",
            shortUUID: "abc123",
            createdAt: Date(),
            privacy: .public,
            duration: 3600, // 1 hour
            name: "Test Video",
            views: 1000,
            likes: 50,
            dislikes: 5,
            state: .published,
            account: account,
            channel: channel
        )

        XCTAssertEqual(video.id, 100)
        XCTAssertEqual(video.uuid, "550e8400-e29b-41d4-a716-446655440000")
        XCTAssertEqual(video.shortUUID, "abc123")
        XCTAssertEqual(video.name, "Test Video")
        XCTAssertEqual(video.duration, 3600)
        XCTAssertEqual(video.views, 1000)
        XCTAssertEqual(video.likes, 50)
        XCTAssertEqual(video.dislikes, 5)
        XCTAssertEqual(video.privacy, .public)
        XCTAssertEqual(video.state, .published)
        XCTAssertTrue(video.isPublished)
        XCTAssertFalse(video.isCurrentlyLive)
        XCTAssertEqual(video.formattedDuration, "1:00:00")
    }

    func testVideoFormattedDuration() {
        let account = AccountSummary(id: 1, name: "test", host: "example.com", displayName: "Test")
        let channel = VideoChannelSummary(
            id: 1, name: "test", host: "example.com", displayName: "Test"
        )

        let shortVideo = Video(
            id: 1,
            uuid: "uuid1",
            shortUUID: "short1",
            createdAt: Date(),
            privacy: .public,
            duration: 125, // 2:05
            name: "Short Video",
            state: .published,
            account: account,
            channel: channel
        )

        let longVideo = Video(
            id: 2,
            uuid: "uuid2",
            shortUUID: "short2",
            createdAt: Date(),
            privacy: .public,
            duration: 7265, // 2:01:05
            name: "Long Video",
            state: .published,
            account: account,
            channel: channel
        )

        XCTAssertEqual(shortVideo.formattedDuration, "2:05")
        XCTAssertEqual(longVideo.formattedDuration, "2:01:05")
    }

    func testVideoLikeRatio() {
        let account = AccountSummary(id: 1, name: "test", host: "example.com", displayName: "Test")
        let channel = VideoChannelSummary(
            id: 1, name: "test", host: "example.com", displayName: "Test"
        )

        let videoWithRatings = Video(
            id: 1,
            uuid: "uuid1",
            shortUUID: "short1",
            createdAt: Date(),
            privacy: .public,
            duration: 100,
            name: "Test Video",
            likes: 80,
            dislikes: 20,
            state: .published,
            account: account,
            channel: channel
        )

        let videoWithoutRatings = Video(
            id: 2,
            uuid: "uuid2",
            shortUUID: "short2",
            createdAt: Date(),
            privacy: .public,
            duration: 100,
            name: "Test Video 2",
            likes: 0,
            dislikes: 0,
            state: .published,
            account: account,
            channel: channel
        )

        XCTAssertEqual(videoWithRatings.likeRatio, 0.8)
        XCTAssertEqual(videoWithoutRatings.likeRatio, 0.5) // Default when no ratings
    }

    func testVideoNSFWContent() {
        let account = AccountSummary(id: 1, name: "test", host: "example.com", displayName: "Test")
        let channel = VideoChannelSummary(
            id: 1, name: "test", host: "example.com", displayName: "Test"
        )

        let nsfwVideo = Video(
            id: 1,
            uuid: "uuid1",
            shortUUID: "short1",
            createdAt: Date(),
            privacy: .public,
            duration: 100,
            name: "NSFW Video",
            nsfw: true,
            state: .published,
            account: account,
            channel: channel
        )

        let flaggedVideo = Video(
            id: 2,
            uuid: "uuid2",
            shortUUID: "short2",
            createdAt: Date(),
            privacy: .public,
            duration: 100,
            name: "Flagged Video",
            nsfw: false,
            nsfwFlags: [NSFWFlag(id: 1, label: "Violence")],
            state: .published,
            account: account,
            channel: channel
        )

        let safeVideo = Video(
            id: 3,
            uuid: "uuid3",
            shortUUID: "short3",
            createdAt: Date(),
            privacy: .public,
            duration: 100,
            name: "Safe Video",
            nsfw: false,
            nsfwFlags: [],
            state: .published,
            account: account,
            channel: channel
        )

        XCTAssertTrue(nsfwVideo.hasNSFWContent)
        XCTAssertTrue(flaggedVideo.hasNSFWContent)
        XCTAssertFalse(safeVideo.hasNSFWContent)
    }

    // MARK: - VideoPrivacy Tests

    func testVideoPrivacyDescriptions() {
        XCTAssertEqual(VideoPrivacy.public.description, "Public")
        XCTAssertEqual(VideoPrivacy.unlisted.description, "Unlisted")
        XCTAssertEqual(VideoPrivacy.private.description, "Private")
        XCTAssertEqual(VideoPrivacy.internal.description, "Internal")
        XCTAssertEqual(VideoPrivacy.passwordProtected.description, "Password Protected")
    }

    // MARK: - VideoState Tests

    func testVideoStateDescriptions() {
        XCTAssertEqual(VideoState.published.description, "Published")
        XCTAssertEqual(VideoState.toTranscode.description, "To Transcode")
        XCTAssertEqual(VideoState.waitingForLive.description, "Waiting for Live")
    }

    func testVideoStateViewable() {
        XCTAssertTrue(VideoState.published.isViewable)
        XCTAssertTrue(VideoState.waitingForLive.isViewable)
        XCTAssertFalse(VideoState.toTranscode.isViewable)
        XCTAssertFalse(VideoState.transcodeError.isViewable)
    }

    // MARK: - VideoDetails Tests

    func testVideoDetailsInitialization() {
        let account = Account(
            id: 1,
            url: "https://example.com/accounts/uploader",
            name: "uploader",
            host: "example.com",
            createdAt: Date(),
            updatedAt: Date(),
            displayName: "Uploader"
        )

        let channel = VideoChannel(
            id: 10,
            url: "https://example.com/channels/testchannel",
            name: "testchannel",
            host: "example.com",
            createdAt: Date(),
            updatedAt: Date(),
            displayName: "Test Channel",
            ownerAccount: account.summary
        )

        let videoFile = VideoFile(
            id: 1,
            resolution: VideoResolution(id: 720, label: "720p"),
            size: 1_048_576,
            fps: 30,
            fileExtension: "mp4"
        )

        let videoDetails = VideoDetails(
            id: 100,
            uuid: "550e8400-e29b-41d4-a716-446655440000",
            shortUUID: "abc123",
            createdAt: Date(),
            privacy: .public,
            description: "This is a detailed description of the video",
            duration: 3600,
            name: "Test Video Details",
            views: 1000,
            likes: 50,
            dislikes: 5,
            state: .published,
            channel: channel,
            account: account,
            files: [videoFile],
            tags: ["test", "video", "example"]
        )

        XCTAssertEqual(videoDetails.id, 100)
        XCTAssertEqual(videoDetails.description, "This is a detailed description of the video")
        XCTAssertEqual(videoDetails.tags, ["test", "video", "example"])
        XCTAssertEqual(videoDetails.files.count, 1)
        XCTAssertEqual(videoDetails.bestQualityFile, videoFile)
        XCTAssertEqual(videoDetails.lowestQualityFile, videoFile)
    }

    func testVideoDetailsQualityFileSelection() {
        let lowRes = VideoFile(
            resolution: VideoResolution(id: 240, label: "240p"),
            fileExtension: "mp4"
        )

        let midRes = VideoFile(
            resolution: VideoResolution(id: 480, label: "480p"),
            fileExtension: "mp4"
        )

        let highRes = VideoFile(
            resolution: VideoResolution(id: 1080, label: "1080p"),
            fileExtension: "mp4"
        )

        let account = Account(
            id: 1,
            url: "https://example.com/accounts/test",
            name: "test",
            host: "example.com",
            createdAt: Date(),
            updatedAt: Date(),
            displayName: "Test"
        )

        let channel = VideoChannel(
            id: 1,
            url: "https://example.com/channels/test",
            name: "test",
            host: "example.com",
            createdAt: Date(),
            updatedAt: Date(),
            displayName: "Test",
            ownerAccount: account.summary
        )

        let videoDetails = VideoDetails(
            id: 1,
            uuid: "uuid1",
            shortUUID: "short1",
            createdAt: Date(),
            privacy: .public,
            duration: 100,
            name: "Test Video",
            state: .published,
            channel: channel,
            account: account,
            files: [midRes, lowRes, highRes]
        )

        XCTAssertEqual(videoDetails.bestQualityFile, highRes)
        XCTAssertEqual(videoDetails.lowestQualityFile, lowRes)
    }

    // MARK: - Instance Tests

    func testInstanceInitialization() {
        let instance = Instance(
            host: "peertube.example.com",
            name: "Example PeerTube",
            shortDescription: "A test instance",
            version: "3.4.1",
            signupAllowed: true,
            totalUsers: 1000,
            totalVideos: 5000
        )

        XCTAssertEqual(instance.host, "peertube.example.com")
        XCTAssertEqual(instance.name, "Example PeerTube")
        XCTAssertEqual(instance.shortDescription, "A test instance")
        XCTAssertEqual(instance.version, "3.4.1")
        XCTAssertTrue(instance.signupAllowed)
        XCTAssertEqual(instance.totalUsers, 1000)
        XCTAssertEqual(instance.totalVideos, 5000)
        XCTAssertEqual(instance.effectiveName, "Example PeerTube")
        XCTAssertEqual(instance.baseURL?.absoluteString, "https://peertube.example.com")
        XCTAssertEqual(instance.apiBaseURL?.absoluteString, "https://peertube.example.com/api/v1")
    }

    func testInstanceEffectiveName() {
        let instanceWithName = Instance(
            host: "test.com",
            name: "Test Instance"
        )

        let instanceWithoutName = Instance(
            host: "noname.com",
            name: nil
        )

        let instanceWithEmptyName = Instance(
            host: "empty.com",
            name: ""
        )

        XCTAssertEqual(instanceWithName.effectiveName, "Test Instance")
        XCTAssertEqual(instanceWithoutName.effectiveName, "noname.com")
        XCTAssertEqual(instanceWithEmptyName.effectiveName, "empty.com")
    }

    // MARK: - JSON Encoding/Decoding Tests

    func testActorImageJSONEncoding() throws {
        let image = ActorImage(
            id: 1,
            filename: "avatar.jpg",
            fileExtension: "jpg",
            width: 120,
            height: 120,
            size: 1024,
            createdAt: Date(timeIntervalSince1970: 1_640_995_200), // 2022-01-01
            updatedAt: Date(timeIntervalSince1970: 1_640_995_200)
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase

        let data = try encoder.encode(image)
        XCTAssertNotNil(data)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let decoded = try decoder.decode(ActorImage.self, from: data)
        XCTAssertEqual(decoded.id, image.id)
        XCTAssertEqual(decoded.filename, image.filename)
        XCTAssertEqual(decoded.fileExtension, image.fileExtension)
        XCTAssertEqual(decoded.width, image.width)
        XCTAssertEqual(decoded.height, image.height)
        XCTAssertEqual(decoded.size, image.size)
    }

    func testVideoPrivacyJSONEncoding() throws {
        let privacy = VideoPrivacy.public

        let encoder = JSONEncoder()
        let data = try encoder.encode(privacy)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(VideoPrivacy.self, from: data)

        XCTAssertEqual(decoded, privacy)
        XCTAssertEqual(decoded.rawValue, 1)
    }

    func testVideoStateJSONEncoding() throws {
        let state = VideoState.published

        let encoder = JSONEncoder()
        let data = try encoder.encode(state)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(VideoState.self, from: data)

        XCTAssertEqual(decoded, state)
        XCTAssertEqual(decoded.rawValue, 1)
    }

    // MARK: - Performance Tests

    func testVideoSummaryCreationPerformance() {
        let account = AccountSummary(id: 1, name: "test", host: "example.com", displayName: "Test")
        let channel = VideoChannelSummary(
            id: 1, name: "test", host: "example.com", displayName: "Test"
        )

        let video = Video(
            id: 1,
            uuid: "uuid1",
            shortUUID: "short1",
            createdAt: Date(),
            privacy: .public,
            duration: 100,
            name: "Test Video",
            state: .published,
            account: account,
            channel: channel
        )

        measure {
            for _ in 0 ..< 1000 {
                _ = video.summary
            }
        }
    }

    func testActorHandleGenerationPerformance() {
        let actor = Actor(
            id: 1,
            url: "https://example.com/accounts/test",
            name: "test",
            host: "example.com",
            createdAt: Date(),
            updatedAt: Date()
        )

        measure {
            for _ in 0 ..< 10000 {
                _ = actor.handle
            }
        }
    }
}
