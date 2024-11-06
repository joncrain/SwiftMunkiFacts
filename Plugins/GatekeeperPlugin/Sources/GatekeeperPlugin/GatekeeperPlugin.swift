import Foundation
import MunkiFactsInterface

public class GatekeeperPlugin: NSObject, FactPlugin {
    public static func createPlugin() -> FactPlugin {
        return GatekeeperPlugin()
    }

    public func getGatekeeperStatus() -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/spctl")
        process.arguments = ["--status"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return "Unknown"
        }
        
        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
            return output == "assessments enabled" ? "Enabled" : "Disabled"
        } else {
            return "Unknown"
        }
    }

    public func gatherFacts() -> [Fact] {
        let gateKeeperEnabled: String = getGatekeeperStatus()
        let gatekeeperVersion = CFPreferencesCopyAppValue("CFBundleShortVersionString" as CFString, "/private/var/db/gkopaque.bundle/Contents/version.plist" as CFString) as? String ?? "None"
        return [
            Fact(name: "gatekeeper_status", value: gateKeeperEnabled),
            Fact(name: "gatekeeper_version", value: gatekeeperVersion)
        ]
    }
}

@_cdecl("createPlugin")
public func createPlugin() -> UnsafeMutableRawPointer {
    let plugin = GatekeeperPlugin.createPlugin()
    return Unmanaged.passRetained(plugin as AnyObject).toOpaque()
}
