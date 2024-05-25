import XCTest
import EnvironmentVariables

final class MultiLoaderTests: XCTestCase {
	func test__get__threeLoaders_variousValues__returnsExpectedValue() async throws {
		let loaders = [
			[
				"unique1": "123",
				"shared": "1",
			],
			[
				"unique2": "456",
				"shared": "2",
			],
			[
				"unique3": "789",
				"shared": "3",
			],
		]

		let subject = MultiLoader(loaders: loaders)

		XCTAssertEqual(subject.get("shared"), "1")
		XCTAssertEqual(subject.get("unique1"), "123")
		XCTAssertEqual(subject.get("unique2"), "456")
		XCTAssertEqual(subject.get("unique3"), "789")
	}
}
