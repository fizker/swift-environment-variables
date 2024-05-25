import Foundation

/// A loader used to extract values from a key-source.
public protocol Loader {
	/// Returns the value that matches the given key.
	///
	/// - parameter key: The key.
	/// - returns: The matching value or `nil` if there is no match.
	func get(_ key: String) -> String?
}

extension Loader where Self == MultiLoader {
	/// A default loader that looks in the environment for the process, as well as looks for `.env` files in the current working directory for the process and the folder where the executable is.
	///
	/// The priority is as follows:
	/// 1. The environment
	/// 2. The current working directory.
	/// 3. The directory containing the executable.
	public static var `default`: MultiLoader {
		MultiLoader(loaders: [
			ProcessInfo.processInfo.environment,
			DotEnvLoader(location: .currentWorkingDir),
			DotEnvLoader(location: .executableDir),
		])
	}
}

extension Dictionary: Loader where Key == String, Value == String {
	/// Returns the value that matches the given key.
	///
	/// - parameter key: The key.
	/// - returns: The matching value or `nil` if there is no match.
	public func get(_ key: String) -> String? {
		self[key]
	}
}
