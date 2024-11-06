import Foundation
import MunkiFactsInterface

public class XProtectPlugin: NSObject, FactPlugin {
    public static func createPlugin() -> FactPlugin {
        return XProtectPlugin()
    }

    private func getXProtectDate() -> String? {
        // Create Process to list XProtect packages
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/pkgutil")
        process.arguments = ["--pkgs=.*XProtect.*"]
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        
        do {
            try process.run()
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            
            guard process.terminationStatus == 0,
                let output = String(data: outputData, encoding: .utf8) else {
                return nil
            }
            
            // Process each package ID
            var dates: [TimeInterval] = []
            let packageIds = output.components(separatedBy: .newlines).filter { !$0.isEmpty }
            
            for packageId in packageIds {
                let infoPlistProcess = Process()
                infoPlistProcess.executableURL = URL(fileURLWithPath: "/usr/sbin/pkgutil")
                infoPlistProcess.arguments = ["--pkg-info-plist", packageId]
                
                let infoPlistPipe = Pipe()
                infoPlistProcess.standardOutput = infoPlistPipe
                
                try infoPlistProcess.run()
                let infoPlistData = infoPlistPipe.fileHandleForReading.readDataToEndOfFile()
                infoPlistProcess.waitUntilExit()
                
                if let plistDict = try PropertyListSerialization.propertyList(
                    from: infoPlistData,
                    options: [],
                    format: nil) as? [String: Any],
                let installTime = plistDict["install-time"] as? TimeInterval {
                    dates.append(installTime)
                }
            }
            
            // Format the latest date
            if let maxDate = dates.max() {
                let date = Date(timeIntervalSince1970: maxDate)
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                return formatter.string(from: date)
            }
            
        } catch {
            print("Error: \(error)")
            return nil
        }
        
        return nil
    }


    private func getXProtectVersion() -> String? {
        let xProtectPath = "/System/Library/CoreServices/XProtect.bundle/Contents/Resources/XProtect.meta.plist"
        let xProtectURL = URL(fileURLWithPath: xProtectPath)
        
        guard let plistData = try? Data(contentsOf: xProtectURL) else {
            print("Failed to read XProtect plist file.")
            return nil
        }
        
        do {
            if let plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any],
            let version = plist["Version"] as? String {
                return version
            }
        } catch {
            print("Failed to parse XProtect plist file: \(error)")
        }
        
        return nil
    }

    public func gatherFacts() -> [Fact] {
        return [
            Fact(name: "xprotect_date", value: getXProtectDate() ?? "Unknown"),
            Fact(name: "xprotect_version", value: getXProtectVersion() ?? "Unknown")
        ]
    }
}

@_cdecl("createPlugin")
public func createPlugin() -> UnsafeMutableRawPointer {
    let plugin = XProtectPlugin.createPlugin()
    return Unmanaged.passRetained(plugin as AnyObject).toOpaque()
}
