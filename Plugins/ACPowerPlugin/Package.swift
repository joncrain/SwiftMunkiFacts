// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ACPowerPlugin",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "ACPowerPlugin",
            type: .dynamic,
            targets: ["ACPowerPlugin"]
        )
    ],
    dependencies: [
        .package(name: "MunkiFactsInterface", path: "../../MunkiFactsInterface")
    ],
    targets: [
        .target(
            name: "ACPowerPlugin",
            dependencies: [
                .product(name: "MunkiFactsInterface", package: "MunkiFactsInterface")
            ]
        )
    ]
)