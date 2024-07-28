import XCTest
@testable import EnvironmentVariables

final class MissingEnvironmentVariablesTests: XCTestCase {
	func test__description__singleErrorProvided__returnsCorrectDescription() async throws {
		let subject = MissingEnvironmentVariables(keys: ["b"])
		XCTAssertEqual(subject.description, "Following required env keys are missing: b")
	}

	func test__description__multipleErrorsProvided__returnsCorrectDescription() async throws {
		let subject = MissingEnvironmentVariables(keys: ["b", "a", "c"])
		XCTAssertEqual(subject.description, "Following required env keys are missing: b, a, c")
	}
}
