import ComposableArchitecture
import Dependencies
import FontKit
import SwiftUI
import TubeSDK

enum VideoCardVariant {
  case large
  case medium
  case small

  var videoCardWidth: CGFloat {
    switch self {
    case .small: .infinity
    case .medium: 300
    case .large: .infinity
    }
  }

  var titleFont: Font {
    switch self {
    case .small, .medium: CustomFont.fjallaOne.swiftUIFont(size: 20, relativeTo: .title3)
    case .large: CustomFont.fjallaOne.swiftUIFont(size: 22, relativeTo: .title2)
    }
  }
}

@Reducer
struct VideoCardFeature {
  @ObservableState
  struct State: Equatable, Identifiable {
    var variant: VideoCardVariant
    var id: String
    var videoUUID: String?
    var videoName: String
    var videoThumbnailUrl: String?
    var videoDuration: Int?
    var videoCurrentTime: Int?
    var videoPublishDate: Date?
    var videoViews: Int?
    var channelDisplayName: String
    var channelAvatarUrl: String?
    var channelId: String?
    var channelDescription: String?
    var instanceDisplayHost: String
    var instanceDisplayAvatarUrl: String?
    var userBadge: UserBadgeFeature.State
    var videoRow: VideoRow?
  }

  enum Action {
    case videoTapped
    case userBadge(UserBadgeFeature.Action)
    case delegate(Delegate)

    enum Delegate: Equatable {
      case videoTapped
      case openChannel
    }
  }

  var body: some ReducerOf<Self> {
    Scope(state: \.userBadge, action: \.userBadge) {
      UserBadgeFeature()
    }
    Reduce { state, action in
      switch action {
      case .videoTapped:
        return .send(.delegate(.videoTapped))
      case .userBadge(.openChannel):
        return .send(.delegate(.openChannel))
      case .userBadge:
        return .none
      case .delegate:
        return .none
      }
    }
  }
}

extension VideoCardFeature.State {
  init(row: VideoRow, variant: VideoCardVariant) {
    self.variant = variant
    self.id = row.video.id.uuidString
    self.videoUUID = row.video.id.uuidString
    self.videoName = row.video.name
    self.videoThumbnailUrl = row.video.thumbnailUrl
    self.videoDuration = row.video.duration
    self.videoCurrentTime = row.video.currentTime
    self.videoPublishDate = row.video.publishDate
    self.videoViews = row.video.views
    self.channelDisplayName = row.channel?.name ?? "unknown"
    self.channelAvatarUrl = row.channel?.avatarUrl
    self.channelId = row.channel.map { "\($0.name)@\(row.instance?.host ?? "")" }
    self.channelDescription = row.channel?.description
    self.instanceDisplayHost = row.instance?.host ?? ""
    self.instanceDisplayAvatarUrl = row.instance?.avatarUrl
    self.userBadge = UserBadgeFeature.State(
      variant: variant == .small ? .small : variant == .medium ? .small : .medium,
      avatarUrl: row.channel?.avatarUrl ?? "",
      channelDisplayName: row.channel?.name ?? "unknown",
      instanceDisplayName: row.instance?.host ?? "",
      instanceIconUrl: row.instance?.avatarUrl ?? ""
    )
    self.videoRow = row
  }

}

struct VideoCardView: View {
  let store: StoreOf<VideoCardFeature>

  @Dependency(\.peertubeOrchestrator) var peertubeOrchestrator
  @Dependency(\.defaultDatabase) var database

  let formatter = RelativeDateTimeFormatter()
  let hourStyle = Duration.TimeFormatStyle(pattern: .hourMinuteSecond(padHourToLength: 1))
  let minuteStyle = Duration.TimeFormatStyle(pattern: .minuteSecond(padMinuteToLength: 1))
  let secondStyle = Duration.TimeFormatStyle(pattern: .minuteSecond(padMinuteToLength: 2))

  var body: some View {
    VStack {
      if let thumbnailUrl = store.videoThumbnailUrl,
        let url = URL(string: thumbnailUrl)
      {
        ZStack(alignment: .topLeading) {
          AsyncImage(url: url) { image in
            image.resizable()
          } placeholder: {
            Color.secondary
          }
          .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
          .aspectRatio(16 / 9, contentMode: .fit)
          .clipShape(.rect(cornerRadius: 8))
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .stroke(.separator, lineWidth: 0.3)
          )
          .task {
            try? await peertubeOrchestrator.cacheImageIfNeeded(thumbnailUrl, database)
          }

          VStack(alignment: .leading) {

            Spacer()

            HStack {
              Spacer()
              if let durationInt = store.videoDuration {
                Text(
                  Duration
                    .seconds(durationInt)
                    .formatted(
                      durationInt > 3_600 ? hourStyle : durationInt > 60 ? minuteStyle : secondStyle
                    )
                )
                .font(
                  CustomFont.inclusiveSansRegular.swiftUIFont(size: 15, relativeTo: .subheadline)
                )
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 4))
                .padding(8)
              }
            }
          }

          if let duration = store.videoDuration,
            let currentTime = store.videoCurrentTime,
            duration > 0, currentTime > 0
          {
            VStack {
              Spacer()
              GeometryReader { geometry in
                Rectangle()
                  .fill(Color.red)
                  .frame(
                    width: geometry.size.width
                      * CGFloat(min(Double(currentTime) / Double(duration), 1.0))
                  )
              }
              .frame(height: 4)
            }
            .clipShape(.rect(cornerRadius: 8))
          }
        }
        .aspectRatio(16 / 9, contentMode: .fit)
      } else {
        Color.secondary
          .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
          .aspectRatio(16 / 9, contentMode: .fit)
          .clipShape(.rect(cornerRadius: 8))
      }

      HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: 4) {
          VStack(alignment: .leading) {
            Text(store.videoName)
              .font(store.state.variant.titleFont)
              .lineLimit(2)

            HStack {
              if let views = store.videoViews {
                Text("^[\(views) View](inflect: true)")
                  .font(.caption)
              }

              Text("·")

              if let publishDate = store.videoPublishDate {
                Text(formatter.localizedString(for: publishDate, relativeTo: Date.now))
                  .font(.caption)
              }
            }
          }

          UserBadge(
            store: store.scope(state: \.userBadge, action: \.userBadge)
          )
          .onTapGesture { store.send(.userBadge(.openChannel)) }
        }
        Spacer()
      }
      .padding(.horizontal, 8)
    }
    .padding(8)
    .frame(width: store.state.variant.videoCardWidth)
    .onTapGesture { store.send(.videoTapped) }
  }
}

#Preview {
  ScrollView {
    VStack {
      VideoCardView(
        store: Store(
          initialState: VideoCardFeature.State(
            variant: .large,
            id: "preview",
            videoUUID: "preview-uuid",
            videoName: "Sample Video",
            videoThumbnailUrl: "https://picsum.photos/400/225",
            videoDuration: 3600,
            videoCurrentTime: nil,
            videoPublishDate: Date().addingTimeInterval(-86400),
            videoViews: 420,
            channelDisplayName: "Test Channel",
            channelAvatarUrl: "https://picsum.photos/40",
            channelId: "test@peertube.example.com",
            channelDescription: nil,
            instanceDisplayHost: "peertube.example.com",
            instanceDisplayAvatarUrl: "https://picsum.photos/40",
            userBadge: UserBadgeFeature.State(
              variant: .medium,
              avatarUrl: "https://picsum.photos/40",
              channelDisplayName: "Test Channel",
              instanceDisplayName: "peertube.example.com",
              instanceIconUrl: "https://picsum.photos/40"
            ),
            videoRow: nil
          ),
          reducer: { VideoCardFeature() }
        )
      )
      VideoCardView(
        store: Store(
          initialState: VideoCardFeature.State(
            variant: .medium,
            id: "preview",
            videoUUID: "preview-uuid",
            videoName: "Sample Video",
            videoThumbnailUrl: "https://picsum.photos/400/225",
            videoDuration: 3600,
            videoCurrentTime: nil,
            videoPublishDate: Date().addingTimeInterval(-86400),
            videoViews: 420,
            channelDisplayName: "Test Channel",
            channelAvatarUrl: "https://picsum.photos/40",
            channelId: "test@peertube.example.com",
            channelDescription: nil,
            instanceDisplayHost: "peertube.example.com",
            instanceDisplayAvatarUrl: "https://picsum.photos/40",
            userBadge: UserBadgeFeature.State(
              variant: .small,
              avatarUrl: "https://picsum.photos/40",
              channelDisplayName: "Test Channel",
              instanceDisplayName: "peertube.example.com",
              instanceIconUrl: "https://picsum.photos/40"
            ),
            videoRow: nil
          ),
          reducer: { VideoCardFeature() }
        )
      )
      VideoCardView(
        store: Store(
          initialState: VideoCardFeature.State(
            variant: .small,
            id: "preview",
            videoUUID: "preview-uuid",
            videoName: "Sample Video",
            videoThumbnailUrl: "https://picsum.photos/400/225",
            videoDuration: 3600,
            videoCurrentTime: nil,
            videoPublishDate: Date().addingTimeInterval(-86400),
            videoViews: 420,
            channelDisplayName: "Test Channel",
            channelAvatarUrl: "https://picsum.photos/40",
            channelId: "test@peertube.example.com",
            channelDescription: nil,
            instanceDisplayHost: "peertube.example.com",
            instanceDisplayAvatarUrl: "https://picsum.photos/40",
            userBadge: UserBadgeFeature.State(
              variant: .small,
              avatarUrl: "https://picsum.photos/40",
              channelDisplayName: "Test Channel",
              instanceDisplayName: "peertube.example.com",
              instanceIconUrl: "https://picsum.photos/40"
            ),
            videoRow: nil
          ),
          reducer: { VideoCardFeature() }
        )
      )
    }
  }
}
