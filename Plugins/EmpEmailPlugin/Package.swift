// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "EmpEmailPlugin",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "EmpEmailPlugin",
            type: .dynamic,
            targets: ["EmpEmailPlugin"]
        )
    ],
    dependencies: [
        .package(name: "MunkiFactsInterface", path: "../../MunkiFactsInterface")
    ],
    targets: [
        .target(
            name: "EmpEmailPlugin",
            dependencies: [
                .product(name: "MunkiFactsInterface", package: "MunkiFactsInterface")
            ]
        )
    ]
)