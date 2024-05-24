typealias EnvFile = [String: String]

public struct DotEnvLoader {
	static func parse(file: String) -> EnvFile? {
		enum State {
			case key, value, comment
			case beforeValue, afterQuote(Character)
			case quotedValue(Character)
		}

		var output: [String: String] = [:]

		var state = State.key

		var currentKey: [Character] = []
		var currentValue: [Character] = []

		func finishValue() {
			if !currentKey.isEmpty {
				var value = String(currentValue)
				if case let .afterQuote(quotation) = state {
					if quotation == "\"" {
						value = value.replacingOccurrences(of: "\\n", with: "\n")
					}
				} else {
					value = value.trimmingCharacters(in: .whitespaces)
				}
				output[String(currentKey).trimmingCharacters(in: .whitespaces)] = value
				currentKey = []
				currentValue = []
			}
		}

		for token in file {
			if token.isNewline {
				switch state {
				case .quotedValue(_):
					break
				default:
					finishValue()
					state = .key
					continue
				}
			}
			if token == "#" {
				switch state {
				case .quotedValue(_), .afterQuote:
					break
				default:
					state = .comment
					continue
				}
			}

			switch state {
			case .comment:
				continue
			case .key:
				if token == "=" {
					state = .beforeValue
				} else {
					currentKey.append(token)
				}
			case .afterQuote:
				continue
			case .beforeValue:
				switch token {
				case "{":
					state = .quotedValue("}")
					currentValue.append("{")
				case "'", "`", "\"":
					state = .quotedValue(token)
				default:
					currentValue.append(token)
				}
			case let .quotedValue(quotation):
				guard token == quotation
				else { fallthrough }

				if token == "}" {
					currentValue.append("}")
				}

				state = .afterQuote(quotation)
			case .value:
				currentValue.append(token)
			}
		}

		finishValue()

		return output
	}
}
