import Foundation
import MunkiFactsInterface
import IOKit.ps

public final class ACPowerPlugin: NSObject, FactPlugin {
    public static func createPlugin() -> FactPlugin {
        return ACPowerPlugin()
    }

    public func gatherFact() -> Fact {
        // Check if external power adapter details can be retrieved
        let isPluggedIn: Bool = IOPSCopyExternalPowerAdapterDetails()?.takeRetainedValue() != nil
        return Fact(name: "ac_power", value: isPluggedIn)
    }
}

@_cdecl("createPlugin")
public func createPlugin() -> UnsafeMutableRawPointer {
    let plugin = ACPowerPlugin.createPlugin()
    return Unmanaged.passRetained(plugin as AnyObject).toOpaque()
}