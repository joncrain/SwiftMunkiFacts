import XCTest
@testable import MunkiFactsInterface // Replace with your actual module name

class MunkiFactsTests: XCTestCase {
    
    // MARK: - SwiftFact Tests
    
    func testSwiftFactInitialization() {
        let stringFact = SwiftFact(name: "TestString", value: .string("test"))
        XCTAssertEqual(stringFact.name, "TestString")
        if case .string(let value) = stringFact.value {
            XCTAssertEqual(value, "test")
        } else {
            XCTFail("Expected string value")
        }
        
        let boolFact = SwiftFact(name: "TestBool", value: .bool(true))
        XCTAssertEqual(boolFact.name, "TestBool")
        if case .bool(let value) = boolFact.value {
            XCTAssertTrue(value)
        } else {
            XCTFail("Expected bool value")
        }
    }
    
    func testSwiftFactFromFact() {
        let fact = Fact(name: "Test", value: "value")
        let swiftFact = SwiftFact(from: fact)
        
        XCTAssertEqual(swiftFact.name, "Test")
        if case .string(let value) = swiftFact.value {
            XCTAssertEqual(value, "value")
        } else {
            XCTFail("Expected string value")
        }
    }
    
    // MARK: - FactValue Tests
    
    func testFactValueInitialization() {
        // Test string
        let stringValue = FactValue(from: "test")
        if case .string(let value) = stringValue {
            XCTAssertEqual(value, "test")
        } else {
            XCTFail("Expected string value")
        }
        
        // Test bool
        let boolValue = FactValue(from: true)
        if case .bool(let value) = boolValue {
            XCTAssertTrue(value)
        } else {
            XCTFail("Expected bool value")
        }
        
        // Test integer
        let intValue = FactValue(from: 42)
        if case .integer(let value) = intValue {
            XCTAssertEqual(value, 42)
        } else {
            XCTFail("Expected integer value")
        }
        
        // Test array
        let arrayValue = FactValue(from: ["test", true, 42])
        if case .array(let value) = arrayValue {
            XCTAssertEqual(value.count, 3)
            if case .string(let str) = value[0] {
                XCTAssertEqual(str, "test")
            }
            if case .bool(let bool) = value[1] {
                XCTAssertTrue(bool)
            }
            if case .integer(let int) = value[2] {
                XCTAssertEqual(int, 42)
            }
        } else {
            XCTFail("Expected array value")
        }
    }
    
    func testFactValueToAny() {
        // Test string conversion
        let stringValue = FactValue.string("test")
        XCTAssertEqual(stringValue.toAny() as? String, "test")
        
        // Test bool conversion
        let boolValue = FactValue.bool(true)
        XCTAssertEqual(boolValue.toAny() as? Bool, true)
        
        // Test integer conversion
        let intValue = FactValue.integer(42)
        XCTAssertEqual(intValue.toAny() as? Int, 42)
        
        // Test array conversion
        let arrayValue = FactValue.array([.string("test"), .bool(true), .integer(42)])
        let convertedArray = arrayValue.toAny() as? [Any]
        XCTAssertNotNil(convertedArray)
        XCTAssertEqual(convertedArray?.count, 3)
        XCTAssertEqual(convertedArray?[0] as? String, "test")
        XCTAssertEqual(convertedArray?[1] as? Bool, true)
        XCTAssertEqual(convertedArray?[2] as? Int, 42)
    }
    
    // MARK: - Mock Plugin Tests
    
    class MockSingleFactPlugin: NSObject, FactPlugin {
        static func createPlugin() -> FactPlugin {
            return MockSingleFactPlugin()
        }
        
        func gatherFact() -> Fact {
            return Fact(name: "MockFact", value: "MockValue")
        }
    }
    
    class MockMultiFactPlugin: NSObject, FactPlugin {
        static func createPlugin() -> FactPlugin {
            return MockMultiFactPlugin()
        }
        
        func gatherFacts() -> [Fact] {
            return [
                Fact(name: "Fact1", value: "Value1"),
                Fact(name: "Fact2", value: true)
            ]
        }
    }
    
    func testSingleFactPlugin() {
        let plugin = MockSingleFactPlugin()
        let swiftFact = plugin.gatherSwiftFact()
        
        XCTAssertEqual(swiftFact.name, "MockFact")
        if case .string(let value) = swiftFact.value {
            XCTAssertEqual(value, "MockValue")
        } else {
            XCTFail("Expected string value")
        }
        
        let facts = plugin.gatherSwiftFacts()
        XCTAssertEqual(facts.count, 1)
        XCTAssertEqual(facts[0].name, "MockFact")
    }
    
    func testMultiFactPlugin() {
        let plugin = MockMultiFactPlugin()
        let facts = plugin.gatherSwiftFacts()
        
        XCTAssertEqual(facts.count, 2)
        XCTAssertEqual(facts[0].name, "Fact1")
        XCTAssertEqual(facts[1].name, "Fact2")
        
        if case .string(let value1) = facts[0].value {
            XCTAssertEqual(value1, "Value1")
        } else {
            XCTFail("Expected string value")
        }
        
        if case .bool(let value2) = facts[1].value {
            XCTAssertTrue(value2)
        } else {
            XCTFail("Expected bool value")
        }
    }
}