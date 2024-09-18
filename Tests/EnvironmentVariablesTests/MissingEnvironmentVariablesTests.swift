import Testing
@testable import EnvironmentVariables

struct MissingEnvironmentVariablesTests {
	@Test
	func description__singleErrorProvided__returnsCorrectDescription() async throws {
		let subject = MissingEnvironmentVariables(keys: ["b"])
		#expect(subject.description == "Following required env keys are missing: b")
	}

	@Test
	func description__multipleErrorsProvided__returnsCorrectDescription() async throws {
		let subject = MissingEnvironmentVariables(keys: ["b", "a", "c"])
		#expect(subject.description == "Following required env keys are missing: b, a, c")
	}
}
