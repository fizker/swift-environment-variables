typealias EnvFile = [String: String]

public struct DotEnvLoader {
	static func parse(file: String) -> EnvFile? {
		enum State {
			case key, value
		}

		var output: [String: String] = [:]

		var state = State.key

		var currentKey: [Character] = []
		var currentValue: [Character] = []

		func finishValue() {
			if !currentKey.isEmpty && !currentValue.isEmpty {
				output[String(currentKey)] = String(currentValue)
				currentKey = []
				currentValue = []
			}
		}

		for token in file {
			if token == "\n" {
				state = .key
				finishValue()
				continue
			}

			switch state {
			case .key:
				if token == "=" {
					state = .value
				} else {
					currentKey.append(token)
				}
			case .value:
				currentValue.append(token)
			}
		}

		finishValue()

		return output
	}
}
