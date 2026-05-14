# Foundation Tests

## Dart tests

The package has normal Flutter-side tests for:

- Dart API forwarding
- registration
- Pigeon transport behavior on the Dart side

Command:

```sh
cd flutter_badge_manager_foundation && make test-unit
```

## Native Darwin tests

The package also has native Swift tests for host-side logic.

Command:

```sh
cd flutter_badge_manager_foundation && make test-darwin-native
```

Direct SwiftPM command:

```sh
cd flutter_badge_manager_foundation/darwin/flutter_badge_manager_foundation
swift test
```

## CI

GitHub Actions runs these Darwin native tests in a dedicated macOS job.

## Why native tests exist separately

They validate host implementation details that are not covered by plain
`flutter test`, such as:

- plugin registration wiring
- native badge writer delegation
- iOS-specific and macOS-specific host behavior
