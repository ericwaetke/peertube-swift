# PeerTubeSwift Architecture

## Overview

PeerTubeSwift is a native iOS library for interacting with PeerTube instances. It provides a clean, modular architecture that supports local subscriptions, video playback, and PeerTube API integration without requiring user authentication.

## Core Architecture Principles

### 1. Dependency Injection
- **Container-based DI**: All services are managed through `DependencyContainer`
- **Property wrapper support**: `@Injected` for automatic dependency resolution
- **Service Locator pattern**: Global access through `ServiceLocator` when needed
- **Testability**: Easy mocking and testing through protocol-based design

### 2. Local-First Design
- **No authentication required**: Users can subscribe to channels without PeerTube accounts
- **Core Data storage**: All subscriptions and cached data stored locally
- **Instance flexibility**: Support for multiple PeerTube instances simultaneously

### 3. Modular Components
- **Separation of concerns**: Each module has a single responsibility
- **Protocol-based interfaces**: Easy to extend and test
- **Minimal dependencies**: Keep external dependencies to minimum

## Project Structure

```
PeerTubeSwift/
├── Sources/PeerTubeSwift/
│   ├── Core/                    # Core infrastructure
│   │   └── DependencyContainer.swift
│   ├── Models/                  # Data models and DTOs
│   ├── Networking/              # API communication
│   │   └── NetworkingFoundation.swift
│   ├── Storage/                 # Local data persistence
│   │   ├── CoreDataStack.swift
│   │   └── PeerTubeDataModel.swift
│   ├── UI/                      # User interface components (future)
│   └── PeerTubeSwift.swift      # Main library entry point
└── Tests/PeerTubeSwiftTests/
    └── PeerTubeSwiftTests.swift
```

## Core Components

### 1. DependencyContainer

**Purpose**: Manages service registration and resolution throughout the application.

**Key Features**:
- Singleton and factory registration patterns
- Thread-safe service resolution
- Property wrapper support (`@Injected`)
- Testing support with service replacement

**Usage**:
```swift
// Registration
container.registerSingleton(APIClient.self) { APIClient() }

// Resolution
let apiClient = container.resolve(APIClient.self)

// Property wrapper
@Injected(APIClient.self) var apiClient: APIClient
```

### 2. CoreDataStack

**Purpose**: Provides Core Data infrastructure for local storage.

**Key Features**:
- Programmatic model creation (no .xcdatamodeld files)
- Main and background context management
- Automatic context merging
- Async/await support for background operations

**Entities**:
- **Channel**: PeerTube channels/accounts
- **Video**: Video metadata and cached info
- **Subscription**: Local subscription records
- **Instance**: PeerTube instance information

**Usage**:
```swift
// Background operations
try await coreDataStack.performBackgroundTask { context in
    // Perform Core Data operations
    let subscription = Subscription(context: context)
    // ... configure subscription
}
```

### 3. NetworkingFoundation

**Purpose**: Handles HTTP communication with PeerTube instances.

**Key Features**:
- URLSession-based networking
- Automatic JSON encoding/decoding
- Comprehensive error handling
- Request/response logging
- Rate limiting support

**Error Types**:
- Network connectivity issues
- HTTP status code errors
- JSON parsing errors
- Timeout handling

**Usage**:
```swift
// Generic API call
let videos: [Video] = try await networking.request(
    url: apiURL,
    method: .GET
)

// With request body
let result: APIResponse = try await networking.request(
    url: apiURL,
    method: .POST,
    requestBody: requestData
)
```

## Data Flow Architecture

### 1. Subscription Management

```
User Action → UI Layer → Service Layer → Core Data → API Layer
                                     ↓
User sees updated data ← UI Layer ← Background Sync ← PeerTube API
```

1. User subscribes to a channel through UI
2. Subscription service creates local subscription record
3. Background sync service periodically fetches new videos
4. UI automatically updates through Core Data change notifications

### 2. Video Playback

```
User selects video → Video Service → Stream URL Resolution → AVPlayer
                                 ↓
                   Metadata fetch → Core Data cache → UI updates
```

1. User selects video from subscription feed
2. Video service resolves streaming URLs
3. Metadata is cached locally for offline viewing
4. AVPlayer handles actual playback

## Future Architecture Considerations

### 1. SwiftUI Integration
- **ObservableObject** wrappers for Core Data entities
- **@StateObject** and **@ObservedObject** for data binding
- Custom view modifiers for common UI patterns

### 2. Background Sync
- **Background App Refresh** for subscription updates
- **URLSessionBackgroundConfiguration** for downloads
- **Push notifications** for new videos (optional)

### 3. P2P Streaming (Future)
- **WebRTC** integration for peer-to-peer video streaming
- **Fallback mechanism** to HTTP streaming
- **Bandwidth optimization** based on connection quality

### 4. Multi-Instance Support
- **Instance discovery** and validation
- **Cross-instance subscriptions**
- **Federated search** capabilities

## Testing Strategy

### 1. Unit Tests
- **Dependency injection**: Easy mocking of dependencies
- **Core Data**: In-memory store for testing
- **Networking**: Mock URLSession for predictable responses

### 2. Integration Tests
- **API compatibility**: Real PeerTube instance testing
- **Core Data migrations**: Schema evolution testing
- **Background sync**: End-to-end subscription flow

### 3. UI Tests (Future)
- **SwiftUI previews**: Component-level testing
- **XCUITest**: Full user journey testing
- **Snapshot testing**: Visual regression prevention

## Performance Considerations

### 1. Core Data Optimization
- **Batch operations** for large data sets
- **Faulting relationships** to minimize memory usage
- **Background context** for heavy operations
- **Fetch request optimization** with predicates and limits

### 2. Networking Optimization
- **Request batching** where supported by API
- **Response caching** for frequently accessed data
- **Image caching** for thumbnails and avatars
- **Connection pooling** through URLSession configuration

### 3. Memory Management
- **Weak references** in delegate patterns
- **Lazy initialization** for expensive resources
- **Resource cleanup** in background tasks
- **Image resizing** for display optimization

## Configuration and Customization

### 1. Library Configuration
```swift
// Configure Core Data stack
let coreDataStack = CoreDataStack(modelName: "CustomModel")

// Configure networking
let networkConfig = URLSessionConfiguration.default
networkConfig.timeoutIntervalForRequest = 60.0
let networking = NetworkingFoundation(configuration: networkConfig)

// Register custom services
container.registerSingleton(CustomService.self) { CustomService() }
```

### 2. Instance Management
```swift
// Add PeerTube instance
let instance = Instance(host: "peertube.example.com")
try await instanceManager.add(instance)

// Set default instance
try await instanceManager.setDefault(instance)
```

## Security Considerations

### 1. Data Protection
- **Core Data encryption** for sensitive data
- **Keychain integration** for API tokens (future auth)
- **Certificate pinning** for known instances
- **Input validation** for all user-provided data

### 2. Privacy
- **No tracking** or analytics by default
- **Local storage only** for subscription data
- **Optional telemetry** with user consent
- **Data export/import** capabilities

This architecture provides a solid foundation for the PeerTubeSwift library while maintaining flexibility for future enhancements and platform requirements.
