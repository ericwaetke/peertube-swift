# Fedilab Research

## Overview

Fedilab is a popular, open-source Android client for the Fediverse. It aims to provide a unified experience for various Fediverse platforms, including Mastodon, Pleroma, Pixelfed, and PeerTube.

## Key Features

*   **Multi-Account Support**: Users can manage multiple accounts from different Fediverse instances.
*   **Cross-Platform Support**: It supports a wide array of Fediverse software, not just Mastodon. This includes PeerTube for video, Pixelfed for images, and more.
*   **Customization**: Offers extensive customization options for timelines, notifications, and user interface elements.
*   **Advanced Features**: Includes features like scheduled posts, advanced filtering, and a "local" timeline view that shows posts from the user's own instance.
*   **Accessibility**: Strong focus on accessibility features.

## PeerTube Integration

Fedilab's PeerTube integration is particularly relevant to this project.

*   **Video Playback**: It allows users to browse and watch PeerTube videos directly within the app.
*   **Account Interaction**: Users can interact with PeerTube content (like, comment, subscribe) if they are logged into a PeerTube account.
*   **Unified Timeline**: PeerTube videos can appear in the main timeline alongside content from other platforms like Mastodon.

## Architecture & Technology

*   **Platform**: Android (Java/Kotlin).
*   **Source Code**: The project is open source and the code is available on [Codeberg](https://codeberg.org/tom79/Fedilab).
*   **API**: It interacts with the various Fediverse platforms' APIs, including the PeerTube REST API.

## Learnings & Takeaways for PeerTube-Swift

*   **Unified Experience is Key**: Fedilab's success shows the value of a single app that can handle multiple types of Fediverse content. A Swift app that integrates well with other Fediverse clients or services could be very powerful.
*   **API Client is Crucial**: A robust and well-tested API client is the foundation for a good user experience. Fedilab's ability to talk to so many different server types is a testament to this.
*   **User Customization Matters**: Users appreciate the ability to tailor their experience. This is something to consider for the UI/UX of the `PeerTube Swift` app.

## Deep Dive: PeerTube API Client (`PeertubeService.java`)

An analysis of Fedilab's `PeertubeService.java` interface reveals a mature and comprehensive client for the PeerTube API.

### Strengths

*   **Comprehensive API Coverage**: The service defines methods for a vast range of PeerTube API endpoints, covering everything from video browsing and user authentication to content management and moderation.
*   **Declarative Style**: It uses Retrofit annotations (`@GET`, `@POST`, `@Path`, `@Query`, etc.) to create a clean, declarative, and easy-to-understand API client interface.
*   **Clear Naming**: Method names are descriptive and map logically to the underlying API calls (e.g., `getSubscriptionVideos`, `updateVideo`, `deleteComment`).
*   **Authentication Handling**: It correctly handles multiple authentication flows, including OAuth and direct token-based authentication, which is crucial for a full-featured client.

### Areas for a Different Approach in Swift

*   **Monolithic Interface**: The `PeertubeService` is a single, massive interface. For `PeerTube-Swift`, a better approach would be to break this down into smaller, more focused services (e.g., `VideoService`, `ChannelService`, `AccountService`). This would improve modularity, testability, and maintainability.
*   **Lack of Documentation**: The interface lacks inline comments explaining the purpose of each method or its parameters. While method names are clear, our Swift implementation should include comprehensive documentation.
*   **Java-centric Patterns**: The code naturally uses Java patterns like the `Call<T>` object for network requests. Our implementation will be more "Swifty," leveraging modern concurrency with `async/await` and `Result` types for error handling.

### Notable API Endpoints Used

Fedilab's client provides a good reference for the essential API endpoints needed for a mobile client. Here are some examples:

*   **Authentication & User:**
    *   `POST /api/v1/users/token` (To get auth tokens)
    *   `GET /api/v1/users/me` (To verify credentials and get user info)
    *   `PUT /api/v1/users/me` (To update user settings)
*   **Videos & Content:**
    *   `GET /api/v1/videos` (Used with various sort parameters like `-likes`, `-trending`, `-publishedAt`)
    *   `GET /api/v1/users/me/subscriptions/videos` (To get videos from followed channels)
    *   `GET /api/v1/videos/{id}` (To fetch details for a single video)
    *   `POST /api/v1/videos/{id}/views` (To register a video view)
    *   `PUT /api/v1/videos/{id}/rate` (To like or dislike a video)
*   **Channels & Subscriptions:**
    *   `GET /api/v1/accounts/{name}/video-channels` (To list channels for an account)
    *   `POST /api/v1/users/me/subscriptions` (To follow a channel)
    *   `DELETE /api/v1/users/me/subscriptions/{handle}` (To unfollow a channel)
*   **Comments:**
    *   `GET /api/v1/videos/{id}/comment-threads` (To fetch comments for a video)
    *   `POST /api/v1/videos/{id}/comment-threads` (To post a new comment)
*   **Search:**
    *   `GET /api/v1/search/videos`
    *   `GET /api/v1/search/video-channels`
