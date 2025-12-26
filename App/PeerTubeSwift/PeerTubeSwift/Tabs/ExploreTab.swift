//
//  ExploreTab.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 26.12.25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct ExploreTabFeature {
    struct State {
        var explorePath = StackState<ExplorePath.State>()
    }
    
    enum Action {
        case explorePath(StackActionOf<ExplorePath>)
    }
    
    @Reducer
    struct ExplorePath {
        enum State {
            case oldExplore(ExploreFeature.State)
//            case manageInstances
//            case feed(feedType: FeedType)
//            case video(video: Video)
//            case searchResults(search: String)
//            case channel(channel: VideoChannel)
//            case instance(instance: Instance)
        }
        enum Action {
            case oldExplore(ExploreFeature.Action)
        }
        var body: some ReducerOf<Self> {
            Scope(state: \.oldExplore, action: \.oldExplore) {
                ExploreFeature()
            }
        }
    }
}


struct ExploreTab: View {
    let store: StoreOf<ExploreTabFeature>
    var body: some View {
        Explore(
            store: Store(initialState: ExploreFeature.State()
        ) {
            ExploreFeature()
        })
    }
}
