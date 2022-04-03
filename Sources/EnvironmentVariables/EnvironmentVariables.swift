import Foundation

/// Errors that could be thrown by the `EnvironmentVariables` struct.
public enum EnvironmentVariablesError: Error {
	/// Contains a value that a given mapper failed to convert to the expected type.
	/// See ``EnvironmentVariables/EnvironmentVariables/get(_:map:)`` for an example.
	case couldNotMap(String)
}

/// Helper for looking up environment variables in a manner where the keys are safe from misspellings.
public struct EnvironmentVariables<Key> where Key: Hashable, Key: CaseIterable, Key: RawRepresentable, Key.RawValue == String {
	/// Creates a new `EnvironmentVariables`.
	///
	/// - Parameter valueGetter: A function that takes a `String` key and returns the matching
	/// value from the environment, or `nil` if there are no matches.
	public init(valueGetter: (String) -> String? = { ProcessInfo.processInfo.environment[$0] }) {
		missingKeys.keys = []

		for key in Key.allCases {
			if let value = valueGetter(key.rawValue) {
				values[key] = value
			} else {
				values[key] = nil
				missingKeys.keys.append(key.rawValue)
			}
		}
	}

	/// Creates a new `EnvironmentVariables`.
	///
	/// - Parameter valueGetter: An async function that takes a `String` key and returns the matching
	/// value from the environment, or `nil` if there are no matches.
	@available(macOS 10.15.0, *)
	public init(valueGetter: (String) async -> String?) async {
		missingKeys.keys = []

		for key in Key.allCases {
			if let value = await valueGetter(key.rawValue) {
				values[key] = value
			} else {
				values[key] = nil
				missingKeys.keys.append(key.rawValue)
			}
		}
	}

	/// Asserts if any keys are missing, and throws if there are.
	///
	/// See ``assertKeys(_:)`` to specify a subset of the keys.
	///
	/// - Throws: An instance of `MissingEnvironmentVariables` containing all the required keys that are missing.
	public func assertKeys() throws {
		guard !missingKeys.keys.isEmpty
		else { return }

		throw missingKeys
	}

	/// Asserts if any of the given keys are missing, and throws if there are.
	///
	/// See ``assertKeys()`` if all the keys are required.
	///
	/// - Parameter requiredKeys: The list of keys to assert against.
	///
	/// - Throws: An instance of `MissingEnvironmentVariables` containing all the required keys that are missing.
	public func assertKeys(_ requiredKeys: [Key]) throws {
		guard !missingKeys.keys.isEmpty
		else { return }

		let keys = requiredKeys.map(\.rawValue)
		let missingKeys = keys.filter(self.missingKeys.keys.contains)

		guard !missingKeys.isEmpty
		else { return }

		throw MissingEnvironmentVariables(keys: missingKeys)
	}

	/// Returns the matching values from the environment, or throws if the value is not present.
	///
	/// - Parameter key: The key to look up.
	///
	/// - Returns: The matching value.
	///
	/// See ``get(_:default:)`` for a non-throwing version.
	///
	/// See ``get(_:map:)`` for a version that maps to a different value than `String`.
	///
	/// See ``get(_:map:default:)`` for a non-throwing version that maps to a different value than `String`.
	///
	/// - Throws: An instance of `MissingEnvironmentVariables` containing all the required keys that are missing, including the currently requested.
	public func get(_ key: Key) throws -> String {
		guard let value = values[key]
		else { throw missingKeys }

		return value
	}

	/// Returns the matching values from the environment, after mapping it, or the given default if the value is not present.
	///
	/// - Parameter key: The key to look up.
	/// - Parameter map: The map function used to transform the value.
	///
	/// - Returns: The transformed value, or the default if the value could not be transformed.
	///
	/// See ``get(_:)`` for a throwing version.
	///
	/// See ``get(_:default:)`` for a non-throwing version.
	///
	/// See ``get(_:map:default:)`` for a non-throwing version that maps to a different value than `String`.
	///
	/// - Throws: If the `map` function can throw, that `Error` is propagated from here.
	///     If the `map` function returns `nil`, `EnvironmentVariablesError.couldNotMap(value)` is thrown.
	public func get<T>(_ key: Key, map: (String) throws -> T?) throws -> T {
		let value = try get(key)

		guard let mapped = try map(value)
		else { throw EnvironmentVariablesError.couldNotMap(value) }

		return mapped
	}

	/// Returns the matching values from the environment, or the given default if the value is not present.
	///
	/// - Parameter key: The key to look up.
	/// - Parameter default: The default value to use if the variable is missing.
	///
	/// - Returns: The matching value.
	///
	/// See ``get(_:)`` for a throwing version.
	///
	/// See ``get(_:map:)`` for a version that maps to a different value than `String`.
	///
	/// See ``get(_:map:default:)`` for a non-throwing version that maps to a different value than `String`.
	public func get(_ key: Key, default: String) -> String {
		let value = try? get(key)
		return value ?? `default`
	}

	/// Returns the matching values from the environment, after mapping it, or the given default if the value is not present.
	///
	/// - Parameter key: The key to look up.
	/// - Parameter map: The map function used to transform the value.
	/// - Parameter default: The default value to use if the variable is missing.
	///
	/// - Returns: The transformed value, or the default if the value could not be transformed.
	///
	/// See ``get(_:)`` for a throwing version.
	///
	/// See ``get(_:default:)`` for a non-throwing version.
	///
	/// See ``get(_:map:)`` for a version that maps to a different value than `String`.
	///
	/// - Throws: If the `map` function can throw, that `Error` is propagated from here.
	public func get<T>(_ key: Key, map: (String) throws -> T?, default: T) rethrows -> T {
		let value = try? get(key)
		return try value.flatMap(map) ?? `default`
	}

	private var values: [Key: String] = [:]
	private var missingKeys: MissingEnvironmentVariables = .init()
}
