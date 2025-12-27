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
    @Reducer
    enum Path {
      case exploreFeature(ExploreFeature)
//      case screenB(ScreenB)
//      case screenC(ScreenC)
    }
    
    @ObservableState
    struct State: Equatable {
      var path = StackState<Path.State>()
    }
    
    enum Action {
        case path(StackActionOf<Path>)
    }
    
//    @Reducer
//    struct Path {
//        enum State {
//            case oldExplore(ExploreFeature.State)
////            case manageInstances
////            case feed(feedType: FeedType)
////            case video(video: Video)
////            case searchResults(search: String)
////            case channel(channel: VideoChannel)
////            case instance(instance: Instance)
//        }
//        enum Action {
//            case oldExplore(ExploreFeature.Action)
//        }
//        var body: some ReducerOf<Self> {
//            Scope(state: \.oldExplore, action: \.oldExplore) {
//                ExploreFeature()
//            }
//        }
//    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
              
            case let .path(action):
              switch action {
//              case .element(id: _, action: .screenB(.screenAButtonTapped)):
//                state.path.append(.screenA(ScreenA.State()))
//                return .none
//
//              case .element(id: _, action: .screenB(.screenBButtonTapped)):
//                state.path.append(.screenB(ScreenB.State()))
//                return .none
//
//              case .element(id: _, action: .screenB(.screenCButtonTapped)):
//                state.path.append(.screenC(ScreenC.State()))
//                return .none

              default:
                return .none
              }
//            case .path(_):
//                return .none
//            }
        }
        .forEach(\.path, action: \.path)
    }
}
extension ExploreTabFeature.Path.State: Equatable {}


struct ExploreTab: View {
    let store: StoreOf<ExploreTabFeature>
    var body: some View {
//        NavigationStackStore(
//            self.store.scope(state: \.path, action: \.path)) {
//                Text("Explore Stuff (this will be the default eplore view")
//            } destination: { store in
//                switch store.state {
//                case .oldExplore:
//                    if let store = store.scope(state: \.oldExplore, action: \.oldExplore) {
//                        Explore(store: store)
//                    }
//                }
//            }
        EmptyView()
    }
}
