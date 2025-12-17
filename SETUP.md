# PeerTubeSwift Setup Guide

## Project Overview

PeerTubeSwift is a native iOS library and app for interacting with PeerTube instances. This project provides a clean, modular architecture that supports local subscriptions, video playback, and PeerTube API integration without requiring user authentication.

## Project Structure

```
peertube-swift/
├── .beads/                          # Issue tracking database
├── .github/                         # GitHub configuration
├── PeerTubeSwift/                   # Swift Package Library
│   ├── Package.swift               # Swift Package Manager configuration
│   ├── Sources/PeerTubeSwift/      # Library source code
│   │   ├── Core/                   # Dependency injection and core infrastructure
│   │   ├── Models/                 # Data models and DTOs
│   │   ├── Networking/             # API communication layer
│   │   ├── Storage/                # Core Data and local persistence
│   │   └── UI/                     # Reusable UI components (future)
│   ├── Tests/PeerTubeSwiftTests/   # Unit tests
│   └── ARCHITECTURE.md             # Detailed architecture documentation
├── PeerTubeApp/                    # iOS App (future)
├── research/                       # Research notes and references
└── README.md                       # Project overview
```

## Development Environment Setup

### Prerequisites

1. **Xcode 15.0+** - For iOS development and testing
2. **iOS 16.0+** - Minimum deployment target
3. **Swift 5.9+** - Language version
4. **bd (beads)** - Issue tracking tool

### Installing bd (beads)

```bash
# Install bd for issue tracking
pip install beads-cli

# Initialize in project (if not already done)
cd peertube-swift
bd init

# Check ready issues
bd ready --json
```

### Building the Library

```bash
cd peertube-swift/PeerTubeSwift

# Build the library
swift build

# Run tests
swift test

# Generate documentation
swift package generate-documentation
```

### Using Xcode

1. Open `PeerTubeSwift/Package.swift` in Xcode
2. Xcode will automatically resolve dependencies
3. Build and test using Xcode's interface
4. Use Xcode's built-in testing tools

## Core Components

### 1. Swift Package Manager Configuration

The library is configured as a Swift Package with:
- iOS 16.0+ and macOS 13.0+ support
- Zero external dependencies (uses Foundation and Core Data)
- Proper test target configuration

### 2. Dependency Injection

```swift
// Access core services through the container
let container = DependencyContainer.shared
let coreData = container.resolve(CoreDataStack.self)
let networking = container.resolve(NetworkingFoundation.self)

// Or use property wrapper
@Injected(CoreDataStack.self) var coreData: CoreDataStack
```

### 3. Core Data Stack

Programmatically defined Core Data model with entities:
- **Channel**: PeerTube channels and accounts
- **Video**: Video metadata and cached information
- **Subscription**: Local subscription records  
- **Instance**: PeerTube instance information

```swift
// Background operations
try await CoreDataStack.shared.performBackgroundTask { context in
    // Perform Core Data operations safely
}
```

### 4. Networking Foundation

URLSession-based networking with:
- JSON encoding/decoding with Codable
- Comprehensive error handling
- Request/response logging
- Rate limiting support

```swift
let videos: [Video] = try await NetworkingFoundation.shared.request(
    url: apiURL,
    method: .GET
)
```

## Development Workflow

### 1. Check Available Work

```bash
# See what issues are ready to work on
bd ready --json

# Claim an issue
bd update <issue-id> --status in_progress --json
```

### 2. Make Changes

1. Create/modify source files in `PeerTubeSwift/Sources/`
2. Add corresponding tests in `PeerTubeSwift/Tests/`
3. Update documentation as needed
4. Build and test locally

### 3. Commit Changes

```bash
# Commit code changes with bd sync
git add .
git commit -m "feat: implement feature XYZ"

# Close the issue
bd close <issue-id> --reason "Implemented" --json

# Sync bd changes to git
bd sync
```

## Testing Strategy

### Unit Tests

```bash
cd PeerTubeSwift
swift test
```

Tests cover:
- Dependency injection container
- Core Data stack functionality
- Networking foundation
- Model serialization/deserialization
- Error handling

### Integration Tests

Future integration tests will cover:
- Real PeerTube API compatibility
- Core Data migrations
- End-to-end subscription workflows

## Library Usage

### Integration into iOS Projects

1. **Swift Package Manager**:
   ```swift
   dependencies: [
       .package(url: "https://github.com/your-org/peertube-swift", from: "0.1.0")
   ]
   ```

2. **Local Development**:
   - Add as local package in Xcode
   - Or copy source files directly

### Basic Usage

```swift
import PeerTubeSwift

// Setup (typically in AppDelegate or App struct)
let container = PeerTubeSwift.container

// Access services
let coreData = container.resolve(CoreDataStack.self)
let networking = container.resolve(NetworkingFoundation.self)

// Use in your app
class VideoService {
    @Injected(NetworkingFoundation.self) var networking: NetworkingFoundation
    
    func fetchVideos() async throws -> [Video] {
        // Implementation
    }
}
```

## Configuration

### Core Data

The Core Data stack is configured with:
- SQLite persistent store
- Automatic migrations
- Main and background contexts
- Thread-safe operations

### Networking

URLSession is configured with:
- 30 second request timeout
- 60 second resource timeout
- 5 connections per host
- Proper User-Agent headers

## Troubleshooting

### Build Issues

1. **Module not found errors**: Ensure Xcode Command Line Tools are up to date
   ```bash
   xcode-select --install
   ```

2. **Swift version conflicts**: Check Swift version compatibility
   ```bash
   swift --version
   ```

3. **Core Data model issues**: Verify entity relationships in `PeerTubeDataModel.swift`

### Runtime Issues

1. **Dependency resolution failures**: Check service registration in `DependencyContainer`
2. **Core Data errors**: Verify model migration and store setup
3. **Network errors**: Check URL formation and error handling

## Next Steps

1. **Create PeerTube API Models** (`bd-88h`) - Define Swift models for API responses
2. **Build API Client** - Implement networking layer for PeerTube instances  
3. **Implement Local Subscriptions** - Core subscription management system
4. **Add Video Playback** - AVPlayer integration for streaming
5. **Build iOS App UI** - SwiftUI interface for the complete app

## Resources

- [PeerTube API Documentation](https://docs.joinpeertube.org/api-rest-reference.html)
- [Core Data Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/)
- [URLSession Programming Guide](https://developer.apple.com/documentation/foundation/urlsession)
- [Swift Package Manager](https://swift.org/package-manager/)

## Issue Tracking

This project uses **bd (beads)** for all issue tracking. See `AGENTS.md` and `.github/copilot-instructions.md` for detailed workflow instructions.

Key commands:
- `bd ready --json` - Show available work
- `bd create "Title" -t task -p 1 --json` - Create new issues
- `bd update <id> --status in_progress --json` - Claim work
- `bd close <id> --reason "Done" --json` - Complete work
- `bd sync` - Sync changes to git

**Important**: Always use bd for task tracking. Do NOT create markdown TODO lists.
