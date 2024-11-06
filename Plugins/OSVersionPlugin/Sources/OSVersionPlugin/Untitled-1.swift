// main.swift
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

// PluginLoader.swift
import Foundation
import Darwin
import MunkiFactsInterface

typealias PluginInitializer = @convention(c) () -> UnsafeMutableRawPointer

class PluginLoader {
    private let pluginDirectory: String

    init(pluginDirectory: String) {
        self.pluginDirectory = pluginDirectory
    }

    func loadPlugins() -> [FactPlugin] {
        var plugins: [FactPlugin] = []

        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: pluginDirectory)
            for file in files where file.hasSuffix(".plugin") {
                let pluginPath = (pluginDirectory as NSString).appendingPathComponent(file)
                print("Attempting to load plugin: \(file)")

                guard let handle = dlopen(pluginPath, RTLD_NOW) else {
                    if let error = dlerror() {
                        print("Failed to load plugin \(file): \(String(cString: error))")
                    }
                    continue
                }

                guard let symbolPtr = dlsym(handle, "createPlugin") else {
                    print("Failed to find createPlugin symbol in \(file)")
                    dlclose(handle)
                    continue
                }

                let initializer = unsafeBitCast(symbolPtr, to: PluginInitializer.self)
                let pluginPtr = initializer()

                let plugin = Unmanaged<AnyObject>.fromOpaque(pluginPtr).takeRetainedValue()
                guard let factPlugin = plugin as? FactPlugin else {
                    print("Failed to cast plugin instance for \(file)")
                    continue
                }

                print("Successfully loaded plugin: \(file)")
                plugins.append(factPlugin)
            }
        } catch {
            print("Error scanning plugin directory: \(error)")
        }

        return plugins
    }
}

// MunkiFactsInterface.swift
import Foundation

// Update SwiftFact to handle arrays
public struct SwiftFact: Codable {
    public let name: String
    public let value: FactValue
    
    public init(name: String, value: FactValue) {
        self.name = name
        self.value = value
    }
    
    // Convert from bridge class
    public init(from fact: Fact) {
        self.name = fact.name
        self.value = FactValue(from: fact.value)
    }
}

// Enum to represent a value that can be either a String or a Bool
public enum FactValue: Codable {
    case string(String)
    case bool(Bool)
    case integer(Int)
    case array([FactValue])
    
    // Convert from Objective-C compatible type
    public init(from value: Any) {
        if let stringValue = value as? String {
            self = .string(stringValue)
        } else if let boolValue = value as? Bool {
            self = .bool(boolValue)
        } else if let intValue = value as? Int {
            self = .integer(intValue)
        } else if let arrayValue = value as? [Any] {
            self = .array(arrayValue.map { FactValue(from: $0) })
        } else {
            fatalError("Unsupported type")
        }
    }
    
    // Convert to Objective-C compatible type
    public func toAny() -> Any {
        switch self {
        case .string(let stringValue):
            return stringValue
        case .bool(let boolValue):
            return boolValue
        case .integer(let intValue):
            return intValue 
        case .array(let arrayValue):
            return arrayValue.map { $0.toAny() }
        }
    }
}

// Objective-C compatible class
@objc public class Fact: NSObject {
    @objc public let name: String
    @objc public let value: Any
    
    @objc public init(name: String, value: Any) {
        self.name = name
        self.value = value
    }
}

// Objective-C compatible class
@objc public protocol FactPlugin: NSObjectProtocol {
    @objc static func createPlugin() -> FactPlugin
    @objc optional func gatherFact() -> Fact
    @objc optional func gatherFacts() -> [Fact]
}

// Extension to provide default implementations
public extension FactPlugin {
    // Default implementation for single SwiftFact
    func gatherSwiftFact() -> SwiftFact {
        // If plugin implements gatherFact(), use that
        if let fact = self.gatherFact?() {
            return SwiftFact(from: fact)
        }
        // Otherwise, take the first fact from gatherFacts
        guard let facts = self.gatherFacts?(),
              let firstFact = facts.first else {
            fatalError("Plugin must implement either gatherFact() or gatherFacts()")
        }
        return SwiftFact(from: firstFact)
    }
    
    // Default implementation for array of SwiftFacts
    func gatherSwiftFacts() -> [SwiftFact] {
        // If plugin implements gatherFacts(), use that
        if let facts = self.gatherFacts?() {
            return facts.map { SwiftFact(from: $0) }
        }
        // Otherwise, if plugin implements gatherFact(), use that
        if let fact = self.gatherFact?() {
            return [SwiftFact(from: fact)]
        }
        fatalError("Plugin must implement either gatherFact() or gatherFacts()")
    }
}

// Example plugin
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