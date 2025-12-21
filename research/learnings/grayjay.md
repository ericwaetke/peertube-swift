# Grayjay and PeerTube Plugin Research Findings

This document summarizes the findings from researching the Grayjay application and its PeerTube plugin. The goal of this research is to identify architectural patterns and strategies that can be applied to the development of a native iOS PeerTube client.

## 1. Grayjay Overview

Grayjay is a media aggregator application that allows users to consume content from multiple platforms ("sources") through a single interface.

### Key Features:
- **Extensible Plugin Architecture**: Grayjay uses JavaScript-based plugins to integrate with different platforms. This allows for community contributions and easy expansion.
- **Unified User Experience**: It provides a consistent UI for features like search, subscriptions, playlists, and comments across different sources.
- **Creator-Centric**: It includes features aimed at helping creators monetize their content directly.
- **Federation Support**: As seen with the PeerTube plugin, it is capable of handling decentralized and federated platforms.

## 2. PeerTube Plugin Analysis

The PeerTube plugin for Grayjay is a comprehensive implementation that interacts with the PeerTube API to fetch and display content.

### `PeerTubeConfig.json`
This configuration file defines the plugin's metadata, permissions, settings, and capabilities.
- **Permissions**: `allowUrls: ["everywhere"]` is crucial for a federated platform, allowing the plugin to communicate with any PeerTube instance.
- **Dependencies**: It relies on a built-in `Http` package for network requests.
- **Settings**: It offers user-configurable settings, such as choosing a search engine (instance-specific vs. global `sepiasearch.org`) and enabling/disabling view reporting. This demonstrates a good approach to providing user control over plugin behavior.

### `PeerTubeScript.js`
This is the core logic of the plugin, written in JavaScript.
- **API-Centric**: All interactions are done through the official PeerTube v1 REST API.
- **Federation Handling**:
    - It maintains a list of known PeerTube instances.
    	- This list is accessible here: https://instances.joinpeertube.org/api/v1/instances/hosts?start=0&count=10000
    - It has logic to parse URLs and identify the correct instance host for a given piece of content (video, channel, etc.).
    - API calls are directed to the appropriate instance.
- **Data Mapping**: The script maps the JSON data from the PeerTube API to Grayjay's standardized internal data models (e.g., `PlatformVideoDetails`, `PlatformChannel`).
- **Feature Completeness**: The script implements a wide array of features, including:
    - Home feed, search (videos, channels, playlists), and recommendations.
    - Detailed views for videos, channels, and playlists.
    - Comment fetching and parsing.
    - Subtitle support.
    - View reporting for analytics.

## 3. Recommended Architectural Patterns for iOS

Based on the analysis of the Grayjay PeerTube plugin, the following architectural patterns are recommended for the native iOS application:

### a. Dedicated Networking Layer
Create a robust networking layer that encapsulates all interactions with the PeerTube API. This layer should handle request creation, response parsing, and error handling. Using a library like `Alamofire` or relying on native `URLSession` with `async/await` would be appropriate.

### b. Federation-Aware URL Handling
Implement a utility or service that can parse any PeerTube URL (for videos, channels, playlists) and extract both the content identifier (e.g., video UUID) and the instance's base URL. This is fundamental for a federated client.

### c. Data Mapping (Model Layer)
Define native Swift models (using `Codable`) that correspond to the JSON objects returned by the PeerTube API. Create a mapping layer to transform the API responses into these models. This decouples the UI and business logic from the raw network responses.

### d. Service-Oriented Architecture
Structure the application's logic into services based on features. For example:
- `VideoService`: Handles fetching video details, recommendations, etc.
- `ChannelService`: Handles fetching channel details and content.
- `SearchService`: Implements search functionality, potentially with different scopes (local instance vs. Sepia Search).
- `InstanceService`: Manages a list of PeerTube instances and their capabilities.

### e. Configurable Search Strategy
Provide users with the option to choose their search provider, similar to the Grayjay plugin. This could be a setting that switches the `SearchService` between using the current instance's search API and the Sepia Search API.

### f. State Management
Utilize SwiftUI's data flow features (`@State`, `@StateObject`, `@EnvironmentObject`) to manage the application's state. For complex state management, consider using the Composable Architecture (TCA) or a similar pattern.

By adopting these patterns, the iOS application can achieve a flexible, maintainable, and scalable architecture that is well-suited for the complexities of the federated PeerTube ecosystem.
