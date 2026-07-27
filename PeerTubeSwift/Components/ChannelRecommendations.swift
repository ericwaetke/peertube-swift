//
//  ChannelRecommendations.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 27.07.26.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct ChannelRecommendationsFeature {
  @ObservableState
  struct State: Equatable {
    var loading: Bool = false
    var error: String?
    var channels: [RecommendedChannel] = []
  }

  enum Action {
    case setLoading(Bool)
    case setError(String)
    case setChannels([RecommendedChannel])
    case getRecommendations
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .setLoading(let loading):
        state.loading = loading
        return .none
      case .setError(let error):
        state.error = error
        return .send(.setLoading(false))
      case .setChannels(let channels):
        state.channels = channels
        return .send(.setLoading(false))
      case .getRecommendations:
        return .run { send in
          print("getting recommendations")
          do {
            await send(.setLoading(true))
            let channels = try await getRecommendations()
            await send(.setChannels(channels))
          } catch {
            await send(.setError(error.localizedDescription))
          }
        }
      }
    }
  }
}

struct ChannelRecommendations: View {
  @Bindable var store: StoreOf<ChannelRecommendationsFeature>

  var body: some View {
    Section("Recommendations") {
      if store.state.loading {
        ProgressView()
      } else if store.state.error != nil {
        ContentUnavailableView {
          Label("Couldn’t get recommendations", systemImage: "tray.fill")
        } description: {
          Text(store.state.error!)
          Button("Retry") {
            store.send(.getRecommendations)
          }
        }
      } else {
        ForEach(self.store.state.channels) {
          Text($0.name)
        }
      }
    }
    .onAppear {
      store.send(.getRecommendations)
    }
  }
}

//#Preview {
//    NotificationBell(
//        store: Store(
//            initialState: NotificationBellFeature.State(channelId: nil)
//        ) {
//            NotificationBellFeature()
//        }
//    )
//}
