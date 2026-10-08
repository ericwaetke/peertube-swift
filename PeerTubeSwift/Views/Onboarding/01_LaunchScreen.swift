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
    @Presents var whatIsPeertube: WhatIsPeertubeFeature.State?
  }

  enum Action {
    case startWithoutAccountButtonTapped
    case usePeerTubeAccountButtonTapped
    case infoButtonTapped

    case whatIsPeertube(PresentationAction<WhatIsPeertubeFeature.Action>)
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .startWithoutAccountButtonTapped:
        return .none
      case .usePeerTubeAccountButtonTapped:
        return .none
      case .infoButtonTapped:
        state.whatIsPeertube = WhatIsPeertubeFeature.State()
        return .none

      case .whatIsPeertube(.presented(.dismiss)):
        state.whatIsPeertube = nil
        return .none
      case .whatIsPeertube(_):
        return .none
      }
    }
    .ifLet(\.$whatIsPeertube, action: \.whatIsPeertube) {
      WhatIsPeertubeFeature()
    }
  }
}

struct OnboardingLaunchScreenView: View {
  @Bindable var store: StoreOf<OnboardingLaunchScreenFeature>

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
    .sheet(item: $store.scope(state: \.whatIsPeertube, action: \.whatIsPeertube)) {
      whatIsPeertube in
      WhatIsPeerTubeView(store: whatIsPeertube)
        .presentationDetents([.large])
    }
    .zIndex(2)
    .containerRelativeFrame(.horizontal)
    .background(Color(uiColor: .secondarySystemBackground))
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
