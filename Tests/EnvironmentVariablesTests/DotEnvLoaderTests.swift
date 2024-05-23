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
}
