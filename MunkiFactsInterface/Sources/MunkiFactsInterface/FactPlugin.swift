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
