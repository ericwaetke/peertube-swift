import ComposableArchitecture
import Dependencies
import SwiftUI
import TubeSDK

@Reducer
struct VideoActionsFeature {
    @ObservableState
    struct State: Equatable {
        let host: String
        let videoId: String
        @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(scheme: "https", host: "peertube.wtf")
        
        var hasLiked = false
        var hasDisliked = false
        var videoDetails: TubeSDK.VideoDetails?
        var selectedQuality: TubeSDK.VideoFile?
    }
    
    enum Action {
        case dislikeButtonTapped
        case likeButtonTapped
        case loadUserRating
        case ratingLoaded(TubeSDK.VideoRating)
        case newResolutionSelected(TubeSDK.VideoFile)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
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
                
            case .loadUserRating:
                return .run { [client = state.client, videoId = state.videoId] send in
                    if client.currentToken != nil {
                        if let rating = try? await client.getRating(videoID: videoId) {
                            await send(.ratingLoaded(rating))
                        }
                    }
                }
                
            case .ratingLoaded(let rating):
                state.hasLiked = rating == .like
                state.hasDisliked = rating == .dislike
                return .none
                
            case .newResolutionSelected(let resolution):
                state.selectedQuality = resolution
                return .none
            }
        }
    }
}

struct VideoActionsView: View {
    @Bindable var store: StoreOf<VideoActionsFeature>
    
    var body: some View {
        HStack {
            if let likes = store.state.videoDetails?.likes,
               let dislikes = store.state.videoDetails?.dislikes {
                
                Button {
                    self.store.send(.likeButtonTapped)
                } label: {
                    HStack {
                        Image(systemName: "hand.thumbsup")
                        Text(likes.formatted())
                            .contentTransition(.numericText())
                    }
                }
                .buttonStyle(.bordered)
                .foregroundStyle(self.store.state.hasLiked ? .blue : .primary)
                Button {
                    self.store.send(.dislikeButtonTapped)
                } label: {
                    HStack {
                        Image(systemName: "hand.thumbsdown")
                        Text(dislikes.formatted())
                            .contentTransition(.numericText())
                    }
                }
                .buttonStyle(.bordered)
                .foregroundStyle(self.store.state.hasDisliked ? .blue : .primary)
                
            }
            
            Spacer()
            
            if let playlist = store.state.videoDetails?.streamingPlaylists?.first,
               let qualities = playlist.files {
                Menu {
                    ForEach(qualities) { quality in
                        if let resolution = quality.resolution?.label {
                            Button {
                                self.store.send(.newResolutionSelected(quality))
                            } label: {
                                if self.store.state.selectedQuality == quality {
                                    Label(resolution, systemImage: "checkmark")
                                } else {
                                    Text(resolution)
                                }
                            }
                        }
                    }
                } label: {
                    Label(
                        self.store.state.selectedQuality?.resolution?.label ?? "Quality",
                        systemImage: "gear"
                    )
                }
                .buttonStyle(.bordered)
                .foregroundStyle(.primary)
            }
            
            if let url = URL(string: "https://\(self.store.state.host)/w/\(self.store.state.videoId)") {
                ShareLink(item: url) {
                    Image(systemName: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
                .foregroundStyle(.primary)
            }
        }
    }
}

#Preview {
    VideoActionsView(
        store: Store(
            initialState: VideoActionsFeature.State(
                host: "peertube.cpy.re",
                videoId: "eRbrxETVKN3gxKKD8bcaHK",
                videoDetails: TubeSDK.VideoDetails(
                    likes: 1234,
                    dislikes: 12,
                    streamingPlaylists: [
                        TubeSDK.VideoStreamingPlaylists(
                            files: [
                                TubeSDK.VideoFile(
                                    resolution: TubeSDK.VideoResolutionConstant(id: 1080, label: "1080p"),
                                    hasAudio: true,
                                    hasVideo: true
                                ),
                                TubeSDK.VideoFile(
                                    resolution: TubeSDK.VideoResolutionConstant(id: 720, label: "720p"),
                                    hasAudio: true,
                                    hasVideo: true
                                )
                            ]
                        )
                    ]
                ),
                selectedQuality: TubeSDK.VideoFile(
                    resolution: TubeSDK.VideoResolutionConstant(id: 1080, label: "1080p"),
                    hasAudio: true,
                    hasVideo: true
                )
            )
        ) {
            VideoActionsFeature()
        }
    )
}
