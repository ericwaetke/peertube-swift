import ComposableArchitecture
import SQLiteData
import SwiftUI

@Reducer
struct WatchHistoryFeature {
  @ObservableState
  struct State: Equatable {
    var cards: IdentifiedArrayOf<VideoCardFeature.State> = []
  }

  enum Action {
    case onTask
    case cards(IdentifiedActionOf<VideoCardFeature>)
    case delegate(Delegate)
    enum Delegate: Equatable {
      case videoTapped(row: VideoRow)
      case channelTapped(row: VideoRow)
    }
    case watchHistoryResponse([VideoRow])
  }

  @Dependency(\.defaultDatabase) var database

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onTask:
        return .run { send in
          if let rows = try? await self.loadWatchHistoryFromDB() {
            await send(.watchHistoryResponse(rows))
          }
        }
      case .watchHistoryResponse(let rows):
        state.cards = IdentifiedArray(
          uncheckedUniqueElements: rows.map {
            VideoCardFeature.State.init(row: $0, variant: .medium)
          }
        )
        return .none
      case .cards(.element(id: let id, action: .delegate(.videoTapped))):
        guard let card = state.cards[id: id], let row = card.videoRow else { return .none }
        return .send(.delegate(.videoTapped(row: row)))
      case .cards(.element(id: let id, action: .delegate(.openChannel))):
        guard let card = state.cards[id: id], let row = card.videoRow else { return .none }
        return .send(.delegate(.channelTapped(row: row)))
      case .cards, .delegate:
        return .none
      }
    }
    .forEach(\.cards, action: \.cards) {
      VideoCardFeature()
    }
  }

  private func loadWatchHistoryFromDB() async throws -> [VideoRow] {
    try await database.read { db in
      let allVideos =
        Video
        .order { $0.publishDate.desc() }
        .leftJoin(VideoChannel.all) { $0.channelID.eq($1.id) }
        .leftJoin(Instance.all) { $0.instanceID.eq($2.host) }

      let rows =
        try allVideos
        .select { VideoRow.Columns(video: $0, channel: $1, instance: $2) }
        .fetchAll(db)

      return rows.filter { row in
        guard let currentTime = row.video.currentTime else {
          return false
        }
        return currentTime > 0
      }
    }
  }
}

struct WatchHistory: View {
  @Bindable var store: StoreOf<WatchHistoryFeature>

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      LazyHStack(alignment: .top, spacing: 12) {
        ForEach(store.scope(state: \.cards, action: \.cards)) { cardStore in
          VideoCardView(store: cardStore)
            .frame(width: 280)
        }
      }
      .scrollTargetLayout()
      .padding(.vertical, 8)
    }
    .scrollTargetBehavior(.viewAligned)
    .safeAreaPadding(.horizontal, 16)
    .task {
      store.send(.onTask)
    }
  }
}
