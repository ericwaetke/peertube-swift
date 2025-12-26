//
//  FeedTab.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 26.12.25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct FeedTabFeature {
    struct State {
        var path = StackState<FeedPath.State>()
    }
    
    enum Action {
        case path(StackActionOf<FeedPath>)
    }
    
    @Reducer
    struct FeedPath {
        enum State {
            case manageSubscriptions(SubscriptionFeature.State)
//            case feed(feedType: FeedType)
//            case video(video: Video)
//            case channel(channel: VideoChannel)
//            case instance(instance: Instance)
        }
        enum Action {
            case manageSubscriptions(SubscriptionFeature.Action)
        }
        var body: some ReducerOf<Self> {
            Scope(state: \.manageSubscriptions, action: \.manageSubscriptions) {
                SubscriptionFeature()
            }
        }
    }
}



struct FeedTab: View {
    let store: StoreOf<FeedTabFeature>
    var body: some View {
        NavigationStack {
        Subscriptions(store: Store(initialState: SubscriptionFeature.State()) {
            SubscriptionFeature()
        })
        }
    }
}
