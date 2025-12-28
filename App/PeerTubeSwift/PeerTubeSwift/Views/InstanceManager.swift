//
//  InstanceManager.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 28.12.25.
//

import ComposableArchitecture
import SwiftUI
import WebURL

@Reducer
struct InstanceManagerFeature {
    @ObservableState
    struct State: Equatable {
        var instanceUrlString: String = ""
        var instanceUrl: WebURL?
        var readyToSaveInstance: Bool = false
        var tryingInstanceConnection: Bool = false
        
        var connectionError: String?
    }
    
    enum Action {
        case instanceUrlChanged(String)
        case attemptConnectionButtonPressed
        case textFieldSubmitButtonPressed
        
        case testConnection
        case connectionResponse(Result<String, NetworkError>)
        case setInstanceUrl(WebURL)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .instanceUrlChanged(text):
                state.instanceUrlString = text
                state.connectionError = nil
//                TODO: Enable onlyonce effect-cancellation is implemented
//                state.tryingInstanceConnection = false
                state.readyToSaveInstance = false

                return .none
            case .attemptConnectionButtonPressed:
                return .send(.testConnection)
            case .textFieldSubmitButtonPressed:
                return .send(.testConnection)
                
            case .testConnection:
                state.tryingInstanceConnection = true
                return .run { [instanceUrl = state.instanceUrlString] send in
                    // TODO: Implement the real test, this is only a stub

                    guard let url = WebURL(instanceUrl) else {
                        await send(.connectionResponse(.failure(.badURL)))
                        return
                    }
                    await send(.setInstanceUrl(url))
                    try await Task.sleep(for: .seconds(1))
                    await send(.connectionResponse(.success("Connection Successful")))
                }
            case let .connectionResponse(response):
                state.tryingInstanceConnection = false
                
                switch response {
                case let .success(successMessage):
                    state.readyToSaveInstance = true
                case let .failure(error):
                    state.connectionError = error.localizedDescription
                }
                
                return .none
            case let .setInstanceUrl(url):
                state.instanceUrl = url
                return .none
            }
        }
    }
}

enum NetworkError: Error {
    case badURL
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            case .badURL:
                return String(localized: "The Instance URL doesn’t seem to be valid.")
        }
    }
}

struct InstanceManager: View {
    @Bindable var store: StoreOf<InstanceManagerFeature>
    
    var body: some View {
        Form {
            Section("Instance Details") {
                TextField("Instance URL", text: $store.instanceUrlString.sending(\.instanceUrlChanged))
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onSubmit {
                        self.store.send(.textFieldSubmitButtonPressed)
                    }
            }
            
            Section("Connection") {
                Button {
                    self.store.send(.attemptConnectionButtonPressed)
                } label: {
                    HStack {
                        Text("Attempt connection")
                        Spacer()
                        if self.store.state.tryingInstanceConnection {
                            ProgressView()
                        }
                    }
                }
                .disabled(self.store.state.instanceUrlString == "" || self.store.state.tryingInstanceConnection)
                
                if let connectionError = self.store.state.connectionError {
                    Text(connectionError)
                        .monospaced()
                }
                
                if self.store.state.readyToSaveInstance {
                    Label("Instance is working fine, ready to add", systemImage: "checkmark")
                }
            }
        
        }
    }
}

#Preview {
    NavigationStack {
        InstanceManager(store: Store(initialState: InstanceManagerFeature.State()) {
            InstanceManagerFeature()
        })
        .navigationTitle("Instance Manager")
        .toolbar {
            ToolbarItem {
                Button("Save") {}
                    .disabled(true)
            }
        }
    }
}
