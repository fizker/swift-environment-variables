public protocol Loader {
	func get(_ key: String) -> String?
}

extension Dictionary: Loader where Key == String, Value == String {
	public func get(_ key: String) -> String? {
		self[key]
	}
}
