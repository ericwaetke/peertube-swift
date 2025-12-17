# PeerTube Swift Models Documentation

This document provides comprehensive documentation for all PeerTube API models implemented in PeerTubeSwift.

## Overview

The PeerTube Swift models provide type-safe representations of all major PeerTube API entities. These models are designed to:

- **Mirror the PeerTube API structure** - Direct mapping from JSON responses
- **Provide computed properties** - Convenient access to derived values
- **Support Codable** - Automatic JSON encoding/decoding
- **Maintain relationships** - Proper modeling of entity relationships
- **Enable local storage** - Compatible with Core Data entities

## Core Models

### ActorImage

Represents avatar and banner images for actors (accounts and channels).

```swift
public struct ActorImage: Codable, Hashable {
    public let id: Int?
    public let filename: String
    public let fileExtension: String?
    public let width: Int?
    public let height: Int?
    public let size: Int?
    public let createdAt: Date?
    public let updatedAt: Date?
    
    // Computed Properties
    public var url: String? // Generated URL path
}
```

**Usage:**
```swift
let avatar = ActorImage(filename: "avatar.jpg", width: 120, height: 120)
print(avatar.url) // "/lazy-static/avatars/avatar.jpg"
```

### Actor

Base actor model for accounts and channels, following ActivityPub standards.

```swift
public struct Actor: Codable, Hashable, Identifiable {
    public let id: Int
    public let url: String
    public let name: String
    public let avatars: [ActorImage]
    public let host: String
    public let followingCount: Int
    public let followersCount: Int
    public let createdAt: Date
    public let updatedAt: Date
    
    // Computed Properties
    public var handle: String // "username@domain.com"
    public var primaryAvatar: ActorImage? // Largest avatar
    public var smallAvatar: ActorImage? // Smallest avatar
    public var isLocal: Bool // Whether from local instance
}
```

**Key Features:**
- **Handle generation**: Automatic `username@domain` formatting
- **Avatar selection**: Smart selection of best avatar sizes
- **Local detection**: Identifies local vs. federated actors

### Account

Represents a PeerTube user account, extending Actor with account-specific properties.

```swift
public struct Account: Codable, Hashable, Identifiable {
    // Actor properties (inherited conceptually)
    public let id: Int
    public let url: String
    public let name: String
    public let avatars: [ActorImage]
    public let host: String
    public let followingCount: Int
    public let followersCount: Int
    public let createdAt: Date
    public let updatedAt: Date
    
    // Account-specific properties
    public let userId: Int? // Local user ID
    public let displayName: String
    public let description: String?
    
    // Computed Properties
    public var effectiveDisplayName: String // displayName or fallback to name
    public var isLocal: Bool // Based on userId presence
}
```

**Summary Variant:**
```swift
public struct AccountSummary: Codable, Hashable, Identifiable {
    public let id: Int
    public let name: String
    public let host: String
    public let displayName: String
    public let avatar: ActorImage?
}
```

### VideoChannel

Represents a PeerTube video channel, extending Actor with channel-specific properties.

```swift
public struct VideoChannel: Codable, Hashable, Identifiable {
    // Actor properties
    public let id: Int
    public let url: String
    public let name: String
    public let avatars: [ActorImage]
    public let host: String
    public let followingCount: Int
    public let followersCount: Int
    public let createdAt: Date
    public let updatedAt: Date
    
    // Channel-specific properties
    public let displayName: String
    public let description: String?
    public let support: String? // Funding/support information
    public let isLocal: Bool
    public let banners: [ActorImage]
    public let ownerAccount: AccountSummary
    
    // Computed Properties
    public var primaryBanner: ActorImage? // Largest banner
    public var effectiveDisplayName: String
}
```

**Usage:**
```swift
let channel = VideoChannel(
    id: 1,
    name: "my_channel",
    displayName: "My Awesome Channel",
    description: "Videos about Swift development",
    ownerAccount: accountSummary
)
```

## Video Models

### Video

Core video model representing a PeerTube video with essential metadata.

```swift
public struct Video: Codable, Hashable, Identifiable {
    // Identifiers
    public let id: Int
    public let uuid: String // Universal identifier
    public let shortUUID: String // Short URL identifier
    
    // Metadata
    public let name: String
    public let duration: Int // In seconds
    public let views: Int
    public let likes: Int
    public let dislikes: Int
    public let privacy: VideoPrivacy
    public let state: VideoState
    
    // Relationships
    public let account: AccountSummary
    public let channel: VideoChannelSummary
    
    // Computed Properties
    public var formattedDuration: String // "MM:SS" or "HH:MM:SS"
    public var likeRatio: Double // 0.0 to 1.0
    public var isPublished: Bool
    public var hasNSFWContent: Bool
}
```

### VideoDetails

Extended video information with full details for video pages.

```swift
public struct VideoDetails: Codable, Hashable, Identifiable {
    // All Video properties plus:
    public let description: String? // Full description (not truncated)
    public let files: [VideoFile] // Available video files
    public let streamingPlaylists: [VideoStreamingPlaylist] // HLS/DASH
    public let tags: [String]
    public let support: String? // Creator support information
    public let downloadEnabled: Bool
    public let commentsEnabled: Bool
    
    // Full relationship objects
    public let channel: VideoChannel // Full channel object
    public let account: Account // Full account object
    
    // Computed Properties
    public var bestQualityFile: VideoFile?
    public var lowestQualityFile: VideoFile?
}
```

### VideoFile

Represents an individual video file with quality and format information.

```swift
public struct VideoFile: Codable, Hashable {
    public let id: Int?
    public let resolution: VideoResolution
    public let size: Int? // File size in bytes
    public let fps: Int? // Frames per second
    public let fileExtension: String
    public let fileDownloadUrl: String?
    public let torrentDownloadUrl: String? // P2P support
    public let magnetUri: String?
}
```

### VideoStreamingPlaylist

Represents streaming playlists (HLS, DASH) for adaptive bitrate streaming.

```swift
public struct VideoStreamingPlaylist: Codable, Hashable {
    public let id: Int
    public let type: Int // 1 = HLS
    public let playlistUrl: String
    public let segmentsSha256Url: String
    public let files: [VideoFile]
    public let redundancies: [VideoStreamingPlaylistRedundancy]?
}
```

## Enumerations

### VideoPrivacy

Defines video privacy levels.

```swift
public enum VideoPrivacy: Int, Codable, CaseIterable {
    case public = 1
    case unlisted = 2
    case private = 3
    case internal = 4
    case passwordProtected = 5
    
    public var description: String // Human-readable description
}
```

### VideoState

Represents video processing states.

```swift
public enum VideoState: Int, Codable, CaseIterable {
    case published = 1
    case toTranscode = 2
    case toImport = 3
    case waitingForLive = 4
    case liveEnded = 5
    case transcodeError = 7
    // ... more states
    
    public var description: String
    public var isViewable: Bool // Whether ready for viewing
}
```

## Instance Models

### Instance

Represents a PeerTube server instance.

```swift
public struct Instance: Codable, Hashable, Identifiable {
    public let id: UUID
    public let host: String // Domain name
    public let name: String?
    public let shortDescription: String?
    public let version: String?
    public let signupAllowed: Bool
    public let totalUsers: Int?
    public let totalVideos: Int?
    
    // App-specific properties
    public let isDefault: Bool
    public let addedAt: Date
    public let isReachable: Bool
    
    // Computed Properties
    public var baseURL: URL?
    public var apiBaseURL: URL?
    public var effectiveName: String
}
```

### InstanceConfig

Detailed instance configuration information.

```swift
public struct InstanceConfig: Codable, Hashable {
    public let instance: InstanceInfo
    public let serverVersion: String?
    public let signup: InstanceSignupConfig?
    public let transcoding: InstanceTranscodingConfig?
    public let video: InstanceVideoConfig?
    // ... more configuration sections
}
```

## Model Relationships

### Hierarchical Structure

```
Instance
├── Account (Actor)
│   ├── VideoChannel (Actor)
│   │   └── Video
│   │       ├── VideoFile
│   │       └── VideoStreamingPlaylist
│   └── Direct Videos
└── Configuration
```

### Summary Relationships

Models provide summary variants to avoid circular references and reduce payload size:

- `Account` ↔ `AccountSummary`
- `VideoChannel` ↔ `VideoChannelSummary`
- `Video` ↔ `VideoSummary`
- `Instance` ↔ `InstanceSummary`

## Usage Patterns

### Creating Models from API Response

```swift
// Decode from JSON API response
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601
decoder.keyDecodingStrategy = .convertFromSnakeCase

let video = try decoder.decode(Video.self, from: jsonData)
```

### Converting Between Model Types

```swift
// Convert detailed model to summary
let videoSummary = videoDetails.summary
let accountSummary = account.summary

// Convert to basic Video from VideoDetails
let basicVideo = videoDetails.video
```

### Accessing Computed Properties

```swift
// Duration formatting
print(video.formattedDuration) // "5:23" or "1:23:45"

// Like ratio calculation
print("👍 \(Int(video.likeRatio * 100))%")

// Handle generation
print("Subscribe to \(channel.handle)")
```

### Working with Files and Quality

```swift
// Find best quality
if let bestFile = videoDetails.bestQualityFile {
    print("Best quality: \(bestFile.resolution.label)")
}

// Check available resolutions
let resolutions = videoDetails.files.map { $0.resolution.label }
print("Available: \(resolutions.joined(separator: ", "))")
```

## JSON Serialization

All models support automatic JSON encoding/decoding with proper key conversion:

```swift
// Configure encoder/decoder for PeerTube API
let encoder = JSONEncoder()
encoder.dateEncodingStrategy = .iso8601
encoder.keyEncodingStrategy = .convertToSnakeCase

let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601
decoder.keyDecodingStrategy = .convertFromSnakeCase
```

## Performance Considerations

### Memory Efficiency

- Use summary models for lists and references
- Lazy loading for detailed information
- Weak references in UI components

### Computed Properties

Most computed properties are lightweight string/numeric calculations. For performance-critical code:

```swift
// Cache computed values if needed
let handle = actor.handle
let duration = video.formattedDuration
```

## Testing

Comprehensive test coverage includes:

- **Model initialization** - All properties correctly set
- **JSON encoding/decoding** - Round-trip serialization
- **Computed properties** - Expected calculations
- **Edge cases** - Empty/nil values handled gracefully
- **Performance** - Model creation and property access

## Future Enhancements

Planned improvements include:

- **Live streaming models** - Enhanced live video support
- **Comment models** - Video comment threading
- **Playlist models** - User and channel playlists
- **Statistics models** - Detailed analytics data
- **Plugin models** - Extension and theme support
