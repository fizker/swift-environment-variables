import XCTest
@testable import EnvironmentVariables

enum Keys: String, CaseIterable {
	case foo, bar, baz
}

final class EnvironmentVariablesTests: XCTestCase {
	func test__init__allKeysArePresent__initialisesCorrectly_asksForAllValues() throws {
		var remainingKeys = Set(Keys.allCases)

		let envVars = EnvironmentVariables<Keys> {
			guard let key = Keys(rawValue: $0)
			else {
				XCTFail("\($0) is not a valid key")
				return nil
			}

			guard remainingKeys.remove(key) != nil
			else {
				XCTFail("Matched key \(key) multiple times")
				return nil
			}

			return key.rawValue.uppercased()
		}

		XCTAssertTrue(remainingKeys.isEmpty, "Remaining keys: \(remainingKeys)")

		// This should not throw, since all keys are present
		try envVars.assertKeys()

		for key in Keys.allCases {
			let expected = key.rawValue.uppercased()
			let actual = try envVars.get(key)
			XCTAssertEqual(expected, actual)
		}
	}

	func test__init__someKeysAreMissing__initialisesCorrectly_asksForAllValues() throws {
		var remainingKeys = Set(Keys.allCases)

		let envVars = EnvironmentVariables<Keys> {
			guard let key = Keys(rawValue: $0)
			else {
				XCTFail("\($0) is not a valid key")
				return nil
			}

			guard remainingKeys.remove(key) != nil
			else {
				XCTFail("Matched key \(key) multiple times")
				return nil
			}

			if key == .foo {
				return nil
			}

			return key.rawValue.uppercased()
		}

		XCTAssertTrue(remainingKeys.isEmpty, "Remaining keys: \(remainingKeys)")

		// This should not throw, since these keys are present
		try envVars.assertKeys([ .bar, .baz ])

		for key in Keys.allCases {
			let expected = key == .foo ? nil : key.rawValue.uppercased()
			let actual = try? envVars.get(key)
			XCTAssertEqual(expected, actual)
		}
	}

	func test__init_async__allKeysArePresent__initialisesCorrectly_asksForAllValues() async throws {
		var remainingKeys = Set(Keys.allCases)

		let envVars = await EnvironmentVariables<Keys> {
			try! await Task.sleep(nanoseconds: 100_000_000)

			guard let key = Keys(rawValue: $0)
			else {
				XCTFail("\($0) is not a valid key")
				return nil
			}

			guard remainingKeys.remove(key) != nil
			else {
				XCTFail("Matched key \(key) multiple times")
				return nil
			}

			return key.rawValue.uppercased()
		}

		XCTAssertTrue(remainingKeys.isEmpty, "Remaining keys: \(remainingKeys)")

		// This should not throw, since all keys are present
		try envVars.assertKeys()

		for key in Keys.allCases {
			let expected = key.rawValue.uppercased()
			let actual = try envVars.get(key)
			XCTAssertEqual(expected, actual)
		}
	}

	func test__init_async__someKeysAreMissing__initialisesCorrectly_asksForAllValues() async throws {
		var remainingKeys = Set(Keys.allCases)

		let envVars = await EnvironmentVariables<Keys> {
			try! await Task.sleep(nanoseconds: 100_000_000)

			guard let key = Keys(rawValue: $0)
			else {
				XCTFail("\($0) is not a valid key")
				return nil
			}

			guard remainingKeys.remove(key) != nil
			else {
				XCTFail("Matched key \(key) multiple times")
				return nil
			}

			if key == .foo {
				return nil
			}

			return key.rawValue.uppercased()
		}

		XCTAssertTrue(remainingKeys.isEmpty, "Remaining keys: \(remainingKeys)")

		// This should not throw, since these keys are present
		try envVars.assertKeys([ .bar, .baz ])

		for key in Keys.allCases {
			let expected = key == .foo ? nil : key.rawValue.uppercased()
			let actual = try? envVars.get(key)
			XCTAssertEqual(expected, actual)
		}
	}
}
