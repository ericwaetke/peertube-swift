//
//  01_b_WhatIsPeertube.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 08.10.26.
//

import ComposableArchitecture
import FontKit
import PeerSeekSDK
import SwiftUI
import TubeSDK

enum WhatIsPeerTubeSteps {
  case whatsSpecial
  case benefits

  var index: Int {
    switch self {
    case .whatsSpecial:
      return 0
    case .benefits:
      return 1
    }
  }

  var backButtonVisible: Bool {
    switch self {
    case .whatsSpecial:
      return false
    case .benefits:
      return true
    }
  }

  var nextButtonVisible: Bool {
    switch self {
    case .whatsSpecial:
      return true
    case .benefits:
      return false
    }
  }

  var finishButtonVisible: Bool {
    switch self {
    case .whatsSpecial:
      return false
    case .benefits:
      return true
    }
  }
}

@Reducer
struct WhatIsPeertubeFeature {
  @ObservableState
  struct State: Equatable {
    var currentStep: WhatIsPeerTubeSteps = .whatsSpecial
  }

  enum Action {
    case dismissButtonTapped
    case dismiss

    case backButtonTapped
    case nextButtonTapped
    case closeButtonTapped
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .dismiss:
        return .none
      case .backButtonTapped:
        state.currentStep = .whatsSpecial
        return .none
      case .nextButtonTapped:
        state.currentStep = .benefits
        return .none
      case .closeButtonTapped:
        return .send(.dismiss)
      case .dismissButtonTapped:
        return .send(.dismiss)
      }
    }
  }
}

struct WhatIsPeerTubeView: View {
  @Bindable var store: StoreOf<WhatIsPeertubeFeature>

  var body: some View {
    NavigationStack {

      VStack(alignment: .center) {
        GeometryReader { geometry in
          HStack(spacing: 0) {
            whatsSpecial
              .padding(.horizontal, 16)
              .containerRelativeFrame(.horizontal)

            benefits
              .padding(.horizontal, 16)
              .containerRelativeFrame(.horizontal)
          }
          .zIndex(1)
          .offset(
            x: CGFloat(store.state.currentStep.index)
              * -geometry.size.width
          )
          .animation(.default, value: store.state.currentStep)
        }

        Spacer()

        bottomBar

      }
      .background(Color(uiColor: .systemBackground))
      .navigationTitle("What is PeerTube?")

      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        if #available(iOS 26.0, *) {
          ToolbarItem(placement: .topBarLeading) {
            dismissButton
          }
          .sharedBackgroundVisibility(.hidden)
        } else {
          ToolbarItem(placement: .topBarLeading) {
            dismissButton
          }
        }
      }
    }
  }

  var federated: AttributedString {
    (try? AttributedString(
      markdown:
        "Instead of all videos being stored on a single large server like YouTube, they are distributed across many small **communities** (called instances) worldwide. [Here is a list with all communities.](https://woven.design)",
      options: .init(interpretedSyntax: .inlineOnly))) ?? AttributedString("")
  }
  var openSource: AttributedString {
    (try? AttributedString(
      markdown: "Anyone can run their own **PeerTube** server or use an existing instance.",
      options: .init(interpretedSyntax: .inlineOnly))) ?? AttributedString("")
  }

  @ViewBuilder
  var whatsSpecial: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Whats Special About PeerTube?")
        .font(CustomFont.fjallaOne.swiftUIFont(size: 28, relativeTo: .title))

      InfoCard(title: "Federated") {
        Text(federated)
          .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body))
      }
      InfoCard(title: "Open Source") {
        Text(openSource)
          .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body))
      }
    }
  }

  struct InfoCard<Content: View>: View {
    let title: String
    let titleIcon: String?
    let illustration: Bool
    @ViewBuilder var content: () -> Content

    init(title: String, content: @escaping () -> Content) {
      self.title = title
      self.titleIcon = nil
      self.illustration = true
      self.content = content
    }

    init(title: String, titleIcon: String, content: @escaping () -> Content) {
      self.title = title
      self.titleIcon = titleIcon
      self.illustration = false
      self.content = content
    }

    var body: some View {
      HStack {
        VStack(alignment: .leading, spacing: 12) {
          HStack(spacing: 6) {
            if let titleIcon {
              Image(systemName: titleIcon)
                .foregroundStyle(Color.Label.action)
                .background {
                  Circle()
                    .stroke(.separator, lineWidth: 0.33)
                    .fill(Color.Fill.secondary)
                    .frame(width: 28, height: 28)
                }
                .frame(width: 28, height: 28)
            }
            Text(title)
              .font(CustomFont.fjallaOne.swiftUIFont(size: 22, relativeTo: .title2))
          }
          content()
        }
        Spacer()
      }
      .frame(width: .infinity)
      .padding(.top, illustration ? 120 : 20)
      .padding(.horizontal, 16)
      .padding(.bottom, 20)

      .background {
        RoundedRectangle(cornerRadius: 21)
          .fill(Color(uiColor: .secondarySystemBackground))
          .stroke(.separator, lineWidth: 0.33)
      }
    }
  }

  @ViewBuilder
  var benefits: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("What are the benefits?")
        .font(CustomFont.fjallaOne.swiftUIFont(size: 28, relativeTo: .title))

      InfoCard(title: "No Censorship", titleIcon: "checkmark") {
        Text("No censorship by a single company, as many independent servers exist.")
          .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body))
      }

      InfoCard(title: "Independent", titleIcon: "checkmark") {
        Text("Less dependence on large tech corporations. The people control the platform.")
          .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body))
      }

      InfoCard(title: "Privacy-Friendly", titleIcon: "checkmark") {
        Text("Most communities do not store user data or display ads.")
          .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body))
      }
    }
  }

  @ViewBuilder
  var bottomBar: some View {
    HStack {
      if store.currentStep.backButtonVisible {
        Button("Back") {
          store.send(.backButtonTapped)
        }
        .buttonStyle(RiverButtonLarge(type: .gray))
        .transition(.offset(y: 50).combined(with: .blurReplace))
      }
      Spacer()

      if store.currentStep.nextButtonVisible || store.currentStep.finishButtonVisible {
        Button {
          if store.currentStep.nextButtonVisible {
            store.send(.nextButtonTapped)
          } else {
            store.send(.closeButtonTapped)
          }
        } label: {
          Text(store.currentStep.nextButtonVisible ? "Next" : "Close")
        }
        .buttonStyle(RiverButtonLarge(type: .filled))
        .transition(.offset(y: 50).combined(with: .blurReplace))
      }
    }
    .padding()
    //    .padding(.bottom, 44)
    .ignoresSafeArea()
    .containerRelativeFrame(.horizontal)
    //    .zIndex(2)
    .animation(.default, value: store.state.currentStep.backButtonVisible)
    .animation(.default, value: store.state.currentStep.nextButtonVisible)
  }

  @ViewBuilder
  var dismissButton: some View {
    Button {
      store.send(.dismissButtonTapped)
    } label: {
      Image(systemName: "xmark")
    }
    .buttonStyle(RiverButtonToolbar(type: .gray))
  }
}

#Preview {
  @Previewable @State var sheetOpen = true
  NavigationStack {
    Button("OpenSheet") {
      sheetOpen = true
    }
    .sheet(isPresented: $sheetOpen) {
      WhatIsPeerTubeView(
        store: Store(initialState: WhatIsPeertubeFeature.State()) {
          WhatIsPeertubeFeature()
        }
      )
    }
  }
}

#Preview {
  WhatIsPeerTubeView(
    store: Store(
      initialState: WhatIsPeertubeFeature.State(
        currentStep: .benefits
      )
    ) {
      WhatIsPeertubeFeature()
    }
  )
}
