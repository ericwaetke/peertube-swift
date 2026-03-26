//
//  VideoDetails.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 22.12.25.
//

import ComposableArchitecture
import Dependencies
import SQLiteData
import SwiftUI
import TubeSDK

@Reducer
struct VideoDetailsFeature {
    @ObservableState
    struct State: Equatable {
        let host: String
        let videoId: String
        var seekRequest: SeekRequest? = nil
        @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(scheme: "https", host: "peertube.wtf")
        
        var videoDetails: TubeSDK.VideoDetails?
        
        var actions: VideoActionsFeature.State
        var channel: VideoChannelFeature.State
        var description: VideoDescriptionFeature.State
        var comments: VideoCommentsFeature.State
        
        init(host: String, videoId: String) {
            self.host = host
            self.videoId = videoId
            self.actions = VideoActionsFeature.State(host: host, videoId: videoId)
            self.channel = VideoChannelFeature.State(host: host)
            self.description = VideoDescriptionFeature.State()
            self.comments = VideoCommentsFeature.State(videoId: videoId)
        }
    }

    enum Action {
        case timeUpdate(Int)
        case seekTo(Int)
        case loadVideo(TubeSDK.VideoDetails)
        case loadInstance
        case instanceLoaded(Instance)
        case screenLoaded

        case actions(VideoActionsFeature.Action)
        case channel(VideoChannelFeature.Action)
        case description(VideoDescriptionFeature.Action)
        case comments(VideoCommentsFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.actions, action: \.actions) {
            VideoActionsFeature()
        }
        Scope(state: \.channel, action: \.channel) {
            VideoChannelFeature()
        }
        Scope(state: \.description, action: \.description) {
            VideoDescriptionFeature()
        }
        Scope(state: \.comments, action: \.comments) {
            VideoCommentsFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .seekTo(let time):
                state.seekRequest = SeekRequest(time: time)
                return .none
                
            case .timeUpdate(let time):
                return .run { [client = state.client, videoId = state.videoId, videoDetails = state.videoDetails] send in
                    try? await client.pingVideoWatchingInProgress(videoID: videoId, currentTime: time)
                    
                    if let uuid = videoDetails?.uuid {
                        @Dependency(\.defaultDatabase) var database
                        try? await database.write { db in
                            try Video
                                .where { $0.id == uuid }
                                .update { $0.currentTime = time }
                                .execute(db)
                        }
                    }
                }
                
            case .screenLoaded:
                return .send(.loadInstance)
                
            case .loadInstance:
                return .run { [host = state.host] send in
                    @Dependency(\.defaultDatabase) var database

                    await withErrorReporting {
                        let instance = try await database.write { db in
                            return try Instance
                                .upsert { Instance(host: host, scheme: "https") }
                                .returning(\.self)
                                .fetchOne(db)
                        }

                        if let instance = instance {
                            await send(.instanceLoaded(instance))
                        }
                    }
                }
                
            case .instanceLoaded(let instance):
                state.channel.instance = instance
                return .run { [client = state.client, videoId = state.videoId] send in
                    print("running side-effect screen loaded")
                    var videoDetails = try await client.getVideo(
                        host: client.instance.host, id: videoId)
                        
                    if videoDetails.userHistory == nil {
                        if let uuid = videoDetails.uuid {
                            @Dependency(\.defaultDatabase) var database
                            let localTime = try? await database.read { db in
                                try Video.find(uuid).fetchOne(db)?.currentTime
                            }
                            if let time = localTime {
                                videoDetails.userHistory = TubeSDK.VideoUserHistory(currentTime: time)
                            }
                        }
                    }
                        
                    await send(.loadVideo(videoDetails))
                }
                
            case .loadVideo(let videoDetails):
                state.videoDetails = videoDetails
                
                state.actions.videoDetails = videoDetails
                state.channel.videoDetails = videoDetails
                state.description.videoDetails = videoDetails
                state.comments.videoDetails = videoDetails
                
                if state.actions.selectedQuality == nil {
                    if let quality = videoDetails.streamingPlaylists?.first?.files?.first {
                        state.actions.selectedQuality = quality
                    }
                }
                
                return .merge(
                    .send(.channel(.loadChannel(videoDetails))),
                    .send(.actions(.loadUserRating)),
                    .send(.comments(.loadComments))
                )
                
            case .description(.delegate(.seekTo(let time))):
                return .send(.seekTo(time))
                
            case .actions, .channel, .description, .comments:
                return .none
            }
        }
    }
}

struct VideoDetails: View {
    let store: StoreOf<VideoDetailsFeature>
    let formatter = RelativeDateTimeFormatter()

    var body: some View {
        ZStack { 
            if let videoDetails = self.store.videoDetails {
                ScrollView {
                    VStack(spacing: 16) {
                        if let videoFiles = videoDetails.streamingPlaylists?.first?.files,
                           !videoFiles.isEmpty {

                            VideoPlayerView(
                                onTimeUpdate: { time in self.store.send(.timeUpdate(time)) }, 
                                videoFiles: videoFiles, 
                                selectedVideoFile: self.store.actions.selectedQuality, 
                                startTime: videoDetails.userHistory?.currentTime,
                                seekRequest: self.store.seekRequest,
                                videoTitle: videoDetails.name,
                                channelName: videoDetails.channel?.displayName,
                                thumbnailPath: (try? store.client.getImageUrl(path: videoDetails.thumbnailPath ?? ""))?.absoluteString
                            )
                            .frame(
                                minWidth: 0,
                                maxWidth: .infinity,
                                minHeight: 100,
                                maxHeight: .infinity
                            )
                            .aspectRatio(16 / 9, contentMode: .fit)
                        }
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(videoDetails.name ?? "Unknown Video Title")
                                    .font(.title2)
                                    .fontWeight(.bold)

                                HStack {
                                    if let views = videoDetails.views {
                                        Text("^[\(views) View](inflect: true)")
                                            .font(.callout)
                                    }

                                    if let publishedAt = videoDetails.publishedAt {
                                        Text("·")
                                        Text(
                                            formatter.localizedString(
                                                for: publishedAt, relativeTo: Date.now)
                                        )
                                        .font(.callout)
                                    }
                                }
                            }
                            
                            VideoActionsView(store: self.store.scope(state: \.actions, action: \.actions))
                            
                            VideoChannelView(store: self.store.scope(state: \.channel, action: \.channel))

                            VideoDescriptionView(store: self.store.scope(state: \.description, action: \.description))

                            Divider()

                            VStack(alignment: .leading) {
                                VideoCommentsView(store: self.store.scope(state: \.comments, action: \.comments))
                            }
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .task {
            await self.store.send(.screenLoaded).finish()
        }
    }
}


#Preview {
    let _ = prepareDependencies {
        try! $0.bootstrapDatabase()
        try! $0.defaultDatabase.seed()
    }

    NavigationStack {
        VideoDetails(
            store: Store(
                initialState: VideoDetailsFeature.State(
                    host: "peertube.cpy.re", videoId: "eRbrxETVKN3gxKKD8bcaHK")
            ) {
                VideoDetailsFeature()
            })
    }
}
