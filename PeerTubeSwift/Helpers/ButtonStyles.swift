//
//  ButtonStyles.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 28.07.26.
//

import FontKit
import SwiftUI

enum RiverButtonLargeType {
  case filled
  case gray
  case destructive
  case plain

  var backgroundResting: Color {
    switch self {
    case .filled:
      return Color("Fill/Primary")
    case .gray:
      return Color("Fill/Secondary")
    case .destructive:
      return Color("Fill/Destructive")
    case .plain:
      return Color.clear
    }
  }

  var backgroundPressed: Color {
    switch self {
    case .filled:
      return backgroundResting.mix(with: .black, by: 0.2)
    case .plain:
      return Color.clear
    default:
      return backgroundResting.mix(with: .black, by: 0.1)
    }
  }

  var foregroundStyle: Color {
    switch self {
    case .filled:
      return .white
    case .gray:
      return Color("Label/Action")
    case .destructive:
      return Color("Label/Destructive")
    case .plain:
      return Color("Label/Action")
    }
  }
}

struct RiverButtonLarge: ButtonStyle {
  let type: RiverButtonLargeType

  func makeBody(configuration: ButtonStyleConfiguration) -> some View {
    configuration.label
      .font(CustomFont.inclusiveSansSemiBold.swiftUIFont(size: 17, relativeTo: .body))
      .padding(.horizontal, 20)
      .padding(.vertical, 4)
      .frame(height: 52)
      .foregroundStyle(type.foregroundStyle)
      .clipShape(Capsule())
      .background {
        Capsule()
          .fill(
            RiverButtonLargeShadow(
              color: configuration.isPressed ? type.backgroundPressed : type.backgroundResting
            )
          )
      }
      .overlay {
        if type != .plain {
          Capsule()
            .stroke(Color(uiColor: .tertiaryLabel), lineWidth: 0.3)
        }
      }
  }
}

// Overview on ShapeStyle Usage (e.g. light or dark color scheme) https://developer.apple.com/documentation/swiftui/shapestyle
struct RiverButtonLargeShadow: ShapeStyle {
  let color: Color
  func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
    return
      color
      .shadow(
        .inner(color: .white.opacity(0.3), radius: 4, y: 2)
      )
      .shadow(
        .inner(color: .black.opacity(0.1), radius: 2, y: -2)
      )
      .shadow(
        .drop(color: .black.opacity(0.15), radius: 2, y: 2)
      )
  }
}

struct RiverButtonSmallShadow: ShapeStyle {
  let color: Color
  func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
    return
      color
      .shadow(
        .inner(color: .white.opacity(0.3), radius: 2, y: 1)
      )
      .shadow(
        .inner(color: .black.opacity(0.1), radius: 1, y: -1)
      )
      .shadow(
        .drop(color: .black.opacity(0.15), radius: 2, y: 2)
      )
  }
}

enum RiverButtonToolbarType {
  case fill
  case gray

  var backgroundResting: Color {
    switch self {
    case .fill:
      return Color("Fill/Primary")
    case .gray:
      return Color("Fill/Secondary")
    }
  }

  var backgroundPressed: Color {
    switch self {
    case .fill:
      return backgroundResting.mix(with: .black, by: 0.2)
    case .gray:
      return backgroundResting.mix(with: .black, by: 0.1)
    }
  }

  var foregroundStyle: Color {
    switch self {
    case .fill:
      return .white
    case .gray:
      return Color("Label/Action")
    }
  }
}

struct RiverButtonToolbar: ButtonStyle {
  let type: RiverButtonToolbarType

  func makeBody(configuration: ButtonStyleConfiguration) -> some View {
    configuration.label
      .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body))
      .padding(.horizontal, 16)
      .padding(.vertical, 4)
      .frame(height: 44)
      .foregroundStyle(type.foregroundStyle)
      .clipShape(Capsule())
      .background {
        Capsule()
          .fill(
            RiverButtonLargeShadow(
              color: configuration.isPressed ? type.backgroundPressed : type.backgroundResting
            )
          )
      }
      .overlay {
        Capsule()
          .stroke(Color(uiColor: .tertiaryLabel), lineWidth: 0.3)
      }
  }
}

enum RiverButtonSmallType {
  case filled
  case tinted
  case tertiary
  case tertiaryActive
  case plain

  var backgroundResting: Color {
    switch self {
    case .filled, .tertiaryActive:
      return Color("Fill/Primary")
    case .tinted:
      return Color("Fill/Secondary")
    case .tertiary:
      return Color(uiColor: .secondarySystemFill)
    case .plain:
      return Color.clear
    }
  }

  var backgroundPressed: Color {
    switch self {
    case .filled, .tertiaryActive:
      return backgroundResting.mix(with: .black, by: 0.2)
    case .tinted:
      return backgroundResting.mix(with: .black, by: 0.1)
    case .tertiary:
      return Color(uiColor: .systemFill)
    case .plain:
      return Color(uiColor: .secondarySystemFill)
    }
  }

  var foregroundStyle: Color {
    switch self {
    case .filled, .tertiaryActive:
      return .white
    case .tinted:
      return Color("Label/Action")
    case .tertiary:
      return Color("Label/Secondary")
    case .plain:
      return Color("Label/Action")
    }
  }
}

struct RiverButtonSmall: ButtonStyle {
  let type: RiverButtonSmallType

  func makeBody(configuration: ButtonStyleConfiguration) -> some View {
    configuration.label
      .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 15, relativeTo: .subheadline))
      .padding(.horizontal, 10)
      .padding(.vertical, 4)
      .frame(height: 28)
      .foregroundStyle(type.foregroundStyle)
      .clipShape(Capsule())
      .background {
        if type == .plain || type == .tertiary || type == .tertiaryActive {
          Capsule()
            .fill(configuration.isPressed ? type.backgroundPressed : type.backgroundResting)
        } else {
          Capsule()
            .fill(
              RiverButtonSmallShadow(
                color: configuration.isPressed ? type.backgroundPressed : type.backgroundResting
              )
            )
        }

      }
      .overlay {
        if type != .plain && type != .tertiary && type != .tertiaryActive {
          Capsule()
            .stroke(Color(uiColor: .tertiaryLabel), lineWidth: 0.3)
        }
      }
  }
}

#Preview {
  ScrollView {
    VStack(alignment: .leading, spacing: 24) {
      Text("River Button Large").font(.headline)
      Button("Filled") {}
        .buttonStyle(RiverButtonLarge(type: .filled))
      Button("Gray") {}
        .buttonStyle(RiverButtonLarge(type: .gray))
      Button("Destructive") {}
        .buttonStyle(RiverButtonLarge(type: .destructive))
      Button("Plain Style") {}
        .buttonStyle(RiverButtonLarge(type: .plain))

      Button {

      } label: {
        Image(systemName: "ellipsis")
      }
      .buttonStyle(RiverButtonLarge(type: .filled))
    }
    .padding()

    VStack(alignment: .leading, spacing: 24) {
      Text("River Button Toolbar").font(.headline)
      Button("Fill") {}
        .buttonStyle(RiverButtonToolbar(type: .fill))
      Button("Gray") {}
        .buttonStyle(RiverButtonToolbar(type: .gray))
    }
    .padding()

    VStack(alignment: .leading, spacing: 24) {
      Text("River Button Small").font(.headline)
      Button("Filled") {}
        .buttonStyle(RiverButtonSmall(type: .filled))
      Button("Tinted") {}
        .buttonStyle(RiverButtonSmall(type: .tinted))
      Button("Tertiary") {}
        .buttonStyle(RiverButtonSmall(type: .tertiary))
      Button("Plain Style") {}
        .buttonStyle(RiverButtonSmall(type: .plain))

      Button {

      } label: {
        Image(systemName: "ellipsis")
      }
      .buttonStyle(RiverButtonSmall(type: .tertiary))
    }
    .padding()
  }
}
