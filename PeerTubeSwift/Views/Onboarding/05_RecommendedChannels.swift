//
//  05_RecommendedChannels.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 21.09.26.
//

import ComposableArchitecture
import FontKit
import PeerSeekSDK
import SwiftUI
import TubeSDK

@Reducer
struct OnboardingRecommendedChannelsFeature {
  @ObservableState
  struct State: Equatable {
    var channels: [VideoChannel] = [
      VideoChannel(
        id: "peertube.wtf-1", name: "Gronkh",
        avatarUrl:
          "https://yt3.googleusercontent.com/ytc/AIdro_ko2x8r12BwkrHwYRNEVLUwCkd1MsWA496y7Pr8wX-3c6Y=s160-c-k-c0x00ffffff-no-rj",
        instanceID: "peertube.wtf"),
      VideoChannel(id: "peertube.wtf-2", name: "Collective Change", instanceID: "peertube.wtf"),
    ]
  }

  enum Action {

  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      }
    }
  }
}

struct OnboardingRecommendedChannelsView: View {
  let store: StoreOf<OnboardingRecommendedChannelsFeature>

  var body: some View {
    ScrollView {
      LazyVStack {
        ForEach(store.channels) { channel in
          VStack {
            ChannelPreviewView(
              store: Store(
                initialState: ChannelPreviewFeature.State(
                  host: channel.instanceID,
                  notificationBell: NotificationBellFeature.State(channelId: channel.id),
                  videoChannel: TubeSDK.VideoChannel(
                    id: Int(channel.id),
                    avatars: [ActorImage(fileUrl: channel.avatarUrl)],
                    displayName: channel.name
                  ),
                  instance: Instance(host: "https", scheme: channel.instanceID),
                  isSubscribedToChannel: false
                ),
                reducer: {
                  ChannelPreviewFeature()
                }))
          }
        }
      }
      .padding()
    }
  }

}

#Preview {
  OnboardingRecommendedChannelsView(
    store: Store(initialState: OnboardingRecommendedChannelsFeature.State()) {
      OnboardingRecommendedChannelsFeature()
    }
  )
}
