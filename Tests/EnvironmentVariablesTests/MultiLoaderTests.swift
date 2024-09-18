import Testing
import EnvironmentVariables

struct MultiLoaderTests {
	@Test
	func get__threeLoaders_variousValues__returnsExpectedValue() async throws {
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

		#expect(subject.get("shared") == "1")
		#expect(subject.get("unique1") == "123")
		#expect(subject.get("unique2") == "456")
		#expect(subject.get("unique3") == "789")
		#expect(subject.get("unknown") == nil)
	}
}
