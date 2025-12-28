//
//  VideoDetails.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 22.12.25.
//

import ComposableArchitecture
import SwiftUI
import TubeSDK

@Reducer
struct VideoDetailsFeature {
    @ObservableState
    struct State: Equatable {
        let host: String
        let videoId: String
        let client: TubeSDKClient
        
        var hasDisliked = false
        var hasLiked = false
        var videoDetails: TubeSDK.VideoDetails?
        
        var descriptionVisible = true
        var commentsVisible = true
    }
    
    enum Action {
        case dislikeButtonTapped
        case likeButtonTapped
        
        case descriptionVisibleChanged(Bool)
        case commentsVisibleChanged(Bool)
        
        case loadVideo(TubeSDK.VideoDetails)
        case screenLoaded
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
                return .run { [client = state.client, videoId = state.videoId] send in
                    let videoDetails = try await client.getVideo(host: client.instance.host, id: videoId)
                    await send(.loadVideo(videoDetails))
                }
            case let .loadVideo(videoDetails):
                state.videoDetails = videoDetails
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
                    VStack (spacing: 16) {
                        if let streamingPlaylists = videoDetails.streamingPlaylists,
                           let video = streamingPlaylists.first,
                           let urlString = video.playlistUrl,
                           let url = URL(string: urlString){
                            VideoPlayerView(videoURL: url)
                                .frame(
                                    minWidth: 0,
                                    maxWidth: .infinity,
                                    minHeight: 100,
                                    maxHeight: .infinity
                                )
                                .aspectRatio(16 / 9, contentMode: .fit)
    //                            .padding(24)
                        }
                        VStack (alignment: .leading, spacing: 16) {
                            VStack (alignment: .leading, spacing: 8) {
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
                                        Text(formatter.localizedString(for: publishedAt, relativeTo: Date.now))
                                            .font(.callout)
                                    }
                                }
                            }
                            if let likes = videoDetails.likes,
                               let dislikes = videoDetails.dislikes {
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
                                    
                                    if let url = URL(string: "https://\(self.store.state.host)/w/\(self.store.state.videoId)") {
                                        ShareLink(item: url)
                                    }
                                }
                            }
                            
                            // Channel Subscription Bar
                            HStack {
                                ZStack (alignment: .bottomLeading) {
                                    // Default Channel Stuff
                                    HStack (alignment: .top) {
                                        if let avatars = videoDetails.channel?.avatars,
                                           let avatar = avatars.first,
                                           let fileUrl = avatar.fileUrl,
                                           let url = URL(string: fileUrl) {
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
                                        Text("\(videoDetails.channel?.displayName ?? "Unknown Channel")")
                                            .lineLimit(1)
                                    }
                                    // Instance Indicator
                                    if let instanceName = videoDetails.channel?.host {
                                        InstanceIndicator(instanceName: instanceName, instanceImage: nil)
                                            .padding(.leading, 36)
                                    }
                                }
                                Spacer()
                                Button("Subscribe") {
                                    
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
                                DisclosureGroup(isExpanded: $store.descriptionVisible.sending(\.descriptionVisibleChanged)) {
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
                            
                            VStack (alignment: .leading) {
                                if let commentCount = videoDetails.comments {
                                    DisclosureGroup(isExpanded: $store.commentsVisible.sending(\.commentsVisibleChanged)) {
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
            }
            else {
                ProgressView()
            }
        }
        .task {
            self.store.send(.screenLoaded)
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
    NavigationStack {
        VideoDetails(store: Store(initialState: VideoDetailsFeature.State(host: "peertube.wtf", videoId: "18QZB6GTN1DRd1LtkeQm22", client: try! TubeSDKClient(scheme: "https", host: "peertube.wtf"))) {
            VideoDetailsFeature()
        })
    }
}
