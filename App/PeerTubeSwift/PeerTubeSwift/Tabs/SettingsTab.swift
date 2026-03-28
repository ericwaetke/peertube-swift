//
//  SettingsTab.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 26.12.25.
//

import SQLiteData
import ComposableArchitecture
import PostHog
import SwiftUI
import TubeSDK
import WebURL

@Reducer
struct SettingsTabFeature {
    @ObservableState
    struct State: Equatable {
        var path = StackState<SettingsPath.State>()
        
        @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(scheme: "https", host: "peertube.wtf")
        @Presents var editInstance: InstanceManagerFeature.State?
        @Presents var login: LoginFeature.State?
        @Shared(.inMemory("session")) var session: UserSession?
        
        enum HealthStatus: Equatable {
            case loading
            case healthy(ServerConfig)
            case error(String)
        }
        var healthStatus: HealthStatus = .loading
    }
    
    enum Action {
        case path(StackActionOf<SettingsPath>)
        
        case onAppear
        case sessionLoaded(UserSession?)
        
        case checkInstanceHealth
        case instanceHealthResponse(Result<ServerConfig, NetworkError>)
        
        case editInstanceButtonTapped
        case editInstance(PresentationAction<InstanceManagerFeature.Action>)
        case goToCCVideo
        case setClient(TubeSDKClient)
        
        case loginButtonTapped
        case login(PresentationAction<LoginFeature.Action>)
        case logoutButtonTapped
        
        case dismiss
        
        case delegate(Delegate)
        
        enum Delegate {
            case didLogin
            case didLogout
        }
    }

    @Reducer
    struct SettingsPath {
        enum State: Equatable {}
        enum Action {}
        var body: some ReducerOf<Self> {}
    }
    
    @Dependency(\.authClient) var authClient
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let session = try? await authClient.getSession()
                    await send(.sessionLoaded(session))
                    await send(.checkInstanceHealth)
                }
                
            case let .sessionLoaded(session):
                state.$session.withLock { $0 = session }
                if let session = session {
                    state.$client.withLock { 
                        $0 = try! TubeSDKClient(scheme: "https", host: session.host, token: session.token)
                    }
                } else {
                    state.$client.withLock { $0.currentToken = nil }
                }
                return .none
                
            case .checkInstanceHealth:
                state.healthStatus = .loading
                return .run { [client = state.client] send in
                    do {
                        let config = try await client.instance.getConfig()
                        await send(.instanceHealthResponse(.success(config)))
                    } catch {
                        await send(.instanceHealthResponse(.failure(.connectionFailed(error.localizedDescription))))
                    }
                }
                
            case let .instanceHealthResponse(.success(config)):
                state.healthStatus = .healthy(config)
                return .none
                
            case let .instanceHealthResponse(.failure(error)):
                state.healthStatus = .error(error.localizedDescription)
                return .none
                
            case .path(_):
                return .none
            case .goToCCVideo:
                return .none
            case .editInstanceButtonTapped:
                guard let url = state.client.instance.urlComponents.url?.absoluteString else {
                    return .none
                }
                state.editInstance = InstanceManagerFeature.State(instanceUrlString: url)
                return .none
            case let .editInstance(.presented(.delegate(delegate))):
                switch delegate {
                case let .saveNewInstance(url):
                    state.editInstance = nil
                    return .run { send in
                        guard let host = url.host?.serialized else { return }
                        do {
                            await send(.setClient(try TubeSDKClient(scheme: url.scheme, host: host)))
                        } catch {}
                    }
                }
            case let .setClient(client):
                state.$client.withLock { $0 = client }
                return .merge(
                    .send(.checkInstanceHealth),
                    .run { [host = client.instance.host] _ in
                        PostHogSDK.shared.capture("instance_changed", properties: ["instance_host": host])
                    }
                )
            case .editInstance:
                return .none
                
            case .loginButtonTapped:
                state.login = LoginFeature.State()
                return .none
                
            case let .login(.presented(.delegate(.didLogin(session)))):
                state.$session.withLock { $0 = session }
                state.$client.withLock { 
                    $0 = try! TubeSDKClient(scheme: "https", host: session.host, token: session.token)
                }
                return .merge(
                    .send(.checkInstanceHealth),
                    .send(.delegate(.didLogin))
                )
                
            case .login:
                return .none
                
            case .logoutButtonTapped:
                state.$session.withLock { $0 = nil }
                state.$client.withLock { $0.currentToken = nil }
                return .merge(
                    .run { _ in
                        try? await authClient.deleteSession()
                        PostHogSDK.shared.capture("user_logged_out")
                        PostHogSDK.shared.reset()
                    },
                    .send(.delegate(.didLogout))
                )
                
            case .dismiss:
                return .run { [dismiss] _ in
                    await dismiss()
                }
                
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$editInstance, action: \.editInstance) {
            InstanceManagerFeature()
        }
        .ifLet(\.$login, action: \.login) {
            LoginFeature()
        }
    }
}

struct SettingsTab: View {
    @Bindable var store: StoreOf<SettingsTabFeature>
    var body: some View {
        NavigationStack {
            Form {
                Section("Your Home Instance") {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Connected to: \(self.store.client.instance.host)")
                            
                            switch self.store.healthStatus {
                            case .loading:
                                EmptyView()
                            case let .healthy(config):
                                Text(config.instance.name)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("v\(config.serverVersion)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            case let .error(error):
                                Text("Error: \(error)")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                        }
                        
                        Spacer()
                        
                        switch self.store.healthStatus {
                        case .loading:
                            ProgressView()
                                .scaleEffect(0.8)
                        case .healthy:
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        case .error:
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    
                    Button("Change Connected Instance") {
                        self.store.send(.editInstanceButtonTapped)
                    }
                }
                
                Section("Account") {
                    if let session = store.session {
                        Text("Logged in as \(session.username)@\(session.host)")
                        Button("Log Out", role: .destructive) {
                            self.store.send(.logoutButtonTapped)
                        }
                    } else {
                        Button("Log In to \(self.store.client.instance.host)") {
                            self.store.send(.loginButtonTapped)
                        }
                    }
                }
                
                Section("Debugging") {
                    Button("Go to Collective Change Video") {
                        self.store.send(.goToCCVideo)
                    }
                }
            }
            .navigationTitle("Settings")
            .task {
                self.store.send(.onAppear)
            }
            .sheet(item: $store.scope(state: \.editInstance, action: \.editInstance)) { store in
                NavigationStack {
                    InstanceManager(store: store)
                        .navigationTitle("Edit Instance")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem {
                                Button("Save") {
                                    guard let url = store.state.instanceUrl else { return }
                                    store.send(.delegate(.saveNewInstance(url: url)))
                                }
                                .disabled(!store.state.readyToSaveInstance)
                            }
                        }
                }
            }
            .sheet(item: $store.scope(state: \.login, action: \.login)) { loginStore in
                NavigationStack {
                    LoginView(store: loginStore)
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
    
    SettingsTab(
        store: Store(initialState: SettingsTabFeature.State()) {
            SettingsTabFeature()
        }
    )
}
