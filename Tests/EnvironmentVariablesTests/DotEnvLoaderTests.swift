import XCTest
@testable import EnvironmentVariables

final class DotEnvLoaderTests: XCTestCase {
	func test__parseFile__simpleFile__parsesCorrectly() async throws {
		let file = DotEnvLoader.parse(file: """
		foo=123
		bar=somevalue
		""")

		XCTAssertEqual(file, [
			"foo": "123",
			"bar": "somevalue",
		])
	}

	func test__parseFile__quotes__parsesCorrectly() async throws {
		let file = DotEnvLoader.parse(file: """
		foo="123"
		bar='456'
		baz=`789`
		""")

		XCTAssertEqual(file, [
			"foo": "123",
			"bar": "456",
			"baz": "789",
		])
	}

	func test__parseFile__multiLine__parsesCorrectly() async throws {
		let file = DotEnvLoader.parse(file: """
		foo="1
		2"
		bar='1
		2'
		baz=`1
		2`
		""")

		XCTAssertEqual(file, [
			"foo": "1\n2",
			"bar": "1\n2",
			"baz": "1\n2",
		])
	}

	func test__parseFile__emptyLines_quotes__parsesCorrectly() async throws {
		let file = DotEnvLoader.parse(file: """

		foo=1
		# foo
		bar=2

		baz=3 # comment
		""")

		XCTAssertEqual(file, [
		"foo": "1",
		"bar": "2",
		"baz": "3",
		])
	}

	func test__parseFile__emptyValues__parsesCorrectly() async throws {
		let file = DotEnvLoader.parse(file: """
		foo=
		bar=""
		baz=``
		foobar=''
		""")

		XCTAssertEqual(file, [
		"foo": "",
		"bar": "",
		"baz": "",
		"foobar": "",
		])
	}

	func test__parseFile__singleLineSampleFile__parsesCorrectly() async throws {
		guard
			let path = Bundle.module.path(forResource: "sample-env", ofType: nil),
			let data = FileManager.default.contents(atPath: path),
			let content = String(data: data, encoding: .utf8)
		else {
			XCTFail("Failed to load file")
			return
		}

		let file = DotEnvLoader.parse(file: content)

		XCTAssertEqual(file, [
			"BASIC": "basic",
			"AFTER_LINE": "after_line",
			"EMPTY": "",
			"EMPTY_SINGLE_QUOTES": "",
			"EMPTY_DOUBLE_QUOTES": "",
			"EMPTY_BACKTICKS": "",
			"SINGLE_QUOTES": "single_quotes",
			"SINGLE_QUOTES_SPACED": "    single quotes    ",
			"DOUBLE_QUOTES": "double_quotes",
			"DOUBLE_QUOTES_SPACED": "    double quotes    ",
			"DOUBLE_QUOTES_INSIDE_SINGLE": #"double "quotes" work inside single quotes"#,
			"DOUBLE_QUOTES_WITH_NO_SPACE_BRACKET": "{ port: $MONGOLAB_PORT}",
			"SINGLE_QUOTES_INSIDE_DOUBLE": "single 'quotes' work inside double quotes",
			"BACKTICKS_INSIDE_SINGLE": "`backticks` work inside single quotes",
			"BACKTICKS_INSIDE_DOUBLE": "`backticks` work inside double quotes",
			"BACKTICKS": "backticks",
			"BACKTICKS_SPACED": "    backticks    ",
			"DOUBLE_QUOTES_INSIDE_BACKTICKS": #"double "quotes" work inside backticks"#,
			"SINGLE_QUOTES_INSIDE_BACKTICKS": #"single 'quotes' work inside backticks"#,
			"DOUBLE_AND_SINGLE_QUOTES_INSIDE_BACKTICKS": #"double "quotes" and single 'quotes' work inside backticks"#,
			"EXPAND_NEWLINES": "expand\nnew\nlines",
			"DONT_EXPAND_UNQUOTED": "dontexpand\\nnewlines",
			"DONT_EXPAND_SQUOTED": "dontexpand\\nnewlines",
			"INLINE_COMMENTS": "inline comments",
			"INLINE_COMMENTS_SINGLE_QUOTES": "inline comments outside of #singlequotes",
			"INLINE_COMMENTS_DOUBLE_QUOTES": "inline comments outside of #doublequotes",
			"INLINE_COMMENTS_BACKTICKS": "inline comments outside of #backticks",
			"INLINE_COMMENTS_SPACE": "inline comments start with a",
			"EQUAL_SIGNS": "equals==",
			"RETAIN_INNER_QUOTES": #"{"foo": "bar"}"#,
			"RETAIN_INNER_QUOTES_AS_STRING": #"{"foo": "bar"}"#,
			"RETAIN_INNER_QUOTES_AS_BACKTICKS": #"{"foo": "bar's"}"#,
			"TRIM_SPACE_FROM_UNQUOTED": "some spaced out string",
			"USERNAME": "therealnerdybeast@example.tld",
			"SPACED_KEY": "parsed",
		])
	}

	func test__parseFile__multiLineSampleFile__parsesCorrectly() async throws {
		guard
			let path = Bundle.module.path(forResource: "sample-env-multiline", ofType: nil),
			let data = FileManager.default.contents(atPath: path),
			let content = String(data: data, encoding: .utf8)
		else {
			XCTFail("Failed to load file")
			return
		}

		let file = DotEnvLoader.parse(file: content)

		XCTAssertEqual(file, [
			"BASIC": "basic",
			"AFTER_LINE": "after_line",
			"EMPTY": "",
			"SINGLE_QUOTES": "single_quotes",
			"SINGLE_QUOTES_SPACED": "    single quotes    ",
			"DOUBLE_QUOTES": "double_quotes",
			"DOUBLE_QUOTES_SPACED": "    double quotes    ",
			"EXPAND_NEWLINES": "expand\nnew\nlines",
			"DONT_EXPAND_UNQUOTED": "dontexpand\\nnewlines",
			"DONT_EXPAND_SQUOTED": "dontexpand\\nnewlines",
			"EQUAL_SIGNS": "equals==",
			"RETAIN_INNER_QUOTES": #"{"foo": "bar"}"#,
			"RETAIN_INNER_QUOTES_AS_STRING": #"{"foo": "bar"}"#,
			"TRIM_SPACE_FROM_UNQUOTED": "some spaced out string",
			"USERNAME": "therealnerdybeast@example.tld",
			"SPACED_KEY": "parsed",
			"MULTI_DOUBLE_QUOTED": """
				THIS
				IS
				A
				MULTILINE
				STRING
				""",
			"MULTI_SINGLE_QUOTED": """
				THIS
				IS
				A
				MULTILINE
				STRING
				""",
			"MULTI_BACKTICKED": """
				THIS
				IS
				A
				"MULTILINE'S"
				STRING
				""",
			"MULTI_PEM_DOUBLE_QUOTED": """
				-----BEGIN PUBLIC KEY-----
				MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnNl1tL3QjKp3DZWM0T3u
				LgGJQwu9WqyzHKZ6WIA5T+7zPjO1L8l3S8k8YzBrfH4mqWOD1GBI8Yjq2L1ac3Y/
				bTdfHN8CmQr2iDJC0C6zY8YV93oZB3x0zC/LPbRYpF8f6OqX1lZj5vo2zJZy4fI/
				kKcI5jHYc8VJq+KCuRZrvn+3V+KuL9tF9v8ZgjF2PZbU+LsCy5Yqg1M8f5Jp5f6V
				u4QuUoobAgMBAAE=
				-----END PUBLIC KEY-----
				""",
		])
	}
}
