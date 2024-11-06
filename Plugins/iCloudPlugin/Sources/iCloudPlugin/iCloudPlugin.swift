import Foundation
import MunkiFactsInterface
import SystemConfiguration

@objc public class iCloudPlugin: NSObject, FactPlugin {
    // Cache common values
    private var homeFolder: String?
    private var accountsPlistPath: String?
    private var accountsData: [[String: Any]]?
    
    override init() {
        super.init()
        setupCachedValues()
    }
    
    private func setupCachedValues() {
        // Get console user
        var uid: uid_t = 0
        var gid: gid_t = 0
        if let consoleUser = SCDynamicStoreCopyConsoleUser(nil, &uid, &gid) as String?,
           let userHome = NSHomeDirectoryForUser(consoleUser) {
            homeFolder = userHome
            
            // Get plist path and load accounts data
            accountsPlistPath = (userHome as NSString).appendingPathComponent("Library/Preferences/MobileMeAccounts.plist")
            
            if let path = accountsPlistPath,
               FileManager.default.fileExists(atPath: path),
               let plistData = NSDictionary(contentsOfFile: path),
               let accounts = plistData["Accounts"] as? [[String: Any]] {
                accountsData = accounts
            }
        }
    }
    
    @objc public static func createPlugin() -> FactPlugin {
        return iCloudPlugin()
    }
    
    @objc public func gatherFacts() -> [Fact] {
        let info = getICloudInfo()
        return [
            Fact(name: "icloud_account", value: info.accountID),
            Fact(name: "icloud_display_name", value: info.displayName),
            Fact(name: "icloud_drive", value: info.driveEnabled),
            Fact(name: "icloud_optimization", value: info.optimizationEnabled),
            Fact(name: "icloud_sync", value: info.syncEnabled)
        ]
    }
    
    // MARK: - Private Helper Methods
    
    private struct ICloudInfo {
        let accountID: String
        let displayName: String
        let driveEnabled: Bool
        let optimizationEnabled: Bool
        let syncEnabled: Bool
    }
    
    private func getICloudInfo() -> ICloudInfo {
        // Early return if we don't have basic required data
        guard let firstAccount = accountsData?.first else {
            return ICloudInfo(
                accountID: "",
                displayName: "",
                driveEnabled: false,
                optimizationEnabled: false,
                syncEnabled: false
            )
        }
        
        // Get account details
        let accountID = firstAccount["AccountID"] as? String ?? ""
        let displayName = firstAccount["DisplayName"] as? String ?? ""
        
        // Get iCloud Drive status
        let services = firstAccount["Services"] as? [[String: Any]]
        let driveEnabled = (services?.count ?? 0) > 2 ? (services?[2]["Enabled"] as? Bool ?? false) : false
        
        // Get optimization status
        let optimizationEnabled = getOptimizationStatus()
        
        // Get sync status
        let syncEnabled = getSyncStatus(driveEnabled: driveEnabled)
        
        return ICloudInfo(
            accountID: accountID,
            displayName: displayName,
            driveEnabled: driveEnabled,
            optimizationEnabled: optimizationEnabled,
            syncEnabled: syncEnabled
        )
    }
    
    private func getOptimizationStatus() -> Bool {
        guard let homePath = homeFolder else { return false }
        
        let birdPlistPath = (homePath as NSString).appendingPathComponent("Library/Preferences/com.apple.bird.plist")
        guard FileManager.default.fileExists(atPath: birdPlistPath),
              let plistData = NSDictionary(contentsOfFile: birdPlistPath),
              let optimizeStorage = plistData["optimize-storage"] as? Bool else {
            return false
        }
        
        return optimizeStorage
    }
    
    private func getSyncStatus(driveEnabled: Bool) -> Bool {
        guard let homePath = homeFolder, driveEnabled else { return false }
        
        let cloudDocsPath = (homePath as NSString).appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs")
        let cloudDocsURL = URL(fileURLWithPath: cloudDocsPath)
        
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: cloudDocsURL,
            includingPropertiesForKeys: [.isSymbolicLinkKey]
        ) else {
            return false
        }
        
        // Check if any item is a symbolic link
        for itemURL in contents {
            if (try? FileManager.default.destinationOfSymbolicLink(atPath: itemURL.path)) != nil {
                return true
            }
        }
        
        return false
    }
}

@_cdecl("createPlugin")
public func createPlugin() -> UnsafeMutableRawPointer {
    let plugin = iCloudPlugin.createPlugin()
    return Unmanaged.passRetained(plugin as AnyObject).toOpaque()
}