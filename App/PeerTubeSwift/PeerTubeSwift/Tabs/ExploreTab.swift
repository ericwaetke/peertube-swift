//
//  ExploreTab.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 26.12.25.
//

import Dependencies
import SQLiteData
import ComposableArchitecture
import SwiftUI
import TubeSDK
import WebURL

@Reducer
struct ExploreTabFeature {
    @Reducer
    enum Path {
        case oldExplore(ExploreFeature)
        case videoDetail(VideoDetailsFeature)
    }
    
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        
        @Presents var addInstance: InstanceManagerFeature.State?
        
        @FetchAll var instances: [Instance] = []
    }
    
    enum Action {
        case path(StackActionOf<Path>)
        case addInstanceButtonPressed
        case addInstance(PresentationAction<InstanceManagerFeature.Action>)
        
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addInstanceButtonPressed:
                state.addInstance = InstanceManagerFeature.State()
                return .none
            case let .addInstance(.presented(.delegate(delegate))):
                switch delegate {
                case let .saveNewInstance(url):
                    state.addInstance = nil
                    
                    return .run { send in
                        @Dependency(\.defaultDatabase) var database
                        
                        //                    TODO: Add Proper error handeling
                        guard let host = url.host else {
                            return
                        }
                        withErrorReporting {
                            try database.write { db in
                                try Instance.insert {
                                    Instance(host: host.serialized, scheme: url.scheme)
                                }
                                .execute(db)
                            }
                        }
                    }
                }
            case .addInstance:
                return .none
                
            case let .path(action):
                switch action {
                case let .element(id: _, action: .oldExplore(.videoTapped(row: row))):
                    guard let instance = row.instance,
                          let client = try? TubeSDKClient(scheme: instance.scheme, host: instance.host) else {
                        return .none
                    }
                    state.path.append(.videoDetail(VideoDetailsFeature.State(host: instance.host, videoId: row.video.id.uuidString, client: client)))
                    return .none
                    
                default:
                    return .none
                }
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$addInstance, action: \.addInstance) {
            InstanceManagerFeature()
        }
    }
}
extension ExploreTabFeature.Path.State: Equatable {}


struct ExploreTab: View {
    @Bindable var store: StoreOf<ExploreTabFeature>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Instances")
                            .font(.title2)
                            .padding(.horizontal, 16)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(self.store.state.instances) { instance in
                                    VStack(alignment: .leading) {
                                        if let avatarUrlString = instance.avatarUrl,
                                           let avatarUrl = URL(string: avatarUrlString) {
                                            AsyncImage(url: avatarUrl) { image in
                                                image.resizable()
                                            } placeholder: {
                                                Color.secondary
                                            }
                                            .frame(width: 128, height: 128)
                                            .clipShape(.rect(cornerRadius: 8))
                                        } else {
                                            Color.secondary
                                                .frame(width: 128, height: 128)
                                                .clipShape(.rect(cornerRadius: 8))
                                        }
                                        Text(instance.host)
                                    }
                                    //                                    TODO: For whatever reason, this highlightes the entire section, not just the instance
                                    //                                    .contextMenu {
                                    //                                        Button("Delete") {}
                                    //                                    }
                                }
                            }
                        }
                        .contentMargins(.horizontal, 16)
                    }
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Channels")
                            .font(.title2)
                            .padding(.horizontal, 16)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(0...12, id: \.self) { i in
                                    VStack(alignment: .leading) {
                                        Color.secondary
                                            .frame(width: 128, height: 128)
                                            .clipShape(.circle)
                                        Text("Channel \(i)")
                                    }
                                }
                            }
                        }
                        .contentMargins(.horizontal, 16)
                    }
                }
                
                NavigationLink(
                    "Newest",
                    state: ExploreTabFeature.Path.State.oldExplore(ExploreFeature.State())
                )
                //                NavigationLink(
                //                    "Trending",
                //                    state: ExploreTabFeature.Path.State.screenB(ScreenB.State())
                //                )
            }
            .navigationTitle("Explore")
            .toolbar {
                ToolbarItemGroup(placement: .secondaryAction) {
                    Button {
                        self.store.send(.addInstanceButtonPressed)
                    } label: {
                        Label("Add Instance", systemImage: "plus")
                    }
                }
            }
        } destination: { store in
            switch store.case {
            case let .oldExplore(store):
                Explore(store: store)
            case let .videoDetail(store):
                VideoDetails(store: store)
                //            case let .screenB(store):
                //                ScreenBView(store: store)
            }
        }
        .sheet(item: $store.scope(state: \.addInstance, action: \.addInstance)) { store in
            NavigationStack {
                InstanceManager(store: store)
                    .navigationTitle("Add new Instance")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem {
                            Button("Save") {
                                guard let url = store.state.instanceUrl else { return }
                                
                                store.send(.delegate(.saveNewInstance(url: url)))
//                                parentStore.send(.saveNewInstance(scheme: scheme, host: host))
                            }
                            .disabled(!store.state.readyToSaveInstance)
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
    
    ExploreTab(
        store: Store(initialState: ExploreTabFeature.State()) {
            ExploreTabFeature()
        }
    )
}
