// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "FindMyMacStatusPlugin",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "FindMyMacStatusPlugin",
            type: .dynamic,
            targets: ["FindMyMacStatusPlugin"]
        )
    ],
    dependencies: [
        .package(name: "MunkiFactsInterface", path: "../../MunkiFactsInterface")
    ],
    targets: [
        .target(
            name: "FindMyMacStatusPlugin",
            dependencies: [
                .product(name: "MunkiFactsInterface", package: "MunkiFactsInterface")
            ]
        )
    ]
)
