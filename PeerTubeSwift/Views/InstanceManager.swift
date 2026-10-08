//
//  InstanceManager.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 28.12.25.
//

import ComposableArchitecture
import FontKit
import SwiftUI
import TubeSDK
import WebURL

@Reducer
struct InstanceManagerFeature {
  @ObservableState
  struct State: Equatable {

    @Shared(.inMemory("client")) var client: TubeSDKClient?
    var instanceUrlString: String = ""
    var instanceUrl: WebURL?
    var readyToSaveInstance: Bool {
      guard let selectedInstanceId else {
        return false
      }

      return instanceHealth[selectedInstanceId] == .healthy
    }
    var tryingInstanceConnection: Bool = false

    var connectionError: String?
    var instances: [TubeSDK.PeerTubeInstance] = []
    var searchText: String = ""
    var selectedInstanceId: Int?
    var instanceHealth: [Int: InstanceHealthStatus] = [:]
    var selectedCustomInstance: CustomInstanceEntry?

    var selectedInstance: TubeSDKClient? {
      if let selectedCustomInstance,
        let host = selectedCustomInstance.url.host
      {
        do {
          return try TubeSDKClient(scheme: selectedCustomInstance.url.scheme, host: host.serialized)
        } catch {
          // TODO: Display error somewhere
          print(error)
          return nil
        }
      }

      if let selectedInstanceId,
        let instance = instances.first(where: { $0.id == selectedInstanceId })
      {
        do {
          return try TubeSDKClient(scheme: "https", host: instance.host)
        } catch {
          // TODO: Display error somewhere
          print(error)
          return nil
        }
      }

      if let client {
        return client
      }

      return nil
    }
  }

  enum Action {
    case instanceUrlChanged(String)
    case attemptConnectionButtonPressed
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
    case selectNewInstance

    case saveButtonTapped
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .instanceUrlChanged(let text):
        state.instanceUrlString = text
        state.connectionError = nil
        // TODO: Enable only once effect-cancellation is implemented

        return .none
      case .attemptConnectionButtonPressed:
        return .send(.testConnection)
      case .textFieldSubmitButtonPressed:
        return .send(.testConnection)
      case .refreshPull, .onAppear:
        return .send(.loadInstances)
      case .loadInstances:
        return .run { send in
          var pager = TubeSDKClient.instances(
            pageSize: 50, query: InstanceQueryParameters(healthy: true))
          while pager.hasMorePages {
            let chunk = try await pager.nextPage()
            await send(.addInstancesToList(chunk))
          }
        }
      case .addInstancesToList(let instances):
        state.instances.insert(contentsOf: instances, at: state.instances.endIndex)

        // Return Early when Instance already selected
        // To not waste resources matching instances when we know its selected already
        if state.selectedInstanceId != nil {
          return .none
        }

        // Check if one of the incoming instances is the currently set client
        // if so, select it, so the checkmark is correct
        if let client = state.client,
          let matchingInstanceToClient = instances.first(where: { $0.host == client.instance.host })
        {
          state.selectedInstanceId = matchingInstanceToClient.id
        }
        return .none
      case .searchTextChanged(let text):
        state.searchText = text
        if state.selectedCustomInstance == nil {
          state.connectionError = nil
          state.tryingInstanceConnection = false
        }
        return .cancel(id: TestConnectionCancelID.id)
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
      case .selectNewInstance:
        state.instanceUrlString = state.searchText
        return .send(.testConnection)

      // WARN/TODO: The connection isn’t tested if it’s coming directly from the `client`
      case .testConnection:
        state.tryingInstanceConnection = true
        return .run { [instanceUrl = state.instanceUrlString] send in
          let candidate =
            instanceUrl.contains("://")
            ? instanceUrl
            : "https://" + instanceUrl
          guard let url = WebURL(candidate), let host = url.host?.serialized else {
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
        .cancellable(id: TestConnectionCancelID.id)
      case .connectionResponse(let response):
        state.tryingInstanceConnection = false

        switch response {
        case .success(let config):
          state.connectionError =
            "Successfully connected to \(config.instance.name) (v\(config.serverVersion))"
          if let url = state.instanceUrl {
            state.selectedCustomInstance = CustomInstanceEntry(url: url)
          }
        case .failure(let error):
          state.connectionError = error.localizedDescription
        }

        return .none
      case .setInstanceUrl(let url):
        state.instanceUrl = url
        return .none
      case .saveButtonTapped:
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

struct CustomInstanceEntry: Equatable {
  var url: WebURL
}

struct HealthCheckCancelID: Hashable {
  static let id = HealthCheckCancelID()
}

struct TestConnectionCancelID: Hashable {
  static let id = TestConnectionCancelID()
}

struct InstanceManager: View {
  @Environment(\.dismissSearch) var dismissSearch
  @Bindable var store: StoreOf<InstanceManagerFeature>

  var body: some View {
    List {
      if let selectedInstance = store.selectedInstance {
        Section {
          Text("Selected Instance is: \(selectedInstance.instance.host)")
        } header: {
          Text("Currently Selected Instance")
        }
      }

      if let custom = store.selectedCustomInstance {
        Section {
          HStack {
            Text(custom.url.host?.serialized ?? custom.url.serialized())
              .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body))
              .foregroundStyle(Color(uiColor: .label))
            Spacer()
            Image(systemName: "checkmark")
              .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body))
              .foregroundStyle(Color(uiColor: .label))
          }
        }
      }
      Section {
        ForEach(filteredInstances) { instance in
          Button {
            store.send(.selectInstance(instance.id))
            dismissSearch()
          } label: {
            HStack {
              VStack(alignment: .leading) {
                Text(instance.host)
                  .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body))
                  .foregroundStyle(Color(uiColor: .label))
                if let health = store.instanceHealth[instance.id] {
                  Text("\(health) connection")
                }
              }
              Spacer()
              Image(systemName: "checkmark")
                .opacity(store.selectedInstanceId == instance.id ? 1 : 0)
                .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body))
                .foregroundStyle(Color(uiColor: .label))
            }
          }
        }
      }
      if let candidate = newInstanceCandidate {
        Section {
          Button {
            store.send(.selectNewInstance)
            dismissSearch()
          } label: {
            HStack {
              Text(candidate)
                .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body))
                .foregroundStyle(Color(uiColor: .label))
              Spacer()
            }
          }
        }
      }
    }
    .searchable(text: $store.searchText.sending(\.searchTextChanged))
    .textInputAutocapitalization(.never)
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

  var newInstanceCandidate: String? {
    guard !store.searchText.isEmpty, filteredInstances.isEmpty else { return nil }
    if let custom = store.selectedCustomInstance,
      custom.url.host?.serialized.caseInsensitiveCompare(store.searchText) == .orderedSame
    {
      return nil
    }
    return store.searchText
  }
}

#Preview("Without Client") {
  var state = InstanceManagerFeature.State()
  NavigationStack {
    InstanceManager(
      store: Store(initialState: state) {
        InstanceManagerFeature()
      }
    )
    .navigationTitle("Instance Manager")
    .toolbar {
      ToolbarItem {
        Button("Save") {}
          .disabled(!state.readyToSaveInstance)
      }
    }
  }
}

#Preview("With Client") {
  var state = InstanceManagerFeature.State(
    client: Shared(
      wrappedValue: try! TubeSDKClient(scheme: "https", host: "peertube.wtf"),
      .inMemory("client"))
  )
  NavigationStack {
    InstanceManager(
      store: Store(initialState: state) {
        InstanceManagerFeature()
      }
    )
    .navigationTitle("Instance Manager")
    .toolbar {
      ToolbarItem {
        Button("Save") {}
          .disabled(!state.readyToSaveInstance)
      }
    }
  }
}
