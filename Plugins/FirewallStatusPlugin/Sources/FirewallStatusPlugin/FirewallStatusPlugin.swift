import Foundation
import MunkiFactsInterface

public class FirewallStatusPlugin: NSObject, FactPlugin {
    public static func createPlugin() -> FactPlugin {
        return FirewallStatusPlugin()
    }

    public func gatherFact() -> Fact {
        var isFirewallEnabled: Bool
        
        do {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/libexec/ApplicationFirewall/socketfilterfw")
            task.arguments = ["--getglobalstate"]
            
            let pipe = Pipe()
            task.standardOutput = pipe
            
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8), output.contains("enabled") {
                isFirewallEnabled = true
            } else {
                isFirewallEnabled = false
            }
        } catch {
            print("Error checking Firewall status: \(error)")
            isFirewallEnabled = false
        }
        return Fact(name: "firewall_status", value: isFirewallEnabled)
    }
}

@_cdecl("createPlugin")
public func createPlugin() -> UnsafeMutableRawPointer {
    let plugin = FirewallStatusPlugin.createPlugin()
    return Unmanaged.passRetained(plugin as AnyObject).toOpaque()
}