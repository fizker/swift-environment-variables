# swift-environment-variables

Safely extract environment values.

## How to use

1. Add `.package(url: "https://github.com/fizker/swift-environment-variables.git", from: "1.1.0")` to the list of dependencies in your Package.swift file.
2. Add `.product(name: "EnvironmentVariables", package: "swift-environment-variables")` to the dependencies of the targets that need to use the models.
3. Add `import EnvironmentVariables` in the file.
4. Then, Xcode can build the DocC documentation, which includes detailed examples for how to use the project.
