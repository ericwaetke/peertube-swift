//
//  ContentView.swift
//  PeerTubeApp
//
//  Created on 2024-12-17.
//

import PeerTubeSwift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            NavigationStack(path: $appState.navigationPath) {
                BrowseView()
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Label(AppState.Tab.browse.rawValue, systemImage: AppState.Tab.browse.systemImage)
            }
            .tag(AppState.Tab.browse)

            NavigationStack {
                SubscriptionsView()
            }
            .tabItem {
                Label(
                    AppState.Tab.subscriptions.rawValue,
                    systemImage: AppState.Tab.subscriptions.systemImage
                )
            }
            .tag(AppState.Tab.subscriptions)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label(
                    AppState.Tab.settings.rawValue, systemImage: AppState.Tab.settings.systemImage
                )
            }
            .tag(AppState.Tab.settings)
        }
        .overlay {
            if appState.isLoading && appState.currentInstance == nil {
                LoadingView()
            }
        }
        .alert("Error", isPresented: .constant(appState.error != nil)) {
            Button("OK") {
                appState.clearError()
            }
        } message: {
            if let error = appState.error {
                Text(error.localizedDescription)
            }
        }
    }

    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .instanceSelection:
            InstanceSelectionView()
        case let .videoDetail(videoId):
            VideoDetailView(videoId: videoId)
        case let .channelDetail(channelId):
            ChannelDetailView(channelId: channelId)
        case let .videoPlayer(video):
            VideoPlayerContainerView(video: video)
        case .search:
            SearchView()
        case .settings:
            SettingsView()
        case .about:
            AboutView()
        case .subscriptionManagement:
            SubscriptionManagementView()
        }
    }
}

// MARK: - Loading View

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)

                Text("Loading PeerTube instance...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(24)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
        }
    }
}

// MARK: - Placeholder Views

struct InstanceSelectionView: View {
    @EnvironmentObject private var appState: AppState
    @State private var instanceURL = ""

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "server.rack")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)

            VStack(spacing: 8) {
                Text("Select PeerTube Instance")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Enter the URL of a PeerTube instance you'd like to browse")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Instance URL")
                    .font(.subheadline)
                    .fontWeight(.medium)

                TextField("https://example.peertube.org", text: $instanceURL)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }

            Button("Connect") {
                Task {
                    try? await appState.setInstanceURL(instanceURL)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(instanceURL.isEmpty || appState.isLoading)

            if appState.isLoading {
                ProgressView("Connecting...")
                    .font(.subheadline)
            }
        }
        .padding()
        .navigationTitle("Select Instance")
        .onAppear {
            if let currentURL = appState.currentInstance?.url.absoluteString {
                instanceURL = currentURL
            }
        }
    }
}

struct SearchView: View {
    var body: some View {
        Text("Search functionality coming soon...")
            .font(.title2)
            .foregroundColor(.secondary)
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
