# PeerTube Swift Service Layer

This document describes the service layer architecture implemented for the PeerTube Swift library, providing high-level APIs for interacting with PeerTube instances using Swift 6 concurrency patterns.

## Overview

The service layer provides three main services:
- **VideoService**: Video-related operations (get, list, search videos)
- **ChannelService**: Channel-related operations (get, list, search channels)  
- **InstanceService**: Instance-related operations (config, stats, metadata)
- **PeerTubeServices**: Unified service manager with convenience methods

All services are designed with Swift 6 concurrency safety in mind, using `@MainActor`, `Sendable` types, and structured concurrency patterns.

## Architecture

### Service Layer Design Principles

1. **Swift 6 Concurrency**: All services are `@MainActor` classes marked as `Sendable`
2. **Structured Concurrency**: Uses `withTaskGroup` for parallel operations
3. **Type Safety**: Comprehensive parameter and response types
4. **Error Handling**: Consistent error propagation with PeerTube-specific error types
5. **Sendable Compliance**: All data types conform to `Sendable` for thread safety

### Core Components

```swift
@MainActor
public final class VideoService: Sendable { ... }

@MainActor  
public final class ChannelService: Sendable { ... }

@MainActor
public final class InstanceService: Sendable { ... }

@MainActor
public final class PeerTubeServices: Sendable { ... }
```

## VideoService

### Basic Operations

```swift
let services = PeerTubeServices(instanceURL: URL(string: "https://example.com")!)

// Get single video by ID or UUID
let video = try await services.videos.getVideo(id: "abc123")
let videoById = try await services.videos.getVideo(id: 12345)

// List videos with parameters
let parameters = VideoListParameters(
    start: 0,
    count: 15,
    sort: .createdAt,
    nsfw: .false,
    isLocal: true
)
let videos = try await services.videos.listVideos(parameters: parameters)
```

### Search Operations

```swift
// Search videos
let searchParams = VideoSearchParameters(
    search: "swift programming",
    count: 10,
    sort: .relevance,
    searchTarget: .local,
    durationMin: 300 // 5 minutes minimum
)
let searchResults = try await services.videos.searchVideos(parameters: searchParams)

// Simple search
let results = try await services.videos.search(query: "tutorial", count: 20)
```

### Batch Operations with Structured Concurrency

```swift
// Get multiple videos concurrently
let videoIds = ["abc123", "def456", "ghi789"]
let videos = await services.videos.getVideos(ids: videoIds)

// Get channel videos
let channelVideos = try await services.videos.getChannelVideos(
    channelHandle: "mychannel@example.com",
    parameters: VideoListParameters(count: 20)
)
```

### Convenience Methods

```swift
// Get trending content
let trending = try await services.videos.getTrendingVideos(count: 15)
let popular = try await services.videos.getPopularVideos(count: 10)
let recent = try await services.videos.getRecentVideos(count: 25)
let local = try await services.videos.getLocalVideos(count: 20)
let live = try await services.videos.getLiveVideos(count: 5)
```

## ChannelService

### Basic Operations

```swift
// Get channel by handle or ID
let channel = try await services.channels.getChannel(handle: "mychannel@example.com")
let channelById = try await services.channels.getChannel(id: 123)

// List channels
let channelParams = ChannelListParameters(
    count: 20,
    sort: .followersCount,
    isLocal: false
)
let channels = try await services.channels.listChannels(parameters: channelParams)
```

### Search and Discovery

```swift
// Search channels
let searchParams = ChannelSearchParameters(
    search: "music",
    sort: .relevance,
    searchTarget: .searchIndex
)
let channelResults = try await services.channels.searchChannels(parameters: searchParams)

// Get account channels
let accountChannels = try await services.channels.getAccountChannels(
    accountHandle: "user@example.com"
)
```

### Advanced Operations

```swift
// Get channel with its videos in one operation
let (channel, videos) = try await services.channels.getChannelWithVideos(
    channelHandle: "mychannel@example.com",
    videoCount: 10
)

// Get channel statistics
let stats = try await services.channels.getChannelStats(
    channelHandle: "mychannel@example.com"
)
print("Total views: \(stats.totalViews)")
print("Average views per video: \(stats.averageViews)")
```

### Batch Operations

```swift
// Get multiple channels concurrently
let channelHandles = ["channel1@example.com", "channel2@example.com"]
let channels = await services.channels.getChannels(handles: channelHandles)
```

## InstanceService

### Instance Information

```swift
// Get instance configuration
let config = try await services.instance.getConfig()
print("Instance name: \(config.instance.name)")
print("Signup allowed: \(config.signup?.allowed ?? false)")

// Get instance about information
let about = try await services.instance.getAbout()
print("Administrator: \(about.administrator?.name ?? "Unknown")")

// Get instance statistics
let stats = try await services.instance.getStats()
print("Total users: \(stats.totalUsers)")
print("Total videos: \(stats.totalVideos)")
```

### Batch Operations

```swift
// Get complete instance info concurrently
let (config, about, stats) = try await services.instance.getCompleteInstanceInfo()

// Get all metadata concurrently
let (categories, licences, languages, privacies) = try await services.instance.getAllMetadata()
```

### Health and Connectivity

```swift
// Check instance health
let isHealthy = await services.instance.checkHealth()

// Test connectivity with timeout
let isReachable = await services.instance.testConnectivity(timeout: 5.0)

// Get basic instance info for display
let basicInfo = try await services.instance.getBasicInfo()
print("\(basicInfo.name) - \(basicInfo.userCount) users, \(basicInfo.videoCount) videos")
```

### Feature Detection

```swift
// Check if instance supports specific features
let supportsHLS = try await services.instance.supportsFeature(.hls)
let allowsSignup = try await services.instance.supportsFeature(.signup)
let hasContactForm = try await services.instance.supportsFeature(.contactForm)
```

## PeerTubeServices - Unified Service Manager

### Initialization

```swift
// Initialize with URL
let services = PeerTubeServices(instanceURL: URL(string: "https://peertube.example.com")!)

// Initialize with URL string
let services = PeerTubeServices(instanceURLString: "https://peertube.example.com")

// Initialize with custom API client
let config = APIClientConfig(instanceURL: instanceURL, rateLimitingEnabled: true)
let apiClient = APIClient(config: config)
let services = PeerTubeServices(apiClient: apiClient)
```

### Authentication Management

```swift
// Set authentication token
let token = AuthToken(
    accessToken: "your_token_here",
    tokenType: "Bearer", 
    expiresIn: 3600
)
await services.setAuthToken(token)

// Check authentication status
let isAuthenticated = await services.isAuthenticated()

// Clear authentication
await services.clearAuthentication()
```

### High-Level Operations

```swift
// Quick search across videos and channels
let searchResults = try await services.quickSearch(
    query: "swift tutorial",
    videoCount: 10,
    channelCount: 5
)
print("Found \(searchResults.totalResults) total results")
print("Videos: \(searchResults.videos.data.count)")
print("Channels: \(searchResults.channels.data.count)")

// Get homepage content
let homepage = try await services.getHomepageContent(
    videoCount: 15,
    channelCount: 10
)
print("Instance: \(homepage.instanceInfo.name)")
print("Trending videos: \(homepage.trendingVideos.data.count)")
print("Popular channels: \(homepage.popularChannels.data.count)")
```

### Health Monitoring

```swift
// Quick health check
let isHealthy = await services.checkHealth()

// Connectivity test with timeout
let isConnected = await services.testConnectivity(timeout: 10.0)

// Get instance hostname
print("Connected to: \(services.instanceHost)")
```

## Parameter Types

### VideoListParameters

```swift
public struct VideoListParameters: Sendable {
    public let start: Int           // Pagination start (default: 0)
    public let count: Int           // Results per page (default: 15)
    public let sort: VideoSort      // Sort order (default: .createdAt)
    public let categoryOneOf: [Int]?      // Filter by categories
    public let licenceOneOf: [Int]?       // Filter by licences
    public let languageOneOf: [String]?   // Filter by languages
    public let tagsOneOf: [String]?       // Filter by tags (OR)
    public let nsfw: NSFWFilter?          // NSFW content filter
    public let isLive: Bool?              // Live videos only
    public let isLocal: Bool?             // Local videos only
    public let skipCount: Bool            // Skip total count calculation
}
```

### VideoSearchParameters

```swift
public struct VideoSearchParameters: Sendable {
    public let search: String             // Search query
    public let searchTarget: SearchTarget // Local or federated search
    public let tagsAllOf: [String]?       // Filter by tags (AND)
    public let durationMin: Int?          // Minimum duration in seconds
    public let durationMax: Int?          // Maximum duration in seconds  
    public let startDate: Date?           // Filter by publish date range
    public let endDate: Date?
    // ... includes all VideoListParameters fields
}
```

### ChannelListParameters / ChannelSearchParameters

Similar structure to video parameters, but with channel-specific sorting options:

```swift
public enum ChannelSort: String, CaseIterable, Sendable {
    case createdAt = "-createdAt"
    case updatedAt = "-updatedAt"
    case name = "name"
    case followersCount = "-followersCount"
    case videosCount = "-videosCount"
    case relevance = "-match"  // For search only
}
```

## Response Types

### VideoListResponse / ChannelListResponse

```swift
public struct VideoListResponse: Codable, Sendable {
    public let total: Int       // Total results available
    public let data: [Video]    // Current page of results
}

public struct ChannelListResponse: Codable, Sendable {
    public let total: Int           // Total results available
    public let data: [VideoChannel] // Current page of results
}
```

### Combined Response Types

```swift
public struct QuickSearchResults: Sendable {
    public let query: String
    public let videos: VideoListResponse
    public let channels: ChannelListResponse
    
    public var totalResults: Int { videos.total + channels.total }
    public var hasResults: Bool { !videos.data.isEmpty || !channels.data.isEmpty }
}

public struct HomepageContent: Sendable {
    public let trendingVideos: VideoListResponse
    public let popularChannels: ChannelListResponse
    public let instanceInfo: BasicInstanceInfo
}
```

## Error Handling

All service methods can throw `PeerTubeAPIError`:

```swift
do {
    let video = try await services.videos.getVideo(id: "invalid-id")
} catch let error as PeerTubeAPIError {
    switch error {
    case .httpError(let statusCode):
        print("HTTP error: \(statusCode)")
    case .serverError(let statusCode, let errorResponse):
        print("Server error \(statusCode): \(errorResponse.error)")
    case .networkUnavailable:
        print("Network unavailable")
    case .timeout:
        print("Request timeout")
    case .authenticationRequired:
        print("Authentication required")
    default:
        print("Other error: \(error)")
    }
}
```

## Structured Concurrency Examples

### Parallel Video Fetching

```swift
// Fetch multiple videos concurrently using structured concurrency
let videoIds = ["video1", "video2", "video3"]
let videos = await withTaskGroup(of: VideoDetails?.self) { group in
    for id in videoIds {
        group.addTask {
            try? await services.videos.getVideo(id: id)
        }
    }
    
    var results: [VideoDetails] = []
    for await video in group {
        if let video = video {
            results.append(video)
        }
    }
    return results
}
```

### Combined Data Fetching

```swift
// Fetch homepage data with structured concurrency
let homepageData = try await withThrowingTaskGroup(of: Void.self) { group in
    var videos: VideoListResponse?
    var channels: ChannelListResponse?
    var instanceInfo: BasicInstanceInfo?
    
    group.addTask {
        videos = try await services.videos.getTrendingVideos(count: 15)
    }
    
    group.addTask {
        channels = try await services.channels.getPopularChannels(count: 10)
    }
    
    group.addTask {
        instanceInfo = try await services.instance.getBasicInfo()
    }
    
    try await group.waitForAll()
    
    return HomepageContent(
        trendingVideos: videos!,
        popularChannels: channels!,
        instanceInfo: instanceInfo!
    )
}
```

## Integration with SwiftUI

The service layer is designed to work seamlessly with SwiftUI:

```swift
@MainActor
class VideoViewModel: ObservableObject {
    @Published var videos: [Video] = []
    @Published var isLoading = false
    @Published var error: PeerTubeAPIError?
    
    private let services: PeerTubeServices
    
    init(services: PeerTubeServices) {
        self.services = services
    }
    
    func loadTrendingVideos() async {
        isLoading = true
        error = nil
        
        do {
            let response = try await services.videos.getTrendingVideos(count: 20)
            videos = response.data
        } catch let apiError as PeerTubeAPIError {
            error = apiError
        } catch {
            error = .networkError(.unknown)
        }
        
        isLoading = false
    }
}
```

## Performance Considerations

1. **Rate Limiting**: Built-in rate limiting (configurable, default: 50 requests per 10 seconds)
2. **Concurrent Requests**: Services use structured concurrency for parallel operations
3. **Pagination**: All list operations support pagination with `start` and `count` parameters
4. **Skip Count**: Use `skipCount: true` for faster responses when total count isn't needed
5. **Caching**: Services don't implement caching - implement at the application level as needed

## Testing

The service layer includes comprehensive unit tests with mock networking:

```swift
@MainActor
final class ServiceTests: XCTestCase {
    private var services: PeerTubeServices!
    
    func testVideoService_GetVideo() async throws {
        let video = try await services.videos.getVideo(id: "test123")
        XCTAssertEqual(video.id, 123)
    }
}
```

Tests cover:
- Individual service operations
- Batch operations with structured concurrency
- Error handling scenarios
- Authentication management
- Sendable compliance
- Concurrent access patterns

## Migration from REST to Service Layer

If migrating from direct REST calls:

**Before:**
```swift
// Direct API calls
let url = URL(string: "https://instance.com/api/v1/videos?count=15")!
let data = try await URLSession.shared.data(from: url).0
let videos = try JSONDecoder().decode(VideoListResponse.self, from: data)
```

**After:**
```swift
// Service layer
let services = PeerTubeServices(instanceURLString: "https://instance.com")!
let videos = try await services.videos.getRecentVideos(count: 15)
```

Benefits:
- Type-safe parameters and responses
- Built-in error handling
- Rate limiting and authentication management
- Swift 6 concurrency safety
- Structured concurrency support
- Comprehensive documentation and testing
