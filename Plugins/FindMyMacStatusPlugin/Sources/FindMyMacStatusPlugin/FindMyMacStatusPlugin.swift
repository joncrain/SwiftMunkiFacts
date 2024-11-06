import Foundation
import IOKit
import MunkiFactsInterface

public class FindMyMacStatusPlugin: NSObject, FactPlugin {
    public static func createPlugin() -> FactPlugin {
        return FindMyMacStatusPlugin()
    }

    public func getNVRAMVariable(named variable: String) -> String? {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IODTNVRAM"))
        guard service != 0 else {
            print("Failed to access NVRAM")
            return nil
        }
        
        if let value = IORegistryEntryCreateCFProperty(service, variable as CFString, kCFAllocatorDefault, 0) {
            IOObjectRelease(service)
            return (value.takeUnretainedValue() as? Data).flatMap { String(data: $0, encoding: .utf8) }
        } else {
            IOObjectRelease(service)
            return nil
        }
    }

    public func gatherFact() -> Fact {
        let isFindMyMacEnabled = getNVRAMVariable(named: "fmm-mobileme-token-FMM") != nil
        return Fact(name: "fmm_status", value: isFindMyMacEnabled)
    }
}

@_cdecl("createPlugin")
public func createPlugin() -> UnsafeMutableRawPointer {
    let plugin = FindMyMacStatusPlugin.createPlugin()
    return Unmanaged.passRetained(plugin as AnyObject).toOpaque()
}
