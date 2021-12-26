# ``EnvironmentVariables``

Safely extract environment values.

## Overview

First, create a enum for the keys. It must be `: String, CaseIterable` to be usable.

```swift
enum EnvKey: String, CaseIterable {
	case foo = "my-env-var", bar
}
```

Then create an instance of ``EnvironmentVariables/EnvironmentVariables`` that use that enum.

The default init pulls the values from `ProcessInfo.processInfo`, but a function can be passed in if a different source is wanted.

```swift
let env = EnvironmentVariables<EnvKey>()
```

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

### Group 1
