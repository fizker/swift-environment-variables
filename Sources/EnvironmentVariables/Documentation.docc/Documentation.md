# ``EnvironmentVariables``

Safely extract environment values.

## Overview

First, create a enum for the keys. It must have `String` as the raw value and conform
to `CaseIterable` to be usable. The raw value will be used as the key to look up.

```swift
enum EnvKey: String, CaseIterable {
	/// The key is `foo`.
	case foo
	/// The key is `my-env-var`.
	case bar = "my-env-var"
}
```

Then create an instance of ``EnvironmentVariables/EnvironmentVariables`` that use that enum.

The default init pulls the values from `ProcessInfo.processInfo` first, and then looks for `.env`
files in the current working directory and in the folder containing the executable, in that priority order.

```swift
let env = EnvironmentVariables<EnvKey>()
```

An example for loading a dotenv file with a custom filename in addition to the default values:

```swift
let env = EnvironmentVariables<EnvKey>(loader: MultiLoader(loaders: [
	// Values in the environment takes precedence
	.environment,
	// Our custom name
	DotEnvLoader(location: "custom-dotenv-filename")),
	// The default list. Note that this also includes .environment, but since that is a Dictionary, lookups are very cheap.
	.default,
]))
```

See ``EnvironmentVariables/EnvironmentVariables/init(dictionary:)``, ``MultiLoader`` and ``DotEnvLoader``, if other sources are needed.

If some values are required for the app to function, this would be a good time to assert their presence, so that the app fails early.

```swift
env.assertKeys([ .foo ])
```

If all keys are required, call ``EnvironmentVariables/EnvironmentVariables/assertKeys()`` without parameters.

Retrieving values is easy. ``EnvironmentVariables/EnvironmentVariables/get(_:)`` and related functions provides easy access.

```swift
// throws if `.foo` is not present
let stringValue = try env.get(.foo)

// returns `"bar"` if `.foo` is not present
let defaultedStringValue = env.get(.foo, default: "bar")
```

Mapping the value to something other than String is also easy

```swift
// throws if `.foo` is missing, or if the map-function returns nil.
// It rethrows if the map-function throws.
let intValue = try env.get(.foo, map: { (value: String) in Int(value) })

// returns `1` if `.foo` is missing or the map-function returns nil.
// It rethrows if the map-function can throw.
let defaultedIntValue = try env.get(.foo, map: Int.init, default: 1)
```

Reading the values and passing their default/map in multiple locations is not good for code reuse. This can be helped with a simple extension method.

```swift
extension EnvironmentVariables where Key == EnvKey {
	var foo: Int {
		return get(
			.foo,
			map: Int.init,
			default: 1
		)
	}

	var bar: String {
		get throws {
			return try get(.bar)
		}
	}
}
```

## Topics

### Defining environment variables

- ``EnvironmentVariables/EnvironmentVariables``
- ``EnvironmentVariablesError``
- ``MissingEnvironmentVariables``


### Value Loaders

- ``Loader``
- ``DotEnvLoader``
- ``MultiLoader``
