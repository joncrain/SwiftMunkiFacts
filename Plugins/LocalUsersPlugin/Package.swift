// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "LocalUsersPlugin",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "LocalUsersPlugin",
            type: .dynamic,
            targets: ["LocalUsersPlugin"]
        )
    ],
    dependencies: [
        .package(name: "MunkiFactsInterface", path: "../../MunkiFactsInterface")
    ],
    targets: [
        .target(
            name: "LocalUsersPlugin",
            dependencies: [
                .product(name: "MunkiFactsInterface", package: "MunkiFactsInterface")
            ]
        )
    ]
)
