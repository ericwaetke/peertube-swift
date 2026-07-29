import FontKit
//
//  Fonts.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 28.07.26.
//
import Foundation

extension CustomFont {
  public static let fjallaOne = CustomFont(
    name: "FjallaOne-Regular",
    displayName: "Fjalla One Regular",
    fileExtension: "ttf",
    bundle: .main,
    systemFontScaleFactor: 1.0
  )

  public static let inclusiveSansRegular = CustomFont(
    name: "InclusiveSans-Regular",
    displayName: "Inclusive Sans Regular",
    fileExtension: "ttf",
    bundle: .main,
    systemFontScaleFactor: 1.0
  )
  public static let inclusiveSansItalic = CustomFont(
    name: "InclusiveSans-Italic",
    displayName: "Inclusive Sans Italic",
    fileExtension: "ttf",
    bundle: .main,
    systemFontScaleFactor: 1.0
  )

  public static let inclusiveSansSemiBold = CustomFont(
    name: "InclusiveSans-SemiBold",
    displayName: "Inclusive Sans SemiBold",
    fileExtension: "ttf",
    bundle: .main,
    systemFontScaleFactor: 1.0
  )
  public static let inclusiveSansSemiBoldItalic = CustomFont(
    name: "InclusiveSans-SemiBoldItalic",
    displayName: "Inclusive Sans SemiBold Italic",
    fileExtension: "ttf",
    bundle: .main,
    systemFontScaleFactor: 1.0
  )
}
