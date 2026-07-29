import ComposableArchitecture
import SQLiteData
import SwiftUI

@Reducer
struct ContinueWatchingFeature {
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
        case continueWatchingResponse([VideoRow])
    }

    @Dependency(\.defaultDatabase) var database

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onTask:
                return .run { send in
                    if let rows = try? await self.loadContinueWatchingFromDB() {
                        await send(.continueWatchingResponse(rows))
                    }
                }
            case .continueWatchingResponse(let rows):
                state.cards = IdentifiedArray(
                    uncheckedUniqueElements: rows.map(VideoCardFeature.State.init(row:)))
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

    private func loadContinueWatchingFromDB() async throws -> [VideoRow] {
        try await database.read { db in
            let allVideos = Video
                .order { $0.publishDate.desc() }
                .leftJoin(VideoChannel.all) { $0.channelID.eq($1.id) }
                .leftJoin(Instance.all) { $0.instanceID.eq($2.host) }

            let rows = try allVideos
                .select { VideoRow.Columns(video: $0, channel: $1, instance: $2) }
                .fetchAll(db)

            return rows.filter { row in
                guard let currentTime = row.video.currentTime,
                    let duration = row.video.duration,
                    duration > 0
                else {
                    return false
                }
                let remaining = duration - currentTime
                return currentTime > 60 && remaining > 180
            }
        }
    }
}

struct ContinueWatching: View {
    @Bindable var store: StoreOf<ContinueWatchingFeature>

    var body: some View {
        DisclosureGroup("Continue Watching") {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 12) {
                    ForEach(store.scope(state: \.cards, action: \.cards)) { cardStore in
                        VideoCardView(store: cardStore)
                            .frame(width: 280)
                    }
                }
                .scrollTargetLayout()
//                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .scrollTargetBehavior(.viewAligned)
            .safeAreaPadding(.horizontal, 16)
        }
        .disclosureGroupStyle(InnerSectionDisclosureGroup())
        .task {
            store.send(.onTask)
        }
    }
}

#Preview {
    let _ = prepareDependencies {
        try! $0.bootstrapDatabase()
        try! $0.defaultDatabase.seed()
        try! $0.defaultDatabase.write { db in
            _ = try Video.upsert {
                Video(
                    id: UUID(2),
                    channelID: "peertube.wtf-1",
                    instanceID: "peertube.wtf",
                    name: "Minecraft Let's Play #002",
                    publishDate: .now,
                    duration: 600,
                    currentTime: 120,
                    views: 142,
                    thumbnailUrl: "https://i.ytimg.com/vi/DM52HxaLK-Y/hqdefault.jpg"
                )
                Video(
                    id: UUID(20),
                    channelID: "peertube.wtf-1",
                    instanceID: "peertube.wtf",
                    name: "Minecraft Let's Play #003",
                    publishDate: .now,
                    duration: 600,
                    currentTime: 120,
                    views: 142,
                    thumbnailUrl: "https://i.ytimg.com/vi/DM52HxaLK-Y/hqdefault.jpg"
                )
                Video(
                    id: UUID(21),
                    channelID: "peertube.wtf-1",
                    instanceID: "peertube.wtf",
                    name: "Minecraft Let's Play #004 Jetzt geht es aber richtig ab, ich sag es euch!!!",
                    publishDate: .now,
                    duration: 600,
                    currentTime: 120,
                    views: 142,
                    thumbnailUrl: "https://i.ytimg.com/vi/DM52HxaLK-Y/hqdefault.jpg"
                )
            }
            .returning(\.self)
            .fetchOne(db)
        }
    }

    ContinueWatching(store: Store(initialState: ContinueWatchingFeature.State()) {
        ContinueWatchingFeature()
    })
}
