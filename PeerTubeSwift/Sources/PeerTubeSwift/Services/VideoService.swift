//
//  VideoService.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

import Foundation

/// Parameters for listing videos
public struct VideoListParameters: Sendable {
    public let start: Int
    public let count: Int
    public let sort: VideoSort
    public let categoryOneOf: [Int]?
    public let licenceOneOf: [Int]?
    public let languageOneOf: [String]?
    public let tagsOneOf: [String]?
    public let nsfw: NSFWFilter?
    public let isLive: Bool?
    public let isLocal: Bool?
    public let skipCount: Bool

    public init(
        start: Int = 0,
        count: Int = 15,
        sort: VideoSort = .createdAt,
        categoryOneOf: [Int]? = nil,
        licenceOneOf: [Int]? = nil,
        languageOneOf: [String]? = nil,
        tagsOneOf: [String]? = nil,
        nsfw: NSFWFilter? = nil,
        isLive: Bool? = nil,
        isLocal: Bool? = nil,
        skipCount: Bool = false
    ) {
        self.start = start
        self.count = count
        self.sort = sort
        self.categoryOneOf = categoryOneOf
        self.licenceOneOf = licenceOneOf
        self.languageOneOf = languageOneOf
        self.tagsOneOf = tagsOneOf
        self.nsfw = nsfw
        self.isLive = isLive
        self.isLocal = isLocal
        self.skipCount = skipCount
    }
}

/// Parameters for searching videos
public struct VideoSearchParameters: Sendable {
    public let search: String
    public let start: Int
    public let count: Int
    public let sort: VideoSort
    public let searchTarget: SearchTarget
    public let categoryOneOf: [Int]?
    public let licenceOneOf: [Int]?
    public let languageOneOf: [String]?
    public let tagsOneOf: [String]?
    public let tagsAllOf: [String]?
    public let nsfw: NSFWFilter?
    public let isLive: Bool?
    public let isLocal: Bool?
    public let durationMin: Int?
    public let durationMax: Int?
    public let startDate: Date?
    public let endDate: Date?
    public let skipCount: Bool

    public init(
        search: String,
        start: Int = 0,
        count: Int = 15,
        sort: VideoSort = .relevance,
        searchTarget: SearchTarget = .local,
        categoryOneOf: [Int]? = nil,
        licenceOneOf: [Int]? = nil,
        languageOneOf: [String]? = nil,
        tagsOneOf: [String]? = nil,
        tagsAllOf: [String]? = nil,
        nsfw: NSFWFilter? = nil,
        isLive: Bool? = nil,
        isLocal: Bool? = nil,
        durationMin: Int? = nil,
        durationMax: Int? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        skipCount: Bool = false
    ) {
        self.search = search
        self.start = start
        self.count = count
        self.sort = sort
        self.searchTarget = searchTarget
        self.categoryOneOf = categoryOneOf
        self.licenceOneOf = licenceOneOf
        self.languageOneOf = languageOneOf
        self.tagsOneOf = tagsOneOf
        self.tagsAllOf = tagsAllOf
        self.nsfw = nsfw
        self.isLive = isLive
        self.isLocal = isLocal
        self.durationMin = durationMin
        self.durationMax = durationMax
        self.startDate = startDate
        self.endDate = endDate
        self.skipCount = skipCount
    }
}

/// Video sorting options
public enum VideoSort: String, CaseIterable, Sendable {
    case createdAt = "-createdAt"
    case publishedAt = "-publishedAt"
    case updatedAt = "-updatedAt"
    case views = "-views"
    case likes = "-likes"
    case duration = "-duration"
    case name
    case relevance = "-match" // For search results only

    public var displayName: String {
        switch self {
        case .createdAt: return "Created Date"
        case .publishedAt: return "Published Date"
        case .updatedAt: return "Updated Date"
        case .views: return "Views"
        case .likes: return "Likes"
        case .duration: return "Duration"
        case .name: return "Name"
        case .relevance: return "Relevance"
        }
    }
}

/// NSFW content filtering
public enum NSFWFilter: String, CaseIterable, Sendable {
    case `true`
    case `false`
    case both

    public var displayName: String {
        switch self {
        case .true: return "NSFW Only"
        case .false: return "No NSFW"
        case .both: return "All Content"
        }
    }
}

/// Search target scope
public enum SearchTarget: String, CaseIterable, Sendable {
    case local
    case searchIndex = "search-index"

    public var displayName: String {
        switch self {
        case .local: return "Local Instance"
        case .searchIndex: return "Federated Search"
        }
    }
}

/// Response wrapper for paginated video results
public struct VideoListResponse: Codable, Sendable {
    public let total: Int
    public let data: [Video]

    public init(total: Int, data: [Video]) {
        self.total = total
        self.data = data
    }
}

/// Service for video-related API operations with Swift 6 concurrency support
@MainActor
public final class VideoService: Sendable {
    // MARK: - Properties

    private let apiClient: APIClient

    // MARK: - Initialization

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    // MARK: - Video Operations

    /// Get a single video by ID or UUID
    /// - Parameter id: Video ID (numeric) or UUID string
    /// - Returns: Detailed video information
    /// - Throws: PeerTubeAPIError if the request fails
    public func getVideo(id: String) async throws -> VideoDetails {
        return try await apiClient.get(
            path: "/videos/\(id)",
            authenticated: false
        )
    }

    /// Get a single video by numeric ID
    /// - Parameter id: Video numeric ID
    /// - Returns: Detailed video information
    /// - Throws: PeerTubeAPIError if the request fails
    public func getVideo(id: Int) async throws -> VideoDetails {
        return try await getVideo(id: String(id))
    }

    /// List videos with filtering and pagination
    /// - Parameter parameters: Filtering and pagination parameters
    /// - Returns: Paginated list of videos
    /// - Throws: PeerTubeAPIError if the request fails
    public func listVideos(parameters: VideoListParameters = VideoListParameters()) async throws
        -> VideoListResponse
    {
        var queryParams: [String: String] = [
            "start": String(parameters.start),
            "count": String(parameters.count),
            "sort": parameters.sort.rawValue,
            "skipCount": String(parameters.skipCount),
        ]

        // Add optional parameters
        if let categoryOneOf = parameters.categoryOneOf, !categoryOneOf.isEmpty {
            queryParams["categoryOneOf"] = categoryOneOf.map(String.init).joined(separator: ",")
        }

        if let licenceOneOf = parameters.licenceOneOf, !licenceOneOf.isEmpty {
            queryParams["licenceOneOf"] = licenceOneOf.map(String.init).joined(separator: ",")
        }

        if let languageOneOf = parameters.languageOneOf, !languageOneOf.isEmpty {
            queryParams["languageOneOf"] = languageOneOf.joined(separator: ",")
        }

        if let tagsOneOf = parameters.tagsOneOf, !tagsOneOf.isEmpty {
            queryParams["tagsOneOf"] = tagsOneOf.joined(separator: ",")
        }

        if let nsfw = parameters.nsfw {
            queryParams["nsfw"] = nsfw.rawValue
        }

        if let isLive = parameters.isLive {
            queryParams["isLive"] = String(isLive)
        }

        if let isLocal = parameters.isLocal {
            queryParams["isLocal"] = String(isLocal)
        }

        return try await apiClient.get(
            path: "/videos",
            queryParameters: queryParams,
            authenticated: false
        )
    }

    /// Search videos
    /// - Parameter parameters: Search parameters
    /// - Returns: Paginated search results
    /// - Throws: PeerTubeAPIError if the request fails
    public func searchVideos(parameters: VideoSearchParameters) async throws -> VideoListResponse {
        var queryParams: [String: String] = [
            "search": parameters.search,
            "start": String(parameters.start),
            "count": String(parameters.count),
            "sort": parameters.sort.rawValue,
            "searchTarget": parameters.searchTarget.rawValue,
            "skipCount": String(parameters.skipCount),
        ]

        // Add optional parameters
        if let categoryOneOf = parameters.categoryOneOf, !categoryOneOf.isEmpty {
            queryParams["categoryOneOf"] = categoryOneOf.map(String.init).joined(separator: ",")
        }

        if let licenceOneOf = parameters.licenceOneOf, !licenceOneOf.isEmpty {
            queryParams["licenceOneOf"] = licenceOneOf.map(String.init).joined(separator: ",")
        }

        if let languageOneOf = parameters.languageOneOf, !languageOneOf.isEmpty {
            queryParams["languageOneOf"] = languageOneOf.joined(separator: ",")
        }

        if let tagsOneOf = parameters.tagsOneOf, !tagsOneOf.isEmpty {
            queryParams["tagsOneOf"] = tagsOneOf.joined(separator: ",")
        }

        if let tagsAllOf = parameters.tagsAllOf, !tagsAllOf.isEmpty {
            queryParams["tagsAllOf"] = tagsAllOf.joined(separator: ",")
        }

        if let nsfw = parameters.nsfw {
            queryParams["nsfw"] = nsfw.rawValue
        }

        if let isLive = parameters.isLive {
            queryParams["isLive"] = String(isLive)
        }

        if let isLocal = parameters.isLocal {
            queryParams["isLocal"] = String(isLocal)
        }

        if let durationMin = parameters.durationMin {
            queryParams["durationMin"] = String(durationMin)
        }

        if let durationMax = parameters.durationMax {
            queryParams["durationMax"] = String(durationMax)
        }

        if let startDate = parameters.startDate {
            queryParams["startDate"] = ISO8601DateFormatter().string(from: startDate)
        }

        if let endDate = parameters.endDate {
            queryParams["endDate"] = ISO8601DateFormatter().string(from: endDate)
        }

        return try await apiClient.get(
            path: "/search/videos",
            queryParameters: queryParams,
            authenticated: false
        )
    }

    /// Get videos from a specific channel
    /// - Parameters:
    ///   - channelHandle: Channel handle (name@host) or numeric ID
    ///   - parameters: Filtering and pagination parameters
    /// - Returns: Paginated list of videos from the channel
    /// - Throws: PeerTubeAPIError if the request fails
    public func getChannelVideos(
        channelHandle: String,
        parameters: VideoListParameters = VideoListParameters()
    ) async throws -> VideoListResponse {
        var queryParams: [String: String] = [
            "start": String(parameters.start),
            "count": String(parameters.count),
            "sort": parameters.sort.rawValue,
            "skipCount": String(parameters.skipCount),
        ]

        // Add optional parameters (subset relevant for channel videos)
        if let nsfw = parameters.nsfw {
            queryParams["nsfw"] = nsfw.rawValue
        }

        if let isLive = parameters.isLive {
            queryParams["isLive"] = String(isLive)
        }

        return try await apiClient.get(
            path: "/video-channels/\(channelHandle)/videos",
            queryParameters: queryParams,
            authenticated: false
        )
    }

    /// Get videos from a specific account
    /// - Parameters:
    ///   - accountHandle: Account handle (name@host) or numeric ID
    ///   - parameters: Filtering and pagination parameters
    /// - Returns: Paginated list of videos from the account
    /// - Throws: PeerTubeAPIError if the request fails
    public func getAccountVideos(
        accountHandle: String,
        parameters: VideoListParameters = VideoListParameters()
    ) async throws -> VideoListResponse {
        var queryParams: [String: String] = [
            "start": String(parameters.start),
            "count": String(parameters.count),
            "sort": parameters.sort.rawValue,
            "skipCount": String(parameters.skipCount),
        ]

        // Add optional parameters (subset relevant for account videos)
        if let nsfw = parameters.nsfw {
            queryParams["nsfw"] = nsfw.rawValue
        }

        if let isLive = parameters.isLive {
            queryParams["isLive"] = String(isLive)
        }

        return try await apiClient.get(
            path: "/accounts/\(accountHandle)/videos",
            queryParameters: queryParams,
            authenticated: false
        )
    }

    // MARK: - Batch Operations with Structured Concurrency

    /// Get multiple videos concurrently by their IDs
    /// - Parameter ids: Array of video IDs (numeric or UUID)
    /// - Returns: Array of video details (may be fewer than requested if some fail)
    /// - Note: Uses structured concurrency to fetch videos in parallel
    public func getVideos(ids: [String]) async -> [VideoDetails] {
        return await withTaskGroup(of: VideoDetails?.self) { group in
            // Add tasks for each video ID
            for id in ids {
                group.addTask { [weak self] in
                    guard let self = self else { return nil }
                    do {
                        return try await self.getVideo(id: id)
                    } catch {
                        // Log error in a real implementation
                        return nil
                    }
                }
            }

            // Collect results
            var results: [VideoDetails] = []
            for await video in group {
                if let video = video {
                    results.append(video)
                }
            }
            return results
        }
    }

    /// Get multiple videos concurrently by numeric IDs
    /// - Parameter ids: Array of numeric video IDs
    /// - Returns: Array of video details
    public func getVideos(ids: [Int]) async -> [VideoDetails] {
        return await getVideos(ids: ids.map(String.init))
    }
}

// MARK: - Convenience Extensions

public extension VideoService {
    /// Get the most recent videos
    /// - Parameter count: Number of videos to fetch (default: 15)
    /// - Returns: Recent videos sorted by creation date
    func getRecentVideos(count: Int = 15) async throws -> VideoListResponse {
        let parameters = VideoListParameters(
            start: 0,
            count: count,
            sort: .createdAt
        )
        return try await listVideos(parameters: parameters)
    }

    /// Get the most viewed videos
    /// - Parameter count: Number of videos to fetch (default: 15)
    /// - Returns: Popular videos sorted by view count
    func getPopularVideos(count: Int = 15) async throws -> VideoListResponse {
        let parameters = VideoListParameters(
            start: 0,
            count: count,
            sort: .views
        )
        return try await listVideos(parameters: parameters)
    }

    /// Get trending videos (most liked)
    /// - Parameter count: Number of videos to fetch (default: 15)
    /// - Returns: Trending videos sorted by likes
    func getTrendingVideos(count: Int = 15) async throws -> VideoListResponse {
        let parameters = VideoListParameters(
            start: 0,
            count: count,
            sort: .likes
        )
        return try await listVideos(parameters: parameters)
    }

    /// Get local videos only
    /// - Parameter count: Number of videos to fetch (default: 15)
    /// - Returns: Local videos from this instance
    func getLocalVideos(count: Int = 15) async throws -> VideoListResponse {
        let parameters = VideoListParameters(
            start: 0,
            count: count,
            sort: .createdAt,
            isLocal: true
        )
        return try await listVideos(parameters: parameters)
    }

    /// Get live videos currently streaming
    /// - Parameter count: Number of videos to fetch (default: 15)
    /// - Returns: Currently live videos
    func getLiveVideos(count: Int = 15) async throws -> VideoListResponse {
        let parameters = VideoListParameters(
            start: 0,
            count: count,
            sort: .createdAt,
            isLive: true
        )
        return try await listVideos(parameters: parameters)
    }

    /// Simple text search
    /// - Parameters:
    ///   - query: Search query string
    ///   - count: Number of results to fetch (default: 15)
    /// - Returns: Search results
    func search(query: String, count: Int = 15) async throws -> VideoListResponse {
        let parameters = VideoSearchParameters(
            search: query,
            count: count
        )
        return try await searchVideos(parameters: parameters)
    }
}
