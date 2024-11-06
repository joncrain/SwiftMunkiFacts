// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "GatekeeperPlugin",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "GatekeeperPlugin",
            type: .dynamic,
            targets: ["GatekeeperPlugin"]
        )
    ],
    dependencies: [
        .package(name: "MunkiFactsInterface", path: "../../MunkiFactsInterface")
    ],
    targets: [
        .target(
            name: "GatekeeperPlugin",
            dependencies: [
                .product(name: "MunkiFactsInterface", package: "MunkiFactsInterface")
            ]
        )
    ]
)
