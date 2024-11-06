// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "FirewallStatusPlugin",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "FirewallStatusPlugin",
            type: .dynamic,
            targets: ["FirewallStatusPlugin"]
        )
    ],
    dependencies: [
        .package(name: "MunkiFactsInterface", path: "../../MunkiFactsInterface")
    ],
    targets: [
        .target(
            name: "FirewallStatusPlugin",
            dependencies: [
                .product(name: "MunkiFactsInterface", package: "MunkiFactsInterface")
            ]
        )
    ]
)
