# PeerTube iOS App Navigation

This document describes the navigation architecture and structure of the PeerTube iOS application built with SwiftUI.

## Overview

The PeerTube iOS app uses a tab-based navigation structure with three main sections:
- **Browse**: Discover and explore videos from the connected PeerTube instance
- **Subscriptions**: Manage channel subscriptions and view latest videos
- **Settings**: Configure app preferences and instance settings

The app follows modern iOS design patterns with NavigationStack for hierarchical navigation and TabView for top-level organization.

## Architecture

### App State Management

The app uses a centralized `AppState` class for global state management:

```swift
@MainActor
final class AppState: ObservableObject {
    // Instance and services
    @Published var currentInstance: InstanceSummary?
    @Published var services: PeerTubeServices?
    @Published var isAuthenticated = false
    
    // Navigation state
    @Published var selectedTab: MainTab = .browse
    @Published var navigationPath = NavigationPath()
    
    // User preferences
    @Published var colorScheme: ColorScheme?
    @Published var autoPlayVideos = true
    @Published var defaultVideoQuality: VideoQuality = .auto
    // ... other settings
}
```

Key responsibilities:
- Instance connection and switching
- PeerTube services management
- Navigation state coordination
- User settings persistence
- Authentication status

### Tab Structure

```
MainTabView
├── Browse Tab (NavigationStack)
│   ├── BrowseView
│   ├── SearchView
│   ├── VideoDetailView
│   └── ChannelDetailView
├── Subscriptions Tab (NavigationStack)
│   ├── SubscriptionsView
│   ├── VideoDetailView
│   └── ChannelDetailView
└── Settings Tab (NavigationStack)
    ├── SettingsView
    ├── InstanceSelectionView
    └── AboutView
```

### Navigation Destinations

The app uses a centralized `NavigationDestination` enum for type-safe navigation:

```swift
enum NavigationDestination: Hashable {
    case videoDetail(videoId: String)
    case channelDetail(channelId: String)
    case instanceSelection
    case about
    case videoPlayer(video: VideoDetails)
}
```

## Core Components

### PeerTubeApp.swift
- Main app entry point
- Configures AppState and environment
- Handles app lifecycle and initial setup

### ContentView.swift
- Root content view with tab navigation
- Handles navigation destination routing
- Manages instance selection flow
- Provides error handling and alerts

### Navigation Methods

```swift
// Navigate to a specific destination
appState.navigateTo(.videoDetail(videoId: "abc123"))

// Navigate back
appState.navigateBack()

// Reset navigation stack
appState.resetNavigation()

// Switch tabs
appState.selectedTab = .subscriptions
```

## Tab Views

### 1. Browse Tab

**Purpose**: Discover and explore content from the connected PeerTube instance

**Features**:
- Search functionality
- Trending videos carousel
- Recent videos section
- Popular channels grid
- Local videos (when available)
- Instance switching
- Pull-to-refresh

**Navigation Paths**:
- Browse → Search
- Browse → Video Detail
- Browse → Channel Detail
- Browse → Instance Selection

**Key Components**:
- `BrowseView`: Main discovery interface
- `BrowseViewModel`: Data loading and state management
- `VideoCardView`: Video thumbnail cards
- `ChannelCardView`: Channel avatar cards
- `SearchView`: Search interface (placeholder)

### 2. Subscriptions Tab

**Purpose**: Manage channel subscriptions and view latest content

**Features**:
- Local subscription management
- Latest videos from subscribed channels
- Channel grid with subscription info
- Notification preferences
- Empty state for new users
- Subscription import/export (planned)

**Navigation Paths**:
- Subscriptions → Channel Detail
- Subscriptions → Video Detail
- Subscriptions → Subscription Management

**Key Components**:
- `SubscriptionsView`: Main subscriptions interface
- `SubscriptionsViewModel`: Subscription data management
- `ChannelSubscription`: Subscription data model
- `SubscriptionVideoCardView`: Video cards with "NEW" indicators
- `SubscriptionChannelCardView`: Channel cards with notification status

**Data Management**:
- Local storage using UserDefaults/CoreData
- Concurrent video loading from multiple channels
- Subscription status tracking
- Notification preferences per channel

### 3. Settings Tab

**Purpose**: Configure app preferences and manage instance connections

**Features**:
- Instance management and switching
- Video playback preferences
- Data and storage management
- Notification settings
- Appearance customization
- About and support information

**Navigation Paths**:
- Settings → Instance Selection
- Settings → About
- Settings → External links (PeerTube website)

**Settings Categories**:

1. **PeerTube Instance**
   - Current instance display
   - Instance switching
   - Connection status

2. **Video Playback**
   - Auto-play toggle
   - Default video quality
   - WiFi-only streaming
   - Playback rate preferences

3. **Data & Storage**
   - Cache management
   - Storage usage display
   - Offline content (planned)

4. **Notifications**
   - Push notification toggle
   - Subscription notifications
   - Channel-specific preferences

5. **Appearance**
   - Color scheme (Auto/Light/Dark)
   - Text size (planned)
   - Interface customization

6. **About & Support**
   - App information
   - PeerTube information
   - Privacy policy
   - Version information

## Instance Management

### Instance Selection Flow

The app requires users to select a PeerTube instance before accessing content:

1. **First Launch**: Shows instance selection screen
2. **Instance Selection**: List of popular instances + custom URL
3. **Connection Test**: Validates instance connectivity
4. **Service Setup**: Configures PeerTubeServices for the instance
5. **Content Loading**: Loads initial content from the instance

### Instance Switching

Users can switch instances at any time:

```swift
// Switch to new instance
await appState.setCurrentInstance(newInstance)

// This automatically:
// 1. Creates new PeerTubeServices
// 2. Clears authentication state
// 3. Reloads content for new instance
// 4. Saves instance preference
```

### Popular Instances

The app includes a curated list of popular PeerTube instances:
- framatube.org (Framatube)
- peertube.cpy.re (Peertube CPY)
- tube.tchncs.de (TCHNCS Tube)
- peertube.social (PeerTube Social)
- video.blender.org (Blender Video)

## Navigation Patterns

### Hierarchical Navigation

Each tab uses NavigationStack for hierarchical navigation:

```swift
NavigationStack(path: $appState.navigationPath) {
    BrowseView()
        .navigationDestination(for: NavigationDestination.self) { destination in
            destinationView(for: destination)
        }
}
```

### Deep Linking Support

The navigation system supports deep linking through the shared navigation path:

```swift
// Navigate directly to a video from any tab
appState.navigationPath.append(NavigationDestination.videoDetail(videoId: "abc123"))
```

### State Preservation

Navigation state is preserved across:
- Tab switches
- App backgrounding/foregrounding
- Instance switching (with reset)

## Error Handling

### Network Errors

- Connection failures during instance setup
- API request failures
- Invalid instance URLs
- Authentication errors

### User Experience

- Non-blocking error alerts
- Retry mechanisms
- Graceful fallbacks
- Loading states and progress indicators

### Error Recovery

```swift
// Automatic retry with exponential backoff
// User-initiated retry actions
// Fallback to cached content when available
// Clear error states on successful operations
```

## Accessibility

### VoiceOver Support

- Proper accessibility labels for all interactive elements
- Semantic structure with navigation landmarks
- Custom accessibility actions for complex controls

### Dynamic Type

- Text scales with user preferences
- Layout adapts to larger text sizes
- Maintains usability across size categories

### Reduced Motion

- Respects reduced motion preferences
- Alternative animations for motion-sensitive users
- Removes unnecessary transitions when requested

## Performance Considerations

### Memory Management

- Lazy loading of tab content
- Image caching and memory pressure handling
- Proper view lifecycle management
- Cleanup of resources on tab switches

### Network Efficiency

- Concurrent loading where appropriate
- Request deduplication
- Caching of instance metadata
- Efficient pagination

### Responsive UI

- Non-blocking network requests
- Progressive content loading
- Skeleton screens during loading
- Smooth animations and transitions

## Development and Testing

### SwiftUI Previews

All views include comprehensive previews:

```swift
#if DEBUG
struct BrowseView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseView()
            .environmentObject(AppState())
    }
}
#endif
```

### Navigation Testing

- Unit tests for navigation state management
- Integration tests for tab switching
- UI tests for complete user flows
- Deep linking validation

## Future Enhancements

### Planned Features

1. **Search Enhancement**
   - Advanced search filters
   - Search history
   - Saved searches
   - Cross-instance search

2. **Offline Support**
   - Download videos for offline viewing
   - Offline subscription management
   - Sync when online

3. **Authentication**
   - User login and account management
   - Personal video uploads
   - Comment and interaction features

4. **Multi-Instance**
   - Follow channels across instances
   - Unified subscription management
   - Cross-instance content discovery

5. **Advanced Features**
   - Playlists and collections
   - Watch history
   - Bookmarks and favorites
   - Sharing and social features

## Integration with PeerTube Services

The navigation layer integrates seamlessly with the PeerTube service layer:

```swift
// Loading content in view models
let videos = try await appState.services?.videos.getTrendingVideos()
let channels = try await appState.services?.channels.getPopularChannels()

// Playing videos with integrated player
appState.navigateTo(.videoPlayer(video: videoDetails))
```

## Best Practices

### State Management
- Use @StateObject for view-owned state
- Use @ObservedObject for passed state
- Minimize state duplication
- Clear state when appropriate

### Navigation
- Use type-safe navigation destinations
- Maintain consistent navigation patterns
- Provide clear back navigation
- Handle navigation edge cases

### Performance
- Lazy load content when possible
- Cache frequently accessed data
- Minimize view updates
- Use efficient data structures

### User Experience
- Provide loading feedback
- Handle errors gracefully
- Maintain context during navigation
- Support accessibility features

This navigation architecture provides a solid foundation for the PeerTube iOS app while remaining flexible for future enhancements and feature additions.
