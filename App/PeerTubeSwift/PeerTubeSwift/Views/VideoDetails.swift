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

func test() async throws {
    @Dependency(\.defaultDatabase) var database

    let host = ""
    let channelId = ""
    let subscriptionState = false

    await withErrorReporting {
        if subscriptionState {
            try await database.write { db in
                try PeertubeSubscription
                    .delete()
                    .where { $0.channelID == "\(host)-\(channelId)" }
                    .execute(db)
            }
        } else {
            try await database.write { db in
                try PeertubeSubscription
                    .insert {
                        PeertubeSubscription.Draft(
                            channelID: "\(host)-\(channelId)", createdAt: .now)
                    }
                    .execute(db)
            }
        }
    }
}

@Reducer
struct VideoDetailsFeature {
    @ObservableState
    struct State: Equatable {
        let host: String
        let videoId: String
        let client: TubeSDKClient
        var videoChannel: VideoChannel?
        var instance: Instance?
        var selectedQuality: TubeSDK.VideoFile?

        var hasDisliked = false
        var hasLiked = false
        var videoDetails: TubeSDK.VideoDetails?

        var descriptionVisible = true
        var commentsVisible = true

        //        TODO: Fetch from DB
        var isSubscribedToChannel = false
    }

    enum Action {
        case dislikeButtonTapped
        case likeButtonTapped

        case descriptionVisibleChanged(Bool)
        case commentsVisibleChanged(Bool)

        case loadVideo(TubeSDK.VideoDetails)
        case loadChannel(TubeSDK.VideoDetails)
        case loadInstance
        case instanceLoaded(Instance)
        case saveChannel(VideoChannel)

        case screenLoaded
        case subscribeButtonTapped
        case changeSubscriptionState(Bool)
        case channelTapped
        case instanceTapped

        case newResolutionSelected(TubeSDK.VideoFile)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .dislikeButtonTapped:
                state.hasLiked = false
                state.hasDisliked = true
                return .none
            case .likeButtonTapped:
                state.hasLiked = true
                state.hasDisliked = false
                return .none
            case .descriptionVisibleChanged(_):
                state.descriptionVisible.toggle()
                return .none
            case .commentsVisibleChanged(_):
                state.commentsVisible.toggle()
                return .none
            case .screenLoaded:
                return .send(.loadInstance)
            case .loadVideo(let videoDetails):
                state.videoDetails = videoDetails
                if state.selectedQuality == nil {
                    if let quality = videoDetails.streamingPlaylists?.first?.files?.first {
                        state.selectedQuality = quality
                    }
                }
                return .send(.loadChannel(videoDetails))
            case .loadInstance:
                return .run { [host = state.host] send in
                    @Dependency(\.defaultDatabase) var database

                    await withErrorReporting {
                        let instance = try await database.write { db in
                            return
                                try Instance
                                .upsert {
                                    Instance(host: host, scheme: "https")
                                }
                                .returning(\.self)
                                .fetchOne(db)
                        }

                        if let instance = instance {
                            await send(.instanceLoaded(instance))
                        }
                    }
                }
            case .instanceLoaded(let instance):
                state.instance = instance
                return .run { [client = state.client, videoId = state.videoId] send in
                    print("running side-effect screen loaded")
                    let videoDetails = try await client.getVideo(
                        host: client.instance.host, id: videoId)
                    await send(.loadVideo(videoDetails))
                }
            case .loadChannel(let videoDetails):
                return .run {
                    [videoDetails = videoDetails, host = state.host, instance = state.instance] send
                    in
                    @Dependency(\.defaultDatabase) var database

                    guard let instanceId = instance?.id,
                        let channelDetails = videoDetails.channel,
                        let channelId = channelDetails.id,
                        let channelName = channelDetails.displayName
                    else {
                        return
                    }

                    let channel = withErrorReporting {
                        return try database.write { db in
                            return
                                try VideoChannel
                                .upsert {
                                    VideoChannel(
                                        id: "\(host)-\(channelId)",
                                        name: channelName,
                                        avatarUrl: channelDetails.avatars?.first?.fileUrl,
                                        instanceID: instanceId
                                    )
                                }
                                .returning(\.self)
                                .fetchOne(db)
                        }
                    }
                    if let channel = channel {
                        await send(.saveChannel(channel))
                    }
                }
            case .saveChannel(let channel):
                print(channel)
                state.videoChannel = channel
                return .none
            case .subscribeButtonTapped:
                let isSubscribed = state.isSubscribedToChannel
                return .send(.changeSubscriptionState(!isSubscribed))
            case .changeSubscriptionState(let newSubscriptionState):
                state.isSubscribedToChannel = newSubscriptionState
                return .run {
                    [
                        host = state.host, videoDetails = state.videoDetails,
                        newSubscriptionState = newSubscriptionState
                    ] send in
                    @Dependency(\.defaultDatabase) var database

                    guard let videoDetails = videoDetails,
                        let channel = videoDetails.channel,
                        let peertubeChannelId = channel.id
                    else {
                        return
                    }

                    let channelId = "\(host)-\(peertubeChannelId)"
                    print("changing subscription state of »\(channelId)«")

                    await withErrorReporting {
                        if newSubscriptionState == true {
                            try await database.write { db in
                                try PeertubeSubscription
                                    .insert {
                                        PeertubeSubscription.Draft(
                                            channelID: channelId, createdAt: .now)
                                    }
                                    .execute(db)
                            }
                        } else {
                            try await database.write { db in
                                try PeertubeSubscription
                                    .where { $0.channelID == channelId }
                                    .delete()
                                    .execute(db)
                            }
                        }
                    }
                }
            case .channelTapped:
                return .none
            case .instanceTapped:
                return .none
            case .newResolutionSelected(let resolution):
                state.selectedQuality = resolution
                return .none
            }
        }
    }
}

struct VideoDetails: View {
    @Bindable var store: StoreOf<VideoDetailsFeature>

    let formatter = RelativeDateTimeFormatter()

    var body: some View {
        ZStack { 
            if let videoDetails = self.store.state.videoDetails {
                ScrollView {
                    VStack(spacing: 16) {
                        if let videoFiles = videoDetails.streamingPlaylists?.first?.files,
                            !videoFiles.isEmpty
                        {

//                            VideoPlayerView(
//                                videoFiles: videoFiles,
//                                selectedVideoFile: self.store.state.selectedQuality
//                            )
                            VideoPlayerView(videoFiles: videoFiles, selectedVideoFile: self.store.state.selectedQuality)
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
                            if let likes = videoDetails.likes,
                                let dislikes = videoDetails.dislikes
                            {
                                HStack {
                                    Button {
                                        self.store.send(.likeButtonTapped)
                                    } label: {
                                        HStack {
                                            Image(systemName: "hand.thumbsup")
                                            Text(likes.formatted())
                                        }
                                    }
                                    .tint(self.store.state.hasLiked ? .blue : .primary)
                                    .apply {
                                        if #available(iOS 26.0, *) {
                                            $0.buttonStyle(.glass)
                                        } else {
                                            $0.buttonStyle(.automatic)
                                        }
                                    }

                                    Button {
                                        self.store.send(.dislikeButtonTapped)
                                    } label: {
                                        HStack {
                                            Image(systemName: "hand.thumbsdown")
                                            Text(dislikes.formatted())
                                        }
                                    }
                                    .tint(self.store.state.hasDisliked ? .blue : .primary)
                                    .apply {
                                        if #available(iOS 26.0, *) {
                                            $0.buttonStyle(.glass)
                                        } else {
                                            $0.buttonStyle(.automatic)
                                        }
                                    }

                                    if let playlist = videoDetails.streamingPlaylists?.first,
                                        let qualities = playlist.files
                                    {
                                        Menu {
                                            ForEach(qualities) { quality in
                                                if let resolution = quality.resolution?.label {
                                                    Button {
                                                        //                                                        withAnimation {
                                                        self.store.send(
                                                            .newResolutionSelected(quality))
                                                        //                                                        }
                                                    } label: {
                                                        let string =
                                                            "\(resolution) (A: \((quality.hasAudio ?? false) ? "✓" : "×"), V: \((quality.hasVideo ?? false) ? "✓" : "×")"
                                                        if self.store.state.selectedQuality
                                                            == quality
                                                        {
                                                            Label(string, systemImage: "checkmark")
                                                        } else {
                                                            Text(string)
                                                        }
                                                    }
                                                }
                                            }
                                        } label: {
                                            Label(
                                                self.store.state.selectedQuality?.resolution?.label
                                                    ?? "Quality", systemImage: "gear")
                                        }
                                        .apply {
                                            if #available(iOS 26.0, *) {
                                                $0.buttonStyle(.glass)
                                            } else {
                                                $0.buttonStyle(.automatic)
                                            }
                                        }

                                        //                                        Picker("Quality", selection: $store.selectedQuality.sending(\.changeSubscriptionState)) {
                                        //                                            ForEach(qualities) { quality in
                                        //                                                if let resolution = quality.resolution?.label {
                                        //                                                    Text(resolution).tag(quality)
                                        //                                                }
                                        //                                            }
                                        //                                        }
                                    }

                                    if let url = URL(
                                        string:
                                            "https://\(self.store.state.host)/w/\(self.store.state.videoId)"
                                    ) {
                                        ShareLink(item: url)
                                    }
                                }
                            }

                            // Channel Subscription Bar
                            HStack {
                                ZStack(alignment: .bottomLeading) {
                                    // Default Channel Stuff
                                    HStack(alignment: .top) {
                                        if let avatars = videoDetails.channel?.avatars,
                                            let avatar = avatars.first,
                                            let fileUrl = avatar.fileUrl,
                                            let url = URL(string: fileUrl)
                                        {
                                            AsyncImage(url: url) { image in
                                                image.resizable()
                                            } placeholder: {
                                                Color.secondary
                                            }
                                            .frame(width: 48, height: 48)
                                            .clipShape(.circle)
                                        } else {
                                            Color.secondary
                                                .frame(width: 48, height: 48)
                                                .clipShape(.circle)
                                        }
                                        Text(
                                            "\(videoDetails.channel?.displayName ?? "Unknown Channel")"
                                        )
                                        .lineLimit(1)
                                    }
                                    // Instance Indicator
                                    if let instanceName = videoDetails.channel?.host {
                                        InstanceIndicator(
                                            instanceName: instanceName, instanceImage: nil
                                        )
                                        .padding(.leading, 36)
                                    }
                                }
                                Spacer()
                                Button(
                                    self.store.state.isSubscribedToChannel
                                        ? "Unsubscribe" : "Subscribe"
                                ) {
                                    self.store.send(.subscribeButtonTapped)
                                }
                                .apply {
                                    if #available(iOS 26.0, *) {
                                        $0.buttonStyle(.glass)
                                    } else {
                                        $0.buttonStyle(.automatic)
                                    }
                                }
                            }

                            // Description

                            if let description = videoDetails.description {
                                Divider()
                                DisclosureGroup(
                                    isExpanded: $store.descriptionVisible.sending(
                                        \.descriptionVisibleChanged)
                                ) {
                                    // TODO: don’t do this, ugh … can’t get it to work differently right now though
                                    HStack {
                                        Text(description)
                                        Spacer()
                                    }
                                } label: {
                                    Text("Description")
                                        .foregroundStyle(.primary)
                                        .fontWeight(.bold)

                                }
                            }

                            Divider()

                            VStack(alignment: .leading) {
                                if let commentCount = videoDetails.comments {
                                    DisclosureGroup(
                                        isExpanded: $store.commentsVisible.sending(
                                            \.commentsVisibleChanged)
                                    ) {
                                    } label: {
                                        HStack {
                                            Text("Comments")
                                                .fontWeight(.bold)
                                            Text(commentCount.formatted())
                                                .opacity(0.5)
                                        }
                                    }

                                }
                            }
                            Spacer()
                        }
                        .padding()

                        .containerRelativeFrame(.horizontal)
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

// Source - https://stackoverflow.com/a
// Posted by Mojtaba Hosseini
// Retrieved 2025-12-22, License - CC BY-SA 4.0

extension View {
    func apply<V: View>(@ViewBuilder _ block: (Self) -> V) -> V { block(self) }
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
                    host: "peertube.wtf", videoId: "18QZB6GTN1DRd1LtkeQm22",
                    client: try! TubeSDKClient(scheme: "https", host: "peertube.wtf"))
            ) {
                VideoDetailsFeature()
            })
    }
}
