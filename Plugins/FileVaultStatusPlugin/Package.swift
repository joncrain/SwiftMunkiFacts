// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "FileVaultStatusPlugin",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "FileVaultStatusPlugin",
            type: .dynamic,
            targets: ["FileVaultStatusPlugin"]
        )
    ],
    dependencies: [
        .package(name: "MunkiFactsInterface", path: "../../MunkiFactsInterface")
    ],
    targets: [
        .target(
            name: "FileVaultStatusPlugin",
            dependencies: [
                .product(name: "MunkiFactsInterface", package: "MunkiFactsInterface")
            ]
        )
    ]
)
