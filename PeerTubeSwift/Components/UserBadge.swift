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

enum UserBadgeVariant {
  case large
  case medium
  case small

  var avatarSize: CGFloat {
    switch self {
    case .small: 20
    case .medium: 38
    case .large: 48
    }
  }
  var instanceIndicatorOffsetX: CGFloat {
    switch self {
    case .small: 0
    case .medium: -26
    case .large: -26
    }
  }
  var instanceIndicatorOffsetY: CGFloat {
    switch self {
    case .small: 0
    case .medium: 4
    case .large: 4
    }
  }
  var rootHStackSpacing: CGFloat {
    switch self {
    case .small: 4
    case .medium: 8
    case .large: 8
    }
  }
}

@Reducer
struct UserBadgeFeature {
  @ObservableState
  struct State: Equatable {
    let variant: UserBadgeVariant
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

  @ViewBuilder
  private var textContent: some View {
    Text(self.store.state.channelDisplayName)
      .font(CustomFont.inclusiveSansSemiBold.swiftUIFont(size: 15, relativeTo: .subheadline))
    InstanceIndicator(
      instanceName: store.state.instanceDisplayName,
      instanceImage: store.state.instanceIconUrl
    )
    .offset(
      x: self.store.state.variant.instanceIndicatorOffsetX,
      y: self.store.state.variant.instanceIndicatorOffsetY
    )
  }

  var body: some View {
    HStack(alignment: .bottom, spacing: self.store.state.variant.rootHStackSpacing) {
      AvatarView(
        url: self.store.state.avatarUrl,
        name: self.store.state.channelDisplayName,
        size: self.store.state.variant.avatarSize
      )
      .onTapGesture {
        self.store.send(.openChannel)
      }
      switch store.state.variant {
      case .small:
        HStack(alignment: .center, spacing: 8) { textContent }
      case .medium, .large:
        VStack(alignment: .leading, spacing: -2) { textContent }
      }
    }
  }
}

#Preview {
  UserBadge(
    store: Store(
      initialState: UserBadgeFeature.State(
        variant: .large,
        avatarUrl: "https://picsum.photos/200",
        channelDisplayName: "Gronkh",
        instanceDisplayName: "PeerTube.WTF",
        instanceIconUrl: "https://picsum.photos/40"
      )
    ) {
      UserBadgeFeature()
    })
  UserBadge(
    store: Store(
      initialState: UserBadgeFeature.State(
        variant: .medium,
        avatarUrl: "https://picsum.photos/200",
        channelDisplayName: "Gronkh",
        instanceDisplayName: "PeerTube.WTF",
        instanceIconUrl: "https://picsum.photos/40"
      )
    ) {
      UserBadgeFeature()
    })
  UserBadge(
    store: Store(
      initialState: UserBadgeFeature.State(
        variant: .small,
        avatarUrl: "https://picsum.photos/200",
        channelDisplayName: "Gronkh",
        instanceDisplayName: "PeerTube.WTF",
        instanceIconUrl: "https://picsum.photos/40"
      )
    ) {
      UserBadgeFeature()
    })
}
