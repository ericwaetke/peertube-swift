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
        @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(scheme: "https", host: "peertube.wtf")
        var videoChannel: VideoChannel?
        var instance: Instance?
        var selectedQuality: TubeSDK.VideoFile?

        var hasDisliked = false
        var hasLiked = false
        var videoDetails: TubeSDK.VideoDetails?

        var descriptionVisible = true
        var commentsVisible = true
        var comments: [TubeSDK.VideoComment] = []

        //        TODO: Fetch from DB
        var isSubscribedToChannel = false
        var notifyOnNewVideo = false
    }

    enum Action {
        case timeUpdate(Int)
        case dislikeButtonTapped
        case likeButtonTapped

        case descriptionVisibleChanged(Bool)
        case commentsVisibleChanged(Bool)
        
        case loadComments
        case commentsLoaded([TubeSDK.VideoComment])

        case loadVideo(TubeSDK.VideoDetails)
        case loadChannel(TubeSDK.VideoDetails)
        case loadInstance
        case instanceLoaded(Instance)
        case saveChannel(VideoChannel)

        case screenLoaded
        case subscribeButtonTapped
        case toggleNotificationButtonTapped
        case updateNotificationState(Bool)
        case changeSubscriptionState(Bool)
        case channelTapped
        case instanceTapped
        case subscriptionStateLoaded(Bool, Bool)
        case loadUserRating
        case ratingLoaded(TubeSDK.VideoRating)

        case newResolutionSelected(TubeSDK.VideoFile)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .timeUpdate(let time):
                return .run { [client = state.client, videoId = state.videoId, videoDetails = state.videoDetails] send in
                    try? await client.pingVideoWatchingInProgress(videoID: videoId, currentTime: time)
                    
                    // Also update the local database so watch history works offline/unauthenticated
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
            case .dislikeButtonTapped:
                let wasDisliked = state.hasDisliked
                let wasLiked = state.hasLiked
                
                state.hasLiked = false
                state.hasDisliked = !wasDisliked
                
                var newLikes = state.videoDetails?.likes ?? 0
                var newDislikes = state.videoDetails?.dislikes ?? 0
                
                if wasLiked { newLikes = max(0, newLikes - 1) }
                if wasDisliked {
                    newDislikes = max(0, newDislikes - 1)
                } else {
                    newDislikes += 1
                }
                
                state.videoDetails?.likes = newLikes
                state.videoDetails?.dislikes = newDislikes
                return .run { [client = state.client, videoId = state.videoId, hasDisliked = state.hasDisliked] send in
                    try? await client.rate(videoID: videoId, rating: hasDisliked ? .dislike : .none)
                }
            case .likeButtonTapped:
                let wasLiked = state.hasLiked
                let wasDisliked = state.hasDisliked
                
                state.hasLiked = !wasLiked
                state.hasDisliked = false
                
                var newLikes = state.videoDetails?.likes ?? 0
                var newDislikes = state.videoDetails?.dislikes ?? 0
                
                if wasDisliked { newDislikes = max(0, newDislikes - 1) }
                if wasLiked {
                    newLikes = max(0, newLikes - 1)
                } else {
                    newLikes += 1
                }
                
                state.videoDetails?.likes = newLikes
                state.videoDetails?.dislikes = newDislikes
                return .run { [client = state.client, videoId = state.videoId, hasLiked = state.hasLiked] send in
                    try? await client.rate(videoID: videoId, rating: hasLiked ? .like : .none)
                }
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
                return .merge(
                    .send(.loadChannel(videoDetails)),
                    .send(.loadUserRating),
                    .send(.loadComments)
                )
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
            case .loadChannel(let videoDetails):
                return .run {
                    [videoDetails = videoDetails, host = state.host, instance = state.instance] send
                    in
                    @Dependency(\.defaultDatabase) var database

                    guard let instanceId = instance?.id,
                        let channelDetails = videoDetails.channel,
                        let channelId = channelDetails.id,
                        let channelName = channelDetails.displayName,
                          let channelUsername = channelDetails.name,
                          let channelHost = channelDetails.host
                    else {
                        return
                    }

                    let channel = withErrorReporting {
                        return try database.write { db in
                            return
                                try VideoChannel
                                .upsert {
                                    VideoChannel(
                                        id: "\(channelUsername)@\(channelHost)",
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
                return .run { [client = state.client, channel = channel] send in
                    @Dependency(\.defaultDatabase) var database
                    var localNotificationState = false
                    if let subscription = try? await database.read({ db in
                        try PeertubeSubscription.find(channel.id).fetchOne(db)
                    }) {
                        localNotificationState = subscription.notifyOnNewVideo
                    }

                    if client.currentToken != nil {
                        if let isSubscribed = try? await client.checkSubscription(channelUri: channel.id) {
                            await send(.subscriptionStateLoaded(isSubscribed, localNotificationState))
                        }
                    } else {
                        // Unauthenticated fallback: If they have a local subscription record
                        let hasLocalSub = try? await database.read({ db in
                            try PeertubeSubscription.find(channel.id).fetchOne(db) != nil
                        })
                        await send(.subscriptionStateLoaded(hasLocalSub ?? false, localNotificationState))
                    }
                }
            case .subscribeButtonTapped:
                let isSubscribed = state.isSubscribedToChannel
                return .send(.changeSubscriptionState(!isSubscribed))
            case .toggleNotificationButtonTapped:
                let currentNotificationState = state.notifyOnNewVideo
                return .run { send in
                    let center = UNUserNotificationCenter.current()
                    let settings = await center.notificationSettings()
                    
                    if settings.authorizationStatus == .notDetermined {
                        let granted = try? await center.requestAuthorization(options: [.alert, .sound])
                        if granted == true {
                            await send(.updateNotificationState(!currentNotificationState))
                        }
                    } else if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
                        await send(.updateNotificationState(!currentNotificationState))
                    } else {
                        // User denied notifications in settings
                        print("User denied notifications")
                    }
                }
            case .updateNotificationState(let notify):
                state.notifyOnNewVideo = notify
                return .run { [channel = state.videoChannel, notify = notify] _ in
                    guard let channelId = channel?.id else { return }
                    @Dependency(\.defaultDatabase) var database
                    try? await database.write { db in
                        try PeertubeSubscription
                            .where { $0.channelID == channelId }
                            .update { $0.notifyOnNewVideo = notify }
                            .execute(db)
                    }
                }
            case .changeSubscriptionState(let newSubscriptionState):
                state.isSubscribedToChannel = newSubscriptionState
                return .run {
                    [
                        client = state.client,
                        host = state.host, videoDetails = state.videoDetails,
                        newSubscriptionState = newSubscriptionState
                    ] send in
                    @Dependency(\.defaultDatabase) var database

                    guard let videoDetails = videoDetails,
                          let channel = videoDetails.channel,
                          let channelUsername = channel.name,
                          let channelHost = channel.host
                    else {
                        return
                    }

                    let channelId = "\(channelUsername)@\(channelHost)"
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
                            if client.currentToken != nil {
                                try? await client.addSubscription(channelUri: channelId)
                            }
                        } else {
                            try await database.write { db in
                                try PeertubeSubscription
                                    .where { $0.channelID == channelId }
                                    .delete()
                                    .execute(db)
                            }
                            if client.currentToken != nil {
                                try? await client.removeSubscription(channelUri: channelId)
                            }
                        }
                    }
                }
                        case .subscriptionStateLoaded(let isSubscribed, let notifyOnNewVideo):
                state.isSubscribedToChannel = isSubscribed
                state.notifyOnNewVideo = notifyOnNewVideo
                return .none
            case .loadUserRating:
                return .run { [client = state.client, videoId = state.videoId] send in
                    if client.currentToken != nil {
                        if let rating = try? await client.getRating(videoID: videoId) {
                            await send(.ratingLoaded(rating))
                        }
                    }
                }
            case .loadComments:
                return .run { [client = state.client, videoId = state.videoId] send in
                    if let commentsResponse = try? await client.getCommentThreads(videoID: videoId) {
                        await send(.commentsLoaded(commentsResponse.data ?? []))
                    }
                }
            case .commentsLoaded(let comments):
                state.comments = comments
                return .none
            case .ratingLoaded(let rating):
                state.hasLiked = rating == .like
                state.hasDisliked = rating == .dislike
                return .none
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

                            VideoPlayerView(
                                onTimeUpdate: { time in self.store.send(.timeUpdate(time)) }, 
                                videoFiles: videoFiles, 
                                selectedVideoFile: self.store.state.selectedQuality, 
                                startTime: videoDetails.userHistory?.currentTime,
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
                                    .buttonStyle(.bordered)

                                    Button {
                                        self.store.send(.dislikeButtonTapped)
                                    } label: {
                                        HStack {
                                            Image(systemName: "hand.thumbsdown")
                                            Text(dislikes.formatted())
                                        }
                                    }
                                    .tint(self.store.state.hasDisliked ? .blue : .primary)
                                    .buttonStyle(.bordered)

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
                                        .buttonStyle(.bordered)

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
                                HStack {
                                    if self.store.state.isSubscribedToChannel {
                                        Button {
                                            self.store.send(.toggleNotificationButtonTapped)
                                        } label: {
                                            Image(systemName: self.store.state.notifyOnNewVideo ? "bell.fill" : "bell")
                                        }
                                        .buttonStyle(.bordered)
                                    }

                                    Button(
                                        self.store.state.isSubscribedToChannel
                                            ? "Unsubscribe" : "Subscribe"
                                    ) {
                                        self.store.send(.subscribeButtonTapped)
                                    }
                                    .buttonStyle(.bordered)
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
                                        VStack(alignment: .leading, spacing: 16) {
                                            ForEach(store.comments) { comment in
                                                VStack(alignment: .leading, spacing: 4) {
                                                    HStack(alignment: .top) {
                                                        if let avatars = comment.account?.avatars,
                                                           let avatar = avatars.first(where: { $0.width == 48 }) ?? avatars.first,
                                                           let avatarPath = avatar.path,
                                                           let url = try? store.client.getImageUrl(path: avatarPath) {
                                                            AsyncImage(url: url) { image in
                                                                image.resizable().scaledToFill()
                                                            } placeholder: {
                                                                Color.gray.opacity(0.3)
                                                            }
                                                            .frame(width: 32, height: 32)
                                                            .clipShape(Circle())
                                                        } else {
                                                            Circle()
                                                                .fill(Color.gray.opacity(0.3))
                                                                .frame(width: 32, height: 32)
                                                        }
                                                        
                                                        VStack(alignment: .leading, spacing: 2) {
                                                            HStack {
                                                                Text(comment.account?.displayName ?? comment.account?.name ?? "Unknown")
                                                                    .fontWeight(.semibold)
                                                                    .font(.subheadline)
                                                                if let createdAt = comment.createdAt {
                                                                    Text(createdAt, style: .date)
                                                                        .font(.caption)
                                                                        .opacity(0.6)
                                                                }
                                                            }
                                                            if let text = comment.text {
                                                                // Stripping basic HTML tags
                                                                let cleanText = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                                                                Text(cleanText)
                                                                    .font(.body)
                                                            }
                                                        }
                                                    }
                                                }
                                                .padding(.vertical, 4)
                                                
                                                if comment.id != store.comments.last?.id {
                                                    Divider()
                                                }
                                            }
                                        }
                                        .padding(.top, 8)
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
                    host: "peertube.wtf", videoId: "18QZB6GTN1DRd1LtkeQm22")
            ) {
                VideoDetailsFeature()
            })
    }
}
