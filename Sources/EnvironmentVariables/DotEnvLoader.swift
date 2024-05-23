typealias EnvFile = [String: String]

public struct DotEnvLoader {
	static func parse(file: String) -> EnvFile? {
		enum State {
			case key, value
			case beforeValue, afterValue
			case quotedValue(Character)
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
				switch state {
				case .quotedValue(_):
					break
				default:
					state = .key
					finishValue()
					continue
				}
			}

			switch state {
			case .key:
				if token == "=" {
					state = .beforeValue
				} else {
					currentKey.append(token)
				}
			case .afterValue:
				continue
			case .beforeValue:
				switch token {
				case "'", "`", "\"":
					state = .quotedValue(token)
				default:
					currentValue.append(token)
				}
			case let .quotedValue(quotation):
				guard token == quotation
				else { fallthrough }

				state = .afterValue
			case .value:
				currentValue.append(token)
			}
		}

		finishValue()

		return output
	}
}
