import ComposableArchitecture
import FontKit
import SwiftUI
import TubeSDK
import WebURL

@Reducer
struct LoginFeature {
  @ObservableState
  struct State: Equatable {
    @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(
      scheme: "https", host: "peertube.wtf")
    @Presents var editInstance: InstanceManagerFeature.State?
    var username = ""
    var password = ""
    var isLoading = false
    var errorMessage: String?
  }

  enum Action: BindableAction {
    case binding(BindingAction<State>)

    case communityButtonTapped
    case editInstance(PresentationAction<InstanceManagerFeature.Action>)

    case loginButtonTapped
    case loginResponse(Result<UserSession, Error>)
    case delegate(Delegate)

    case setClient(TubeSDKClient)

    public enum Delegate {
      case didLogin(UserSession)
    }
  }

  @Dependency(\.authClient) var authClient
  @Dependency(\.dismiss) var dismiss
  @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(
    scheme: "https", host: "peertube.wtf")

  var body: some Reducer<State, Action> {
    BindingReducer()

    Reduce<State, Action> { state, action in
      switch action {
      case .binding:
        state.errorMessage = nil
        return .none

      case .loginButtonTapped:
        state.isLoading = true
        state.errorMessage = nil

        return .run {
          [client = self.client, username = state.username, password = state.password] send in
          do {
            let credentials = try await client.getClientOAuthCredentials()
            let token = try await client.login(
              username: username, password: password, client: credentials)
            let session = UserSession(username: username, host: client.instance.host, token: token)

            // Fetch avatar from user/me
            var avatarUrl: String? = nil
            do {
              let user = try await client.getMe()
              avatarUrl = user.account?.avatars?.first?.fileUrl
            } catch {
              // Avatar fetching is optional, continue without it
              print("Failed to fetch avatar: \(error)")
            }

            let sessionWithAvatar = UserSession(
              username: session.username,
              host: session.host,
              token: session.token,
              avatarUrl: avatarUrl
            )
            await send(.loginResponse(.success(sessionWithAvatar)))
          } catch {
            await send(.loginResponse(.failure(error)))
          }
        }

      case .loginResponse(.success(let session)):
        state.isLoading = false
        return .run { [authClient = self.authClient, dismiss = self.dismiss, session] send in
          try await authClient.saveSession(session)
          await send(.delegate(.didLogin(session)))
          await dismiss()
        } catch: { _, _ in
          print("Failed to save session: \\(error)")
        }

      case .loginResponse(.failure(let error)):
        state.isLoading = false
        print("Failed to login: \\(error)")
        state.errorMessage = error.localizedDescription
        return .none

      case .communityButtonTapped:
        //        guard let url = state.client.instance.urlComponents.url?.absoluteString else {
        //          return .none
        //        }
        state.editInstance = InstanceManagerFeature.State(instanceUrlString: "")
        return .none

      case .editInstance(.presented(.delegate(let delegate))):
        switch delegate {
        case .saveNewInstance(let url):
          state.editInstance = nil
          return .run { send in
            guard let host = url.host?.serialized else { return }
            do {
              try await send(
                .setClient(TubeSDKClient(scheme: url.scheme, host: host)))
            } catch {}
          }
        }

      case .setClient(let client):
        state.$client.withLock { $0 = client }
        return .none

      case .delegate:
        return .none
      case .editInstance(_):
        return .none
      }
    }
    .ifLet(\.$editInstance, action: \.editInstance) {
      InstanceManagerFeature()
    }
  }
}

struct LoginView: View {
  @Bindable var store: StoreOf<LoginFeature>

  @ViewBuilder
  private var loginButton: some View {
    Button {
      store.send(.loginButtonTapped)
    } label: {
      if store.isLoading {
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle())
      } else {
        Text("Log In")
      }
    }
    .disabled(store.isLoading || store.username.isEmpty || store.password.isEmpty)
    .buttonStyle(RiverTertiary())
  }

  var body: some View {
    Form {
      Section {
        Button {
          store.send(.communityButtonTapped)
        } label: {
          HStack {
            Text("Select a Community")
            Spacer()
            Text(store.client.instance.host)
            Image(systemName: "chevron.right")
          }
        }
      } header: {
        HStack {
          Text("Community")
            .font(
              CustomFont.inclusiveSansSemiBold.swiftUIFont(size: 13, relativeTo: .footnote)
            )
            .textCase(.uppercase)
            .foregroundStyle(Color("Label/Secondary"))
        }
      }

      Section {
        TextField("Username", text: $store.username)
          .textContentType(.username)
          .autocapitalization(.none)
      } header: {
        HStack {
          Text("Email")
            .font(
              CustomFont.inclusiveSansSemiBold.swiftUIFont(size: 13, relativeTo: .footnote)
            )
            .textCase(.uppercase)
            .foregroundStyle(Color("Label/Secondary"))
        }
      }

      Section {
        SecureField("Password", text: $store.password)
          .textContentType(.password)
      } header: {
        HStack {
          Text("Password")
            .font(
              CustomFont.inclusiveSansSemiBold.swiftUIFont(size: 13, relativeTo: .footnote)
            )
            .textCase(.uppercase)
            .foregroundStyle(Color("Label/Secondary"))
        }
      }

      if let errorMessage = store.errorMessage {
        Section {
          Text(errorMessage)
            .foregroundColor(.red)
            .font(.caption)
        }
      }
    }
    .navigationTitle("Sign In")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      if #available(iOS 26.0, *) {
        ToolbarItem(placement: .primaryAction) {
          loginButton
        }
        .sharedBackgroundVisibility(.hidden)
      } else {
        ToolbarItem(placement: .primaryAction) {
          loginButton
        }
      }
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
  }
}

#Preview {
  NavigationStack {
    LoginView(
      store: Store(initialState: LoginFeature.State()) {
        LoginFeature()
      }
    )
  }
}
