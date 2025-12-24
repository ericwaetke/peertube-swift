//
//  Subscriptions.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 23.12.25.
//

import SQLiteData
import SwiftUI

struct Subscriptions: View {
    @FetchAll(animation: .default) var subscriptions: [Subscription]
    @Dependency(\.defaultDatabase) var database
    
    var body: some View {
        VStack {
            if !$subscriptions.isLoading, subscriptions.isEmpty {
                ContentUnavailableView {
                    Label("You are not subscribed to anyone", systemImage: "person.crop.square.on.square.angled.fill")
                } description: {
                    Button("Find interesing channels") {
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
                }
            } else {
                List {
                    ForEach(subscriptions) { subscription in
                        Text(subscription.id.description)
                    }
                    .onDelete { offsets in
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
        .task {
            withErrorReporting {
                try database.write { db in
                    try Instance
                        .insert { Instance(id: UUID(1), scheme: "https", host: "peertube.wtf") }
                        .execute(db)
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
        Subscriptions()
    }
}
