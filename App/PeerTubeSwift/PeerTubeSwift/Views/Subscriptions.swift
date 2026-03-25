//
//  Subscriptions.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 23.12.25.
//

import ComposableArchitecture
import SQLiteData
import SwiftUI
import TubeSDK

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

enum RecommendationCategory: String, CaseIterable {
    case tech = "Technology"
    case photography = "Photography"
    case politics = "Politics"
}

struct Recommendation: Equatable, Hashable, Identifiable {
    let id: UUID = UUID()
    let username: String
    let displayName: String
    let avatarUrl: URL
    let category: RecommendationCategory
    
    var isSubscribed = false
}

@Reducer
struct SubscriptionFeature {
    
    @ObservableState
    struct State {
        @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(scheme: "https", host: "peertube.wtf")
        
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
                },
            animation: .default
        )
        var records: [SubRecord]
        
        var recommendations: [Recommendation] = [
            Recommendation(username: "veronicaexplains@tinkerbetter.tube", displayName: "Veronica Explains", avatarUrl: URL(string: "https://peertube.wtf/lazy-static/avatars/52cda089-6645-4306-8a8e-e54459652462.jpg")!, category: .tech),
            Recommendation(username: "arthurpizza@tilvids.com", displayName: "arthurpizza", avatarUrl: URL(string: "https://peertube.wtf/lazy-static/avatars/af6645ec-6d5e-4880-a710-98475525162d.jpg")!, category: .tech),
            Recommendation(username: "ct_3003@peertube.heise.de", displayName: "c’t 3003", avatarUrl: URL(string: "https://peertube.wtf/lazy-static/avatars/86130f91-8d83-42e3-853c-b3a50ea29944.jpg")!, category: .tech),
            Recommendation(username: "transit@video.canadiancivil.com", displayName: "Transit", avatarUrl: URL(string: "https://peertube.wtf/lazy-static/avatars/59406d16-fd0d-4604-963c-4aae5bfdb1d9.jpg")!, category: .politics),
            Recommendation(username: "she_drives_mobility@tube.tchncs.de", displayName: "Katja Diehl", avatarUrl: URL(string: "https://peertube.wtf/lazy-static/avatars/a9fb9cca-b70f-47c4-9b8c-62edcb696e14.png")!, category: .politics),
            Recommendation(username: "thelinuxexperiment_channel@tilvids.com", displayName: "The Linux Experiment", avatarUrl: URL(string: "https://peertube.wtf/lazy-static/avatars/a35f3a25-ff7f-4dff-886c-e8373f6ed306.jpg")!, category: .tech),
            Recommendation(username: "gardiner_bryant@subscribeto.me", displayName: "Gardiner Bryant", avatarUrl: URL(string: "https://peertube.wtf/lazy-static/avatars/178a420f-a00a-4db9-960f-ef5a213a168e.png")!, category: .tech),
            Recommendation(username: "ewen@makertube.net", displayName: "Photography with Ewen Bell", avatarUrl: URL(string: "https://peertube.wtf/lazy-static/avatars/86012f0f-1fad-4405-8a1a-a00210a44848.jpg")!, category: .photography),
            Recommendation(username: "norberteder.photography@tube.graz.social", displayName: "Norbert Eder Photography", avatarUrl: URL(string: "https://tube.tchncs.de/lazy-static/avatars/5d7ad89e-2d1b-4799-82ca-3cfc19af12f3.jpg")!, category: .photography),
            Recommendation(username: "obsidianurbexvideos@lostpod.space", displayName: "Obsidian Urbex - Abandoned Places Videos", avatarUrl: URL(string: "https://peertube.wtf/lazy-static/avatars/c73cb49d-a7cc-4e93-9278-83ee8e8bc37f.png")!, category: .photography),
        ]
    }
    
    enum Action {
        case findChannelsButtonTapped
        case listElementDeleteSwiped(offsets: IndexSet)
        
        case recommendationSubscribeButtonTapped(Recommendation)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .findChannelsButtonTapped:
                return .none
            case .listElementDeleteSwiped(offsets: let offsets):
                return .run { [client = state.client, subscriptions = state.records] send in
                    withErrorReporting {
                        try database.write { db in
                            try PeertubeSubscription.find(offsets.map { subscriptions[$0].id })
                                .delete()
                                .execute(db)
                        }
                    }
                    if client.currentToken != nil {
                        for index in offsets {
                            let channelId = subscriptions[index].subscription.channelID
                            try? await client.removeSubscription(channelUri: channelId)
                        }
                    }
                }
            case let .recommendationSubscribeButtonTapped(recommendation):
                @Dependency(\.defaultDatabase) var database
                let isSubscribed = state.records.filter {$0.channel?.id == recommendation.username}.count > 0
                
                if isSubscribed {
                    return .run { [client = state.client] send in
                        await withErrorReporting {
                            try await database.write { db in
                                try PeertubeSubscription
                                    .where { $0.channelID == recommendation.username }
                                    .delete()
                                    .execute(db)
                            }
                            if client.currentToken != nil {
                                try? await client.removeSubscription(channelUri: recommendation.username)
                            }
                        }
                    }
                } else {
                    return .run { [client = state.client] send in
                        await withErrorReporting {
                            try await database.write { db in
                                guard let hostSubstring = recommendation.username.split(separator: "@").last else {
                                    print("could not get host")
                                    return
                                }
                                
                                let instance = try Instance
                                    .upsert {
                                        Instance(host: String(hostSubstring), scheme: "https")
                                    }
                                    .returning(\.self)
                                    .fetchOne(db)
                                
                                guard let instance = instance else {
                                    return
                                }
                                
                                try VideoChannel
                                    .upsert {
                                        VideoChannel(
                                            id: recommendation.username,
                                            name: recommendation.displayName,
                                            avatarUrl: recommendation.avatarUrl.absoluteString,
                                            instanceID: instance.id
                                        )
                                    }
                                    .execute(db)
                                
                                try PeertubeSubscription
                                    .insert {
                                        PeertubeSubscription.Draft(
                                            channelID: recommendation.username, createdAt: .now)
                                    }
                                    .execute(db)
                            }
                            if client.currentToken != nil {
                                try? await client.addSubscription(channelUri: recommendation.username)
                            }
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
        Form {
            Section {
                if !self.store.$records.isLoading, self.store.records.isEmpty {
                    ContentUnavailableView {
                        Label("You are not subscribed to anyone", systemImage: "person.crop.square.on.square.angled.fill")
                    } description: {
                        //                    Button("Find interesing channels") {
                        //                        self.store.send(.findChannelsButtonTapped)
                        //                    }
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
            
            Section("Recommendations") {
                ForEach(RecommendationCategory.allCases, id: \.rawValue) { category in
                    VStack(alignment: .leading) {
                        Text(category.rawValue)
                            .font(.title3)
                        ScrollView(.horizontal) {
                            LazyHStack {
                                ForEach(self.store.recommendations.filter { $0.category == category }) { recommendation in
                                    VStack {
                                        AsyncImage(url: recommendation.avatarUrl) { image in
                                            image.resizable()
                                        } placeholder: {
                                            Color.secondary
                                        }
                                        .frame(width: 48, height: 48)
                                        .clipShape(.circle)
                                        
                                        Text(recommendation.displayName)
                                        
                                        Button(
                                            self.store.state.records.filter {$0.channel?.id == recommendation.username}.count > 0
                                            ? "Unsubscribe" : "Subscribe"
                                        ) {
                                            self.store.send(.recommendationSubscribeButtonTapped(recommendation))
                                        }
                                        .buttonStyle(.bordered)
                                    }
                                    .padding()
                                    .background(.quinary)
                                    .clipShape(.rect(cornerRadius: 8))
                                }
                            }
                        }
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
