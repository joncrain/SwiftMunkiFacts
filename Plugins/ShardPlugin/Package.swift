// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ShardPlugin",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "ShardPlugin",
            type: .dynamic,
            targets: ["ShardPlugin"]
        )
    ],
    dependencies: [
        .package(name: "MunkiFactsInterface", path: "../../MunkiFactsInterface")
    ],
    targets: [
        .target(
            name: "ShardPlugin",
            dependencies: [
                .product(name: "MunkiFactsInterface", package: "MunkiFactsInterface")
            ]
        )
    ]
)
