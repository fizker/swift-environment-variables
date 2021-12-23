import XCTest
@testable import EnvironmentVariables

final class EnvironmentVariablesTests: XCTestCase {
	func smokeTest() throws {
		XCTAssertEqual("Foo", "Foo")
	}
}
