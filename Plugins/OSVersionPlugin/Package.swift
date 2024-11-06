// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "OSVersionPlugin",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "OSVersionPlugin",
            type: .dynamic,
            targets: ["OSVersionPlugin"]
        )
    ],
    dependencies: [
        .package(name: "MunkiFactsInterface", path: "../../MunkiFactsInterface")
    ],
    targets: [
        .target(
            name: "OSVersionPlugin",
            dependencies: [
                .product(name: "MunkiFactsInterface", package: "MunkiFactsInterface")
            ]
        )
    ]
)