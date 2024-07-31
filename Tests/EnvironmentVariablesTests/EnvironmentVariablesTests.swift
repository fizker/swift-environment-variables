import XCTest
@testable import EnvironmentVariables

enum Keys: String, CaseIterable {
	case foo, bar, baz
}

final class EnvironmentVariablesTests: XCTestCase {
	func test__initWithDictionary__allKeysArePresent__initialisesCorrectly_asksForAllValues() throws {
		let input = [
			Keys.foo.rawValue: "FOO",
			Keys.bar.rawValue: "BAR",
			Keys.baz.rawValue: "BAZ",
		]

		let envVars = EnvironmentVariables<Keys>(dictionary: input)

		// This should not throw, since these keys are present
		try envVars.assertKeys([ .bar, .baz ])

		// This should not throw, since all keys are present
		try envVars.assertKeys()

		for key in Keys.allCases {
			let expected = key.rawValue.uppercased()
			let actual = try envVars.get(key)
			XCTAssertEqual(expected, actual)
		}
	}

	func test__initWithinitWithDictionary__someKeysAreMissing__initialisesCorrectly_asksForAllValues() throws {
		let input = [
			Keys.bar.rawValue: "BAR",
			Keys.baz.rawValue: "BAZ",
		]

		let envVars = EnvironmentVariables<Keys>(dictionary: input)

		// This should not throw, since these keys are present
		try envVars.assertKeys([ .bar, .baz ])

		for key in Keys.allCases {
			let expected = key == .foo ? nil : key.rawValue.uppercased()
			let actual = try? envVars.get(key)
			XCTAssertEqual(expected, actual)
		}
	}

	func test__initWithValueGetter__allKeysArePresent__initialisesCorrectly_asksForAllValues() throws {
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

	func test__initWithValueGetter__someKeysAreMissing__initialisesCorrectly_asksForAllValues() throws {
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

	func test__initWithValueGetter_async__allKeysArePresent__initialisesCorrectly_asksForAllValues() async throws {
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

	func test__initWithValueGetter_async__someKeysAreMissing__initialisesCorrectly_asksForAllValues() async throws {
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

	func test__assertKeys__allKeysAreRequired_noKeysArePresent__allKeysIncludedInError() async throws {
		let subject = EnvironmentVariables<Keys>(dictionary: [:])

		XCTAssertThrowsError(try subject.assertKeys()) { error in
			if let error = error as? MissingEnvironmentVariables {
				XCTAssertEqual(error.keys, Keys.allCases.map(\.rawValue))
			} else {
				XCTFail("Unexpected error: \(error)")
			}
		}
	}

	func test__get__keyExists__returnsValue() async throws {
		let subject = EnvironmentVariables<Keys>(dictionary: [
			Keys.foo.rawValue: "1",
		])

		let actual = try subject.get(.foo)
		XCTAssertEqual(actual, "1")
	}

	func test__get__keyDotNotExist__throws() async throws {
		let subject = EnvironmentVariables<Keys>(dictionary: [
			Keys.foo.rawValue: "1",
		])

		try subject.assertKeys([.foo])

		XCTAssertThrowsError(try subject.get(.bar)) { error in
			guard let error = error as? MissingEnvironmentVariables
			else {
				XCTFail("Unexpected error: \(error)")
				return
			}

			XCTAssertEqual(error.keys, [Keys.bar, .baz].map(\.rawValue))
		}
	}

	func test__assertKeys__someKeysAreRequired_noKeysArePresent__requiredKeysIncludedInError() async throws {
		let subject = EnvironmentVariables<Keys>(dictionary: [:])

		XCTAssertThrowsError(try subject.assertKeys([.foo, .bar])) { error in
			if let error = error as? MissingEnvironmentVariables {
				XCTAssertEqual(error.keys, [Keys.foo, .bar].map(\.rawValue))
			} else {
				XCTFail("Unexpected error: \(error)")
			}
		}
	}

	func test__getWithMap__keyExists_mapperReturnsValidValue__returnsMappedValue() async throws {
		let subject = EnvironmentVariables<Keys>(dictionary: [
			Keys.foo.rawValue: "1",
		])

		let actual = try subject.get(.foo, map: Int.init)
		XCTAssertEqual(actual, 1)
	}

	func test__getWithMap__keyExists_mapperReturnsNil__throws() async throws {
		let subject = EnvironmentVariables<Keys>(dictionary: [
			Keys.foo.rawValue: "a",
		])

		XCTAssertThrowsError(try subject.get(.foo, map: Int.init)) { error in
			guard case let EnvironmentVariablesError.couldNotMap(value) = error
			else {
				XCTFail("Unexpected error: \(error)")
				return
			}
			XCTAssertEqual(value, "a")
		}
	}

	func test__getWithMap__keyDotNotExist_mapperIsNotCalled__throws() async throws {
		let subject = EnvironmentVariables<Keys>(dictionary: [
			:
		])

		var mapperWasCalled = false
		XCTAssertThrowsError(try subject.get(.foo, map: { _ in
			mapperWasCalled = true
			return 1
		})) { error in
			guard let error = error as? MissingEnvironmentVariables
			else {
				XCTFail("Unexpected error: \(error)")
				return
			}

			XCTAssertEqual(error.keys, Keys.allCases.map(\.rawValue))
		}

		XCTAssertFalse(mapperWasCalled)
	}

	func test__getWithMapAndDefault__keyExists_mapperReturnsValidValue__returnsMappedValue() async throws {
		let subject = EnvironmentVariables<Keys>(dictionary: [
			Keys.foo.rawValue: "1",
		])

		let actual = subject.get(.foo, map: Int.init, default: 0)
		XCTAssertEqual(actual, 1)
	}

	func test__getWithMapAndDefault__keyExists_mapperReturnsNil__returnsDefault() async throws {
		let subject = EnvironmentVariables<Keys>(dictionary: [
			Keys.foo.rawValue: "a",
		])

		let actual = subject.get(.foo, map: Int.init, default: 0)
		XCTAssertEqual(actual, 0)
	}

	func test__getWithMapAndDefault__keyDotNotExist_mapperIsNotCalled__returnsDefault() async throws {
		let subject = EnvironmentVariables<Keys>(dictionary: [
			:
		])

		var mapperWasCalled = false
		let actual = subject.get(.foo, map: { _ in
			mapperWasCalled = true
			return 1
		}, default: 0)

		XCTAssertEqual(actual, 0)
		XCTAssertFalse(mapperWasCalled)
	}

	func test__getWithDefault__keyExists__returnsValue() async throws {
		let subject = EnvironmentVariables<Keys>(dictionary: [
			Keys.foo.rawValue: "1",
		])

		let actual = subject.get(.foo, default: "0")
		XCTAssertEqual(actual, "1")
	}

	func test__getWithDefault__keyDotNotExist__returnsDefault() async throws {
		let subject = EnvironmentVariables<Keys>(dictionary: [
			:
		])

		let actual = subject.get(.foo, default: "0")

		XCTAssertEqual(actual, "0")
	}
}
