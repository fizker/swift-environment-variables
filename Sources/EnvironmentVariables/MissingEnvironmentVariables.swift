/// Error container for any required Environment keys that are missing
public struct MissingEnvironmentVariables: Error, Sendable {
	/// The keys that are missing.
	public var keys: [String]
}

extension MissingEnvironmentVariables: CustomStringConvertible {
	public var description: String {
		"""
		Following required env keys are missing: \(keys.joined(separator: ", "))
		"""
	}
}
