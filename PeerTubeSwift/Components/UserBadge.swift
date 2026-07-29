//
//  VideoChannel.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 28.07.26.
//

import ComposableArchitecture
import Dependencies
import FontKit
import SQLiteData
import SwiftUI
import TubeSDK

@Reducer
struct UserBadgeFeature {
  @ObservableState
  struct State: Equatable {
    let avatarUrl: String?
    let channelDisplayName: String
    let instanceDisplayName: String
    let instanceIconUrl: String?
  }

  enum Action {
    case openChannel
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .openChannel:
        return .none
      }
    }
  }
}

struct UserBadge: View {
  @Bindable var store: StoreOf<UserBadgeFeature>

  var body: some View {
    HStack(alignment: .bottom, spacing: 8) {
      AvatarView(
        url: self.store.state.avatarUrl, name: self.store.state.channelDisplayName, size: 38
      )
      .onTapGesture {
        self.store.send(.openChannel)
      }
      VStack(alignment: .leading, spacing: -2) {
        Text(self.store.state.channelDisplayName)
          .font(CustomFont.inclusiveSansSemiBold.swiftUIFont(size: 15, relativeTo: .subheadline))
        InstanceIndicator(
          instanceName: store.state.instanceDisplayName,
          instanceImage: store.state.instanceIconUrl
        )
        .offset(x: -26, y: 4)
      }

    }

  }
}

#Preview {
  UserBadge(
    store: Store(
      initialState: UserBadgeFeature.State(
        avatarUrl: "https://picsum.photos/200",
        channelDisplayName: "Gronkh",
        instanceDisplayName: "PeerTube.WTF",
        instanceIconUrl: "https://picsum.photos/40"
      )
    ) {
      UserBadgeFeature()
    })
}
