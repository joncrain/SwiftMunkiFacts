import Foundation
import SystemConfiguration
import MunkiFactsInterface

public class EmpEmailPlugin: NSObject, FactPlugin {
    public static func createPlugin() -> FactPlugin {
        return EmpEmailPlugin()
    }

    public func gatherFact() -> Fact {
        let ownerValue = CFPreferencesCopyAppValue("Owner" as CFString, "com.unity3d.itops.settings" as CFString) as? String ?? "None"
        return Fact(name: "emp_email", value: ownerValue)
    }
}

@_cdecl("createPlugin")
public func createPlugin() -> UnsafeMutableRawPointer {
    let plugin = EmpEmailPlugin.createPlugin()
    return Unmanaged.passRetained(plugin as AnyObject).toOpaque()
}