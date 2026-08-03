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
public struct SettingsFeature {
  @ObservableState
  public struct State: Equatable {
    let text: String
  }

  public enum Action {
    case buttonTapped
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .buttonTapped:
        return .none
      }
    }
  }
}

public struct SettingsView: View {
  @Bindable var store: StoreOf<SettingsFeature>

  public var body: some View {
    Form {
      Section {
        Button {
        } label: {
          Text("peertube.wtf")
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
            .foregroundStyle(Color.labelSecondary)
          Spacer()
        }
      }
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
              .foregroundStyle(Color.labelAction)
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
            .foregroundStyle(Color.labelSecondary)
          Spacer()
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
            .foregroundStyle(Color.labelSecondary)
          Spacer()
        }
      }
      Button {
      } label: {
        Text("Log out")
          .foregroundStyle(Color.labelAction)
          .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body))
          .containerRelativeFrame(.horizontal)
      }
    }
    .navigationTitle("Account Settings")
  }
}

#Preview {
  NavigationStack {
    SettingsView(
      store: Store(
        initialState: SettingsFeature.State(text: "some")
      ) {
        SettingsFeature()
      })
  }
}
