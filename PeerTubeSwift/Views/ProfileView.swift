//
//  ProfileView.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 03.08.26.
//

import ComposableArchitecture
import FontKit
import SQLiteData
import SwiftUI
import TubeSDK
import WebURL

@Reducer
struct ProfileTabViewFeature {
  @ObservableState
  struct State: Equatable {
    @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(
      scheme: "https", host: "peertube.wtf")
    @Presents var editInstance: InstanceManagerFeature.State?
    @Presents var login: LoginFeature.State?
    @Shared(.inMemory("session")) var session: UserSession?

    enum HealthStatus: Equatable {
      case loading
      case healthy(ServerConfig)
      case error(String)
    }

    var healthStatus: HealthStatus = .loading
    var watchHistory = WatchHistoryFeature.State()
  }

  enum Action {
    case onAppear
    case sessionLoaded(UserSession?)
      
      case accountButtonTapped

    case checkInstanceHealth
    case instanceHealthResponse(Result<ServerConfig, NetworkError>)

    case editInstanceButtonTapped
    case editInstance(PresentationAction<InstanceManagerFeature.Action>)
    case goToCCVideo
    case setClient(TubeSDKClient)

    case loginButtonTapped
    case login(PresentationAction<LoginFeature.Action>)
    case logoutButtonTapped

    case testNotification

    case dismiss

    case watchHistory(WatchHistoryFeature.Action)

    case delegate(Delegate)

    enum Delegate {
      case didLogin
      case didLogout
    }
  }

  @Dependency(\.authClient) var authClient
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.urlSession) var urlSession

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .run { send in
          let session = try? await authClient.getSession()
          await send(.sessionLoaded(session))
          await send(.checkInstanceHealth)
        }

      case .sessionLoaded(let session):
        state.$session.withLock { $0 = session }
        if let session = session {
          state.$client.withLock {
            $0 = try! TubeSDKClient(
              scheme: "https", host: session.host, token: session.token, session: urlSession)
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
            await send(
              .instanceHealthResponse(.failure(.connectionFailed(error.localizedDescription))))
          }
        }

      case .instanceHealthResponse(.success(let config)):
        state.healthStatus = .healthy(config)
        return .none

      case .instanceHealthResponse(.failure(let error)):
        state.healthStatus = .error(error.localizedDescription)
        return .none

      case .goToCCVideo:
        return .none

      case .editInstanceButtonTapped:
        guard let url = state.client.instance.urlComponents.url?.absoluteString else {
          return .none
        }
        state.editInstance = InstanceManagerFeature.State(instanceUrlString: url)
        return .none

      case .editInstance(.presented(.delegate(let delegate))):
        switch delegate {
        case .saveNewInstance(let url):
          state.editInstance = nil
          return .run { send in
            guard let host = url.host?.serialized else { return }
            do {
              try await send(
                .setClient(TubeSDKClient(scheme: url.scheme, host: host, session: urlSession)))
            } catch {}
          }
        }

      case .setClient(let client):
        state.$client.withLock { $0 = client }
        return .send(.checkInstanceHealth)

      case .editInstance:
        return .none
          
      case .accountButtonTapped:
          return .none

      case .loginButtonTapped:
        state.login = LoginFeature.State()
        return .none

      case .login(.presented(.delegate(.didLogin(let session)))):
        state.$session.withLock { $0 = session }
        state.$client.withLock {
          $0 = try! TubeSDKClient(
            scheme: "https", host: session.host, token: session.token, session: urlSession)
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
        return .run { send in
          try? await authClient.deleteSession()
          await send(.delegate(.didLogout))
        }

      case .dismiss:
        return .run { [dismiss] _ in
          await dismiss()
        }

      case .watchHistory:
        return .none

      case .delegate:
        return .none

      case .testNotification:
        return .run { @MainActor _ in
          await PeerTubeSwiftApp.performSubscriptionRefresh()
        }
      }
    }
    .ifLet(\.$editInstance, action: \.editInstance) {
      InstanceManagerFeature()
    }
    .ifLet(\.$login, action: \.login) {
      LoginFeature()
    }
    Scope(state: \.watchHistory, action: \.watchHistory) {
      WatchHistoryFeature()
    }
  }
}

struct ProfileTabView: View {
    @Bindable var store: StoreOf<ProfileTabViewFeature>
    var body: some View {
        Form {
            Button {
                store.send(.accountButtonTapped)
            } label: {
                HStack(spacing: 8) {
                    Circle()
                        .frame(height: 68)
                    VStack(alignment: .leading) {
                        Text("User Name")
                            .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body))
                            .lineLimit(1)
                            .foregroundStyle(Color(uiColor: .label))
                        Text("Account & App Settings")
                            .font(
                                CustomFont.inclusiveSansRegular.swiftUIFont(size: 15, relativeTo: .subheadline)
                            )
                            .scaledToFit()
                            .lineLimit(1)
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color(uiColor: .tertiaryLabel))
                }
            }
            
            Section {
                WatchHistory(
                    store: store.scope(
                        state: \.watchHistory,
                        action: \.watchHistory
                    )
                )
            } header: {
                HStack {
                    Text("Watch History")
                        .font(
                            CustomFont.inclusiveSansSemiBold.swiftUIFont(size: 13, relativeTo: .footnote)
                        )
                        .textCase(.uppercase)
                        .foregroundStyle(Color.labelSecondary)
                    Spacer()
                    Button("Show All") {}
                }
            }
            
            Section {
                
            } header: {
                HStack {
                    Text("Playlists")
                        .font(
                            CustomFont.inclusiveSansSemiBold.swiftUIFont(size: 13, relativeTo: .footnote)
                        )
                        .textCase(.uppercase)
                        .foregroundStyle(Color.labelSecondary)
                    Spacer()
                    Button("Show All") {}
                }
            }
        }
        .navigationTitle("Your Profile")
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

#Preview {
    let _ = prepareDependencies {
        try! $0.bootstrapDatabase()
        try! $0.defaultDatabase.seed()
    }
    
    ProfileTab(
        store: Store(initialState: ProfileTabFeature.State()) {
      ProfileTabFeature()
    }
  )
}
