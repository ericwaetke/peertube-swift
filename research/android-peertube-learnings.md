# Android PeerTube Learnings

This document summarizes patterns, strategies, and architectural lessons from established Android clients and related apps that interact with PeerTube or similar federated video ecosystems. It distills actionable recommendations for our iOS app and SDK.

References explored conceptually:
- FloatNative (coulterpeterson)
- Grayjay (FUTO) and PeerTube plugin
- NewPipe
- Fedilab
- P2Play
- Swiftfin (Jellyfin) players.md (iOS, but relevant player architecture patterns)
- AVKit (Apple) docs for iOS player alignment

Note: This document now includes initial code-backed findings and citations from upstream repositories; further deep dives will add more file-level references and class-level analysis.

## Code Findings and Citations

- NewPipe (TeamNewPipe/NewPipe)
  - Multi-service architecture and PeerTube support confirmed in repository README with explicit mention of supported services and privacy-preserving approach.
    - Source: https://raw.githubusercontent.com/TeamNewPipe/NewPipe/dev/README.md
  - Local subscriptions and notifications capability indicate an internal database and sync logic that we should mirror for instance-keyed subscriptions on iOS.
    - Source: https://raw.githubusercontent.com/TeamNewPipe/NewPipe/dev/README.md (features list)
  - Player UX includes PiP, background audio, captions, and manual quality selection across heterogeneous sources; implies a normalized extractor-to-player interface for streams and tracks.
    - Source: https://raw.githubusercontent.com/TeamNewPipe/NewPipe/dev/README.md (features list)
  - Extractor library confirms PeerTube support and shows how sites are integrated via structured extractors and link handlers.
    - Source: https://raw.githubusercontent.com/TeamNewPipe/NewPipeExtractor/dev/README.md
  - PeerTube stream extraction: progressive (MP4/WebM), HLS, subtitles, chapters/storyboards, live detection, and related items via tags/uploader endpoints.
    - Source: https://raw.githubusercontent.com/TeamNewPipe/NewPipeExtractor/dev/extractor/src/main/java/org/schabi/newpipe/extractor/services/peertube/extractors/PeertubeStreamExtractor.java
  - PeerTube search extractor: builds initial page with start/count and collects items; uses total to compute next page via helper.
    - Source: https://raw.githubusercontent.com/TeamNewPipe/NewPipeExtractor/dev/extractor/src/main/java/org/schabi/newpipe/extractor/services/peertube/extractors/PeertubeSearchExtractor.java
  - PeerTube search query handling: endpoints for videos, channels, playlists; optional global SepiaSearch base URL.
    - Source: https://raw.githubusercontent.com/TeamNewPipe/NewPipeExtractor/dev/extractor/src/main/java/org/schabi/newpipe/extractor/services/peertube/linkHandler/PeertubeSearchQueryHandlerFactory.java
  - PeerTube stream link handling: supports /w/ and /videos/watch/ URL patterns; API endpoint /api/v1/videos/{id}.
    - Source: https://raw.githubusercontent.com/TeamNewPipe/NewPipeExtractor/dev/extractor/src/main/java/org/schabi/newpipe/extractor/services/peertube/linkHandler/PeertubeStreamLinkHandlerFactory.java
  - Info item extractors for streams, channels, playlists: normalize fields like thumbnails, names, URLs, counts, and live/vod.
    - Sources:
      - Stream: https://raw.githubusercontent.com/TeamNewPipe/NewPipeExtractor/dev/extractor/src/main/java/org/schabi/newpipe/extractor/services/peertube/extractors/PeertubeStreamInfoItemExtractor.java
      - Channel: https://raw.githubusercontent.com/TeamNewPipe/NewPipeExtractor/dev/extractor/src/main/java/org/schabi/newpipe/extractor/services/peertube/extractors/PeertubeChannelInfoItemExtractor.java
      - Playlist: https://raw.githubusercontent.com/TeamNewPipe/NewPipeExtractor/dev/extractor/src/main/java/org/schabi/newpipe/extractor/services/peertube/extractors/PeertubePlaylistInfoItemExtractor.java
  - Helper patterns: pagination via start/count (ITEMS_PER_PAGE=12), JSON validation of “error”, image URL construction with baseUrl + path, type detection via keys (videosLength, followersCount).
    - Source: https://raw.githubusercontent.com/TeamNewPipe/NewPipeExtractor/dev/extractor/src/main/java/org/schabi/newpipe/extractor/services/peertube/PeertubeParsingHelper.java

- P2Play (Android PeerTube client)
  - Dedicated PeerTube client validating canonical flows (channels, comments, playlists, trending/recent lists). We should align our SwiftUI navigation to these flows and extract pagination patterns.
    - Source: https://gitlab.com/agosto182/p2play/-/raw/master/README.md
  - App structure: Jetpack Compose UI, Room database, shared preferences, Media3/ExoPlayer integration with mini-player and dedicated playback activity; routes include Videos, Subscriptions, Search, You, VideoList, Notifications, ChooseInstance.
    - Source: https://gitlab.com/agosto182/p2play/-/raw/master/app/src/main/java/org/libre/agosto/p2play/activities/MainActivity.kt
  - Next code targets to cite: network/API client for login/register, subscriptions, comments/replies, downloads, notifications; player quality selection components.

- Grayjay (FUTO) and PeerTube Plugin
  - Plugin-based provider abstraction suggests a capabilities schema for formats, qualities, metadata, and search that we can adapt as provider adapters in our SDK.
    - Source: https://gitlab.futo.org/videostreaming/grayjay (project overview; specific plugin README may require different access paths)

---

## Executive Summary

- Favor a clear separation of concerns:
  - Instance and federation management
  - Content fetching and normalization
  - Player orchestration (quality selection, fallback, subtitles)
  - Offline and subscriptions data model
- Normalize PeerTube’s heterogeneous APIs to a stable, app-friendly model layer. Use adapters per instance to handle deviations and version differences.
- Treat playback sources as capabilities: HLS, MP4, WebM, DASH, and captions/subtitles as first-class entities with robust fallback.
- Implement a unified “quality ladder” selection strategy with user preference, auto, and manual override—mirroring Android clients that offer consistent controls regardless of source format.
- Build a resilient pagination and caching layer. Many Android clients emphasize incremental loading with local caches to hide network variability.
- Adopt explicit federation boundaries: a root “Instance” context with lightweight switching and per-instance storage for auth and preferences, while surfacing cross-instance collections via an aggregated view.

---

## Cross-App Architectural Patterns

### 1) Data Layer and API Normalization
- Pattern:
  - Define stable domain models (Video, Channel, Account, Instance, Playlist, Comment).
  - Introduce service interfaces that return domain models, not raw API DTOs.
  - Use per-instance adapters to map divergent PeerTube versions or plugins to domain models.
- Rationale:
  - Android clients often grapple with multiple backends and variants; normalization reduces UI and player complexity.
- iOS Actionables:
  - Maintain a `PeerTubeServices` facade that exposes domain-level operations and shields the app from API drift.
  - Add “capabilities” metadata to models (available formats, captions, chapters, live flags).
  - Version-aware request builders that negotiate supported endpoints for each instance.

### 2) Federation and Instance Management
- Pattern:
  - Instance registry with per-instance settings (auth tokens, content preferences, moderation toggles).
  - Soft multi-instance support: switch active instance quickly; maintain local storage keyed by instance.
- Rationale:
  - Apps like Fedilab and Grayjay handle federation via pluggable sources and instance-oriented state.
- iOS Actionables:
  - Model `Instance` as a source context: base URL, API version, auth, features.
  - Per-instance keychain entries for tokens; per-instance caches for recommendations/history.
  - Instance switcher in settings plus a cross-instance aggregated view for subscriptions.

### 3) Networking Strategies
- Pattern:
  - Aggressive pagination and partial hydration (fetch lists first, enrich with details lazily).
  - Resilient retry and format fallbacks when endpoints or media URLs are missing.
  - Unified HTTP client with request interceptors for auth and logging.
- Rationale:
  - Android clients use robust pagination to hide network latency and avoid heavyweight payloads.
- iOS Actionables:
  - Implement incremental pagination across lists with Combine/async sequences.
  - Request interceptors for auth headers and instance-specific base URLs.
  - Backoff and retry policies; structured errors with recovery hints in UI.

### 4) Player Orchestration and Quality Selection
- Pattern:
  - Abstract player controller that supports multiple source types: HLS, DASH, MP4/WebM.
  - Central quality selection logic with “Auto”, user preferences, and manual override.
  - Subtitle and audio track management; persistence of last chosen quality per video or globally.
- Rationale:
  - NewPipe and Grayjay emphasize user control of quality and fallback to ensure playback continuity.
- iOS Actionables:
  - With AVKit/AVPlayer, implement a player coordinator that:
    - Detects available renditions and captions from model capabilities.
    - Applies user’s default quality and supports manual quality changes.
    - Provides graceful fallback (e.g., switch from MP4 to HLS if MP4 fails).
  - Persist user preferences for quality, captions, and audio via app settings.

### 5) Offline and Subscriptions
- Pattern:
  - Distinguish “subscriptions” (channels/accounts followed) from “downloads” (offline media).
  - Local database tracks:
    - Subscribed channels and last sync timestamp
    - New uploads since last sync
    - Downloaded videos with storage policies and revalidation
- Rationale:
  - Android clients commonly separate follow-state and offline assets for clarity and robustness.
- iOS Actionables:
  - Storage model for subscriptions keyed by instance and channel.
  - Background sync tasks to fetch new videos for subscribed channels.
  - Offline download manager with space quota and revalidation strategy.

### 6) UI/UX Patterns
- Pattern:
  - Unified video detail page: title, description, channel, publish date, stats, actions (like/share/download), comments, recommendations.
  - Lists with stable skeleton loading; clear state for empty/error.
  - Filters and sorting on feeds (date, popularity, duration).
- Rationale:
  - Consistent patterns across apps facilitate user familiarity and reduce complexity.
- iOS Actionables:
  - SwiftUI views for:
    - Feed: infinite scroll with clear loading placeholders.
    - Video detail: modular sections (metadata, actions, comments, related).
    - Channel: header, uploads, playlists, info.
  - Use `@Published` properties and async loading with cancellation on navigation.

---

## App-Specific Notes by Reference

### FloatNative (coulterpeterson)
- Likely patterns:
  - Clear separation of playback controller and data source.
  - Emphasis on a streamlined user experience and minimal friction.
- Actionables:
  - Keep player UI clean; expose quality and captions in a simple drawer.
  - Centralize media source resolution to avoid UI coupling to network layer.

### Grayjay (FUTO) + PeerTube Plugin
- Patterns:
  - Plugin-based architecture to support multiple providers including PeerTube.
  - Unified capabilities description for each provider (formats, metadata, search).
  - Robust quality selection and provider fallback.
- Actionables:
  - Consider “provider adapter” abstractions for future extensibility, even if MVP focuses on PeerTube.
  - Encode provider capabilities into our domain models to streamline player decisions.

### NewPipe
- Patterns:
  - Strong emphasis on local parsing and privacy—minimal server reliance.
  - Quality selection UI and consistent playback behavior across sources.
  - Efficient list loading and caching, with clear state handling.
- Actionables:
  - Invest in a frictionless quality UI with sensible defaults.
  - Structured pagination, caching, and error/retry model for lists.
  - Keep privacy-conscious defaults; avoid unnecessary third-party calls.

### Fedilab
- Patterns:
  - Federation-first: multiple instances, identity management, subscriptions tracking.
  - Per-instance feature toggles and moderation controls.
- Actionables:
  - Design instance settings page with per-instance auth and preferences.
  - Build subscription sync routines and per-instance caches.

### P2Play
- Patterns:
  - PeerTube-specific flows: channel pages, comments, playlists, and video listing.
  - Clear navigation structure tied to PeerTube’s information hierarchy.
- Actionables:
  - Align iOS flows to PeerTube: instance → feed → video → channel → related/comments.
  - Implement comments with pagination and posting, respecting instance auth.

### Swiftfin players.md (iOS) and AVKit Docs
- Patterns:
  - AVPlayer-based playback with track selection, HLS-centric flows.
  - Background audio, picture-in-picture, and remote command center integration.
- Actionables:
  - Implement PiP, background playback, and remote controls early to match native expectations.
  - Use `AVMediaSelectionGroup` for captions/audio track selection when available.
  - Integrate with `MPNowPlayingInfoCenter` for lock screen metadata.

---

## Proposed iOS Architecture Alignment

- Models:
  - `Video` includes: sources (HLS URLs, MP4/WebM variants), captions, chapters, live flags, duration, stats, channel reference.
  - `Channel` includes: avatar URL, name, description, subscriber count, uploads.
  - `Instance` includes: base URL, API version, features, auth, rate limits.
- Services:
  - `PeerTubeServices`: search, listings (trending, recent, subscriptions), video details, comments, channel details, playlists.
  - `PlaybackService`: source resolution and quality ladder composition.
  - `SubscriptionService`: follow/unfollow channels, periodic sync, notifications.
  - `DownloadService`: offline downloads, revalidation, quota.
- View Models:
  - `FeedViewModel`, `VideoDetailViewModel`, `ChannelViewModel`, `PlayerViewModel`.
  - Each uses async/await with cancellation and `@Published` for UI updates.
- Player:
  - `PlayerCoordinator` orchestrates AVPlayer, quality selection, captions, PiP, and persistence of user preferences.
- Storage:
  - Per-instance caches and keychain-stored tokens.
  - Lightweight local database for subscriptions, history, and downloads.

---

## Error Handling and Resilience

- Unified error types: NetworkError, ParseError, AuthError, CapabilityError.
- Recovery flows:
  - Retry with exponential backoff for transient network failures.
  - Fallback to alternative sources if a selected quality or format fails.
  - Informative UI states: Retry, Switch Quality, Open in Browser (as last resort).
- Telemetry:
  - Lightweight, privacy-respecting diagnostics for playback failures and network errors to improve defaults over time.

---

## Security and Privacy Considerations

- Per-instance auth storage in keychain; tokens never logged.
- Minimize external service calls; rely on instance APIs only.
- Consider opt-in analytics with anonymized, local aggregation—off by default.

---

## Initial Implementation Plan

1) Domain model enrichment:
   - Add capabilities to `Video` and `Instance`.
   - Normalize format representations (HLS/DASH/MP4/WebM, caption tracks).

2) PlayerCoordinator:
   - Quality preferences and manual override.
   - Captions/audio track selection.
   - PiP, background playback, remote controls.

3) Federation and instance UI:
   - Instance settings page with auth and preferences.
   - Quick switcher and per-instance caches.

4) Subscriptions and feeds:
   - SubscriptionService with periodic sync.
   - FeedViewModel with pagination and skeleton loading.

5) Error resilience:
   - Backoff policies, fallback sources, structured UI states.

---

## Open Questions and Next Steps

- Best cross-instance aggregation strategy for subscriptions and recommendations without overfetching.
- Consistency guarantees for comments and replies across PeerTube versions.
- Download policies for federated content: revalidation intervals and quota management.

---

## Conclusion

Android ecosystem learnings converge on patterns that prioritize capability-driven models, resilient playback orchestration, and federation-aware state management. Adopting these for iOS—with AVKit as the playback foundation—will yield a robust, user-friendly client that handles PeerTube’s variability gracefully while delivering modern iOS features and UX consistency.
