import ComposableArchitecture
import PostHog
import SwiftUI
import TubeSDK

@Reducer
struct CommentComposeFeature {
    @ObservableState
    struct State: Equatable {
        let videoId: String
        let targetCommentId: Int?
        let targetUsername: String?
        var draftText: String = ""
        var isSubmitting: Bool = false
        @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(scheme: "https", host: "peertube.wtf")
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case cancelTapped
        case postTapped
        case postResponse(Result<TubeSDK.VideoComment, Error>)
    }

    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .cancelTapped:
                return .run { _ in await self.dismiss() }
            case .postTapped:
                state.isSubmitting = true
                return .run { [client = state.client, videoId = state.videoId, commentId = state.targetCommentId, text = state.draftText] send in
                    do {
                        let comment: TubeSDK.VideoComment
                        if let commentId = commentId {
                            comment = try await client.replyToVideoComment(videoID: videoId, commentID: commentId, text: text)
                        } else {
                            comment = try await client.postVideoComment(videoID: videoId, text: text)
                        }
                        await send(.postResponse(.success(comment)))
                    } catch {
                        await send(.postResponse(.failure(error)))
                    }
                }
            case .postResponse(.success):
                state.isSubmitting = false
                PostHogSDK.shared.capture("comment_posted", properties: ["video_id": state.videoId, "type": state.targetCommentId == nil ? "top_level" : "reply"])
                return .run { _ in await self.dismiss() }
            case .postResponse(.failure):
                state.isSubmitting = false
                // Handle error (e.g., show alert)
                return .none
            }
        }
    }
}

struct CommentComposeView: View {
    @Bindable var store: StoreOf<CommentComposeFeature>

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextEditor(text: $store.draftText)
                        .frame(minHeight: 150)
                } header: {
                    if let username = store.targetUsername {
                        Text("Replying to @\(username)")
                    } else {
                        Text("Add a comment")
                    }
                }
            }
            .navigationTitle(store.targetCommentId != nil ? "Reply" : "New Comment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        store.send(.cancelTapped)
                    }
                    .disabled(store.isSubmitting)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        store.send(.postTapped)
                    }
                    .disabled(store.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || store.isSubmitting)
                }
            }
            .overlay {
                if store.isSubmitting {
                    ProgressView()
                }
            }
        }
    }
}
