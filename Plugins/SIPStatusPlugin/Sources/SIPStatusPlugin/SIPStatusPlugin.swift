import Foundation
import MunkiFactsInterface

public class SIPStatusPlugin: NSObject, FactPlugin {
    public static func createPlugin() -> FactPlugin {
        return SIPStatusPlugin()
    }

    private func getSIPStatus() -> String {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IODTNVRAM"))
        guard service != 0 else {
            return "Unknown (Failed to access NVRAM)"
        }
        
        if let csrConfigData = IORegistryEntryCreateCFProperty(service, "csr-active-config" as CFString, kCFAllocatorDefault, 0)?.takeUnretainedValue() as? Data {
            IOObjectRelease(service)
            
            let csrConfigBytes = [UInt8](csrConfigData)
            if csrConfigBytes.isEmpty || csrConfigBytes == [0x00, 0x00, 0x00, 0x00] {
                return "Enabled"
            } else {
                return "Disabled"
            }
        } else {
            IOObjectRelease(service)
            return "Enabled"
        }
    }

    public func gatherFact() -> Fact {
        return Fact(name: "sip_status", value: getSIPStatus())
    }
}

@_cdecl("createPlugin")
public func createPlugin() -> UnsafeMutableRawPointer {
    let plugin = SIPStatusPlugin.createPlugin()
    return Unmanaged.passRetained(plugin as AnyObject).toOpaque()
}
