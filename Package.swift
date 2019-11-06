// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Teddy",
    products: [
        .library(name: "Teddy", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),

        // SlackKit
        .package(url: "https://github.com/pvzig/SlackKit.git", .upToNextMinor(from: "4.5.0"))
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "Vapor", "SlackKit"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

