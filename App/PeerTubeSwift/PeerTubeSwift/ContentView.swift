//
//  ContentView.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 18.12.25.
//

import SwiftUI
import peertube_swift_sdk

struct ContentView: View {
    @Environment(AppState.self) private var appState: AppState
    @StateObject private var networkMonitor = NetworkMonitor()
    
    @State var videos: [Video] = []
    @State var videoDetails: VideoDetails?
    
    var body: some View {
        @Bindable var appState = appState
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
                                    .frame(
                                        minWidth: 0,
                                        maxWidth: .infinity,
                                        minHeight: 100,
                                        maxHeight: .infinity
                                    )
                                    .aspectRatio(16 / 9, contentMode: .fit)
                                    .clipShape(.rect(cornerRadius: 8))
                                } else {
                                    Text("Couldn’t load thumbnail")
                                }
                                HStack (alignment: .top) {
                                    if let avatars = video.account?.avatars,
                                       let avatar = avatars.first,
                                       let fileUrl = avatar.fileUrl,
                                       let url = URL(string: fileUrl) {
                                        AsyncImage(url: url) { image in
                                            image.resizable()
                                        } placeholder: {
                                            Color.secondary
                                        }
                                        .frame(width: 48, height: 48)
                                        .clipShape(.rect(cornerRadius: 8))
                                    } else {
                                        Text("Couldn’t load Avatar")
                                    }
                                    VStack (alignment: .leading) {
                                        Text(video.name ?? "Unknown Video Title")
                                            .fontWeight(.bold)
                                        Text(video.account?.displayName ?? "Unknown Channel")
                                            .font(.caption)
                                    }
                                    Spacer()
                                    Image(systemName: "ellipsis.circle")
                                }
                            }
                            .onTapGesture {
                                guard let uuid = video.uuid else {
                                    print("couldnt get video uuid")
                                    return
                                }
                                appState.navigationPath.append(video)
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Browse")
                .navigationDestination(for: Video.self) { video in
                    VideoDetails(video: video)
                }
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
        .environment(AppState())
}
