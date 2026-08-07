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
    @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(
      scheme: "https", host: "peertube.wtf")
    var instanceUrlString: String = ""
    var instanceUrl: WebURL?
    var readyToSaveInstance: Bool = false
    var tryingInstanceConnection: Bool = false

    var connectionError: String?
    var instances: [TubeSDK.PeerTubeInstance] = []
    var searchText: String = ""
    var selectedInstanceId: Int?
    var instanceHealth: [Int: InstanceHealthStatus] = [:]
  }

  enum Action {
    case instanceUrlChanged(String)
    case attemptConnectionButtonPressed
    case delegate(Delegate)
    case textFieldSubmitButtonPressed

    case testConnection
    case connectionResponse(Result<ServerConfig, NetworkError>)
    case setInstanceUrl(WebURL)

    case onAppear
    case refreshPull
    case loadInstances
    case addInstancesToList([TubeSDK.PeerTubeInstance])
    case searchTextChanged(String)
    case selectInstance(Int)
    case instanceHealthResult(Int, Bool)

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
      case .refreshPull, .onAppear:
        return .send(.loadInstances)
      case .loadInstances:
        return .run { [client = state.client] send in
          var pager = client.instances(pageSize: 50, query: InstanceQueryParameters(healthy: true))
          while pager.hasMorePages {
            let chunk = try await pager.nextPage()
            await send(.addInstancesToList(chunk))
          }
        }
      case .addInstancesToList(let instances):
        state.instances.insert(contentsOf: instances, at: state.instances.endIndex)
        return .none
      case .searchTextChanged(let text):
        state.searchText = text
        return .none
      case .selectInstance(let id):
        state.selectedInstanceId = id
        state.instanceHealth[id] = .checking
        guard let instance = state.instances.first(where: { $0.id == id }) else {
          return .none
        }
        return .run { send in
          do {
            let client = try TubeSDKClient(scheme: "https", host: instance.host)
            _ = try await client.instance.getConfig()
            await send(.instanceHealthResult(id, true))
          } catch {
            await send(.instanceHealthResult(id, false))
          }
        }
        .cancellable(id: HealthCheckCancelID.id)
      case .instanceHealthResult(let id, let healthy):
        state.instanceHealth[id] = healthy ? .healthy : .unhealthy
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
            await send(.connectionResponse(.failure(.connectionFailed(error.localizedDescription))))
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

enum InstanceHealthStatus: Equatable {
  case checking, healthy, unhealthy
}

struct HealthCheckCancelID: Hashable {
  static let id = HealthCheckCancelID()
}

struct InstanceManager: View {
  @Bindable var store: StoreOf<InstanceManagerFeature>

  var body: some View {
    List(filteredInstances) { instance in
      Button {
        store.send(.selectInstance(instance.id))
      } label: {
        HStack {
          Image(systemName: "checkmark")
            .opacity(store.selectedInstanceId == instance.id ? 1 : 0)
          Text(instance.host)
          Spacer()
          trailingStatus(for: instance.id)
        }
      }
    }
    .searchable(text: $store.searchText.sending(\.searchTextChanged))
    .refreshable {
      store.send(.refreshPull)
    }
    .onAppear {
      store.send(.onAppear)
    }
  }

  var filteredInstances: [TubeSDK.PeerTubeInstance] {
    guard !store.searchText.isEmpty else { return store.instances }
    return store.instances.filter { $0.host.localizedCaseInsensitiveContains(store.searchText) }
  }

  @ViewBuilder
  func trailingStatus(for id: Int) -> some View {
    switch store.instanceHealth[id] {
    case .checking:
      ProgressView()
    case .healthy:
      Image(systemName: "network")
    case .unhealthy:
      Image(systemName: "network.slash")
    case nil:
      EmptyView()
    }
  }
}

#Preview {
  NavigationStack {
    InstanceManager(
      store: Store(initialState: InstanceManagerFeature.State()) {
        InstanceManagerFeature()
      }
    )
    .navigationTitle("Instance Manager")
    .toolbar {
      ToolbarItem {
        Button("Save") {}
          .disabled(true)
      }
    }
  }
}
