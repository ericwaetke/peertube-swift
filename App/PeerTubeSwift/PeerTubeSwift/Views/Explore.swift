//
//  Explore.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 22.12.25.
//

import ComposableArchitecture
import SQLiteData
import SwiftUI
import TubeSDK

@Selection struct VideoRow: Hashable, Equatable {
    public static func == (lhs: VideoRow, rhs: VideoRow) -> Bool {
        return lhs.video.id == rhs.video.id
    }
    
    let video: Video
    let channel: VideoChannel?
}

@Reducer
struct ExploreFeature {
    @ObservableState
    struct State: Equatable {
        var clients: [TubeSDKClient] = []
        var isLoadingVideos: Bool = false
        var filter: FeedFilter = .all
        var order: FeedOrder = .descending
        
        @FetchAll var instances: [Instance] = []
        
        @FetchAll(
            #sql(
            """
            SELECT 
              \(Video.columns),
              \(VideoChannel.columns),
            FROM \(Video.self)
            LEFT JOIN \(VideoChannel.self) ON \(Video.channelID) = \(VideoChannel.id)
            """
            )
        )
        var feed: [VideoRow] = []
    }
    
    enum Action {
        case videoTapped(row: VideoRow)
        case videoOverflowMenuTapped(row: VideoRow)
        case initialScreenLoad
        case pulledToRefresh
        case loadVideos
        case finishLoading
        case channelTapped(row: VideoRow)
        case instanceTapped
        case addInstanceButtonTapped
    }
    
    enum FeedFilter {
        case all
    }

    enum FeedOrder {
        case ascending
        case descending
    }
    
    @Dependency(\.defaultDatabase) var database
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .videoTapped(row: let row):
                return .none
            case .videoOverflowMenuTapped(row: let row):
                return .none
            case .initialScreenLoad:
                return .send(.loadVideos)
            case .loadVideos:
                state.isLoadingVideos = true
                return .run { [clients = state.clients, instances = state.instances] send in
                    // Get Videos from Peertube
//                    for client in clients {
//                        let videos = try await client.getVideos()
//                        
//                        for peertubeVideo in videos {
//                            guard let channel = peertubeVideo.channel,
//                                  let videoId = peertubeVideo.uuid,
//                                  let videoName = peertubeVideo.name,
//                                  let publishedAt = peertubeVideo.publishedAt,
//                                  let channelId = channel.id,
//                                  let channelDisplayName = channel.displayName
//                            else {
//                                print("Error adding video")
//                                continue
//                            }
//                            
//                            let instance = instances.first { $0.host == client.instance.host }
//                            guard let instance = instance else {
//                                print("instance not found in db")
//                                continue
//                            }
//                            
//                            await withErrorReporting {
//                                try await database.write { db in
//                                    let avatarUrl: String? = channel.avatars?.first?.fileUrl
//                                    
//                                    try VideoChannel
//                                        .upsert {
//                                            VideoChannel(
//                                                id: "\(instance.host)-\(channelId)",
//                                                name: channelDisplayName,
//                                                avatarUrl: avatarUrl,
//                                                instanceID: instance.id,
//                                            )
//                                        }
//                                        .execute(db)
//                                    
//                                    let thumbnailUrl: String? = nil
//                                    if let thumbnailPath = peertubeVideo.thumbnailPath {
//                                        thumbnailUrl = try? client.getImageUrl(path: thumbnailPath)
//                                    }
//                                    
//                                    try Video
//                                        .upsert {
//                                            Video(
//                                                id: videoId,
//                                                channelID: "\(instance.host)-\(channelId)",
//                                                instanceID: instance.id,
//                                                name: videoName,
//                                                publishDate: publishedAt,
//                                                thumbnailUrl: thumbnailUrl
//                                            )
//                                        }
//                                        .execute(db)
//                                }
//                            }
//                        }
//                    }
                    
                    await send(.finishLoading)
                }
            case .finishLoading:
                state.isLoadingVideos = false
                return .none
            case .pulledToRefresh:
                return .send(.loadVideos)
            case .channelTapped(row: let row):
                return .none
            case .instanceTapped:
                return .none
            case .addInstanceButtonTapped:
                return .none
            }
        }
    }
}

struct Explore: View {
    @Environment(AppState.self) private var appState: AppState
    let store: StoreOf<ExploreFeature>
    
    var body: some View {
        @Bindable var appState = appState
        
        NavigationStack(path: $appState.navigationPath) {
            ZStack {
                if self.store.isLoadingVideos {
                    ProgressView()
                } else if self.store.feed.isEmpty {
                    ContentUnavailableView {
                        Label("Your Feed is empty", systemImage: "video")
                    } description: {
                        Button("Add an Instance to get their latest videos") {
                            self.store.send(.addInstanceButtonTapped)
                        }
                    }
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading) {
                            ForEach(self.store.feed, id: \.self) { row in
                                VideoCard(row: row) {
                                    self.store.send(.videoTapped(row: row))
                                } openChannel: {
                                    self.store.send(.channelTapped(row: row))
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Explore")
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .videoDetail(host: let host, videoId: let videoId):
                    VideoDetails(host: host, videoId: videoId)
                default:
                    Text("View not implemented")
                }
                
            }
            .task {
                self.store.send(.initialScreenLoad)
            }
            .refreshable {
                self.store.send(.pulledToRefresh)
            }
        }
    }
}

#Preview {
        let _ = prepareDependencies {
            try! $0.bootstrapDatabase()
            try! $0.defaultDatabase.seed()
        }
        NavigationStack {
            Explore(store: Store(initialState: ExploreFeature.State()) {
                ExploreFeature()
              })
                .environment(AppState())
        }
}
