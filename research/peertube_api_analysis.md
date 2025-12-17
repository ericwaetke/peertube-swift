# PeerTube API Analysis

## Overview
Analysis of PeerTube OpenAPI specification for implementing the iOS client. Focus on endpoints needed for v0.1 features: local subscriptions, video playback, channel browsing, and subscription feed.

## API Base Structure
- **Base URL**: `https://{instance}/api/v1/`
- **Version**: 8.0.0
- **Authentication**: Bearer token (optional for public content)
- **Rate Limits**: 50 requests per 10 seconds
- **Response Format**: JSON

## Key Endpoints for v0.1

### 1. Video Endpoints

#### Get Video Details
```
GET /api/v1/videos/{id}
```
**Purpose**: Get video metadata, streaming URLs, description, etc.
**Response**: Video object with:
- `id`, `uuid`, `name`, `description`
- `streamingPlaylists[]` - HLS/DASH streaming URLs
- `files[]` - Direct download URLs with quality options
- `channel` - Channel information
- `account` - Account information
- `views`, `likes`, `dislikes`
- `duration`, `createdAt`, `updatedAt`

#### List Videos
```
GET /api/v1/videos?start=0&count=15&sort=-publishedAt
```
**Purpose**: Browse/search videos
**Parameters**:
- `start`: Pagination offset
- `count`: Results per page (max 100)
- `sort`: Sort order (`-publishedAt`, `-views`, `-likes`, etc.)
- `categoryOneOf`: Filter by categories
- `languageOneOf`: Filter by languages
- `search`: Search query

#### Get Video Description
```
GET /api/v1/videos/{id}/description
```
**Purpose**: Get full video description (may be truncated in main video object)

#### Increment Video Views
```
POST /api/v1/videos/{id}/views
```
**Purpose**: Track video view (optional, for analytics)

### 2. Channel Endpoints

#### Get Channel Details
```
GET /api/v1/video-channels/{channelHandle}
```
**Purpose**: Get channel information
**Response**: Channel object with:
- `id`, `name`, `displayName`, `description`
- `avatar`, `banner`
- `followersCount`, `followingCount`
- `host`, `hostRedundancyAllowed`

#### Get Channel Videos
```
GET /api/v1/video-channels/{channelHandle}/videos?start=0&count=15&sort=-publishedAt
```
**Purpose**: List videos from a specific channel
**Same parameters as video list endpoint**

#### Search Channels
```
GET /api/v1/search/video-channels?search={query}
```
**Purpose**: Find channels to subscribe to

### 3. Account Endpoints

#### Get Account Details
```
GET /api/v1/accounts/{accountHandle}
```
**Purpose**: Get account information (accounts can have multiple channels)

#### Get Account Videos
```
GET /api/v1/accounts/{accountHandle}/videos
```
**Purpose**: List all videos from an account (across all channels)

### 4. Search Endpoints

#### Global Search
```
GET /api/v1/search/videos?search={query}&start=0&count=15
```
**Purpose**: Search videos across the instance and federation

### 5. Instance Information

#### Get Instance Config
```
GET /api/v1/config
```
**Purpose**: Get instance configuration, features, limits
**Response includes**:
- Instance name, description
- Video upload limits
- Transcoding settings
- Plugin information

#### Get Instance About
```
GET /api/v1/config/about
```
**Purpose**: Get instance about page information

## Data Models (Key Objects)

### Video Object
```json
{
  "id": 1,
  "uuid": "9c9de5e8-0a1e-484a-b099-e80766180a90",
  "name": "Video Title",
  "description": "Video description...",
  "duration": 240,
  "views": 1337,
  "likes": 42,
  "dislikes": 3,
  "streamingPlaylists": [
    {
      "id": 1,
      "type": 1,
      "playlistUrl": "https://instance.com/static/streaming-playlists/hls/.../master.m3u8"
    }
  ],
  "files": [
    {
      "resolution": {"id": 720, "label": "720p"},
      "size": 1024000,
      "fileUrl": "https://instance.com/static/videos/...",
      "fileDownloadUrl": "https://instance.com/download/videos/..."
    }
  ],
  "channel": {
    "id": 1,
    "name": "channel_name",
    "displayName": "Channel Display Name",
    "avatar": {"path": "/static/avatars/..."}
  },
  "account": {
    "id": 1,
    "name": "account_name",
    "displayName": "Account Display Name"
  }
}
```

### Channel Object
```json
{
  "id": 1,
  "name": "channel_name",
  "displayName": "Channel Display Name", 
  "description": "Channel description",
  "avatar": {"path": "/static/avatars/..."},
  "banner": {"path": "/static/banners/..."},
  "followersCount": 123,
  "videosCount": 45,
  "host": "instance.com",
  "hostRedundancyAllowed": true
}
```

## Implementation Strategy

### 1. Local Subscriptions Architecture
Since we're implementing local-only subscriptions (no user accounts):

```swift
// Local storage model
struct LocalSubscription {
    let channelId: String
    let channelHandle: String  // @channel@instance.com
    let displayName: String
    let avatarURL: String?
    let subscriptionDate: Date
}

// Fetch subscribed channels' latest videos
// GET /api/v1/video-channels/{channelHandle}/videos for each subscription
// Merge and sort by publishedAt
```

### 2. Video Streaming Implementation
```swift
// Primary: Use HLS streaming playlists
let streamingURL = video.streamingPlaylists.first?.playlistUrl

// Fallback: Direct file URLs
let directURL = video.files.first?.fileUrl
```

### 3. Instance Management
- Store instance URL in user defaults
- Allow users to switch instances
- Handle cross-instance channel subscriptions

### 4. Error Handling
- Network connectivity issues
- Instance unavailable (federation)
- Video geo-blocked or private
- Rate limiting (429 responses)

### 5. Caching Strategy
- Cache video metadata for offline browsing
- Cache channel information for subscriptions
- Cache thumbnails and avatars
- Implement cache expiration and cleanup

## Rate Limiting Considerations
- 50 requests per 10 seconds per IP
- Batch requests where possible
- Implement request queuing/throttling
- Cache aggressively to reduce API calls

## Cross-Instance Federation
PeerTube instances can federate content:
- Videos may reference other instances
- Channels can exist on different instances
- Handle `@channel@instance.com` format
- May need multiple API clients for different instances

## Privacy and Analytics
- View tracking is optional (POST /api/v1/videos/{id}/views)
- No personal data collection needed for local subscriptions
- Respect instance privacy policies

## Next Steps for Implementation
1. Create Swift API client with proper models
2. Implement basic video fetching and parsing
3. Add HLS streaming support with AVKit
4. Implement local subscription storage (Core Data)
5. Create subscription feed aggregation logic
6. Add search and discovery features
