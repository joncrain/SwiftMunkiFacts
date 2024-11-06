// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "XProtectPlugin",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "XProtectPlugin",
            type: .dynamic,
            targets: ["XProtectPlugin"]
        )
    ],
    dependencies: [
        .package(name: "MunkiFactsInterface", path: "../../MunkiFactsInterface")
    ],
    targets: [
        .target(
            name: "XProtectPlugin",
            dependencies: [
                .product(name: "MunkiFactsInterface", package: "MunkiFactsInterface")
            ]
        )
    ]
)
