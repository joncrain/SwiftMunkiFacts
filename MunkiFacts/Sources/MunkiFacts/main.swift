import Foundation
import CoreFoundation
import MunkiFactsInterface

private func getManagedInstallDir() -> String? {
    let bundleId = "ManagedInstalls"
    let prefName = "ManagedInstallDir"
    
    guard let managedInstallDir = CFPreferencesCopyAppValue(prefName as CFString, bundleId as CFString) as? String else {
        return nil
    }
    
    return managedInstallDir
}

private func loadConditionalItems(at path: String) -> [String: Any] {
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
            let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
        return [:]
    }
    return plist
}

private func saveConditionalItems(_ items: [String: Any], to path: String) {
    guard let data = try? PropertyListSerialization.data(
        fromPropertyList: items,
        format: .xml,
        options: 0
    ) else {
        print("Error: Could not serialize conditional items")
        return
    }
    
    do {
        try data.write(to: URL(fileURLWithPath: path))
    } catch {
        print("Couldn't save conditional items: \(error)")
    }
}

private func process() throws {
    let defaultPluginDir = "/Library/MunkiFacts/Plugins"
    print("Loading plugins from: \(defaultPluginDir)")
    let loader = PluginLoader(pluginDirectory: defaultPluginDir)
    let plugins = loader.loadPlugins()
    print("Found \(plugins.count) plugins")
    
    var allFacts: [Fact] = []
    
    // Process each plugin
    for plugin in plugins {
        if let multipleFacts = plugin.gatherFacts?() {
            allFacts.append(contentsOf: multipleFacts)
        }
        else if let singleFact = plugin.gatherFact?() {
            allFacts.append(singleFact)
        }
        else {
            print("Warning: Plugin does not implement either gatherFact or gatherFacts")
        }
    }
    
    let factsDict = Dictionary(allFacts.map { ($0.name, $0.value) },
                             uniquingKeysWith: { (first, second) in
        print("Warning: Duplicate fact found for key '\(first)'. Using most recent value.")
        return second
    })
    
    guard let managedInstallDir = getManagedInstallDir() else {
        print("Error: Could not determine ManagedInstallDir")
        throw NSError(domain: "MunkiFacts",
                     code: 1,
                     userInfo: [NSLocalizedDescriptionKey: "Could not determine ManagedInstallDir"])
    }

    let conditionalItemsPath = (managedInstallDir as NSString).appendingPathComponent("ConditionalItems.plist")

    var conditionalItems = loadConditionalItems(at: conditionalItemsPath)

    conditionalItems.merge(factsDict) { (_, new) in new }

    saveConditionalItems(conditionalItems, to: conditionalItemsPath)
}

do {
    try process()
} catch {
    print("An error occurred: \(error)")
}