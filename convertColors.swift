#!/usr/bin/env swift
//
//  convertColors.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 07.08.26.
//
//  Converts Figma-exported color tokens (Light.tokens.json / Dark.tokens.json)
//  into Xcode color assets under Resources/Assets.xcassets.
//
//  Usage (from repo root):
//    swift convertColors.swift [lightTokens] [darkTokens] [assetsDir]
//

import Foundation

struct ColorValue {
  let hex: String
  let alpha: Double
}

func die(_ message: String) -> Never {
  FileHandle.standardError.write(Data("error: \(message)\n".utf8))
  exit(1)
}

func loadJSON(_ path: String) -> [String: Any] {
  guard let data = FileManager.default.contents(atPath: path) else {
    die("Cannot read \(path)")
  }
  guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
    die("Cannot parse \(path)")
  }
  return object
}

func parseColorValue(_ value: Any) -> ColorValue? {
  guard let dict = value as? [String: Any] else { return nil }
  guard let hex = dict["hex"] as? String else { return nil }
  let alpha = dict["alpha"] as? Double ?? 1.0
  return ColorValue(hex: hex, alpha: alpha)
}

// Builds a lookup "COLORS.Family.Shade" -> resolved ColorValue from a tokens file.
func buildPaletteLookup(from tokens: [String: Any]) -> [String: ColorValue] {
  var lookup: [String: ColorValue] = [:]
  guard let colors = tokens["COLORS"] as? [String: Any] else { return lookup }

  func walk(_ node: [String: Any], prefix: [String]) {
    for (key, value) in node {
      if let dict = value as? [String: Any] {
        let isColor = dict["$type"] as? String == "color"
        if isColor, let color = parseColorValue(dict["$value"] ?? NSNull()) {
          lookup[(["COLORS"] + prefix + [key]).joined(separator: ".")] = color
        } else {
          walk(dict, prefix: prefix + [key])
        }
      }
    }
  }
  walk(colors, prefix: [])
  return lookup
}

// Collects semantic colors: returns [namePath: [String]] where namePath is like ["Label", "Primary"].
func collectSemanticColors(from tokens: [String: Any], palette: [String: ColorValue]) -> [String:
  ColorValue]
{
  var result: [String: ColorValue] = [:]
  guard let semantic = tokens["semantic"] as? [String: Any] else { return result }

  func walk(_ node: [String: Any], path: [String]) {
    for (key, value) in node {
      guard let dict = value as? [String: Any] else { continue }
      let namePath = path + [key]
      if dict["$type"] as? String == "color" {
        let nameKey = namePath.joined(separator: ".")
        if let raw = dict["$value"] as? String, raw.hasPrefix("{"), raw.hasSuffix("}") {
          let ref = String(raw.dropFirst().dropLast())
          if let color = palette[ref] {
            result[nameKey] = color
          } else {
            die("Unresolved reference \(raw) for semantic token \(nameKey)")
          }
        } else if let color = parseColorValue(dict["$value"] ?? NSNull()) {
          result[nameKey] = color
        } else {
          die("Unsupported $value for semantic token \(nameKey)")
        }
      } else {
        walk(dict, path: namePath)
      }
    }
  }
  walk(semantic, path: [])
  return result
}

func hexByte(_ pair: String) -> UInt8 {
  return UInt8(pair, radix: 16) ?? 0
}

func componentDict(_ color: ColorValue) -> [String: String] {
  guard color.hex.hasPrefix("#"), color.hex.count == 7 else {
    die("Unsupported hex \(color.hex)")
  }
  let hex = String(color.hex.dropFirst())
  let red = hexByte(String(hex[hex.startIndex..<hex.index(hex.startIndex, offsetBy: 2)]))
  let green = hexByte(
    String(hex[hex.index(hex.startIndex, offsetBy: 2)..<hex.index(hex.startIndex, offsetBy: 4)]))
  let blue = hexByte(String(hex[hex.index(hex.startIndex, offsetBy: 4)...]))
  return [
    "alpha": String(format: "%.3f", color.alpha),
    "blue": String(format: "0x%02X", blue),
    "green": String(format: "0x%02X", green),
    "red": String(format: "0x%02X", red),
  ]
}

func colorEntry(_ color: ColorValue, dark: Bool) -> [String: Any] {
  var entry: [String: Any] = [
    "color": [
      "color-space": "srgb",
      "components": componentDict(color),
    ],
    "idiom": "universal",
  ]
  if dark {
    entry["appearances"] = [
      ["appearance": "luminosity", "value": "dark"]
    ]
  }
  return entry
}

func colorSetJSON(light: ColorValue, dark: ColorValue) -> [String: Any] {
  return [
    "colors": [
      colorEntry(light, dark: false),
      colorEntry(dark, dark: true),
    ],
    "info": [
      "author": "xcode",
      "version": 1,
    ],
  ]
}

func folderJSON() -> [String: Any] {
  return [
    "info": [
      "author": "xcode",
      "version": 1,
    ],
    "properties": [
      "provides-namespace": true
    ],
  ]
}

func writeJSON(_ object: [String: Any], to path: String) {
  guard
    let data = try? JSONSerialization.data(
      withJSONObject: object, options: [.prettyPrinted, .sortedKeys]),
    let string = String(data: data, encoding: .utf8)
  else {
    die("Failed to serialize \(path)")
  }
  do {
    try string.write(toFile: path, atomically: true, encoding: .utf8)
  } catch {
    die("Failed to write \(path): \(error)")
  }
}

let arguments = CommandLine.arguments
let defaultLight = "Light.tokens.json"
let defaultDark = "Dark.tokens.json"
let defaultAssets = "PeerTubeSwift/Resources/Assets.xcassets"

let lightTokens = loadJSON(arguments.count > 1 ? arguments[1] : defaultLight)
let darkTokens = loadJSON(arguments.count > 2 ? arguments[2] : defaultDark)
let assetsDir = arguments.count > 3 ? arguments[3] : defaultAssets

let palette = buildPaletteLookup(from: lightTokens)
let lightColors = collectSemanticColors(from: lightTokens, palette: palette)
let darkColors = collectSemanticColors(from: darkTokens, palette: palette)

let assetsURL = URL(fileURLWithPath: assetsDir)

// Remove any colorsets generated by a previous run (group folders like Label/Fill)
// plus the legacy Semantic wrapper folder.
try? FileManager.default.removeItem(at: assetsURL.appendingPathComponent("Semantic"))
let groupNames = Array(
  Set(lightColors.keys.compactMap { $0.split(separator: ".").first.map { $0.capitalized } }))
for groupName in groupNames {
  try? FileManager.default.removeItem(at: assetsURL.appendingPathComponent(groupName))
}

let names = lightColors.keys.sorted()
for name in names {
  guard let light = lightColors[name], let dark = darkColors[name] else {
    die("Mismatched semantic tokens between light and dark files: \(name)")
  }
  let components = name.split(separator: ".").map { String($0) }
  guard components.count >= 2 else {
    die("Unexpected semantic token path: \(name)")
  }
  let groupName = components[0].capitalized
  let colorName = components.dropFirst().map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined(
    separator: "")

  let groupDir = assetsURL.appendingPathComponent(groupName)
  try? FileManager.default.createDirectory(at: groupDir, withIntermediateDirectories: true)
  writeJSON(folderJSON(), to: groupDir.appendingPathComponent("Contents.json").path)

  let colorSetDir = groupDir.appendingPathComponent("\(colorName).colorset")
  try? FileManager.default.createDirectory(at: colorSetDir, withIntermediateDirectories: true)
  writeJSON(
    colorSetJSON(light: light, dark: dark),
    to: colorSetDir.appendingPathComponent("Contents.json").path)

  print("Generated \(groupName)/\(colorName).colorset (light \(light.hex) / dark \(dark.hex))")
}
print("Done. \(names.count) semantic colors generated in \(assetsURL.path)")
