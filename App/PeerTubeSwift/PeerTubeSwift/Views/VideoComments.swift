import ComposableArchitecture
import PostHog
import SwiftUI
import TubeSDK

@Reducer
struct VideoCommentsFeature {
    @ObservableState
    struct State: Equatable {
        let videoId: String
        @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(scheme: "https", host: "peertube.wtf")

        var commentsVisible = false
        var comments: [TubeSDK.VideoCommentThreadTree] = []
        var videoDetails: TubeSDK.VideoDetails?

        var instanceAvatars: [String: String] = [:]
        var collapsedCommentIds: Set<Int> = []

        @Presents var composeSheet: CommentComposeFeature.State?
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case commentsVisibleChanged(Bool)
        case loadComments
        case commentsLoaded([TubeSDK.VideoCommentThreadTree])
        case instanceAvatarLoaded(host: String, avatarUrl: String?)
        case addCommentTapped
        case replyTapped(comment: TubeSDK.VideoComment)
        case toggleThreadCollapsed(commentId: Int)
        case composeSheet(PresentationAction<CommentComposeFeature.Action>)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .commentsVisibleChanged:
                state.commentsVisible.toggle()
                if state.commentsVisible {
                    PostHogSDK.shared.capture("comments_viewed", properties: ["video_id": state.videoId])
                }
                return .none

            case .loadComments:
                return .run { [client = state.client, videoId = state.videoId] send in
                    if let commentsResponse = try? await client.getCommentThreads(videoID: videoId),
                       let data = commentsResponse.data
                    {
                        // Fetch the full tree for each thread
                        var trees: [VideoCommentThreadTree] = []
                        for comment in data {
                            if let threadId = comment.threadId,
                               let tree = try? await client.getCommentThread(videoID: videoId, threadId: threadId)
                            {
                                trees.append(tree)
                            }
                        }
                        await send(.commentsLoaded(trees))
                    }
                }

            case let .commentsLoaded(trees):
                state.comments = trees

                // Collect unique hosts to fetch avatars
                var uniqueHosts = Set<String>()
                func traverse(_ tree: VideoCommentThreadTree) {
                    if let host = tree.comment?.account?.host { uniqueHosts.insert(host) }
                    tree.children?.forEach(traverse)
                }
                trees.forEach(traverse)

                // Convert to array to avoid capturing mutable Set in async context
                let hosts = Array(uniqueHosts)

                return .run { send in
                    @Dependency(\.defaultDatabase) var database
                    @Dependency(\.peertubeOrchestrator) var peertubeOrchestrator

                    await withTaskGroup(of: (String, String?).self) { group in
                        for host in hosts {
                            group.addTask { @Sendable in
                                if let instance = try? await peertubeOrchestrator.syncInstanceInfo(host, database) {
                                    return (host, instance.avatarUrl)
                                }
                                return (host, nil)
                            }
                        }

                        for await (host, avatarUrl) in group {
                            if let avatarUrl = avatarUrl {
                                await send(.instanceAvatarLoaded(host: host, avatarUrl: avatarUrl))
                            }
                        }
                    }
                }

            case let .instanceAvatarLoaded(host, avatarUrl):
                if let avatarUrl = avatarUrl {
                    state.instanceAvatars[host] = avatarUrl
                }
                return .none

            case .addCommentTapped:
                PostHogSDK.shared.capture("comment_compose_started", properties: ["video_id": state.videoId, "type": "top_level"])
                state.composeSheet = CommentComposeFeature.State(
                    videoId: state.videoId,
                    targetCommentId: nil,
                    targetUsername: nil
                )
                return .none

            case let .toggleThreadCollapsed(id):
                let willCollapse = !state.collapsedCommentIds.contains(id)
                PostHogSDK.shared.capture("comment_thread_toggled", properties: ["video_id": state.videoId, "comment_id": id, "action": willCollapse ? "collapsed" : "expanded"])
                if willCollapse {
                    state.collapsedCommentIds.insert(id)
                } else {
                    state.collapsedCommentIds.remove(id)
                }
                return .none

            case let .replyTapped(comment):
                if let id = comment.id {
                    PostHogSDK.shared.capture("comment_compose_started", properties: ["video_id": state.videoId, "type": "reply", "parent_comment_id": id])
                    let username = comment.account?.displayName ?? comment.account?.name ?? "Unknown"
                    state.composeSheet = CommentComposeFeature.State(
                        videoId: state.videoId,
                        targetCommentId: id,
                        targetUsername: username
                    )
                }
                return .none

            case .composeSheet(.presented(.postResponse(.success))):
                // Reload comments after successful post
                return .send(.loadComments)

            case .composeSheet:
                return .none
            }
        }
        .ifLet(\.$composeSheet, action: \.composeSheet) {
            CommentComposeFeature()
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
                    if store.state.client.currentToken != nil {
                        Button {
                            store.send(.addCommentTapped)
                        } label: {
                            HStack {
                                Image(systemName: "plus.bubble")
                                Text("Add a comment...")
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(.primary)
                        }
                        .padding(.top, 8)
                    }

                    ForEach(store.state.comments, id: \.comment?.id) { tree in
                        CommentTreeView(store: store, tree: tree, level: 0)

                        if tree.comment?.id != store.state.comments.last?.comment?.id {
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
            .sheet(item: $store.scope(state: \.composeSheet, action: \.composeSheet)) { composeStore in
                CommentComposeView(store: composeStore)
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

struct CommentTreeView: View {
    let store: StoreOf<VideoCommentsFeature>
    let tree: VideoCommentThreadTree
    let level: Int

    var body: some View {
        if let comment = tree.comment {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    let avatar = comment.account?.avatars?.first(where: { $0.width == 48 }) ?? comment.account?.avatars?.first
                    let urlStr = avatar?.path.flatMap { try? store.state.client.getImageUrl(path: $0).absoluteString }
                    AvatarView(
                        url: urlStr,
                        name: comment.account?.displayName ?? comment.account?.name ?? "Unknown",
                        size: 42
                    )

                    VStack(alignment: .leading, spacing: 4) {
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

                        HStack(spacing: 16) {
                            if store.state.client.currentToken != nil {
                                Button {
                                    store.send(.replyTapped(comment: comment))
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrowshape.turn.up.left")
                                        Text("Reply")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.accentColor)
                                }
                            }

                            if let children = tree.children, !children.isEmpty, let id = comment.id {
                                let isCollapsed = store.state.collapsedCommentIds.contains(id)
                                Button {
                                    store.send(.toggleThreadCollapsed(commentId: id))
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: isCollapsed ? "chevron.down" : "chevron.up")
                                        let replyCount = comment.totalReplies ?? children.count
                                        Text(isCollapsed ? "Show ^[\(replyCount) reply](inflect: true)" : "Hide replies")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.top, 2)
                    }
                }
            }
            .padding(.vertical, 4)
            .padding(.leading, CGFloat(level * 32))

            if let children = tree.children, let id = comment.id, !store.state.collapsedCommentIds.contains(id) {
                ForEach(children, id: \.comment?.id) { childTree in
                    CommentTreeView(store: store, tree: childTree, level: level + 1)
                }
            }
        }
    }
}

// Ensure Equatable for Hashable/Identifiable if needed by SwiftUI
extension VideoCommentThreadTree: Equatable {
    public static func == (lhs: VideoCommentThreadTree, rhs: VideoCommentThreadTree) -> Bool {
        lhs.comment?.id == rhs.comment?.id && lhs.children == rhs.children
    }
}

#Preview {
    VideoCommentsView(
        store: Store(
            initialState: VideoCommentsFeature.State(
                videoId: "eRbrxETVKN3gxKKD8bcaHK",
                comments: [
                    TubeSDK.VideoCommentThreadTree(
                        comment: TubeSDK.VideoComment(
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
                        children: [
                            TubeSDK.VideoCommentThreadTree(
                                comment: TubeSDK.VideoComment(
                                    id: 2,
                                    text: "I agree completely!",
                                    createdAt: Date(),
                                    account: TubeSDK.Account(
                                        id: 2,
                                        name: "swiftfan",
                                        host: "my-sunshine.video",
                                        displayName: "Swift Fan"
                                    )
                                ),
                                children: []
                            ),
                        ]
                    ),
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
