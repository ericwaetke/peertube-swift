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

@Reducer
struct ExploreFeature {
    @ObservableState
    struct State: Equatable {
        @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(scheme: "https", host: "peertube.wtf")
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
                    \(Instance.columns)
                FROM \(Video.self)
                LEFT JOIN \(VideoChannel.self) ON \(Video.channelID) = \(VideoChannel.id)
                LEFT JOIN \(Instance.self) ON \(Video.instanceID) = \(Instance.host)
                ORDER BY \(Video.publishDate) DESC
                """
            )
        )
        var feed: [VideoRow] = []
        
        let columns = Array(repeating: GridItem(.flexible()), count: 2)
    }
    
    enum Action {
        case videoTapped(row: VideoRow)
        case videoOverflowMenuTapped(row: VideoRow, host: String)
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
            case .videoTapped(let row):
                return .none
            case .videoOverflowMenuTapped(let row):
                return .none
            case .initialScreenLoad:
                return .send(.loadVideos)
            case .loadVideos:
                if (state.feed.isEmpty) {
                    state.isLoadingVideos = true
                }
                return .run { [client = state.client, instances = state.instances] send in
                    // Get Videos from Peertube
                    
                    let videos = try await client.getVideos()
                    
                    for peertubeVideo in videos {
                        guard let channel = peertubeVideo.channel,
                              let videoId = peertubeVideo.uuid,
                              let videoName = peertubeVideo.name,
                              let publishedAt = peertubeVideo.publishedAt,
                              let channelId = channel.id,
                              let channelUsername = channel.name,
                              let channelDisplayName = channel.displayName,
                              let instanceHost = channel.host
                        else {
                            print("Error adding video")
                            continue
                        }
                        
                        await withErrorReporting {
                            try await database.write { db in
                                let avatarUrl: String? = channel.avatars?.first?.fileUrl
                                
                                //                                    try Instance
                                //                                    .upsert {
                                //                                        Instance(host: host, scheme: "https")
                                //                                    }
                                //                                    .returning(\.self)
                                //                                    .fetchOne(db)
                                let instance = try Instance
                                    .upsert { Instance(host: instanceHost, scheme: "https") }
                                    .returning(\.self)
                                    .fetchOne(db)
                                
                                guard let instance = instance else {
                                    return
                                }
                                
                                try VideoChannel
                                    .upsert {
                                        VideoChannel(
                                            id: "\(channelUsername)@\(instanceHost)",
                                            name: channelDisplayName,
                                            avatarUrl: avatarUrl,
                                            instanceID: instance.id,
                                        )
                                    }
                                    .execute(db)
                                
                                var thumbnailUrl: String? = nil
                                if let thumbnailPath = peertubeVideo.thumbnailPath {
                                    do {
                                        thumbnailUrl = try client.getImageUrl(
                                            path: thumbnailPath
                                        ).absoluteString
                                    } catch {
                                        print("could not get thumbnail url")
                                    }
                                }
                                
                                try Video
                                    .upsert {
                                        Video(
                                            id: videoId,
                                            channelID: "\(channelUsername)@\(instanceHost)",
                                            instanceID: instance.id,
                                            name: videoName,
                                            publishDate: publishedAt,
                                            thumbnailUrl: thumbnailUrl
                                        )
                                    }
                                    .execute(db)
                            }
                        }
                    }
                    
                    await send(.finishLoading)
                }
            case .finishLoading:
                state.isLoadingVideos = false
                return .none
            case .pulledToRefresh:
                return .send(.loadVideos)
            case .channelTapped(let row):
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
    //    @Environment(AppState.self) private var appState: AppState
    let store: StoreOf<ExploreFeature>
    
    var body: some View {
        //        @Bindable var appState = appState
        
        ZStack {
            if self.store.isLoadingVideos {
                ProgressView()
            } else if self.store.feed.isEmpty {
                if self.store.instances.isEmpty {
                    ContentUnavailableView {
                        Label("Your Feed is empty", systemImage: "video")
                    } description: {
                        Button("Add an Instance to get their latest videos") {
                            self.store.send(.addInstanceButtonTapped)
                        }
                    }
                } else {
                    ContentUnavailableView {
                        Label("Your Feed is empty", systemImage: "video")
                    } description: {
                        VStack {
                            Text(
                                "You have instances added, but they dont seem to have any videos right now"
                            )
                            Button("Reload") {
                                self.store.send(.pulledToRefresh)
                            }
                        }
                    }
                    
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 350))], alignment: .leading, spacing: 12) {
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
        .task {
            await self.store.send(.initialScreenLoad).finish()
        }
        .refreshable {
            self.store.send(.pulledToRefresh)
        }
        
    }
}

#Preview {
    let _ = prepareDependencies {
        try! $0.bootstrapDatabase()
        try! $0.defaultDatabase.seed()
    }
    
    NavigationStack {
        Explore(
            store: Store(initialState: ExploreFeature.State()) {
                ExploreFeature()
            }
        )
        .environment(AppState())
    }
}
