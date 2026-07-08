# feat-video-chapters — iOS Chapter Markers

## Goal
Add PeerTube chapter markers (from the `/api/v1/videos/{id}/chapters` endpoint, available since PeerTube ≥6.0) to the iOS video player.

## Why this branch exists
The PeerTube API exposes video chapters, but iOS does not have a native API to inject chapter markers into `AVPlayerViewController`. The tvOS `AVNavigationMarkerGroup` / `navigationMarkerGroups` API is **tvOS-exclusive** — it is guarded behind `#if TARGET_OS_TV` in AVKit.h and the symbols do not exist in the iOS SDK.

## Approach — Custom SwiftUI Chapter Bar
Since iOS provides no programmatic API to surface chapter markers in the native player UI, this branch implements:

1. **TubeSDK model & method** (in `peertube-swift-sdk` repo):
   - `VideoChapter(title: String, timecode: Int)` and `VideoChaptersResponse(chapters: [VideoChapter])`
   - `TubeSDKClient.getVideoChapters(id:)` calling `GET /api/v1/videos/{id}/chapters`

2. **Custom ChapterBarView** (in `VideoPlayer.swift`):
   - A SwiftUI overlay rendered on top of the `AVPlayerViewControllerRepresentable`
   - Shows a segmented progress bar proportional to each chapter's duration
   - Highlights the current chapter based on `currentPlaybackTime`
   - Tap-to-seek on any chapter segment via `onChapterSeek` callback

3. **VideoDetails integration** (in `VideoDetails.swift`):
   - Fetches chapters alongside video details via `.chaptersLoaded` action
   - Passes chapters, video duration, and `onChapterSeek` to `VideoPlayerView`

## Files changed in this branch (app repo only)
| File | Change |
|---|---|
| `App/PeerTubeSwift/PeerTubeSwift/Components/VideoPlayer.swift` | Added `ChapterBarView`, chapter params, `currentPlaybackTime` tracking |
| `App/PeerTubeSwift/PeerTubeSwift/Views/VideoDetails.swift` | Added `chapters` to state, `.chaptersLoaded` action, fetch + pass to player |
| `BRANCH_INFO.md` | This file |

## SDK changes (separate repo: `peertube-swift-sdk`)
| File | Change |
|---|---|
| `Sources/TubeSDK/Models/Video/VideoChapters.swift` | New model file |
| `Sources/TubeSDK/peertube_swift_sdk.swift` | Added `getVideoChapters(id:)` method |

## Why NOT native `AVNavigationMarkerGroup`
Confirmed by examining the iOS SDK headers directly (`AVKit.h` umbrella header):
```objc
#if TARGET_OS_TV
#import <AVKit/AVNavigationMarkersGroup.h>   // <-- only on tvOS
#endif
```

- `AVNavigationMarkerGroup` class does not exist on iOS — compile error
- `AVPlayerItem.navigationMarkerGroups` property does not exist on iOS — compile error
- Zero symbols matching "navigationMarker" or "chapter" in iOS AVKit.framework or AVFoundation.framework

Apple's [Presenting Chapter Markers](https://developer.apple.com/documentation/avfoundation/presenting-chapter-markers) doc says AVPlayerViewController "automatically presents a chapter-selection interface if it finds chapter markers in the currently played asset" — but this refers to chapter markers **embedded in the media file** (MP4 chapter track, HLS EXT-X-MARKER), not injectable via any iOS API.

## If a native iOS API is ever added
If Apple adds a chapter injection API to iOS in a future SDK, this branch should be refactored to:
1. Remove `ChapterBarView` custom overlay
2. Convert `[VideoChapter]` to the native marker objects
3. Set them on `AVPlayerItem` (or equivalent)
4. Let `AVPlayerViewController` handle the display
