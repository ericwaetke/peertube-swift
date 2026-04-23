// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PeerTubeSwift",
platforms: [
        .iOS(.v18),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "PeerTubeSwift",
            targets: ["PeerTubeSwift"]
        ),
    ],
    dependencies: [
        // TCA - Composable Architecture
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.23.1"),
        
        // SQLiteData - Database
        .package(url: "https://github.com/pointfreeco/sqlite-data", from: "1.0.0"),
        
        // WebURL - URL handling
        .package(url: "https://github.com/karwa/swift-url", from: "0.4.0"),
        
        // TubeSDK - Local package
        .package(path: "/home/eric/Documents/GitHub/peertube-swift-sdk"),
    ],
    targets: [
        .target(
            name: "PeerTubeSwift",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "SQLiteData", package: "sqlite-data"),
                .product(name: "WebURL", package: "swift-url"),
                .product(name: "WebURLFoundationExtras", package: "swift-url"),
                .product(name: "TubeSDK", package: "peertube-swift-sdk"),
            ]
        ),
    ]
)