import Foundation
import IOKit
import IOKit.ps
import CommonCrypto
import MunkiFactsInterface

public class ShardPlugin: NSObject, FactPlugin {
    public static func createPlugin() -> FactPlugin {
        return ShardPlugin()
    }

    @available(macOS, deprecated: 10.15, message: "CC_MD5 is deprecated in macOS 10.15 and later")
    public func gatherFact() -> Fact {
        let shardValue = getShardValue()
        return Fact(name: "shard", value: shardValue)
    }

    private func getSerialNumber() -> String? {
        let platformExpert = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
        guard platformExpert != 0 else {
            return ""
        }
        defer {
            IOObjectRelease(platformExpert)
        }
        guard let serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformSerialNumberKey as CFString, kCFAllocatorDefault, 0)?.takeUnretainedValue() as? String else {
            return ""
        }
        return serialNumberAsCFString
    }

    @available(macOS, deprecated: 10.15, message: "CC_MD5 is deprecated in macOS 10.15 and later")
    private func getShardValue() -> Int {
        guard let serial = getSerialNumber() else {
            return 0
        }
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: "/Library/CPE/.stable") {
            return 100
        } else if fileManager.fileExists(atPath: "/Library/CPE/.beta") {
            return 1
        }
        
        let hash = md5Hash(serial)
        let shard = Int(hash.prefix(8), radix: 16)! % 100
        return shard == 0 ? 1 : shard
    }

    @available(macOS, deprecated: 10.15, message: "CC_MD5 is deprecated in macOS 10.15 and later")
    private func md5Hash(_ string: String) -> String {
        let data = Data(string.utf8)
        var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        
        data.withUnsafeBytes { buffer in
            _ = CC_MD5(buffer.baseAddress, CC_LONG(data.count), &hash)
        }
        
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
}

@_cdecl("createPlugin")
public func createPlugin() -> UnsafeMutableRawPointer {
    let plugin = ShardPlugin.createPlugin()
    return Unmanaged.passRetained(plugin as AnyObject).toOpaque()
}
