import Foundation
import SwiftUI

extension String {
  var initials: String {
    let words = components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
    if words.count > 1 {
      return String(words[0].prefix(1) + words[1].prefix(1)).uppercased()
    } else if let firstWord = words.first, firstWord.count > 1 {
      return String(firstWord.prefix(2)).uppercased()
    } else if let firstWord = words.first {
      return String(firstWord.prefix(1)).uppercased()
    }
    return ""
  }
}

func hashString(_ input: String) -> UInt32 {
    var hash: Int32 = 0

    for scalar in input.unicodeScalars {
        hash = hash &* 31 &+ Int32(scalar.value)
    }

    return UInt32(bitPattern: hash)
}

func stringToHsl(string: String) -> Color {
    let hash = hashString(string)
    let hue: Double = Double(hash % 360);
    let saturation: Double = 65;
    let brightness: Double = 50;
    
    return Color(hue: hue, saturation: saturation, brightness: brightness)
}

func stringToIndex(string: String, arrayLength: Int) -> Int {
    return Int(floor(Double(hashString(string)))) % arrayLength - 1
}

extension Color {
  static func fromHash(of string: String) -> Color {
      let possibleColors = [
        Color.Yellow._100,
        Color.Yellow._300,
        Color.Blue._100,
        Color.Blue._300,
        Color.Orange._100,
        Color.Orange._300,
        Color.Violet._100,
        Color.Violet._300,
        Color.Cyan._100,
        Color.Cyan._300,
      ]
      
      let arrayLength = possibleColors.count
      let stringToIndex = stringToIndex(string: string, arrayLength: arrayLength)
      print("arrayLength: \(arrayLength), stringToIndex: \(stringToIndex)")
      
      
      return possibleColors[stringToIndex]
  }
}
