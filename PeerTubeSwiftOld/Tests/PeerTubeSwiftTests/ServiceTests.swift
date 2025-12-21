//
//  ServiceTests.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

import Foundation
import XCTest

@testable import PeerTubeSwift

@MainActor
final class ServiceTests: XCTestCase {
    // MARK: - Properties

    private var mockNetworking: MockNetworkingFoundation!
    private var apiClient: APIClient!
    private var services: PeerTubeServices!

    // MARK: - Setup

    override func setUp() async throws {
        try await super.setUp()
        mockNetworking = MockNetworkingFoundation()

        let config = APIClientConfig(
            instanceURL: URL(string: "https://test.example.com")!,
            rateLimitingEnabled: false // Disable for testing
        )

        apiClient = APIClient(config: config, networking: mockNetworking)
        services = PeerTubeServices(apiClient: apiClient)
    }

    override func tearDown() async throws {
        services = nil
        apiClient = nil
        mockNetworking = nil
        try await super.tearDown()
    }

    // MARK: - VideoService Tests

    func testVideoService_GetVideo() async throws {
        // Given
        let expectedVideo = createMockVideoDetails()
        mockNetworking.mockResponse = expectedVideo

        // When
        let result = try await services.videos.getVideo(id: "123")

        // Then
        XCTAssertEqual(result.id, expectedVideo.id)
        XCTAssertEqual(result.name, expectedVideo.name)
        XCTAssertEqual(mockNetworking.lastRequestURL?.path, "/api/v1/videos/123")
        XCTAssertEqual(mockNetworking.lastRequestMethod, .GET)
    }

    func testVideoService_GetVideoByNumericId() async throws {
        // Given
        let expectedVideo = createMockVideoDetails()
        mockNetworking.mockResponse = expectedVideo

        // When
        let result = try await services.videos.getVideo(id: 123)

        // Then
        XCTAssertEqual(result.id, expectedVideo.id)
        XCTAssertEqual(mockNetworking.lastRequestURL?.path, "/api/v1/videos/123")
    }

    func testVideoService_ListVideos() async throws {
        // Given
        let expectedResponse = VideoListResponse(
            total: 10,
            data: [createMockVideo()]
        )
        mockNetworking.mockResponse = expectedResponse

        let parameters = VideoListParameters(
            start: 0,
            count: 15,
            sort: .createdAt,
            nsfw: .false,
            isLocal: true
        )

        // When
        let result = try await services.videos.listVideos(parameters: parameters)

        // Then
        XCTAssertEqual(result.total, 10)
        XCTAssertEqual(result.data.count, 1)
        XCTAssertEqual(mockNetworking.lastRequestURL?.path, "/api/v1/videos")

        // Check query parameters
        let queryItems = mockNetworking.lastRequestURL?.query?.components(separatedBy: "&") ?? []
        XCTAssertTrue(queryItems.contains("start=0"))
        XCTAssertTrue(queryItems.contains("count=15"))
        XCTAssertTrue(queryItems.contains("sort=-createdAt"))
        XCTAssertTrue(queryItems.contains("nsfw=false"))
        XCTAssertTrue(queryItems.contains("isLocal=true"))
    }

    func testVideoService_SearchVideos() async throws {
        // Given
        let expectedResponse = VideoListResponse(
            total: 5,
            data: [createMockVideo()]
        )
        mockNetworking.mockResponse = expectedResponse

        let parameters = VideoSearchParameters(
            search: "test query",
            count: 10,
            sort: .relevance,
            searchTarget: .local
        )

        // When
        let result = try await services.videos.searchVideos(parameters: parameters)

        // Then
        XCTAssertEqual(result.total, 5)
        XCTAssertEqual(result.data.count, 1)
        XCTAssertEqual(mockNetworking.lastRequestURL?.path, "/api/v1/search/videos")

        let queryItems = mockNetworking.lastRequestURL?.query?.components(separatedBy: "&") ?? []
        XCTAssertTrue(queryItems.contains("search=test%20query"))
        XCTAssertTrue(queryItems.contains("searchTarget=local"))
    }

    func testVideoService_GetMultipleVideos() async throws {
        // Given
        let video1 = createMockVideoDetails(id: 1, name: "Video 1")
        let video2 = createMockVideoDetails(id: 2, name: "Video 2")

        mockNetworking.responseQueue = [video1, video2]

        // When
        let results = await services.videos.getVideos(ids: ["1", "2"])

        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].name, "Video 1")
        XCTAssertEqual(results[1].name, "Video 2")
        XCTAssertEqual(mockNetworking.requestCount, 2)
    }

    func testVideoService_GetRecentVideos() async throws {
        // Given
        let expectedResponse = VideoListResponse(total: 5, data: [createMockVideo()])
        mockNetworking.mockResponse = expectedResponse

        // When
        let result = try await services.videos.getRecentVideos(count: 10)

        // Then
        XCTAssertEqual(result.total, 5)
        let queryItems = mockNetworking.lastRequestURL?.query?.components(separatedBy: "&") ?? []
        XCTAssertTrue(queryItems.contains("count=10"))
        XCTAssertTrue(queryItems.contains("sort=-createdAt"))
    }

    // MARK: - ChannelService Tests

    func testChannelService_GetChannel() async throws {
        // Given
        let expectedChannel = createMockVideoChannel()
        mockNetworking.mockResponse = expectedChannel

        // When
        let result = try await services.channels.getChannel(handle: "testchannel@example.com")

        // Then
        XCTAssertEqual(result.id, expectedChannel.id)
        XCTAssertEqual(result.name, expectedChannel.name)
        XCTAssertEqual(
            mockNetworking.lastRequestURL?.path, "/api/v1/video-channels/testchannel@example.com"
        )
    }

    func testChannelService_ListChannels() async throws {
        // Given
        let expectedResponse = ChannelListResponse(
            total: 3,
            data: [createMockVideoChannel()]
        )
        mockNetworking.mockResponse = expectedResponse

        let parameters = ChannelListParameters(
            count: 20,
            sort: .followersCount,
            isLocal: true
        )

        // When
        let result = try await services.channels.listChannels(parameters: parameters)

        // Then
        XCTAssertEqual(result.total, 3)
        XCTAssertEqual(result.data.count, 1)
        XCTAssertEqual(mockNetworking.lastRequestURL?.path, "/api/v1/video-channels")

        let queryItems = mockNetworking.lastRequestURL?.query?.components(separatedBy: "&") ?? []
        XCTAssertTrue(queryItems.contains("count=20"))
        XCTAssertTrue(queryItems.contains("sort=-followersCount"))
        XCTAssertTrue(queryItems.contains("isLocal=true"))
    }

    func testChannelService_SearchChannels() async throws {
        // Given
        let expectedResponse = ChannelListResponse(
            total: 2,
            data: [createMockVideoChannel()]
        )
        mockNetworking.mockResponse = expectedResponse

        let parameters = ChannelSearchParameters(
            search: "music channel",
            sort: .relevance
        )

        // When
        let result = try await services.channels.searchChannels(parameters: parameters)

        // Then
        XCTAssertEqual(result.total, 2)
        XCTAssertEqual(mockNetworking.lastRequestURL?.path, "/api/v1/search/video-channels")

        let queryItems = mockNetworking.lastRequestURL?.query?.components(separatedBy: "&") ?? []
        XCTAssertTrue(queryItems.contains("search=music%20channel"))
        XCTAssertTrue(queryItems.contains("sort=-match"))
    }

    func testChannelService_GetChannelWithVideos() async throws {
        // Given
        let expectedChannel = createMockVideoChannel()
        let expectedVideos = VideoListResponse(total: 5, data: [createMockVideo()])

        mockNetworking.responseQueue = [expectedChannel, expectedVideos]

        // When
        let result = try await services.channels.getChannelWithVideos(
            channelHandle: "testchannel",
            videoCount: 10
        )

        // Then
        XCTAssertEqual(result.channel.id, expectedChannel.id)
        XCTAssertEqual(result.videos.total, 5)
        XCTAssertEqual(mockNetworking.requestCount, 2)

        // Verify both requests were made
        XCTAssertTrue(
            mockNetworking.requestHistory.contains {
                $0.path.contains("/video-channels/testchannel")
            })
        XCTAssertTrue(
            mockNetworking.requestHistory.contains {
                $0.path.contains("/video-channels/testchannel/videos")
            })
    }

    // MARK: - InstanceService Tests

    func testInstanceService_GetConfig() async throws {
        // Given
        let expectedConfig = createMockInstanceConfig()
        mockNetworking.mockResponse = expectedConfig

        // When
        let result = try await services.instance.getConfig()

        // Then
        XCTAssertEqual(result.instance.name, expectedConfig.instance.name)
        XCTAssertEqual(mockNetworking.lastRequestURL?.path, "/api/v1/config")
    }

    func testInstanceService_GetAbout() async throws {
        // Given
        let expectedAbout = createMockInstanceAbout()
        mockNetworking.mockResponse = expectedAbout

        // When
        let result = try await services.instance.getAbout()

        // Then
        XCTAssertEqual(result.instance.name, expectedAbout.instance.name)
        XCTAssertEqual(mockNetworking.lastRequestURL?.path, "/api/v1/config/about")
    }

    func testInstanceService_GetStats() async throws {
        // Given
        let expectedStats = InstanceStats(
            totalUsers: 100,
            totalLocalVideos: 1000,
            totalLocalVideoViews: 50000,
            totalLocalVideoComments: 500,
            totalVideos: 1200
        )
        mockNetworking.mockResponse = expectedStats

        // When
        let result = try await services.instance.getStats()

        // Then
        XCTAssertEqual(result.totalUsers, 100)
        XCTAssertEqual(result.totalLocalVideos, 1000)
        XCTAssertEqual(mockNetworking.lastRequestURL?.path, "/api/v1/server/stats")
    }

    func testInstanceService_GetCompleteInstanceInfo() async throws {
        // Given
        let config = createMockInstanceConfig()
        let about = createMockInstanceAbout()
        let stats = InstanceStats(
            totalUsers: 50,
            totalLocalVideos: 500,
            totalLocalVideoViews: 10000,
            totalLocalVideoComments: 100,
            totalVideos: 600
        )

        mockNetworking.responseQueue = [config, about, stats]

        // When
        let result = try await services.instance.getCompleteInstanceInfo()

        // Then
        XCTAssertEqual(result.config.instance.name, config.instance.name)
        XCTAssertEqual(result.about.instance.name, about.instance.name)
        XCTAssertEqual(result.stats.totalUsers, stats.totalUsers)
        XCTAssertEqual(mockNetworking.requestCount, 3)
    }

    func testInstanceService_CheckHealth() async throws {
        // Given
        let config = createMockInstanceConfig()
        mockNetworking.mockResponse = config

        // When
        let result = await services.instance.checkHealth()

        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(mockNetworking.requestCount, 1)
    }

    func testInstanceService_CheckHealthWithError() async throws {
        // Given
        mockNetworking.shouldThrowError = true

        // When
        let result = await services.instance.checkHealth()

        // Then
        XCTAssertFalse(result)
        XCTAssertEqual(mockNetworking.requestCount, 1)
    }

    // MARK: - PeerTubeServices Integration Tests

    func testServices_QuickSearch() async throws {
        // Given
        let videoResults = VideoListResponse(total: 3, data: [createMockVideo()])
        let channelResults = ChannelListResponse(total: 2, data: [createMockVideoChannel()])

        mockNetworking.responseQueue = [videoResults, channelResults]

        // When
        let result = try await services.quickSearch(
            query: "test search",
            videoCount: 5,
            channelCount: 3
        )

        // Then
        XCTAssertEqual(result.query, "test search")
        XCTAssertEqual(result.videos.total, 3)
        XCTAssertEqual(result.channels.total, 2)
        XCTAssertEqual(result.totalResults, 5)
        XCTAssertTrue(result.hasResults)
        XCTAssertEqual(mockNetworking.requestCount, 2)
    }

    func testServices_GetHomepageContent() async throws {
        // Given
        let trendingVideos = VideoListResponse(total: 10, data: [createMockVideo()])
        let popularChannels = ChannelListResponse(total: 5, data: [createMockVideoChannel()])
        let config = createMockInstanceConfig()
        let about = createMockInstanceAbout()
        let stats = InstanceStats(
            totalUsers: 100,
            totalLocalVideos: 1000,
            totalLocalVideoViews: 50000,
            totalLocalVideoComments: 500,
            totalVideos: 1200
        )

        mockNetworking.responseQueue = [trendingVideos, popularChannels, config, about, stats]

        // When
        let result = try await services.getHomepageContent(videoCount: 10, channelCount: 5)

        // Then
        XCTAssertEqual(result.trendingVideos.total, 10)
        XCTAssertEqual(result.popularChannels.total, 5)
        XCTAssertEqual(result.instanceInfo.name, "Test Instance")
        XCTAssertEqual(mockNetworking.requestCount, 5)
    }

    // MARK: - Concurrency Safety Tests

    func testConcurrentVideoRequests() async throws {
        // Given
        let video1 = createMockVideoDetails(id: 1, name: "Video 1")
        let video2 = createMockVideoDetails(id: 2, name: "Video 2")
        let video3 = createMockVideoDetails(id: 3, name: "Video 3")

        mockNetworking.responseQueue = [video1, video2, video3]

        // When - Make concurrent requests
        async let result1 = services.videos.getVideo(id: 1)
        async let result2 = services.videos.getVideo(id: 2)
        async let result3 = services.videos.getVideo(id: 3)

        let results = try await [result1, result2, result3]

        // Then
        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(mockNetworking.requestCount, 3)
    }

    func testServicesSendableCompliance() {
        // This test verifies that our services can be used across actor boundaries
        Task {
            let localServices = services!

            // This should compile without warnings if Sendable compliance is correct
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    _ = await localServices.checkHealth()
                }
            }
        }
    }

    // MARK: - Error Handling Tests

    func testVideoService_NetworkError() async throws {
        // Given
        mockNetworking.shouldThrowError = true

        // When/Then
        await XCTAssertThrowsError(
            try await services.videos.getVideo(id: "123")
        ) { error in
            XCTAssertTrue(error is MockNetworkError)
        }
    }

    func testChannelService_NotFoundError() async throws {
        // Given
        mockNetworking.mockError = PeerTubeAPIError.httpError(statusCode: 404)

        // When/Then
        await XCTAssertThrowsError(
            try await services.channels.getChannel(handle: "nonexistent")
        ) { error in
            XCTAssertTrue(error is PeerTubeAPIError)
        }
    }

    // MARK: - Authentication Tests

    func testAuthentication_SetAndGetToken() async throws {
        // Given
        let token = AuthToken(
            accessToken: "test_token",
            tokenType: "Bearer",
            expiresIn: 3600
        )

        // When
        await services.setAuthToken(token)
        let retrievedToken = await services.getAuthToken()

        // Then
        XCTAssertEqual(retrievedToken?.accessToken, token.accessToken)
        XCTAssertEqual(retrievedToken?.tokenType, token.tokenType)
        XCTAssertEqual(retrievedToken?.expiresIn, token.expiresIn)
    }

    func testAuthentication_IsAuthenticated() async throws {
        // Given
        let token = AuthToken(
            accessToken: "test_token",
            tokenType: "Bearer",
            expiresIn: 3600
        )

        // When - Initially not authenticated
        let initialAuth = await services.isAuthenticated()

        // Set token
        await services.setAuthToken(token)
        let afterSetAuth = await services.isAuthenticated()

        // Clear token
        await services.clearAuthentication()
        let afterClearAuth = await services.isAuthenticated()

        // Then
        XCTAssertFalse(initialAuth)
        XCTAssertTrue(afterSetAuth)
        XCTAssertFalse(afterClearAuth)
    }

    // MARK: - Helper Methods

    private func createMockVideo(
        id: Int = 1,
        name: String = "Test Video"
    ) -> Video {
        Video(
            id: id,
            uuid: "test-uuid-\(id)",
            shortUUID: "short\(id)",
            createdAt: Date(),
            updatedAt: Date(),
            privacy: .public,
            duration: 300,
            name: name,
            views: 100,
            likes: 10,
            dislikes: 1,
            state: .published,
            account: createMockAccountSummary(),
            channel: createMockVideoChannelSummary()
        )
    }

    private func createMockVideoDetails(
        id: Int = 1,
        name: String = "Test Video Details"
    ) -> VideoDetails {
        VideoDetails(
            id: id,
            uuid: "test-uuid-\(id)",
            shortUUID: "short\(id)",
            createdAt: Date(),
            updatedAt: Date(),
            privacy: .public,
            description: "Test description",
            duration: 300,
            name: name,
            views: 100,
            likes: 10,
            dislikes: 1,
            state: .published,
            channel: createMockVideoChannel(),
            account: createMockAccount()
        )
    }

    private func createMockVideoChannel() -> VideoChannel {
        VideoChannel(
            id: 1,
            url: "https://test.example.com/video-channels/testchannel",
            name: "testchannel",
            host: "test.example.com",
            followingCount: 5,
            followersCount: 100,
            createdAt: Date(),
            updatedAt: Date(),
            displayName: "Test Channel",
            description: "Test channel description",
            ownerAccount: createMockAccountSummary()
        )
    }

    private func createMockVideoChannelSummary() -> VideoChannelSummary {
        VideoChannelSummary(
            id: 1,
            name: "testchannel",
            host: "test.example.com",
            displayName: "Test Channel"
        )
    }

    private func createMockAccount() -> Account {
        Account(
            id: 1,
            url: "https://test.example.com/accounts/testuser",
            name: "testuser",
            host: "test.example.com",
            followingCount: 10,
            followersCount: 50,
            createdAt: Date(),
            updatedAt: Date(),
            userId: 1,
            displayName: "Test User"
        )
    }

    private func createMockAccountSummary() -> AccountSummary {
        AccountSummary(
            id: 1,
            name: "testuser",
            host: "test.example.com",
            displayName: "Test User"
        )
    }

    private func createMockInstanceConfig() -> InstanceConfig {
        InstanceConfig(
            instance: InstanceInfo(
                name: "Test Instance",
                shortDescription: "A test instance",
                description: "This is a test PeerTube instance",
                terms: "Test terms",
                defaultNSFWPolicy: "blur"
            ),
            serverVersion: "4.0.0",
            signup: InstanceSignupConfig(allowed: true)
        )
    }

    private func createMockInstanceAbout() -> InstanceAbout {
        InstanceAbout(
            instance: InstanceInfo(
                name: "Test Instance",
                shortDescription: "A test instance",
                description: "This is a test PeerTube instance",
                terms: "Test terms",
                defaultNSFWPolicy: "blur"
            ),
            administrator: Administrator(
                name: "Test Admin",
                email: "admin@test.example.com"
            ),
            createdAt: Date()
        )
    }
}

// MARK: - Mock Networking Foundation

private class MockNetworkingFoundation: NetworkingFoundation {
    var mockResponse: Any?
    var mockError: Error?
    var shouldThrowError = false
    var responseQueue: [Any] = []
    private var responseIndex = 0

    var lastRequestURL: URL?
    var lastRequestMethod: HTTPMethod?
    var lastRequestHeaders: [String: String]?
    var requestCount = 0
    var requestHistory: [URL] = []

    override func request<T: Codable>(
        url: URL,
        method: HTTPMethod,
        headers: [String: String]?,
        requestBody _: (any Codable)? = nil
    ) async throws -> T {
        lastRequestURL = url
        lastRequestMethod = method
        lastRequestHeaders = headers
        requestCount += 1
        requestHistory.append(url)

        if shouldThrowError {
            throw mockError ?? MockNetworkError.testError
        }

        // Use response queue if available, otherwise use mockResponse
        let response: Any
        if !responseQueue.isEmpty && responseIndex < responseQueue.count {
            response = responseQueue[responseIndex]
            responseIndex += 1
        } else if let mockResponse = mockResponse {
            response = mockResponse
        } else {
            throw MockNetworkError.noMockResponse
        }

        guard let typedResponse = response as? T else {
            throw MockNetworkError.typeMismatch
        }

        return typedResponse
    }

    override func requestData(
        url: URL,
        method: HTTPMethod,
        headers: [String: String]?
    ) async throws -> Data {
        lastRequestURL = url
        lastRequestMethod = method
        lastRequestHeaders = headers
        requestCount += 1
        requestHistory.append(url)

        if shouldThrowError {
            throw mockError ?? MockNetworkError.testError
        }

        return Data()
    }
}

// MARK: - Mock Errors

private enum MockNetworkError: Error {
    case testError
    case noMockResponse
    case typeMismatch
}

// MARK: - XCTest Async Extensions

extension XCTestCase {
    func XCTAssertThrowsError<T>(
        _ expression: @autoclosure () async throws -> T,
        _: String = "",
        file: StaticString = #filePath,
        line: UInt = #line,
        _ errorHandler: (_ error: Error) -> Void = { _ in }
    ) async {
        do {
            _ = try await expression()
            XCTFail("Expected error to be thrown", file: file, line: line)
        } catch {
            errorHandler(error)
        }
    }
}
