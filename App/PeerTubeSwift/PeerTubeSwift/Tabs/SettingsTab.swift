//
//  SettingsTab.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 26.12.25.
//

import SQLiteData
import ComposableArchitecture
import SwiftUI
import TubeSDK
import WebURL

@Reducer
struct SettingsTabFeature {
    @ObservableState
    struct State {
        var path = StackState<SettingsPath>()
        
        @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(scheme: "https", host: "peertube.wtf")
        @Presents var editInstance: InstanceManagerFeature.State?
        @Presents var login: LoginFeature.State?
        var session: UserSession?
    }
    
    enum Action {
        case path(StackActionOf<SettingsPath>)
        
        case onAppear
        case sessionLoaded(UserSession?)
        
        case editInstanceButtonTapped
        case editInstance(PresentationAction<InstanceManagerFeature.Action>)
        case goToCCVideo
        case setClient(TubeSDKClient)
        
        case loginButtonTapped
        case login(PresentationAction<LoginFeature.Action>)
        case logoutButtonTapped
    }

    @Reducer
    struct SettingsPath {
        enum State {}
        enum Action {}
        var body: some ReducerOf<Self> {}
    }
    
    @Dependency(\.authClient) var authClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let session = try? await authClient.getSession()
                    await send(.sessionLoaded(session))
                }
                
            case let .sessionLoaded(session):
                state.session = session
                if let session = session {
                    state.$client.withLock { 
                        $0 = try! TubeSDKClient(scheme: "https", host: session.host, token: session.token)
                    }
                } else {
                    state.$client.withLock { $0.currentToken = nil }
                }
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
                return .none
            case .editInstance:
                return .none
                
            case .loginButtonTapped:
                state.login = LoginFeature.State()
                return .none
                
            case let .login(.presented(.delegate(.didLogin(session)))):
                state.session = session
                state.$client.withLock { 
                    $0 = try! TubeSDKClient(scheme: "https", host: session.host, token: session.token)
                }
                return .none
                
            case .login:
                return .none
                
            case .logoutButtonTapped:
                state.session = nil
                state.$client.withLock { $0.currentToken = nil }
                return .run { _ in
                    try? await authClient.deleteSession()
                }
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
                    Text("Connected to: \(self.store.client.instance.host)")
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
