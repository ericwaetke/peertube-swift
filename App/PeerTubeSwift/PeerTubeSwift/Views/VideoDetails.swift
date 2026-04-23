//
//  VideoDetails.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 22.12.25.
//

import ComposableArchitecture
import Dependencies
import PostHog
import SQLiteData
import SwiftUI
import TubeSDK

@Reducer
struct VideoDetailsFeature {
    @ObservableState
    struct State: Equatable {
        let host: String
        let videoId: String
        var seekRequest: SeekRequest?
        @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(scheme: "https", host: "peertube.wtf")

        var videoDetails: TubeSDK.VideoDetails?
        var pauseTrigger: Int = 0

        var actions: VideoActionsFeature.State
        var channelPreview: ChannelPreviewFeature.State
        var description: VideoDescriptionFeature.State
        var comments: VideoCommentsFeature.State
        var isNotFound: Bool = false

        init(host: String, videoId: String) {
            self.host = host
            self.videoId = videoId
            actions = VideoActionsFeature.State(host: host, videoId: videoId)
            channelPreview = ChannelPreviewFeature.State(host: host)
            description = VideoDescriptionFeature.State()
            comments = VideoCommentsFeature.State(videoId: videoId)
        }
    }

    enum Action {
        case timeUpdate(Int)
        case seekTo(Int)
        case loadVideo(TubeSDK.VideoDetails)
        case loadInstance
        case instanceLoaded(Instance)
        case screenLoaded
        case videoLoadFailed

        case actions(VideoActionsFeature.Action)
        case channelPreview(ChannelPreviewFeature.Action)
        case description(VideoDescriptionFeature.Action)
        case comments(VideoCommentsFeature.Action)

        case delegate(Delegate)

        enum Delegate {
            case navigateToChannel(host: String, channel: TubeSDK.VideoChannel)
        }
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.actions, action: \.actions) {
            VideoActionsFeature()
        }
        Scope(state: \.channelPreview, action: \.channelPreview) {
            ChannelPreviewFeature()
        }
        Scope(state: \.description, action: \.description) {
            VideoDescriptionFeature()
        }
        Scope(state: \.comments, action: \.comments) {
            VideoCommentsFeature()
        }

        Reduce { state, action in
            switch action {
            case let .seekTo(time):
                state.seekRequest = SeekRequest(time: time)
                return .none

            case let .timeUpdate(time):
                return .run { [client = state.client, videoId = state.videoId, videoDetails = state.videoDetails] _ in
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
                    @Dependency(\.peertubeOrchestrator) var peertubeOrchestrator

                    await withErrorReporting {
                        let instance = try await peertubeOrchestrator.syncInstanceInfo(host, database)
                        await send(.instanceLoaded(instance))
                    }
                }

            case let .instanceLoaded(instance):
                state.channelPreview.instance = instance
                return .run { [client = state.client, videoId = state.videoId] send in
                    print("running side-effect screen loaded")
                    var videoDetails = try await client.getVideo(
                        host: client.instance.host, id: videoId
                    )

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
                } catch: { error, send in
                    print("Error loading video: \(error)")
                    if let tubeError = error as? TubeError, case .notFound = tubeError {
                        await send(.videoLoadFailed)
                    } else if (error as NSError).code == 404 {
                        await send(.videoLoadFailed)
                    }
                }

            case .videoLoadFailed:
                state.isNotFound = true
                return .none

            case let .loadVideo(videoDetails):
                state.videoDetails = videoDetails

                state.actions.videoDetails = videoDetails
                state.channelPreview.videoDetails = videoDetails
                state.description.videoDetails = videoDetails
                state.comments.videoDetails = videoDetails

                if state.actions.selectedQuality == nil {
                    if let quality = videoDetails.streamingPlaylists?.first?.files?.first {
                        state.actions.selectedQuality = quality
                    }
                }

                return .merge(
                    .send(.channelPreview(.loadChannelPreview(videoDetails))),
                    .send(.actions(.loadUserRating)),
                    .send(.comments(.loadComments)),
                    .run { [videoDetails] _ in
                        PostHogSDK.shared.capture("video_viewed", properties: [
                            "video_id": videoDetails.uuid?.uuidString ?? "",
                            "video_name": videoDetails.name ?? "",
                        ])
                    }
                )

            case let .description(.delegate(.seekTo(time))):
                return .send(.seekTo(time))

            case .channelPreview(.channelTapped):
                guard let channel = state.channelPreview.videoDetails?.channel,
                      let channelName = channel.name
                else {
                    return .none
                }
                state.pauseTrigger += 1
                return .send(.delegate(.navigateToChannel(host: state.host, channel: channel)))

            case .delegate:
                return .none

            case .actions, .channelPreview, .description, .comments:
                return .none
            }
        }
    }
}

struct VideoDetails: View {
    let store: StoreOf<VideoDetailsFeature>
    let formatter = RelativeDateTimeFormatter()
    @State private var isPlayerReady = false

    var body: some View {
        ZStack {
            if self.store.isNotFound {
                ContentUnavailableView(
                    "Video Not Found",
                    systemImage: "video.slash",
                    description: Text("The video you are looking for does not exist or has been removed.")
                )
            } else if let videoDetails = self.store.videoDetails {
                ScrollView {
                    VStack(spacing: 16) {
                        if let videoFiles = videoDetails.streamingPlaylists?.first?.files,
                           !videoFiles.isEmpty
                        {
                            VideoPlayerView(
                                isPlayerReady: $isPlayerReady,
                                onTimeUpdate: { time in self.store.send(.timeUpdate(time)) },
                                videoFiles: videoFiles,
                                selectedVideoFile: self.store.actions.selectedQuality,
                                startTime: videoDetails.userHistory?.currentTime,
                                seekRequest: self.store.seekRequest,
                                videoTitle: videoDetails.name,
                                channelName: videoDetails.channel?.displayName,
                                thumbnailPath: videoDetails.bestThumbnailUrl(client: store.client, size: .large),
                                pauseTrigger: self.store.pauseTrigger
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
                            Button {
                                let newValue = !self.store.state.description.descriptionVisible
                                withAnimation {
                                    self.store.send(.description(.descriptionVisibleChanged(newValue)))
                                }
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(videoDetails.name ?? "Unknown Video Title")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.leading)

                                    HStack(spacing: 4) {
                                        if let views = videoDetails.views {
                                            Text("^[\(views) View](inflect: true)")
                                        }

                                        if let publishedAt = videoDetails.publishedAt {
                                            Text("·")
                                            Text(
                                                formatter.localizedString(
                                                    for: publishedAt, relativeTo: Date.now
                                                )
                                            )
                                        }

                                        if !self.store.state.description.descriptionVisible {
                                            Text("... more")
                                                .fontWeight(.semibold)
                                        }
                                    }
                                    .font(.callout)
                                    .opacity(0.5)
                                    .foregroundStyle(.primary)

                                    VideoDescriptionView(store: self.store.scope(state: \.description, action: \.description))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.plain)

                            VideoActionsView(store: self.store.scope(state: \.actions, action: \.actions))

                            Divider()

                            ChannelPreviewView(store: self.store.scope(state: \.channelPreview, action: \.channelPreview))

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
                    host: "peertube.cpy.re", videoId: "eRbrxETVKN3gxKKD8bcaHK"
                )
            ) {
                VideoDetailsFeature()
            }
        )
    }
}
