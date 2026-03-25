import ComposableArchitecture
import SwiftUI
import TubeSDK

@Reducer
public struct LoginFeature {
    @ObservableState
    public struct State: Equatable {
        public var username = ""
        public var password = ""
        public var isLoading = false
        public var errorMessage: String? = nil
        
        public init() {}
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case loginButtonTapped
        case loginResponse(Result<UserSession, Error>)
        case delegate(Delegate)
        
        public enum Delegate {
            case didLogin(UserSession)
        }
    }
    
    @Dependency(\.authClient) var authClient
    @Dependency(\.dismiss) var dismiss
    @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(scheme: "https", host: "peertube.wtf")
    
    public init() {}
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                state.errorMessage = nil
                return .none
                
            case .loginButtonTapped:
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { [client = self.client, username = state.username, password = state.password] send in
                    do {
                        let credentials = try await client.getClientOAuthCredentials()
                        let token = try await client.login(username: username, password: password, client: credentials)
                        let session = UserSession(username: username, host: client.instance.host, token: token)
                        await send(.loginResponse(.success(session)))
                    } catch {
                        await send(.loginResponse(.failure(error)))
                    }
                }
                
            case let .loginResponse(.success(session)):
                state.isLoading = false
                return .run { [authClient = self.authClient, dismiss = self.dismiss] send in
                    try await authClient.saveSession(session)
                    await send(.delegate(.didLogin(session)))
                    await dismiss()
                } catch: { error, _ in
                    print("Failed to save session: \\(error)")
                }
                
            case let .loginResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}

public struct LoginView: View {
    @Bindable var store: StoreOf<LoginFeature>
    
    public init(store: StoreOf<LoginFeature>) {
        self.store = store
    }
    
    public var body: some View {
        Form {
            Section(header: Text("Credentials")) {
                TextField("Username", text: $store.username)
                    .textContentType(.username)
                    .autocapitalization(.none)
                SecureField("Password", text: $store.password)
                    .textContentType(.password)
            }
            
            if let errorMessage = store.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            Section {
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
            }
        }
        .navigationTitle("Login")
    }
}
