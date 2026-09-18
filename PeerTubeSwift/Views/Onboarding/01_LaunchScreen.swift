//
//  LaunchScreen.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 18.09.26.
//

import ComposableArchitecture
import FontKit
import SwiftUI

@Reducer
struct OnboardingLaunchScreenFeature {
  @ObservableState
  struct State: Equatable {

  }

  enum Action {
    case startWithoutAccountButtonTapped
    case usePeerTubeAccountButtonTapped
    case infoButtonTapped
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {

      case .startWithoutAccountButtonTapped:
        return .none
      case .usePeerTubeAccountButtonTapped:
        return .none
      case .infoButtonTapped:
        return .none
      }
    }
  }
}

struct OnboardingLaunchScreenView: View {
  let store: StoreOf<OnboardingLaunchScreenFeature>

  var body: some View {
    ZStack {
      VStack {
        Text("Powered by PeerTube")
          .font(CustomFont.inclusiveSansSemiBold.swiftUIFont(size: 11, relativeTo: .caption2))
          .foregroundStyle(Color.Label.secondary)

        Spacer()

        headlineArea

        Spacer()

        actionArea
      }
    }
  }

  @ViewBuilder
  var headlineArea: some View {
    VStack {
      Text("River")
        .textCase(.uppercase)
        .font(CustomFont.fjallaOne.swiftUIFont(size: 79, relativeTo: .headline))
        .foregroundStyle(Color.Label.primary)

      Text("Stream Videos Independent of the Tech Giants")
        .textCase(.uppercase)
        .font(CustomFont.fjallaOne.swiftUIFont(size: 28, relativeTo: .title))
        .multilineTextAlignment(.center)
        .foregroundStyle(Color.Label.primary)
    }
    .padding()
  }

  @ViewBuilder
  var actionArea: some View {
    VStack {
      Button("Get Started Without Account") {
        store.send(.startWithoutAccountButtonTapped)
      }
      .buttonStyle(RiverButtonLarge(type: .filled))

      Button("Use Peertube Account") {
        store.send(.usePeerTubeAccountButtonTapped)
      }
      .buttonStyle(RiverButtonLarge(type: .gray))

      Button("What’s Peertube?") {
        store.send(.infoButtonTapped)
      }
      .buttonStyle(RiverButtonLarge(type: .plain))
    }
  }
}

#Preview {
  OnboardingLaunchScreenView(
    store: Store(initialState: OnboardingLaunchScreenFeature.State()) {
      OnboardingLaunchScreenFeature()
    }
  )
}
