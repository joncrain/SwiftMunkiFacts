#!/bin/zsh

# Check if the plugin name is provided
plugin_name=$1

if [ -z "$plugin_name" ]; then
  echo "Usage: make_plugin.sh <plugin_name>"
  exit 1
fi

# Create the plugin directory
mkdir -p "${plugin_name}Plugin"

# Create the plugin files
touch "${plugin_name}Plugin/Package.swift"

# Create a basic Package.swift file
cat <<EOL > "${plugin_name}Plugin/Package.swift"
// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "${plugin_name}Plugin",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "${plugin_name}Plugin",
            type: .dynamic,
            targets: ["${plugin_name}Plugin"]
        )
    ],
    dependencies: [
        .package(name: "MunkiFactsInterface", path: "../../MunkiFactsInterface")
    ],
    targets: [
        .target(
            name: "${plugin_name}Plugin",
            dependencies: [
                .product(name: "MunkiFactsInterface", package: "MunkiFactsInterface")
            ]
        )
    ]
)
EOL

# Create sources directory
mkdir -p "${plugin_name}Plugin/Sources/${plugin_name}Plugin"

# Create a basic source file
cat <<EOL > "${plugin_name}Plugin/Sources/${plugin_name}Plugin/${plugin_name}Plugin.swift"
import Foundation
import MunkiFactsInterface

public class ${plugin_name}Plugin: NSObject, FactPlugin {
    public static func createPlugin() -> FactPlugin {
        return ${plugin_name}Plugin()
    }

    public func gatherFact() -> Fact {
        let returnValue = "Test"
        return Fact(name: "${plugin_name}", value: returnValue)
    }
}

@_cdecl("createPlugin")
public func createPlugin() -> UnsafeMutableRawPointer {
    let plugin = ${plugin_name}Plugin.createPlugin()
    return Unmanaged.passRetained(plugin as AnyObject).toOpaque()
}
EOL
