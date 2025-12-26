//
//  ContentView.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 18.12.25.
//

import SwiftUI
import TubeSDK
import ComposableArchitecture

struct ContentViewOld: View {
    @Environment(AppState.self) private var appState: AppState
    @StateObject private var networkMonitor = NetworkMonitor()
    
    @State var search: String = ""
    @State var errorString: String = ""
    
    var body: some View {
        @Bindable var appState = appState
        TabView(selection: $appState.selectedTab) {
            Tab(AppState.Tab.browse.rawValue, systemImage: AppState.Tab.browse.systemImage, value: AppState.Tab.browse) {
                Explore(store: Store(initialState: ExploreFeature.State()) {
                    ExploreFeature()
                  })
            }
            
            // Subscriptions Tab
            Tab(AppState.Tab.subscriptions.rawValue, systemImage: AppState.Tab.subscriptions.systemImage, value: AppState.Tab.subscriptions) {
                NavigationStack {
                    Subscriptions(store: Store(initialState: SubscriptionFeature.State()) {
                        SubscriptionFeature()
                    })
                }
            }
            
            // Settings Tab
            //            NavigationStack {
            //                Form {
            //                    Section(header: Text("Playback")) {
            //                        Toggle("Auto-play videos", isOn: $appState.autoPlayVideos)
            //                        Picker("Default quality", selection: $appState.defaultVideoQuality) {
            //                            ForEach(VideoQuality.allCases, id: \.self) { quality in
            //                                Text(quality.displayName).tag(quality)
            //                            }
            //                        }
            //                    }
            //                    Section(header: Text("Network")) {
            //                        Toggle("Use WiFi only", isOn: $appState.useWiFiOnly)
            //                    }
            //                    Section(header: Text("Notifications")) {
            //                        Toggle("Enable notifications", isOn: $appState.enableNotifications)
            //                    }
            //                }
            //                .navigationTitle("Settings")
            //            }
            //            .tabItem {
            //                Label(
            //                    AppState.Tab.settings.rawValue, systemImage: AppState.Tab.settings.systemImage)
            //            }
            //            .tag(AppState.Tab.settings)
            
            Tab(AppState.Tab.search.rawValue, systemImage: AppState.Tab.search.systemImage, value: AppState.Tab.search, role: .search) {
                VStack {
                    Text(search)
                    TextField("Search Peertube URL", text: $search, onCommit: {
                        print("searching")
                        Task {
                            do {
                                try await appState.searchVideo(urlString: search)
                            } catch {
                                print("error searching video")
                                print(error)
                            }
                        }
                    })
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    Text(errorString)
                    Button {
                        print("searching")
                        Task {
                            do {
                                try await appState.searchVideo(urlString: search)
                            } catch {
                                print("error searching video")
                                print(error)
                                errorString = error.localizedDescription
                            }
                        }
                    } label: {
                        Text("Search")
                    }
                    
                    Button {
                        appState.selectTab(.browse)
                    } label: {
                        Text("Navigate Back")
                    }
                }
                .onAppear {
                    search = ""
                }
            }
        }
        .onAppear {
            networkMonitor.startMonitoring()
        }
    }
}

#Preview {
    ContentViewOld()
        .environment(AppState())
}
