import Foundation
import MunkiFactsInterface

public class RemoteLoginPlugin: NSObject, FactPlugin {
    public static func createPlugin() -> FactPlugin {
        return RemoteLoginPlugin()
    }

    private func getRemoteLoginStatus() -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/systemsetup")
        process.arguments = ["-getremotelogin"]
        
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
            return output.contains("On") ? "On" : "Off"
        } else {
            return "Unknown"
        }
    }

    public func gatherFact() -> Fact {
        let remoteLoginStatus = getRemoteLoginStatus()
        return Fact(name: "remote_login", value: remoteLoginStatus)
    }
}

@_cdecl("createPlugin")
public func createPlugin() -> UnsafeMutableRawPointer {
    let plugin = RemoteLoginPlugin.createPlugin()
    return Unmanaged.passRetained(plugin as AnyObject).toOpaque()
}
