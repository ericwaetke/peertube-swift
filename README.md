# PeerTube Swift

A native iOS client for [PeerTube](https://joinpeertube.org/) — the decentralized, federated video platform.

PeerTube Swift brings a clean, native iOS experience to the PeerTube ecosystem, supporting multiple instances, local subscriptions, and background notifications for new videos.

## Features

- **Connect to PeerTube Instances**
- **Local Subscriptions** — Subscribe to channels without creating an account; data stays on your device
- **Video Playback** — Native AVKit player with quality selection and Picture-in-Picture
- **Background Notifications (wip)** — Get notified when subscribed channels post new videos
- **Offline-First** — Local caching of subscriptions and metadata
- **Privacy-Focused** — No mandatory login; PostHog analytics are optional (wip)

## Tech Stack

- **SwiftUI** — Modern declarative UI framework
- **The Composable Architecture (TCA)** — Unidirectional data flow and testable state management
- **TubeSDK** — PeerTube API client library
- **SQLite.swift** — Local database for subscriptions and caching
- **PostHog** — Optional analytics integration

## Project Structure

```
App/PeerTubeSwift/PeerTubeSwift/
├── App.swift              # App entry point and configuration
├── PeerTubeSwiftApp.swift  # Main app with PostHog & background tasks
├── Views/
│   ├── Feed.swift          # Main feed view
│   ├── VideoDetails.swift  # Video detail page
│   ├── VideoChannel.swift  # Channel page
│   ├── Subscriptions.swift # Subscription management
│   └── ...
├── Components/
│   ├── VideoPlayer.swift   # Custom video player
│   ├── VideoCard.swift     # Video list item component
│   └── ...
├── Models/
│   └── Schema.swift        # Database schema definitions
└── ...
```

## Getting Started

### Prerequisites

- Xcode 15+
- iOS 17.0+
- [TubeSDK](https://codeberg.org/ericwaetke/peertube-swift-sdk) dependency

### Setup

1. Clone the repository
2. Open in Xcode:
   ```bash
   open App/PeerTubeSwift/PeerTubeSwift.xcodeproj
   ```
3. Configure your PostHog credentials in the Xcode scheme environment variables (optional):
   - `POSTHOG_PROJECT_TOKEN`
   - `POSTHOG_HOST`
4. Build and run on a simulator or device

## References & Inspiration

- [Swiftfin](https://github.com/jellyfin/Swiftfin/) — Jellyfin iOS client
- [NewPipe](https://github.com/TeamNewPipe/NewPipe) — Android YouTube client
- [Grayjay](https://gitlab.futo.org/videostreaming/grayjay) — Plugin-based video player
- [PeerTube Plugin](https://gitlab.futo.org/videostreaming/plugins/peertube) — Grayjay PeerTube plugin

## Contributing

Contributions welcome! Please read the existing codebase structure and follow the TCA patterns used throughout.

## License

See [LICENSE.md](LICENSE.md)
