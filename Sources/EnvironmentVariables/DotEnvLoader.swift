import Foundation

typealias EnvFile = [String: String]

public struct DotEnvLoader {
	/// The location that the Loader should look for `.env` files
	public enum Location {
		/// The currently configured working directory.
		case currentWorkingDir
		/// The directory that the executable is located in.
		case executableDir
		/// A custom path.
		///
		/// - If this is the path to a file, it will be treated as a `.env` file regardless of the name.
		/// - If this is the path of a directory, `.env` will be appended to the path.
		case path(String)
	}

	private let fm: FileManager
	private let pi: ProcessInfo
	private var files: [EnvFile] = []

	public init(locations: [Location] = [.executableDir, .currentWorkingDir], fileManager: FileManager = .default, processInfo: ProcessInfo = .processInfo) {
		fm = fileManager
		pi = processInfo

		var hasFoundCWD = false
		var hasFoundExecutableDir = false

		for location in locations {
			let path: String
			switch location {
			case let .path(p):
				path = p
			case .currentWorkingDir:
				guard !hasFoundCWD
				else { continue }
				hasFoundCWD = true
				var url = URL(fileURLWithPath: fm.currentDirectoryPath)
				url.appendPathComponent(".env")
				path = url.path
			case .executableDir:
				guard !hasFoundExecutableDir
				else { continue }
				hasFoundExecutableDir = true

				let executablePath = pi.arguments[0]
				if #available(macOS 13.0, *) {
					var dir = URL(filePath: executablePath)
					dir.deleteLastPathComponent()
					dir.append(component: ".env")
					path = dir.path()
				} else {
					var dir = URL(fileURLWithPath: executablePath)
					dir.deleteLastPathComponent()
					dir.appendPathComponent(".env")
					path = dir.path
				}
			}

			if let file = handle(path: path) {
				files.append(file)
			}
		}
	}

	func handle(path: String) -> EnvFile? {
		var isDir: ObjCBool = false
		guard fm.fileExists(atPath: path, isDirectory: &isDir)
		else { return nil }

		let data: Data?
		if #available(macOS 13.0, *) {
			var url = URL(filePath: path)
			if isDir.boolValue {
				url.append(component: ".env")
			}
			data = fm.contents(atPath: url.path())
		} else {
			var url = URL(fileURLWithPath: path)
			if isDir.boolValue {
				url.appendPathComponent(".env")
			}
			data = fm.contents(atPath: url.path)
		}

		guard
			let data,
			let content = String(data: data, encoding: .utf8)
		else { return nil }

		return Self.parse(file: content)
	}

	public func get(_ key: String) -> String? {
		for file in files {
			if let value = file[key] {
				return value
			}
		}

		return nil
	}

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
