/// A loader that takes a list of other loaders.
public struct MultiLoader: Loader {
	/// The loaders to search through. If multiple loaders contain the same value, only the first match is used.
	public var loaders: [(String) -> String?]

	/// - parameter loaders: The loaders to search through. If multiple loaders contain the same value, only the first match is used.
	public init(loaders: [any Loader]) {
		self.init(loaders: loaders.map { $0.get })
	}

	/// - parameter loaders: The loaders to search through. If multiple loaders contain the same value, only the first match is used.
	public init(loaders: [(String) -> String?]) {
		self.loaders = loaders
	}

	/// Iterates through the loaders and returns the first non-nil value.
	///
	/// - parameter key: The key to request.
	/// - returns: The first matching value in the list of ``loaders`` or `nil` if no matches are returned.
	public func get(_ key: String) -> String? {
		for loader in loaders {
			if let value = loader(key) {
				return value
			}
		}

		return nil
	}
}
