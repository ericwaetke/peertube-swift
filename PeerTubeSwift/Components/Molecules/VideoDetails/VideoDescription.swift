import ComposableArchitecture
import SwiftUI
import TubeSDK

@Reducer
struct VideoDescriptionFeature {
  @ObservableState
  struct State: Equatable {
    var descriptionVisible = false
    var videoDetails: TubeSDK.VideoDetails?
  }

  enum Action {
    case showLessButtonTapped
    case descriptionVisibleChanged(Bool)
    case delegate(Delegate)

    enum Delegate {
      case seekTo(Int)
    }
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .descriptionVisibleChanged(let visible):
        withAnimation {
          state.descriptionVisible = visible
        }
        return .none
      case .showLessButtonTapped:
        return .send(.descriptionVisibleChanged(false))
      case .delegate:
        return .none
      }
    }
  }
}

struct VideoDescriptionView: View {
  @Bindable var store: StoreOf<VideoDescriptionFeature>

  var body: some View {
    if let description = store.state.videoDetails?.description {
      if store.descriptionVisible {
        HStack {
          VStack(alignment: .leading) {
            Text(RichTextRenderer.render(description))
              .environment(
                \.openURL,
                OpenURLAction { url in
                  if url.scheme == "peertube", url.host == "seek",
                    let seconds = Int(url.pathComponents.last ?? "")
                  {
                    store.send(.delegate(.seekTo(seconds)))
                    return .handled
                  }
                  return .systemAction
                }
              )
              .font(.subheadline)
              .multilineTextAlignment(.leading)
              .transition(.blurReplace)
            Button("show less") {
              store.send(.showLessButtonTapped)
            }
            .buttonStyle(RiverButtonSmall(type: .tertiary))
          }
          Spacer()
        }
        .padding(16)
        .background(
          Color(uiColor: UIColor.systemFill)
            .transition(.move(edge: .top))
        )
        .overlay(alignment: .top) {
          // Top inset shadow
          LinearGradient(
            gradient: Gradient(stops: [
              .init(color: .black.opacity(0.10), location: 0),
              .init(color: .clear, location: 1),
            ]),
            startPoint: .top,
            endPoint: .bottom
          )
          .frame(height: 10)
          .allowsHitTesting(false)
        }
        .overlay(alignment: .bottom) {
          // Bottom inset shadow
          LinearGradient(
            gradient: Gradient(stops: [
              .init(color: .clear, location: 0),
              .init(color: .black.opacity(0.10), location: 1),
            ]),
            startPoint: .top,
            endPoint: .bottom
          )
          .frame(height: 10)
          .allowsHitTesting(false)
        }
      }
    }
  }
}

#Preview {
  VideoDescriptionView(
    store: Store(
      initialState: VideoDescriptionFeature.State(
        descriptionVisible: true,
        videoDetails: TubeSDK.VideoDetails(
          description: """
            Here is a mocked description for the preview!

            You can jump to 1:23 or 2:45 to see cool parts of the video.
            """,
        )
      )
    ) {
      VideoDescriptionFeature()
    }
  )
}
