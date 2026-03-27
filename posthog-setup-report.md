# PostHog Integration Report — PeerTubeSwift

## Overview

PostHog analytics has been integrated into the PeerTubeSwift iOS app using the official `posthog-ios` Swift SDK (v3.48.2) via Swift Package Manager.

## Configuration

| Setting | Value |
|---|---|
| SDK | posthog-ios v3.48.2 |
| Host | `https://eu.i.posthog.com` |
| Token source | Xcode scheme environment variable `POSTHOG_PROJECT_TOKEN` |
| Host source | Xcode scheme environment variable `POSTHOG_HOST` |
| Lifecycle events | Enabled (`captureApplicationLifecycleEvents = true`) |

The token and host are read at runtime via `ProcessInfo.processInfo.environment` — never hardcoded in source.

## Files Changed

| File | Change |
|---|---|
| `project.pbxproj` | Added `posthog-ios` SPM package reference, product dependency, and build file |
| `PeerTubeSwiftApp.swift` | Added `PostHogEnv` enum and SDK initialisation in `init()` |
| `xcschemes/PeerTubeSwift.xcscheme` | Added `POSTHOG_PROJECT_TOKEN` and `POSTHOG_HOST` environment variables |
| `Views/Login.swift` | Identify user and capture `user_logged_in` on successful login |
| `Views/VideoDetails.swift` | Capture `video_viewed` when video details load |
| `Views/VideoActions.swift` | Capture like/dislike/quality-change events |
| `Views/VideoChannel.swift` | Capture `channel_subscribed` / `channel_unsubscribed` |
| `Tabs/SearchTab.swift` | Capture `search_performed` on search submit |
| `Tabs/SettingsTab.swift` | Capture `user_logged_out`, call `reset()`, and capture `instance_changed` |

## Events

| Event | Trigger | Properties |
|---|---|---|
| `user_logged_in` | Successful login | `host` |
| `user_logged_out` | Logout button tapped | — |
| `instance_changed` | PeerTube instance switched | `instance_host` |
| `video_viewed` | Video details screen loads | `video_id`, `video_name` |
| `video_liked` | Like button tapped (on) | `video_id` |
| `video_like_removed` | Like button tapped (off) | `video_id` |
| `video_disliked` | Dislike button tapped (on) | `video_id` |
| `video_dislike_removed` | Dislike button tapped (off) | `video_id` |
| `video_quality_changed` | Resolution selected from menu | `video_id`, `quality` |
| `channel_subscribed` | Subscribe button tapped | `channel_id` |
| `channel_unsubscribed` | Unsubscribe button tapped | `channel_id` |
| `search_performed` | Search form submitted | `query` |

## User Identification

Users are identified on login with `PostHogSDK.shared.identify(username, userProperties: ["host": host])` and anonymous on logout via `PostHogSDK.shared.reset()`.

## Dashboard

**Analytics basics** — https://eu.posthog.com/project/148945/dashboard/591911

| Insight | URL |
|---|---|
| Video Views (Last 30 Days) | https://eu.posthog.com/project/148945/insights/JoZOlPZp |
| Searches Performed (Last 30 Days) | https://eu.posthog.com/project/148945/insights/6fvrCPdH |
| Channel Subscriptions vs Unsubscriptions | https://eu.posthog.com/project/148945/insights/5Dj7ankE |
| User Engagement Funnel | https://eu.posthog.com/project/148945/insights/H8uyA6mr |
