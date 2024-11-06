// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "MunkiFacts",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "munkifacts", targets: ["MunkiFacts"])
    ],
    dependencies: [
        .package(name: "MunkiFactsInterface", path: "../MunkiFactsInterface")
    ],
    targets: [
        .executableTarget(
            name: "MunkiFacts",
            dependencies: [
                .product(name: "MunkiFactsInterface", package: "MunkiFactsInterface")
            ]
        )
    ]
)
