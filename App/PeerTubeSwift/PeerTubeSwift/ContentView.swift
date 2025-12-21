//
//  ContentView.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 18.12.25.
//

import SwiftUI
import peertube_swift_sdk

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var networkMonitor = NetworkMonitor()
    
    @State var videos: [Video] = []
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            // Browse Tab
            NavigationStack(path: $appState.navigationPath) {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(videos, id: \.self) { video in
                            VStack {
                                if let path = video.thumbnailPath,
                                   let url = try? appState.client.getImageUrl(path: path) {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                    } placeholder: {
                                        Color.secondary
                                    }
//                                    .frame(width: .infinity)
                                } else {
                                    Text("Couldn’t load thumbnail")
                                }
                                Text(video.name ?? "Unknown Video Title")
                                    .fontWeight(.bold)
                            }
                            .background(.tertiary)
                            .clipShape(.rect(cornerRadius: 8))
                        }
                    }
                    .padding()
                }
                .navigationTitle("Browse")
                .onAppear {
                    Task {
                        do {
                            let result = try await appState.client.getVideos()
                            videos = result
                        } catch {
                            print("Error getting videos")
                            print(error)
                        }
                    }
                }
            }
            .tabItem {
                Label(AppState.Tab.browse.rawValue, systemImage: AppState.Tab.browse.systemImage)
            }
            .tag(AppState.Tab.browse)
            
            // Subscriptions Tab
            NavigationStack {
                VStack(spacing: 12) {
                    Text("Subscriptions")
                        .font(.title2)
                    //					Text("Count: \(appState.subscriptionService.subscriptionCount)")
                }
                .padding()
                .navigationTitle("Subscriptions")
            }
            .tabItem {
                Label(
                    AppState.Tab.subscriptions.rawValue,
                    systemImage: AppState.Tab.subscriptions.systemImage)
            }
            .tag(AppState.Tab.subscriptions)
            
            // Settings Tab
            NavigationStack {
                Form {
                    Section(header: Text("Playback")) {
                        Toggle("Auto-play videos", isOn: $appState.autoPlayVideos)
                        Picker("Default quality", selection: $appState.defaultVideoQuality) {
                            ForEach(VideoQuality.allCases, id: \.self) { quality in
                                Text(quality.displayName).tag(quality)
                            }
                        }
                    }
                    Section(header: Text("Network")) {
                        Toggle("Use WiFi only", isOn: $appState.useWiFiOnly)
                    }
                    Section(header: Text("Notifications")) {
                        Toggle("Enable notifications", isOn: $appState.enableNotifications)
                    }
                }
                .navigationTitle("Settings")
            }
            .tabItem {
                Label(
                    AppState.Tab.settings.rawValue, systemImage: AppState.Tab.settings.systemImage)
            }
            .tag(AppState.Tab.settings)
        }
        .onAppear {
            networkMonitor.startMonitoring()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
