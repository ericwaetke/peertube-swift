//
//  InstanceManager.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 28.12.25.
//

import ComposableArchitecture
import SwiftUI
import TubeSDK
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
        case delegate(Delegate)
        case textFieldSubmitButtonPressed

        case testConnection
        case connectionResponse(Result<ServerConfig, NetworkError>)
        case setInstanceUrl(WebURL)

        @CasePathable
        enum Delegate {
            case saveNewInstance(url: WebURL)
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .instanceUrlChanged(let text):
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
            case .delegate:
                return .none
            case .testConnection:
                state.tryingInstanceConnection = true
                return .run { [instanceUrl = state.instanceUrlString] send in
                    guard let url = WebURL(instanceUrl), let host = url.host?.serialized else {
                        await send(.connectionResponse(.failure(.badURL)))
                        return
                    }
                    await send(.setInstanceUrl(url))
                    do {
                        let client = try TubeSDKClient(scheme: url.scheme, host: host)
                        let config = try await client.instance.getConfig()
                        await send(.connectionResponse(.success(config)))
                    } catch {
                        await send(
                            .connectionResponse(
                                .failure(.connectionFailed(error.localizedDescription))))
                    }
                }
            case .connectionResponse(let response):
                state.tryingInstanceConnection = false

                switch response {
                case .success(let config):
                    state.readyToSaveInstance = true
                    state.connectionError =
                        "Successfully connected to \(config.instance.name) (v\(config.serverVersion))"
                case .failure(let error):
                    state.connectionError = error.localizedDescription
                }

                return .none
            case .setInstanceUrl(let url):
                state.instanceUrl = url
                return .none
            }
        }
    }
}

enum NetworkError: Error, Equatable {
    case badURL
    case connectionFailed(String)
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .badURL:
            return String(localized: "The Instance URL doesn’t seem to be valid.")
        case .connectionFailed(let error):
            return String(localized: "Connection failed: \(error)")
        }
    }
}

struct InstanceManager: View {
    @Bindable var store: StoreOf<InstanceManagerFeature>

    var body: some View {
        Form {
            Section("Instance Details") {
                TextField(
                    "Instance URL", text: $store.instanceUrlString.sending(\.instanceUrlChanged)
                )
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
                .disabled(
                    self.store.state.instanceUrlString == ""
                        || self.store.state.tryingInstanceConnection)

                if let connectionError = self.store.state.connectionError {
                    Text(connectionError)
                        .monospaced()
                        .foregroundStyle(self.store.state.readyToSaveInstance ? .green : .red)
                }

                if self.store.state.readyToSaveInstance {
                    Label("Instance is working fine, ready to add", systemImage: "checkmark")
                }
            }
        }
    }
}
