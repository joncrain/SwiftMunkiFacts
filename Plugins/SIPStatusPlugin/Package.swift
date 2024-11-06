// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SIPStatusPlugin",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "SIPStatusPlugin",
            type: .dynamic,
            targets: ["SIPStatusPlugin"]
        )
    ],
    dependencies: [
        .package(name: "MunkiFactsInterface", path: "../../MunkiFactsInterface")
    ],
    targets: [
        .target(
            name: "SIPStatusPlugin",
            dependencies: [
                .product(name: "MunkiFactsInterface", package: "MunkiFactsInterface")
            ]
        )
    ]
)
