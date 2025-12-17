# PeerTube Swift Video Player

This document describes the video player implementation for the PeerTube Swift library, providing AVKit-based video playback with support for HLS streaming and direct file playback.

## Overview

The video player implementation consists of three main components:
- **VideoPlayerController**: Core playback logic and state management
- **VideoPlayerView**: SwiftUI integration with AVPlayerViewController
- **VideoPlayerUtils**: Utilities for format detection and quality management

All components are designed with Swift 6 concurrency safety and follow modern iOS development patterns.

## Architecture

### Component Hierarchy

```
VideoPlayerView (SwiftUI)
├── VideoPlayerController (Observable)
│   ├── AVPlayer (AVKit)
│   └── State Management
├── InlineVideoPlayerView (SwiftUI)
└── FullscreenVideoPlayerView (SwiftUI)
```

### Key Features

- **HLS Streaming Support**: Native support for HTTP Live Streaming
- **Multiple Quality Options**: Automatic quality selection and manual override
- **Picture-in-Picture**: Built-in PiP support for iOS
- **Error Handling**: Comprehensive error states with recovery
- **Concurrency Safe**: Swift 6 `@MainActor` and `Sendable` compliance
- **Accessibility**: Full VoiceOver and accessibility support
- **Custom Controls**: Overlay controls with auto-hide functionality

## VideoPlayerController

### Overview

The `VideoPlayerController` is an `@Observable` class that manages AVPlayer state and provides a Swift-friendly API for video playback.

### Basic Usage

```swift
import PeerTubeSwift
import SwiftUI

@MainActor
struct ContentView: View {
    @State private var playerController: VideoPlayerController
    
    init() {
        // Initialize with VideoDetails from API
        let video = // ... fetch from PeerTube API
        _playerController = State(wrappedValue: VideoPlayerController(video: video))
    }
    
    var body: some View {
        VStack {
            // Player controls
            HStack {
                Button("Play") { playerController.play() }
                Button("Pause") { playerController.pause() }
                Button("Stop") { playerController.stop() }
            }
            
            // Player state
            Text("Playing: \(playerController.isPlaying)")
            Text("Time: \(playerController.currentTime, specifier: "%.1f")s")
            Text("Duration: \(playerController.duration, specifier: "%.1f")s")
        }
    }
}
```

### Initialization Options

```swift
// Initialize with VideoDetails (recommended)
let controller = VideoPlayerController(video: videoDetails)

// Initialize with direct URL
let controller = VideoPlayerController(url: videoURL)
```

### Playback Control

```swift
// Basic playback controls
controller.play()
controller.pause() 
controller.stop()
controller.togglePlayback()

// Seeking
controller.seek(to: 30.0) // Seek to 30 seconds
controller.seekForward()  // +15 seconds
controller.seekBackward() // -15 seconds

// Playback speed
controller.setPlaybackRate(1.5) // 1.5x speed
controller.setPlaybackRate(0.5) // 0.5x speed
```

### Quality Management

```swift
// Get available quality options
let qualityOptions = controller.getQualityOptions()
for option in qualityOptions {
    print("\(option.label) (\(option.resolution)p) - HLS: \(option.isHLS)")
}

// Get best streaming URL
if let bestURL = controller.getBestStreamingURL() {
    print("Best quality URL: \(bestURL)")
}
```

### State Observation

```swift
@StateObject private var controller = VideoPlayerController(video: video)

var body: some View {
    VStack {
        // Observe loading state
        if controller.isLoading {
            ProgressView("Loading...")
        }
        
        // Handle errors
        if let error = controller.error {
            VStack {
                Text("Error: \(error.localizedDescription)")
                Button("Retry") {
                    Task { await controller.retry() }
                }
            }
        }
        
        // Show playback state
        Text("Playing: \(controller.isPlaying ? "Yes" : "No")")
        Text("Current Time: \(controller.currentTime, specifier: "%.1f")")
        Text("Duration: \(controller.duration, specifier: "%.1f")")
        Text("Rate: \(controller.playbackRate)x")
        
        // Controls visibility
        Text("Controls Visible: \(controller.showControls ? "Yes" : "No")")
        Button("Toggle Controls") {
            controller.toggleControlsVisibility()
        }
    }
}
```

## SwiftUI Video Player Views

### VideoPlayerView

Basic UIViewControllerRepresentable wrapper for AVPlayerViewController:

```swift
struct VideoExample: View {
    @State private var isPresented = true
    let video: VideoDetails
    
    var body: some View {
        VideoPlayerView(video: video, isPresented: $isPresented)
            .aspectRatio(16/9, contentMode: .fit)
    }
}
```

### InlineVideoPlayerView

Feature-rich inline player with custom controls:

```swift
struct InlineExample: View {
    let video: VideoDetails
    
    var body: some View {
        ScrollView {
            InlineVideoPlayerView(video: video)
            
            VStack(alignment: .leading) {
                Text(video.name)
                    .font(.title)
                
                Text("\(video.views) views • \(video.createdAt, style: .relative)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}
```

Features:
- Custom overlay controls
- Automatic control hiding
- Fullscreen transition
- Loading and error states
- Video information display
- Thumbnail preview

### FullscreenVideoPlayerView

Dedicated fullscreen player:

```swift
struct FullscreenExample: View {
    @State private var showingPlayer = false
    let video: VideoDetails
    
    var body: some View {
        Button("Play Video") {
            showingPlayer = true
        }
        .fullScreenCover(isPresented: $showingPlayer) {
            FullscreenVideoPlayerView(video: video, isPresented: $showingPlayer)
        }
    }
}
```

Features:
- Fullscreen presentation
- Status bar hiding
- Navigation bar hiding
- Automatic playback start
- Dismissal handling

## VideoPlayerUtils

### Format Detection

```swift
// Check video format support
let hlsURL = URL(string: "https://example.com/video.m3u8")!
let mp4URL = URL(string: "https://example.com/video.mp4")!

VideoPlayerUtils.isHLSURL(hlsURL)        // true
VideoPlayerUtils.isDASHURL(mp4URL)       // false
VideoPlayerUtils.isFormatSupported(hlsURL) // true

// Get preferred URL from multiple options
let urls = [mp4URL, hlsURL]
let preferredURL = VideoPlayerUtils.getPreferredVideoURL(from: urls) // returns hlsURL
```

### Quality Management

```swift
// Extract quality options from VideoDetails
let qualityOptions = VideoPlayerUtils.extractQualityOptions(from: video)

// Get best quality URL
let bestURL = VideoPlayerUtils.getBestQualityURL(from: video)

// Get specific quality
let hdURL = VideoPlayerUtils.getQualityURL(from: video, targetResolution: 720)
```

### URL Building

```swift
let instanceURL = URL(string: "https://peertube.example.com")!
let video: VideoDetails = // ... from API

// Build streaming URLs
let streamingURL = VideoPlayerUtils.buildStreamingURL(
    instanceURL: instanceURL,
    path: "/static/videos/abc123.mp4"
)

// Get thumbnail and preview URLs
let thumbnailURL = VideoPlayerUtils.getThumbnailURL(from: video, instanceURL: instanceURL)
let previewURL = VideoPlayerUtils.getPreviewURL(from: video, instanceURL: instanceURL)
```

### Formatting Utilities

```swift
// Format duration for display
VideoPlayerUtils.formatDuration(90)     // "1:30"
VideoPlayerUtils.formatDuration(3661)   // "1:01:01"

// Format file sizes
VideoPlayerUtils.formatFileSize(1_048_576) // "1 MB"

// Get playback speed options
let speedOptions = VideoPlayerUtils.getPlaybackSpeedOptions()
// Returns: [0.25x, 0.5x, 0.75x, 1.0x, 1.25x, 1.5x, 1.75x, 2.0x]
```

### Device and Network Recommendations

```swift
// Get recommended quality based on device and connection
let recommendedQuality = VideoPlayerUtils.getRecommendedQuality(
    for: .iphone,
    connectionType: .wifi
) // Returns 1080 for iPhone on Wi-Fi

// Get buffer duration recommendations
let bufferDuration = VideoPlayerUtils.getRecommendedBufferDuration(for: .cellular4G)
// Returns 15.0 seconds for 4G
```

## Error Handling

### VideoPlayerError Types

```swift
enum VideoPlayerError: LocalizedError {
    case invalidURL
    case audioSessionError(Error)
    case playbackError(Error)
    case networkError
    case unsupportedFormat
    case unknown
}
```

### Error Handling Example

```swift
struct VideoPlayerWithErrorHandling: View {
    @StateObject private var controller: VideoPlayerController
    
    var body: some View {
        Group {
            if let error = controller.error {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    
                    Text("Playback Error")
                        .font(.headline)
                    
                    Text(error.localizedDescription)
                        .font(.body)
                        .multilineTextAlignment(.center)
                    
                    if let suggestion = error.recoverySuggestion {
                        Text(suggestion)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Retry") {
                        Task { await controller.retry() }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            } else {
                InlineVideoPlayerView(video: video)
            }
        }
    }
}
```

## Integration with PeerTube Services

### Loading and Playing Videos

```swift
struct VideoPlayerIntegration: View {
    @StateObject private var services = PeerTubeServices(
        instanceURLString: "https://peertube.example.com"
    )!
    
    @State private var video: VideoDetails?
    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        Group {
            if let video = video {
                InlineVideoPlayerView(video: video)
            } else if isLoading {
                ProgressView("Loading video...")
            } else if let error = error {
                Text("Error: \(error.localizedDescription)")
            }
        }
        .task {
            await loadVideo()
        }
    }
    
    private func loadVideo() async {
        isLoading = true
        error = nil
        
        do {
            video = try await services.videos.getVideo(id: "your-video-id")
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}
```

### Quality Selection Integration

```swift
struct VideoPlayerWithQualitySelector: View {
    @StateObject private var controller: VideoPlayerController
    @State private var selectedQuality: VideoQualityOption?
    @State private var showingQualitySelector = false
    
    var body: some View {
        VStack {
            // Video player
            InlineVideoPlayerView(video: video)
            
            // Quality selector
            HStack {
                Text("Quality: \(selectedQuality?.label ?? "Auto")")
                
                Button("Change Quality") {
                    showingQualitySelector = true
                }
            }
        }
        .sheet(isPresented: $showingQualitySelector) {
            QualitySelectionView(
                options: controller.getQualityOptions(),
                selectedQuality: $selectedQuality
            )
        }
    }
}

struct QualitySelectionView: View {
    let options: [VideoQualityOption]
    @Binding var selectedQuality: VideoQualityOption?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(options) { option in
                HStack {
                    VStack(alignment: .leading) {
                        Text(option.displayName)
                        if option.isHLS {
                            Text("Adaptive Streaming")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if selectedQuality?.id == option.id {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedQuality = option
                    dismiss()
                }
            }
            .navigationTitle("Video Quality")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
```

## Performance Considerations

### Memory Management

- Controllers automatically clean up AVPlayer resources on deinit
- Use `@StateObject` for controllers to ensure proper lifecycle management
- Pause playback when views disappear to save resources

### Network Optimization

```swift
// Configure buffer duration based on connection type
let bufferDuration = VideoPlayerUtils.getRecommendedBufferDuration(
    for: .cellular4G
)

// Select appropriate quality for device and connection
let recommendedQuality = VideoPlayerUtils.getRecommendedQuality(
    for: DeviceType.current,
    connectionType: .wifi
)
```

### Background Playback

```swift
// Configure audio session for background playback (if needed)
do {
    try AVAudioSession.sharedInstance().setCategory(
        .playback,
        mode: .moviePlayback,
        options: [.allowBluetooth, .allowAirPlay]
    )
    try AVAudioSession.sharedInstance().setActive(true)
} catch {
    print("Failed to configure audio session: \(error)")
}
```

## Accessibility

The video player components include built-in accessibility support:

- VoiceOver announcements for playback state changes
- Accessible custom controls with proper labels
- Dynamic Type support for text elements
- High Contrast mode support

### Custom Accessibility Labels

```swift
InlineVideoPlayerView(video: video)
    .accessibilityLabel("Video player for \(video.name)")
    .accessibilityHint("Double tap to show controls, swipe up for more options")
```

## Testing

### Unit Testing VideoPlayerController

```swift
@MainActor
final class VideoPlayerControllerTests: XCTestCase {
    
    func testInitialization() async {
        let controller = VideoPlayerController(
            url: URL(string: "https://example.com/video.mp4")!
        )
        
        XCTAssertFalse(controller.isPlaying)
        XCTAssertFalse(controller.isLoading)
        XCTAssertNil(controller.error)
        XCTAssertEqual(controller.currentTime, 0)
    }
    
    func testPlaybackControls() async {
        let controller = VideoPlayerController(
            url: URL(string: "https://example.com/video.mp4")!
        )
        
        controller.play()
        XCTAssertTrue(controller.isPlaying)
        
        controller.pause()
        XCTAssertFalse(controller.isPlaying)
        
        controller.setPlaybackRate(2.0)
        XCTAssertEqual(controller.playbackRate, 2.0)
    }
}
```

### SwiftUI Preview Testing

```swift
#if DEBUG
struct VideoPlayer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Test with sample video
            InlineVideoPlayerView(
                url: URL(string: "https://sample-videos.com/zip/10/mp4/mp4-15s.mp4")!
            )
            .previewDisplayName("Inline Player")
            
            // Test error state
            InlineVideoPlayerView(
                url: URL(string: "https://invalid-url.com/video.mp4")!
            )
            .previewDisplayName("Error State")
        }
    }
}
#endif
```

## Migration Guide

### From AVPlayerViewController

**Before:**
```swift
struct OldVideoPlayer: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = AVPlayer(url: url)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Manual updates
    }
}
```

**After:**
```swift
struct NewVideoPlayer: View {
    let video: VideoDetails
    
    var body: some View {
        InlineVideoPlayerView(video: video)
    }
}
```

Benefits:
- Automatic quality selection
- Built-in error handling
- Custom controls and UI
- PeerTube integration
- Concurrency safety
- Better state management

## Common Use Cases

### Video Detail Screen

```swift
struct VideoDetailView: View {
    let video: VideoDetails
    @State private var showingFullscreen = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Video player
                InlineVideoPlayerView(video: video)
                
                // Video information
                VStack(alignment: .leading, spacing: 8) {
                    Text(video.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Text("\(video.views) views")
                        Text("•")
                        Text(video.createdAt, style: .relative)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    if let description = video.description {
                        Text(description)
                            .font(.body)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationBarHidden(true)
    }
}
```

### Video List with Thumbnails

```swift
struct VideoListView: View {
    let videos: [Video]
    
    var body: some View {
        List(videos) { video in
            NavigationLink(destination: VideoDetailView(videoId: video.id)) {
                HStack {
                    AsyncImage(url: thumbnailURL(for: video)) { image in
                        image
                            .resizable()
                            .aspectRatio(16/9, contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(16/9, contentMode: .fill)
                    }
                    .frame(width: 120, height: 68)
                    .clipped()
                    .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(video.name)
                            .font(.headline)
                            .lineLimit(2)
                        
                        Text(video.channel.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("\(video.views) views")
                            Text("•")
                            Text(video.formattedDuration)
                        }
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    private func thumbnailURL(for video: Video) -> URL? {
        // Build thumbnail URL from video and instance
        return nil // Implementation depends on your instance setup
    }
}
```

### Picture-in-Picture Integration

```swift
struct PiPVideoPlayer: View {
    @StateObject private var controller: VideoPlayerController
    @State private var showingFullscreen = false
    
    var body: some View {
        VideoPlayerView(video: video, isPresented: .constant(true))
            .onAppear {
                // Enable PiP
                controller.player?.allowsExternalPlayback = true
            }
    }
}
```

The video player implementation provides a robust, feature-rich foundation for video playback in PeerTube iOS applications while maintaining Swift 6 concurrency safety and modern iOS development practices.
