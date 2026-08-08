import ComposableArchitecture
import FontKit
import SwiftUI
import TubeSDK

@Reducer
struct VideoCommentsFeature {
  @ObservableState
  struct State: Equatable {
    let videoId: String
    @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(
      scheme: "https", host: "peertube.wtf")

    var commentsVisible = true
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

      case .commentsLoaded(let trees):
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

      case .instanceAvatarLoaded(let host, let avatarUrl):
        if let avatarUrl = avatarUrl {
          state.instanceAvatars[host] = avatarUrl
        }
        return .none

      case .addCommentTapped:
        state.composeSheet = CommentComposeFeature.State(
          videoId: state.videoId,
          targetCommentId: nil,
          targetUsername: nil
        )
        return .none

      case .toggleThreadCollapsed(let id):
        let willCollapse = !state.collapsedCommentIds.contains(id)
        if willCollapse {
          state.collapsedCommentIds.insert(id)
        } else {
          state.collapsedCommentIds.remove(id)
        }
        return .none

      case .replyTapped(let comment):
        if let id = comment.id {
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

    DisclosureGroup(
      "Comments",
      isExpanded: $store.commentsVisible.sending(\.commentsVisibleChanged)
    ) {
      VStack(alignment: .leading, spacing: 16) {
        if store.state.client.currentToken != nil {
          Button {
            store.send(.addCommentTapped)
          } label: {
            HStack {
              Text("Write a comment …")
              Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .frame(height: 51)
            .background(Color(uiColor: .secondarySystemFill))
            .clipShape(.capsule)
            .foregroundColor(Color(uiColor: .tertiaryLabel))
          }
          .padding(.top, 8)
        }

        ForEach(Array(store.state.comments.enumerated()), id: \.element.comment?.id) {
          index, tree in
          CommentTreeView(
            store: store,
            tree: tree,
            level: 0,
            isLastSibling: false,
            isLastInThread: false
          )

        }
      }
      .padding(.bottom, 8)
      .padding(.horizontal, 16)
    }
    .disclosureGroupStyle(InnerSectionDisclosureGroup())
    .sheet(item: $store.scope(state: \.composeSheet, action: \.composeSheet)) { composeStore in
      CommentComposeView(store: composeStore)
        .presentationDetents([.medium, .large])
    }

  }
}

struct CommentTreeView: View {
  let store: StoreOf<VideoCommentsFeature>
  let tree: VideoCommentThreadTree
  let level: Int
  let isLastSibling: Bool
  let isLastInThread: Bool

  private var avatarSize: CGFloat {
    level == 0 ? UserBadgeVariant.medium.avatarSize : UserBadgeVariant.small.avatarSize
  }
  let lineSpacing: CGFloat = 13
  let bigColumnWidth: CGFloat = 31
  let smallColumnWidth: CGFloat = 22
  let lineIndentBigColumn: CGFloat = 19
  let arcRadius: CGFloat = 6
  let arcLineSpacing: CGFloat = 4

  @ViewBuilder
  private var commentHeader: some View {
    if let comment = tree.comment {
      HStack(alignment: .top) {
        let avatar =
          comment.account?.avatars?.first(where: { $0.width == 48 })
          ?? comment.account?.avatars?.first
        let urlStr = avatar?.path.flatMap {
          try? store.state.client.getImageUrl(path: $0).absoluteString
        }
        if let host = comment.account?.host {
          UserBadge(
            store: Store(
              initialState: UserBadgeFeature.State(
                variant: level == 0 ? .medium : .small,
                avatarUrl: urlStr,
                channelDisplayName: comment.account?.displayName ?? comment.account?.name
                  ?? "Unknown",
                instanceDisplayName: host,
                instanceIconUrl: store.state.instanceAvatars[host]
              ),
              reducer: {
                UserBadgeFeature()
              }))
        }
        Spacer()

        if let createdAt = comment.createdAt {
          Text(createdAt, style: .date)
            .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 13, relativeTo: .footnote))
            .foregroundStyle(Color("Label/Secondary"))
            .opacity(0.6)
        }
      }
    }
  }

  var body: some View {
    if let comment = tree.comment {
      let lineColor = Color.secondary.opacity(0.3)
      let lineWidth: CGFloat = 1
      let hasChildren = tree.children?.isEmpty == false

      VStack(alignment: .leading, spacing: 0) {
        HStack(spacing: lineSpacing) {
          if level > 1 {
            Spacer()
              .frame(width: smallColumnWidth)
          }
          if level > 0 {
            Spacer()
              .frame(width: bigColumnWidth)
          }

          VStack(alignment: .leading, spacing: 4) {
            commentHeader
            VStack(alignment: .leading, spacing: 4) {
              if let text = comment.text {
                let cleanText = text.replacingOccurrences(
                  of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                Text(cleanText)
                  .font(.body)
              }

              // Actions
              VStack {
                HStack(spacing: 4) {
                  if store.state.client.currentToken != nil {
                    Button {
                      store.send(.replyTapped(comment: comment))
                    } label: {
                      Image(systemName: "text.bubble")
                    }
                    .accessibilityLabel("Write a reply")
                    .buttonStyle(RiverButtonSmall(type: .tertiary))
                  }

                  // TODO: Open Comment Menu
                  Menu {
                    Button(role: .destructive) {

                    } label: {
                      Label("Report this comment", systemImage: "exclamationmark.triangle")
                    }
                    if let displayName: String = comment.account?.displayName {
                      Button {

                      } label: {
                        Text("Mute account \(displayName.quoted())")
                      }
                    }

                    if let host = comment.account?.host {
                      let host = "@\(host)"
                      Button {

                      } label: {
                        Text("Mute community \(host.quoted())")
                      }
                    }

                  } label: {
                    Image(systemName: "ellipsis")
                  }
                  .accessibilityLabel("Write a reply")
                  .buttonStyle(RiverButtonSmall(type: .tertiary))

                }

                //                        if let children = tree.children, !children.isEmpty, let id = comment.id {
                //                          let isCollapsed = store.state.collapsedCommentIds.contains(id)
                //                          Button {
                //                            store.send(.toggleThreadCollapsed(commentId: id))
                //                          } label: {
                //                            HStack(spacing: 4) {
                //                              Image(systemName: isCollapsed ? "chevron.down" : "chevron.up")
                //                              let replyCount = comment.totalReplies ?? children.count
                //                              Text(
                //                                isCollapsed ? "Show ^[\(replyCount) reply](inflect: true)" : "Hide replies")
                //                            }
                //                            .font(.caption)
                //                            .foregroundColor(.secondary)
                //                          }
                //                        }
              }
              .padding(.top, 2)
            }
            .padding(.leading, avatarSize + 8)
            .padding(.bottom, 8)
            .overlay(alignment: .leading) {
              if hasChildren && level < 2 {
                CommentThreadLine()
                  .stroke(lineColor, lineWidth: lineWidth)
                  .frame(width: avatarSize)
                  .offset(x: avatarSize / 2)
              }
            }
          }
        }
        .overlay(alignment: .topLeading) {
          if level > 0 {
            if !isLastSibling || !isLastInThread {
              CommentThreadLine()
                .stroke(lineColor, lineWidth: lineWidth)
                .frame(width: bigColumnWidth)
                .offset(x: lineIndentBigColumn, y: level == 1 ? arcRadius * 2 + arcLineSpacing : 0)
            }
            if isLastSibling && (level > 1 && hasChildren) {
              CommentThreadLine()
                .stroke(lineColor, lineWidth: lineWidth)
                .frame(width: bigColumnWidth)
                .offset(
                  x: lineIndentBigColumn + lineSpacing + smallColumnWidth,
                  y: arcRadius * 2 + arcLineSpacing)
            }
            CommentThreadArc(
              lineIndentBogColumn: lineIndentBigColumn,
              arcRadius: arcRadius
            )
            .stroke(lineColor, lineWidth: lineWidth)
            .frame(width: bigColumnWidth)
            .offset(x: level > 1 ? bigColumnWidth + arcLineSpacing : 0)
          }
        }
        .clipped()

        if let children = tree.children, let id = comment.id,
          !store.state.collapsedCommentIds.contains(id)
        {
          ForEach(Array(children.enumerated()), id: \.element.comment?.id) { index, childTree in
            CommentTreeView(
              store: store,
              tree: childTree,
              level: level + 1,
              isLastSibling: index == children.count - 1,
              isLastInThread: level == 0 ? (index == children.count - 1) : isLastInThread
            )
            //            .overlay(alignment: .top) {
            //                Text("Last in Thread: \(isLastInThread.description); \(index == children.count - 1), index: \(index), childrencount: \(children.count - 1)")
            //                    .frame()
            //                    .background(.white)
            //            }
          }
        }
      }
    }
  }
}

struct CommentThreadLine: Shape {
  func path(in rect: CGRect) -> Path {
    var p = Path()

    p.move(to: CGPoint(x: 0, y: 0))

    p.addLine(to: CGPoint(x: 0, y: rect.height))

    return p
  }
}

struct CommentThreadArc: Shape {
  let lineIndentBogColumn: CGFloat
  let arcRadius: CGFloat

  func path(in rect: CGRect) -> Path {
    var p = Path()

    p.move(to: CGPoint(x: lineIndentBogColumn, y: 0))

    p.addLine(to: CGPoint(x: lineIndentBogColumn, y: 0 + arcRadius / 2))

    p.addArc(
      center: CGPoint(x: lineIndentBogColumn + arcRadius, y: arcRadius),
      radius: arcRadius,
      startAngle: .degrees(180),
      endAngle: .degrees(90),
      clockwise: true
    )

    p.addLine(to: CGPoint(x: lineIndentBogColumn + arcRadius * 2, y: arcRadius * 2))

    return p
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
              TubeSDK.VideoCommentThreadTree(
                comment: TubeSDK.VideoComment(
                  id: 3,
                  text: "I don’t agree at all!",
                  createdAt: Date(),
                  account: TubeSDK.Account(
                    id: 3,
                    name: "swifthater",
                    host: "my-sunshine.video",
                    displayName: "Swift Hater"
                  )
                ),
                children: [
                  TubeSDK.VideoCommentThreadTree(
                    comment: TubeSDK.VideoComment(
                      id: 4,
                      text: "well why not?",
                      createdAt: Date(),
                      account: TubeSDK.Account(
                        id: 2,
                        name: "swiftfan",
                        host: "my-sunshine.video",
                        displayName: "Swift Fan"
                      )
                    ),
                    children: [
                      TubeSDK.VideoCommentThreadTree(
                        comment: TubeSDK.VideoComment(
                          id: 7,
                          text: "I just dont, deal with it!",
                          createdAt: Date(),
                          account: TubeSDK.Account(
                            id: 3,
                            name: "swifthater",
                            host: "my-sunshine.video",
                            displayName: "Swift hater"
                          )
                        ),
                        children: []
                      )
                    ]
                  )
                ]
              ),
              TubeSDK.VideoCommentThreadTree(
                comment: TubeSDK.VideoComment(
                  id: 6,
                  text: "Have you seen what happened in minute 5?",
                  createdAt: Date(),
                  account: TubeSDK.Account(
                    id: 2,
                    name: "swiftfan",
                    host: "my-sunshine.video",
                    displayName: "Swift Fan"
                  )
                ),
                children: [
                  TubeSDK.VideoCommentThreadTree(
                    comment: TubeSDK.VideoComment(
                      id: 8,
                      text: "This is a great video! Thanks for sharing.",
                      createdAt: Date(),
                      account: TubeSDK.Account(
                        id: 1,
                        name: "reviewer",
                        host: "peertube.wtf",
                        displayName: "Reviewer 123"
                      )
                    ),
                    children: []
                  )
                ]
              ),
            ]
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
