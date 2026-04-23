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

extension Color {
    static func fromHash(of string: String) -> Color {
        var hash = 0
        for char in string.utf8 {
            hash = char.hashValue &+ (hash << 5) &- hash
        }

        let red = Double((hash & 0xFF0000) >> 16) / 255.0
        let green = Double((hash & 0x00FF00) >> 8) / 255.0
        let blue = Double(hash & 0x0000FF) / 255.0

        return Color(red: red, green: green, blue: blue)
    }
}
