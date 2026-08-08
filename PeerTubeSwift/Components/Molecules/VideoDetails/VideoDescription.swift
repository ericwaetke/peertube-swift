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

  private func parseDescription(_ text: String) -> AttributedString {
    let options = AttributedString.MarkdownParsingOptions(
      interpretedSyntax: .inlineOnlyPreservingWhitespace)
    var attr = (try? AttributedString(markdown: text, options: options)) ?? AttributedString(text)
    let nsString = String(attr.characters)
    let pattern = "\\b(?:\\d+:)?[0-5]?\\d:[0-5]\\d\\b"

    guard let regex = try? NSRegularExpression(pattern: pattern) else { return attr }

    let matches = regex.matches(in: nsString, range: NSRange(nsString.startIndex..., in: nsString))
    for match in matches.reversed() {
      if let swiftRange = Range(match.range, in: nsString),
        let lower = AttributedString.Index(swiftRange.lowerBound, within: attr),
        let upper = AttributedString.Index(swiftRange.upperBound, within: attr)
      {
        let attrRange = lower..<upper
        let timestamp = String(nsString[swiftRange])
        let parts = timestamp.split(separator: ":").map { Int($0) ?? 0 }
        var seconds = 0
        if parts.count == 3 {
          seconds = parts[0] * 3600 + parts[1] * 60 + parts[2]
        } else if parts.count == 2 {
          seconds = parts[0] * 60 + parts[1]
        }

        attr[attrRange].link = URL(string: "peertube://seek/\(seconds)")
      }
    }

    return attr
  }

  var body: some View {
    if let description = store.state.videoDetails?.description {
      if store.descriptionVisible {
        HStack {
          VStack(alignment: .leading) {
            Text(parseDescription(description))
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

            Button("show less") {
              //                    withAnimation{
              store.send(.showLessButtonTapped)
              //                    }
            }
            .buttonStyle(RiverButtonSmall(type: .tertiary))
          }
          Spacer()
        }
        //          .animation(.default, value: store.state.descriptionVisible)
        .padding(16)
        .background(Color(uiColor: UIColor.systemFill))
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
