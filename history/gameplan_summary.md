# PeerTube iOS Client - Development Gameplan

## Project Overview

This document outlines the comprehensive development plan for a native iOS PeerTube client built with SwiftUI. The app will provide a streamlined, privacy-focused experience for watching PeerTube content with local-only subscriptions (no user login required).

## Project Goals

### Primary Objective
Create a fully functional iOS PeerTube client that allows users to:
- Browse and watch PeerTube videos
- Subscribe to channels locally (device-only storage)
- View subscription feeds chronologically
- Enjoy high-quality video playback with native iOS features

### Key Principles
- **Privacy First**: Local subscriptions, no user tracking
- **Native iOS Experience**: SwiftUI, AVKit, Picture-in-Picture
- **Federation Support**: Work with any PeerTube instance
- **Performance**: Efficient API usage, caching, offline support

## Version 0.1 Features

### Core Features
- [x] **Local Subscriptions**: Subscribe to channels without user accounts
- [x] **Video Playback**: HTTP streaming with native iOS player
- [x] **Video Page**: Title, description, player with native controls
- [x] **Channel Page**: Channel videos and information
- [x] **Subscription Feed**: Chronological view of subscribed content

### Technical Features
- [x] **Quality Selection**: Manual and automatic video quality
- [x] **Picture-in-Picture**: Background video playback
- [x] **Cross-Instance Support**: Subscribe to channels on different instances
- [x] **Caching**: Offline content browsing

### Optional v0.1 Features
- [ ] **P2P Streaming**: WebTorrent integration (complexity assessment needed)
- [ ] **Comments**: Video comment display and interaction
- [ ] **Search**: Global video and channel search

## Development Epics

### 1. Project Setup and Architecture (Priority: High)
**Epic ID**: `peertube-swift-iu2`

Foundation for the entire project including Xcode setup, dependencies, and core architecture patterns.

**Key Tasks**:
- Create Xcode iOS project with SwiftUI
- Setup Core Dependencies (Core Data, URLSession, Package Manager)
- Implement basic app navigation structure

### 2. PeerTube API Integration (Priority: High)
**Epic ID**: `peertube-swift-lyu`

Build the networking layer and API client for communicating with PeerTube instances.

**Key Tasks**:
- Create PeerTube API Swift models (Video, Channel, Account, etc.)
- Build PeerTube API client with rate limiting and error handling
- Implement core API service layer (videos, channels, search)

### 3. Video Playback and Streaming (Priority: High)
**Epic ID**: `peertube-swift-id3`

Implement the core video viewing experience using AVKit and native iOS capabilities.

**Key Tasks**:
- Implement basic AVKit video player
- Add video quality selection functionality
- Enable Picture-in-Picture support

### 4. Local Subscriptions System (Priority: High)
**Epic ID**: `peertube-swift-uaz`

Create the subscription management system that works without user authentication.

**Key Tasks**:
- Design local subscription data model (Core Data)
- Implement subscription management (subscribe/unsubscribe)
- Build subscription feed aggregation logic

### 5. User Interface and Navigation (Priority: Medium)
**Epic ID**: `peertube-swift-t73`

Build the user-facing screens and navigation flows.

**Key Tasks**:
- Create video detail page UI
- Build channel page UI
- Design subscription feed UI

## Technical Architecture

### Video Player Strategy
**Recommendation**: Use AVKit (Native Player) for v0.1

**Reasoning**:
- PeerTube primarily serves MP4/H.264 content (compatible)
- Picture-in-Picture support crucial for mobile
- Energy efficient (hardware decoding)
- Simpler implementation and maintenance

**Future Enhancement**: Add VLCKit option for advanced codec support

### API Integration
**Base URL Pattern**: `https://{instance}/api/v1/`
**Rate Limits**: 50 requests per 10 seconds
**Key Endpoints**:
- `GET /videos/{id}` - Video details and streaming URLs
- `GET /video-channels/{handle}/videos` - Channel videos
- `GET /search/videos` - Video search

### Local Subscriptions Architecture
```
LocalSubscription {
  channelId: String
  channelHandle: String  // @channel@instance.com
  displayName: String
  avatarURL: String?
  subscriptionDate: Date
}
```

### Data Flow
1. **Subscription Management**: User subscribes to channels → Store locally in Core Data
2. **Feed Aggregation**: Fetch latest videos from subscribed channels → Merge and sort chronologically
3. **Video Playback**: Select video → Fetch streaming URLs → Play with AVKit

## Development Phases

### Phase 1: Foundation (Weeks 1-2)
- [x] Project setup and architecture
- [x] Basic navigation structure
- [x] PeerTube API models and client
- [x] Simple video playback

### Phase 2: Core Features (Weeks 3-4)
- [x] Local subscription system
- [x] Subscription feed aggregation
- [x] Video and channel detail pages
- [x] Quality selection and PiP

### Phase 3: Polish and Testing (Weeks 5-6)
- [x] Comprehensive testing
- [x] Settings and configuration
- [x] Performance optimization
- [x] Bug fixes and refinements

## Research and Investigation Tasks

### High Priority Research
1. **P2P Streaming Analysis** (`peertube-swift-2l4`)
   - WebTorrent Swift integration options
   - Battery and bandwidth implications
   - Implementation complexity vs benefit

2. **Comment System Analysis** (`peertube-swift-7hr`)
   - PeerTube comments API structure
   - Mobile UI/UX considerations
   - Threading and moderation features

### Future Planning Research
3. **Authentication Integration** (`peertube-swift-hm5`)
   - OAuth flow implementation
   - Migration path from local to authenticated
   - Privacy implications and user choice

## Ready-to-Start Tasks

Based on current dependencies, these tasks are immediately actionable:

1. **Create Xcode iOS Project** (`peertube-swift-5x1`) - Priority 1
2. **Setup Core Dependencies and Architecture** (`peertube-swift-a1h`) - Priority 1
3. **Create PeerTube API Swift Models** (`peertube-swift-88h`) - Priority 1
4. **Design Local Subscription Data Model** (`peertube-swift-32w`) - Priority 1

## Success Metrics

### v0.1 Success Criteria
- [ ] App successfully builds and runs on iOS 16.0+
- [ ] Can browse and play videos from any PeerTube instance
- [ ] Local subscriptions work without user accounts
- [ ] Subscription feed aggregates content chronologically
- [ ] Video quality selection and PiP function correctly
- [ ] App passes Apple's App Store review guidelines

### Performance Targets
- [ ] App launch time < 3 seconds
- [ ] Video playback starts within 5 seconds
- [ ] Subscription feed loads within 10 seconds
- [ ] Smooth 60fps scrolling in video lists
- [ ] Efficient memory usage (< 100MB typical)

## Risk Mitigation

### Technical Risks
- **PeerTube Instance Variability**: Different instances may have different configurations
  - *Mitigation*: Extensive testing with multiple instances, graceful fallbacks
  
- **Video Format Compatibility**: Some instances may serve unsupported formats
  - *Mitigation*: AVKit handles most cases, clear error messages for unsupported content
  
- **Rate Limiting**: API rate limits may impact user experience
  - *Mitigation*: Implement request queuing, caching, and user feedback

### Development Risks
- **Scope Creep**: Adding too many features before v0.1 completion
  - *Mitigation*: Strict adherence to v0.1 feature list, defer enhancements
  
- **Platform Changes**: iOS updates breaking functionality
  - *Mitigation*: Stay current with iOS betas, maintain backward compatibility

## Next Steps

1. **Immediate Action**: Start with "Create Xcode iOS Project" task
2. **First Sprint**: Complete all Phase 1 foundation tasks
3. **Weekly Reviews**: Assess progress against gameplan, adjust priorities
4. **Continuous Integration**: Setup automated testing early
5. **User Feedback**: Plan for beta testing before App Store submission

## Reference Materials

- **FloatNative**: Similar federated video client architecture
- **Swiftfin**: Video player implementation patterns and codec support
- **PeerTube API**: Official API documentation and OpenAPI spec
- **Apple AVKit**: Native video playback documentation

This gameplan provides a structured approach to building a high-quality PeerTube iOS client while maintaining focus on the core v0.1 features and ensuring a solid foundation for future enhancements.
