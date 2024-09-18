import Testing
@testable import EnvironmentVariables

enum Keys: String, CaseIterable {
	case foo, bar, baz
}

struct EnvironmentVariablesTests {
	@Test
	func initWithDictionary__allKeysArePresent__initialisesCorrectly_asksForAllValues() throws {
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
			#expect(expected == actual)
		}
	}

	@Test
	func initWithinitWithDictionary__someKeysAreMissing__initialisesCorrectly_asksForAllValues() throws {
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
			#expect(expected == actual)
		}
	}

	@Test
	func initWithValueGetter__allKeysArePresent__initialisesCorrectly_asksForAllValues() throws {
		var remainingKeys = Set(Keys.allCases)

		let envVars = EnvironmentVariables<Keys> {
			guard let key = Keys(rawValue: $0)
			else {
				Issue.record("\($0) is not a valid key")
				return nil
			}

			guard remainingKeys.remove(key) != nil
			else {
				Issue.record("Matched key \(key) multiple times")
				return nil
			}

			return key.rawValue.uppercased()
		}

		#expect(remainingKeys.isEmpty, "Remaining keys: \(remainingKeys)")

		// This should not throw, since all keys are present
		try envVars.assertKeys()

		for key in Keys.allCases {
			let expected = key.rawValue.uppercased()
			let actual = try envVars.get(key)
			#expect(expected == actual)
		}
	}

	@Test
	func initWithValueGetter__someKeysAreMissing__initialisesCorrectly_asksForAllValues() throws {
		var remainingKeys = Set(Keys.allCases)

		let envVars = EnvironmentVariables<Keys> {
			guard let key = Keys(rawValue: $0)
			else {
				Issue.record("\($0) is not a valid key")
				return nil
			}

			guard remainingKeys.remove(key) != nil
			else {
				Issue.record("Matched key \(key) multiple times")
				return nil
			}

			if key == .foo {
				return nil
			}

			return key.rawValue.uppercased()
		}

		#expect(remainingKeys.isEmpty, "Remaining keys: \(remainingKeys)")

		// This should not throw, since these keys are present
		try envVars.assertKeys([ .bar, .baz ])

		for key in Keys.allCases {
			let expected = key == .foo ? nil : key.rawValue.uppercased()
			let actual = try? envVars.get(key)
			#expect(expected == actual)
		}
	}

	@Test
	func initWithValueGetter_async__allKeysArePresent__initialisesCorrectly_asksForAllValues() async throws {
		var remainingKeys = Set(Keys.allCases)

		let envVars = await EnvironmentVariables<Keys> {
			try! await Task.sleep(nanoseconds: 100_000_000)

			guard let key = Keys(rawValue: $0)
			else {
				Issue.record("\($0) is not a valid key")
				return nil
			}

			guard remainingKeys.remove(key) != nil
			else {
				Issue.record("Matched key \(key) multiple times")
				return nil
			}

			return key.rawValue.uppercased()
		}

		#expect(remainingKeys.isEmpty, "Remaining keys: \(remainingKeys)")

		// This should not throw, since all keys are present
		try envVars.assertKeys()

		for key in Keys.allCases {
			let expected = key.rawValue.uppercased()
			let actual = try envVars.get(key)
			#expect(expected == actual)
		}
	}

	@Test
	func initWithValueGetter_async__someKeysAreMissing__initialisesCorrectly_asksForAllValues() async throws {
		var remainingKeys = Set(Keys.allCases)

		let envVars = await EnvironmentVariables<Keys> {
			try! await Task.sleep(nanoseconds: 100_000_000)

			guard let key = Keys(rawValue: $0)
			else {
				Issue.record("\($0) is not a valid key")
				return nil
			}

			guard remainingKeys.remove(key) != nil
			else {
				Issue.record("Matched key \(key) multiple times")
				return nil
			}

			if key == .foo {
				return nil
			}

			return key.rawValue.uppercased()
		}

		#expect(remainingKeys.isEmpty, "Remaining keys: \(remainingKeys)")

		// This should not throw, since these keys are present
		try envVars.assertKeys([ .bar, .baz ])

		for key in Keys.allCases {
			let expected = key == .foo ? nil : key.rawValue.uppercased()
			let actual = try? envVars.get(key)
			#expect(expected == actual)
		}
	}

	@Test
	func assertKeys__allKeysAreRequired_noKeysArePresent__allKeysIncludedInError() async throws {
		let subject = EnvironmentVariables<Keys>(dictionary: [:])

		#expect { try subject.assertKeys() } throws: { error in
			if let error = error as? MissingEnvironmentVariables {
				return error.keys == Keys.allCases.map(\.rawValue)
			} else {
				return false
			}
		}
	}

	@Test
	func get__keyExists__returnsValue() async throws {
		let subject = EnvironmentVariables<Keys>(dictionary: [
			Keys.foo.rawValue: "1",
		])

		let actual = try subject.get(.foo)
		#expect(actual == "1")
	}

	@Test
	func get__keyDotNotExist__throws() async throws {
		let subject = EnvironmentVariables<Keys>(dictionary: [
			Keys.foo.rawValue: "1",
		])

		try subject.assertKeys([.foo])

		#expect { try subject.get(.bar) } throws: { error in
			guard let error = error as? MissingEnvironmentVariables
			else { return false }

			return error.keys == [Keys.bar, .baz].map(\.rawValue)
		}
	}

	@Test
	func assertKeys__someKeysAreRequired_noKeysArePresent__requiredKeysIncludedInError() async throws {
		let subject = EnvironmentVariables<Keys>(dictionary: [:])

		#expect { try subject.assertKeys([.foo, .bar]) }
		throws: { error in
			guard let error = error as? MissingEnvironmentVariables
			else { return false }
			return error.keys == [Keys.foo, .bar].map(\.rawValue)
		}
	}

	@Test
	func getWithMap__keyExists_mapperReturnsValidValue__returnsMappedValue() async throws {
		let subject = EnvironmentVariables<Keys>(dictionary: [
			Keys.foo.rawValue: "1",
		])

		let actual = try subject.get(.foo, map: Int.init)
		#expect(actual == 1)
	}

	@Test
	func getWithMap__keyExists_mapperReturnsNil__throws() async throws {
		let subject = EnvironmentVariables<Keys>(dictionary: [
			Keys.foo.rawValue: "a",
		])


		#expect { try subject.get(.foo, map: Int.init) }
		throws: { error in
			guard
				let error = error as? EnvironmentVariablesError,
				case let EnvironmentVariablesError.couldNotMap(value) = error
			else { return false }
			return value == "a"
		}
	}

	@Test
	func getWithMap__keyDotNotExist_mapperIsNotCalled__throws() async throws {
		let subject = EnvironmentVariables<Keys>(dictionary: [
			:
		])

		var mapperWasCalled = false
		#expect { try subject.get(.foo, map: { _ in
			mapperWasCalled = true
			return 1
		}) } throws: { error in
			guard let error = error as? MissingEnvironmentVariables
			else { return false }
			return error.keys == Keys.allCases.map(\.rawValue)
		}

		#expect(mapperWasCalled == false)
	}

	@Test
	func getWithMapAndDefault__keyExists_mapperReturnsValidValue__returnsMappedValue() async throws {
		let subject = EnvironmentVariables<Keys>(dictionary: [
			Keys.foo.rawValue: "1",
		])

		let actual = subject.get(.foo, map: Int.init, default: 0)
		#expect(actual == 1)
	}

	@Test
	func getWithMapAndDefault__keyExists_mapperReturnsNil__returnsDefault() async throws {
		let subject = EnvironmentVariables<Keys>(dictionary: [
			Keys.foo.rawValue: "a",
		])

		let actual = subject.get(.foo, map: Int.init, default: 0)
		#expect(actual == 0)
	}

	@Test
	func getWithMapAndDefault__keyDotNotExist_mapperIsNotCalled__returnsDefault() async throws {
		let subject = EnvironmentVariables<Keys>(dictionary: [
			:
		])

		var mapperWasCalled = false
		let actual = subject.get(.foo, map: { _ in
			mapperWasCalled = true
			return 1
		}, default: 0)

		#expect(actual == 0)
		#expect(mapperWasCalled == false)
	}

	@Test
	func getWithDefault__keyExists__returnsValue() async throws {
		let subject = EnvironmentVariables<Keys>(dictionary: [
			Keys.foo.rawValue: "1",
		])

		let actual = subject.get(.foo, default: "0")
		#expect(actual == "1")
	}

	@Test
	func getWithDefault__keyDotNotExist__returnsDefault() async throws {
		let subject = EnvironmentVariables<Keys>(dictionary: [
			:
		])

		let actual = subject.get(.foo, default: "0")

		#expect(actual == "0")
	}
}
