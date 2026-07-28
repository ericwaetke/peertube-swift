//
//  Subscriptions.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 23.12.25.
//

import ComposableArchitecture
import SQLiteData
import SwiftUI
import TubeSDK

@Selection
struct SubRecord: Equatable {
  let subscription: PeertubeSubscription
  let channel: VideoChannel?
}

extension SubRecord: Identifiable {
  var id: String {
    subscription.id
  }
}

enum RecommendationCategory: String, CaseIterable {
  case tech = "Technology"
  case photography = "Photography"
  case politics = "Politics"
}

struct Recommendation: Equatable, Hashable, Identifiable {
  let id: UUID = .init()
  let username: String
  let displayName: String
  let avatarUrl: URL
  let category: RecommendationCategory

  var isSubscribed = false
}

@Reducer
struct SubscriptionFeature {
  @ObservableState
  struct State: Equatable {
    @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(
      scheme: "https", host: "peertube.wtf")

    @FetchAll(
      PeertubeSubscription
        .group(by: \.id)
        .leftJoin(VideoChannel.all) { $0.channelID.eq($1.id) }
        .order(by: \.createdAt)
        .select {
          SubRecord.Columns(
            subscription: $0,
            channel: $1
          )
        },
      animation: .default
    )
    var records: [SubRecord]

    var recommendationsFeature: ChannelRecommendationsFeature.State = .init()
  }

  enum Action {
    case findChannelsButtonTapped
    case listElementDeleteSwiped(offsets: IndexSet)

    case recommendationsFeature(ChannelRecommendationsFeature.Action)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .findChannelsButtonTapped:
        return .none
      case .listElementDeleteSwiped(let offsets):
        return .run { [client = state.client, subscriptions = state.records] _ in
          withErrorReporting {
            try database.write { db in
              try PeertubeSubscription.find(offsets.map { subscriptions[$0].id })
                .delete()
                .execute(db)
            }
          }
          if client.currentToken != nil {
            for index in offsets {
              let channelId = subscriptions[index].subscription.channelID
              try? await client.removeSubscription(channelUri: channelId)
            }
          }
        }
      case .recommendationsFeature(_):
        return .none
      }
    }
    Scope(state: \.recommendationsFeature, action: \.recommendationsFeature) {
      ChannelRecommendationsFeature()
    }
  }

  @Dependency(\.defaultDatabase) var database
}

struct Subscriptions: View {
  @Bindable var store: StoreOf<SubscriptionFeature>

  var body: some View {
    Form {
      Section {
        if !self.store.$records.isLoading, self.store.records.isEmpty {
          ContentUnavailableView {
            Label(
              "You are not subscribed to anyone",
              systemImage: "person.crop.square.on.square.angled.fill")
          } description: {
            //                    Button("Find interesing channels") {
            //                        self.store.send(.findChannelsButtonTapped)
            //                    }
          }
        } else {
          List {
            ForEach(self.store.records) { row in
              SubscriptionRowView(row: row)
            }
            .onDelete { offsets in
              self.store.send(.listElementDeleteSwiped(offsets: offsets))
            }
          }
        }
      }
      ChannelRecommendations(
        store: store.scope(state: \.recommendationsFeature, action: \.recommendationsFeature)
      )
    }
    .navigationTitle("Subscriptions")
  }
}

struct SubscriptionRowView: View {
  let row: SubRecord
  @State private var bellStore: StoreOf<NotificationBellFeature>

  init(row: SubRecord) {
    self.row = row
    _bellStore = State(
      initialValue: Store(
        initialState: NotificationBellFeature.State(
          channelId: row.subscription.channelID,
          isOn: row.subscription.notifyOnNewVideo
        )
      ) {
        NotificationBellFeature()
      }
    )
  }

  var body: some View {
    HStack {
      AvatarView(
        url: row.channel?.avatarUrl,
        name: row.channel?.name ?? "Channel",
        size: 36)
      Text(row.channel?.name ?? "Channel Name Not Available")
      Spacer()
      NotificationBell(store: bellStore)
    }
  }
}

#Preview {
  let _ = prepareDependencies {
    try! $0.bootstrapDatabase()
    try! $0.defaultDatabase.seed()
  }
  NavigationStack {
    Subscriptions(
      store: Store(initialState: SubscriptionFeature.State()) {
        SubscriptionFeature()
      })
  }
}
