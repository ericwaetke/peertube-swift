//
//  Settings.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 03.08.26.
//

import ComposableArchitecture
import FontKit
import SwiftUI
import TubeSDK

@Reducer
struct SettingsFeature {
  @ObservableState
  struct State: Equatable {
    let text: String
    @Shared(.inMemory("session")) var session: UserSession?

    @Shared(.inMemory("client")) var client: TubeSDKClient?
  }

  enum Action {
    case buttonTapped
    case logoutButtonTapped
  }

  @Dependency(\.authClient) var authClient

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .buttonTapped:
        return .none

      case .logoutButtonTapped:
        state.$session.withLock { $0 = nil }
        //      state.$client.withLock { $0.currentToken = nil }
        return .run { send in
          try? await authClient.deleteSession()
        }
      }
    }
  }
}

struct SettingsView: View {
  @Bindable var store: StoreOf<SettingsFeature>

  var body: some View {
    Form {
      if let client = store.client {
        Section {
          Button {
          } label: {
            Text(client.instance.host)
              .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body))
              .foregroundStyle(Color(uiColor: .label))
          }
        } header: {
          HStack {
            Text("Your Community")
              .font(
                CustomFont.inclusiveSansSemiBold.swiftUIFont(size: 13, relativeTo: .footnote)
              )
              .textCase(.uppercase)
              .foregroundStyle(Color("Label/Secondary"))
            Spacer()
          }
        }
      }

      if store.session != nil {
        Section {
          Button {
          } label: {
            Text("Display Name")
              .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body))
              .foregroundStyle(Color(uiColor: .label))
          }
          Button {
          } label: {
            Text("Email")
              .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body))
              .foregroundStyle(Color(uiColor: .label))
          }
          Button {
          } label: {
            HStack {
              Text("Password")
                .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body))
                .foregroundStyle(Color(uiColor: .label))
              Spacer()
              Text("Change")
                .foregroundStyle(Color("Label/Action"))
                .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body))
            }
          }
        } header: {
          HStack {
            Text("Account")
              .font(
                CustomFont.inclusiveSansSemiBold.swiftUIFont(size: 13, relativeTo: .footnote)
              )
              .textCase(.uppercase)
              .foregroundStyle(Color("Label/Secondary"))
            Spacer()
          }
        }
      }
      Section {
        Button {
        } label: {
          Text("Languages")
            .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body))
            .foregroundStyle(Color(uiColor: .label))
        }
        Button {
        } label: {
          Text("Prefered Categories")
            .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body))
            .foregroundStyle(Color(uiColor: .label))
        }
      } header: {
        HStack {
          Text("Recommendations")
            .font(
              CustomFont.inclusiveSansSemiBold.swiftUIFont(size: 13, relativeTo: .footnote)
            )
            .textCase(.uppercase)
            .foregroundStyle(Color("Label/Secondary"))
          Spacer()
        }
      }
      Button {
        store.send(.logoutButtonTapped)
      } label: {
        Text("Log out")
          .foregroundStyle(Color("Label/Action"))
          .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body))
          .containerRelativeFrame(.horizontal)
      }
    }
    .navigationTitle("Account Settings")
  }
}

#Preview("Logged Out") {
  NavigationStack {
    SettingsView(
      store: Store(
        initialState: SettingsFeature.State(text: "some")
      ) {
        SettingsFeature()
      })
  }
}

#Preview("Logged In") {
  NavigationStack {
    SettingsView(
      store: Store(
        initialState: SettingsFeature.State(
          text: "some",
          session: Shared(
            wrappedValue: UserSession(
              username: "somepeertubeuser",
              host: "river.video",
              token: OAuthToken(accessToken: "", refreshToken: "", tokenType: "", expiresIn: 1)
            ), .inMemory("session")),
          client: Shared(
            wrappedValue: try! TubeSDKClient(scheme: "https", host: "peertube.wtf"),
            .inMemory("session"))
        )
      ) {
        SettingsFeature()
      })
  }
}
