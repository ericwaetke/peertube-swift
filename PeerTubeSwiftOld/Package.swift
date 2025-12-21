// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PeerTubeSwift",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "PeerTubeSwift",
            targets: ["PeerTubeSwift"]
        ),
    ],
    dependencies: [
        // No external dependencies for now - keeping it lightweight
        // Core Data and URLSession are part of Foundation
    ],
    targets: [
        .target(
            name: "PeerTubeSwift",
            dependencies: [],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]
        ),
        .testTarget(
            name: "PeerTubeSwiftTests",
            dependencies: ["PeerTubeSwift"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]
        ),
    ]
)
