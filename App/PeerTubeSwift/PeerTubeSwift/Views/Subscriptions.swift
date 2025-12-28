//
//  Subscriptions.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 23.12.25.
//

import ComposableArchitecture
import SQLiteData
import SwiftUI

@Selection
struct SubRecord {
    let subscription: PeertubeSubscription
    let channel: VideoChannel?
}

extension SubRecord: Identifiable {
    var id: String {
        subscription.id
    }
}

@Reducer
struct SubscriptionFeature {
    
    @ObservableState
    struct State {
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
                }
        )
        var records: [SubRecord]
    }
    
    enum Action {
        case findChannelsButtonTapped
        case listElementDeleteSwiped(offsets: IndexSet)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .findChannelsButtonTapped:
                return .none
            case .listElementDeleteSwiped(offsets: let offsets):
                return .run { [subscriptions = state.records] send in
                    withErrorReporting {
                        try database.write { db in
                            try PeertubeSubscription.find(offsets.map { subscriptions[$0].id })
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
            if !self.store.$records.isLoading, self.store.records.isEmpty {
                ContentUnavailableView {
                    Label("You are not subscribed to anyone", systemImage: "person.crop.square.on.square.angled.fill")
                } description: {
                    Button("Find interesing channels") {
                        self.store.send(.findChannelsButtonTapped)
                    }
                }
            } else {
                List {
                    ForEach(self.store.records) { row in
                        HStack {
                            if let avatarUrlString = row.channel?.avatarUrl,
                               let avatarUrl = URL(string: avatarUrlString) {
                                AsyncImage(url: avatarUrl) { image in
                                    image.resizable()
                                } placeholder: {
                                    Color.secondary
                                }
                                .frame(width: 36, height: 36)
                                .clipShape(.circle)
                            } else {
                                Color.secondary
                                    .frame(width: 36, height: 36)
                                    .clipShape(.circle)
                            }
                            
                            Text(row.channel?.name ?? "Channel Name Not Available")
                        }
                    }
                    .onDelete { offsets in
                        self.store.send(.listElementDeleteSwiped(offsets: offsets))
                    }
                }
            }
        }
        .navigationTitle("Subscriptions")
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
