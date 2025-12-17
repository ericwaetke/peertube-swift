# Video Player Research for PeerTube iOS Client

## Overview
Research findings for implementing video playback in the PeerTube Swift iOS client, based on Jellyfin Swiftfin player documentation and FloatNative implementation.

## Player Options

### 1. Native AVKit Player
**Pros:**
- Native iOS integration
- Picture-in-Picture support
- Framerate matching
- Energy efficient (hardware decoding)
- AirPlay support
- External display support
- TLS 1.3 support

**Cons:**
- Limited container support (no MKV, WebM, FLV)
- No subtitle/audio track selection
- Limited codec support (no VP9, Opus, DTS, etc.)
- Requires compatible formats or server-side transcoding

**Best for:** Standard MP4/H.264 content with minimal format variety

### 2. VLCKit Player
**Pros:**
- Extensive format support (MKV, WebM, VP9, Opus, DTS, etc.)
- Full subtitle support (ASS, SRT, SSA)
- Audio track selection
- Chapter support
- Customizable UI controls
- Speed adjustment

**Cons:**
- No Picture-in-Picture
- No framerate matching
- Higher energy consumption (software decoding)
- TLS 1.3 not supported
- AirPlay audio delay issues

**Best for:** Diverse format support and advanced playback features

## Recommendation for PeerTube
**Use Native AVKit for initial implementation** because:
1. PeerTube primarily serves MP4/H.264 content
2. PiP support is crucial for mobile experience
3. Energy efficiency matters for mobile devices
4. Simpler implementation and maintenance

**Future enhancement:** Add VLCKit as optional player for advanced users

## Key Implementation Areas

### 1. Video Streaming Protocol
- HTTP Live Streaming (HLS) support
- Adaptive bitrate streaming
- Quality selection mechanism
- Network condition handling

### 2. Authentication Integration
- Token-based authentication for private videos
- Custom URL schemes for authenticated requests
- Resource loader delegation for secure streaming

### 3. Player Controls
- Native iOS player controls
- Custom overlay for PeerTube-specific features
- Gesture support (seek, volume, brightness)
- Orientation handling

### 4. Format Support Priority
1. **Primary:** MP4 + H.264/H.265 + AAC
2. **Secondary:** WebM + VP9 + Opus (requires VLCKit)
3. **Fallback:** Server-side transcoding for unsupported formats

## Technical Implementation Notes

### Authentication Strategy (from FloatNative)
```swift
// Custom scheme approach for authenticated video requests
// 1. Intercept manifest requests via AVAssetResourceLoaderDelegate
// 2. Sign authentication headers for key requests
// 3. Allow segments to load directly (if public)
```

### Quality Selection
- Implement manual quality selection UI
- Auto-quality based on network conditions
- User preference persistence

### Picture-in-Picture
```swift
// Enable PiP support
player.allowsPictureInPicturePlayback = true
```

## PeerTube Specific Considerations

### 1. P2P Streaming (Optional v0.1 Feature)
- WebTorrent integration possible but complex
- May require hybrid approach (HTTP fallback)
- Battery and bandwidth implications

### 2. Instance Configuration
- Different instances may have different streaming configurations
- Quality levels vary by instance
- Need fallback mechanisms

### 3. Privacy Considerations
- Local-only subscriptions (no server-side state)
- Anonymous viewing support
- Optional analytics/view tracking

## Next Steps
1. Implement basic AVKit video player
2. Add authentication layer for private videos
3. Implement quality selection
4. Add PiP support
5. Test with various PeerTube instances
6. Consider VLCKit integration for advanced features
