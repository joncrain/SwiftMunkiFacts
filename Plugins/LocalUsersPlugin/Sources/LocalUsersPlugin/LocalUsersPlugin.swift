import Foundation
import MunkiFactsInterface

public class LocalUsersPlugin: NSObject, FactPlugin {
    public static func createPlugin() -> FactPlugin {
        return LocalUsersPlugin()
    }

    private func getLocalUsers() -> [String] {
        let userDirs = try? FileManager.default.contentsOfDirectory(atPath: "/Users")
        let skipNames = ["Shared", "admin"]
        let localUsers = userDirs?.filter { !skipNames.contains($0) && !$0.hasPrefix(".") } ?? []
        return localUsers
    }

    public func gatherFact() -> Fact {
        return Fact(name: "local_user_dirs", value: getLocalUsers())
    }
}

@_cdecl("createPlugin")
public func createPlugin() -> UnsafeMutableRawPointer {
    let plugin = LocalUsersPlugin.createPlugin()
    return Unmanaged.passRetained(plugin as AnyObject).toOpaque()
}
