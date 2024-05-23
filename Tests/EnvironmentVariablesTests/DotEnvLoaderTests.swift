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
}
