// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "MunkiFactsInterface",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "MunkiFactsInterface",
            type: .dynamic,
            targets: ["MunkiFactsInterface"]
        )
    ],
    targets: [
        .target(
            name: "MunkiFactsInterface",
            dependencies: []
        ),
        .testTarget(
            name: "MunkiFactsInterfaceTests",
            dependencies: ["MunkiFactsInterface"]
        )
    ]
)