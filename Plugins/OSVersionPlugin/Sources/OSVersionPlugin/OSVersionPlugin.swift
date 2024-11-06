import Foundation
import MunkiFactsInterface

public final class OSVersionPlugin: NSObject, FactPlugin {
    public static func createPlugin() -> FactPlugin {
        return OSVersionPlugin()
    }

    public func gatherFact() -> Fact {
        let processInfo = ProcessInfo.processInfo
        return Fact(name: "os_version", value: processInfo.operatingSystemVersionString)
    }
}

@_cdecl("createPlugin")
public func createPlugin() -> UnsafeMutableRawPointer {
    let plugin = OSVersionPlugin.createPlugin()
    return Unmanaged.passRetained(plugin as AnyObject).toOpaque()
}