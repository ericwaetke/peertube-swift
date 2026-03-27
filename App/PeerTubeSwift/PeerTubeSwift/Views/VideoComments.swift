import ComposableArchitecture
import SwiftUI
import TubeSDK

@Reducer
struct VideoCommentsFeature {
    @ObservableState
    struct State: Equatable {
        let videoId: String
        @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(scheme: "https", host: "peertube.wtf")
        
        var commentsVisible = false
        var comments: [TubeSDK.VideoComment] = []
        var videoDetails: TubeSDK.VideoDetails?
        
        var instanceAvatars: [String: String] = [:]
    }

    enum Action {
        case commentsVisibleChanged(Bool)
        case loadComments
        case commentsLoaded([TubeSDK.VideoComment])
        case instanceAvatarLoaded(host: String, avatarUrl: String?)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .commentsVisibleChanged:
                state.commentsVisible.toggle()
                return .none
            case .loadComments:
                return .run { [client = state.client, videoId = state.videoId] send in
                    if let commentsResponse = try? await client.getCommentThreads(videoID: videoId) {
                        await send(.commentsLoaded(commentsResponse.data ?? []))
                    }
                }
            case .commentsLoaded(let comments):
                state.comments = comments
                let uniqueHosts = Set(comments.compactMap { $0.account?.host })
                return .run { send in
                    @Dependency(\.defaultDatabase) var database
                    @Dependency(\.peertubeOrchestrator) var peertubeOrchestrator
                    for host in uniqueHosts {
                        if let instance = try? await peertubeOrchestrator.syncInstanceInfo(host, database) {
                            await send(.instanceAvatarLoaded(host: host, avatarUrl: instance.avatarUrl))
                        }
                    }
                }
            case .instanceAvatarLoaded(let host, let avatarUrl):
                if let avatarUrl = avatarUrl {
                    state.instanceAvatars[host] = avatarUrl
                }
                return .none
            }
        }
    }
}

struct VideoCommentsView: View {
    @Bindable var store: StoreOf<VideoCommentsFeature>

    var body: some View {
        if let commentCount = store.state.videoDetails?.comments {
            DisclosureGroup(
                isExpanded: $store.commentsVisible.sending(\.commentsVisibleChanged)
            ) {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(store.state.comments) { comment in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .top) {
                                if let avatars = comment.account?.avatars,
                                   let avatar = avatars.first(where: { $0.width == 48 }) ?? avatars.first,
                                   let avatarPath = avatar.path,
                                   let url = try? store.state.client.getImageUrl(path: avatarPath) {
                                    AsyncImage(url: url) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: {
                                        Color.gray.opacity(0.3)
                                    }
                                    .frame(width: 42, height: 42)
                                    .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 42, height: 42)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Text(comment.account?.displayName ?? comment.account?.name ?? "Unknown")
                                            .fontWeight(.semibold)
                                            .font(.subheadline)
                                        
                                        Spacer()
                                        
                                        if let createdAt = comment.createdAt {
                                            Text(createdAt, style: .date)
                                                .font(.caption)
                                                .opacity(0.6)
                                        }
                                    }
                                    if let host = comment.account?.host {
                                        InstanceIndicator(instanceName: host, instanceImage: store.state.instanceAvatars[host])
                                    }
                                    if let text = comment.text {
                                        let cleanText = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                                        Text(cleanText)
                                            .font(.body)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                        
                        if comment.id != store.state.comments.last?.id {
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
}

#Preview {
    VideoCommentsView(
        store: Store(
            initialState: VideoCommentsFeature.State(
                videoId: "eRbrxETVKN3gxKKD8bcaHK",
                comments: [
                    TubeSDK.VideoComment(
                        id: 1,
                        text: "This is a great video! Thanks for sharing.",
                        createdAt: Date(),
                        account: TubeSDK.Account(
                            id: 1,
                            name: "reviewer",
                            host: "peertube.wtf",
                            displayName: "Reviewer 123"
                        )
                    ),
                    TubeSDK.VideoComment(
                        id: 2,
                        text: "I really enjoyed the part where you explained the Composable Architecture.",
                        createdAt: Date(),
                        account: TubeSDK.Account(
                            id: 2,
                            name: "swiftfan",
                            host: "my-sunshine.video",
                            displayName: "Swift Fan"
                        )
                    )
                ],
                videoDetails: TubeSDK.VideoDetails(
                    comments: 2
                )
            )
        ) {
            VideoCommentsFeature()
        }
    )
}
