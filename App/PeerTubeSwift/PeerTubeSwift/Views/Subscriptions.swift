//
//  Subscriptions.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 23.12.25.
//

import ComposableArchitecture
import SQLiteData
import SwiftUI

@Reducer
struct SubscriptionFeature {
    @ObservableState
    struct State {
        @FetchAll(animation: .default) var subscriptions: [Subscription]
    }
    
    enum Action {
        case findChannelsButtonTapped
        case listElementDeleteSwiped(offsets: IndexSet)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .findChannelsButtonTapped:
                return .run { send in
                    withErrorReporting {
                        try database.write { db in
                            try VideoChannel
                                .insert { VideoChannel(id: "peertube.wtf-1", name: "Gronkh", instanceID: UUID(1)) }
                                .execute(db)
                            
                            try Subscription
                                .insert { Subscription.Draft(channelID: "peertube.wtf-2", createdAt: .now) }
                                .execute(db)
                        }
                    }
                }
            case .listElementDeleteSwiped(offsets: let offsets):
                return .run { [subscriptions = state.subscriptions] send in
                    withErrorReporting {
                        try database.write { db in
                            try Subscription.find(offsets.map { subscriptions[$0].id })
                                .delete()
                                .execute(db)
                        }
                    }
                }
            }
        }
    }
    
    @Dependency(\.defaultDatabase) var database
}

struct Subscriptions: View {
    let store: StoreOf<SubscriptionFeature>
    
    
    var body: some View {
        VStack {
            if !self.store.$subscriptions.isLoading, self.store.subscriptions.isEmpty {
                ContentUnavailableView {
                    Label("You are not subscribed to anyone", systemImage: "person.crop.square.on.square.angled.fill")
                } description: {
                    Button("Find interesing channels") {
                        self.store.send(.findChannelsButtonTapped)
                    }
                }
            } else {
                List {
                    ForEach(self.store.subscriptions) { subscription in
                        Text(subscription.id.description)
                    }
                    .onDelete { offsets in
                        self.store.send(.listElementDeleteSwiped(offsets: offsets))
                    }
                }
            }
        }
    }
}

#Preview {
    let _ = prepareDependencies {
        try! $0.bootstrapDatabase()
        try! $0.defaultDatabase.seed()
    }
    NavigationStack {
        Subscriptions(store: Store(initialState: SubscriptionFeature.State()) {
            SubscriptionFeature()
          })
    }
}
