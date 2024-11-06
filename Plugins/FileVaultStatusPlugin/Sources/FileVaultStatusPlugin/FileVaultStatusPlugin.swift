import Foundation
import MunkiFactsInterface

public final class FileVaultStatusPlugin: NSObject, FactPlugin {
    public static func createPlugin() -> FactPlugin {
        return FileVaultStatusPlugin()
    }

    private func getFileVaultStatus() -> String {
        let task = Process()
        task.launchPath = "/usr/bin/fdesetup"
        task.arguments = ["status"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output: String = String(data: data, encoding: String.Encoding.utf8)
            else { return "Disabled" }
        if (output.range(of: "FileVault is On.")) != nil {
            return "Enabled"
        } else if output.range(of: "Decryption in progress:") != nil {
            return "Disabled"
        } else {
            return "Disabled"
        }
    }

    public func gatherFact() -> Fact {
        return Fact(name: "filevault_status", value: getFileVaultStatus())
    }
}

@_cdecl("createPlugin")
public func createPlugin() -> UnsafeMutableRawPointer {
    let plugin = FileVaultStatusPlugin.createPlugin()
    return Unmanaged.passRetained(plugin as AnyObject).toOpaque()
}