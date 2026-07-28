//
//  VideoChannel.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 28.07.26.
//

import ComposableArchitecture
import Dependencies
import SQLiteData
import SwiftUI
import TubeSDK
import FontKit

@Reducer
struct VideoChannelComponentFeature {
    @ObservableState
    struct State: Equatable {
        let avatarUrl: String
        let channelDisplayName: String
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

struct VideoChannelComponent: View {
    @Bindable var store: StoreOf<VideoChannelComponentFeature>
    
  var body: some View {
      HStack {
          AvatarView(url: self.store.state.avatarUrl, name: self.store.state.channelDisplayName)
            .onTapGesture {
                self.store.send(.openChannel)
            }
      }
  }
}

#Preview {
    VideoChannelComponent(store: Store(initialState: VideoChannelComponentFeature.State(
        avatarUrl: "https://picsum.photos/200",
        channelDisplayName: "Gronkh"
    )) {
        VideoChannelComponentFeature()
    })
}
 
