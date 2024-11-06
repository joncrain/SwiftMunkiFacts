// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "iCloudPlugin",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "iCloudPlugin",
            type: .dynamic,
            targets: ["iCloudPlugin"]
        )
    ],
    dependencies: [
        .package(name: "MunkiFactsInterface", path: "../../MunkiFactsInterface")
    ],
    targets: [
        .target(
            name: "iCloudPlugin",
            dependencies: [
                .product(name: "MunkiFactsInterface", package: "MunkiFactsInterface")
            ]
        )
    ]
)
