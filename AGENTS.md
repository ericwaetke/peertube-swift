# AGENTS.md - PeerTube Swift

## Dev Commands (mise)

```bash
mise run lint          # SwiftLint
mise run format        # SwiftFormat
mise run build          # Xcode build (iPhone 17 Simulator)
mise run test           # Run tests
mise run generate-client  # Generate API client from openapi.json
```

## Build & Run

- **Xcode project**: `App/PeerTubeSwift/PeerTubeSwift.xcodeproj`
- **Simulator**: iPhone 17
- **iOS target**: 17.0+
- **Scheme**: "PeerTubeSwift" (Swift package builds cleanly)
- **TubeSDK**: Separate repo at `/Users/ericwatke/Documents/GitHub/peertube-swift-sdk`

Before finishing a feature, **always** format, lint and build to test if everything works.

## Architecture

- **TCA** (Composable Architecture) for state management
- **SwiftUI** + **Combine** (`@Published`, `ObservableObject`)
- Flow: `PeerTubeServices` → `AppState` → ViewModels → SwiftUI Views

## Conventions

- Use `ActorImage.url` NOT `.path` for image URLs
- Import `Combine` when using `@Published`

## References

- `opencode.json` — OpenCode config
- `mise.toml` — all task definitions
- **Pointfree Skills**: Use `skill load pfw-composable-architecture` for TCA patterns; `skill load pfw-sqlite-data` for SQLiteData queries
