// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "RemoteLoginPlugin",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "RemoteLoginPlugin",
            type: .dynamic,
            targets: ["RemoteLoginPlugin"]
        )
    ],
    dependencies: [
        .package(name: "MunkiFactsInterface", path: "../../MunkiFactsInterface")
    ],
    targets: [
        .target(
            name: "RemoteLoginPlugin",
            dependencies: [
                .product(name: "MunkiFactsInterface", package: "MunkiFactsInterface")
            ]
        )
    ]
)
