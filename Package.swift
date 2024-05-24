// swift-tools-version:5.5

import PackageDescription

let package = Package(
	name: "swift-environment-variables",
	products: [
		.library(
			name: "EnvironmentVariables",
			targets: ["EnvironmentVariables"]
		),
	],
	targets: [
		.target(
			name: "EnvironmentVariables",
			dependencies: []
		),
		.testTarget(
			name: "EnvironmentVariablesTests",
			dependencies: ["EnvironmentVariables"],
			resources: [
				.copy("sample-env"),
				.copy("sample-env-multiline"),
			]
		),
	]
)
