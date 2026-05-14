# Tests

## Test layers

The repository uses three main test layers.

### Dart unit tests

Every package has `flutter test` coverage for its Dart-facing API:

- app-facing package behavior
- platform interface behavior
- Android transport and Dart-side forwarding
- Foundation transport and Dart-side forwarding

### Example tests

Packages with an `example/` app also run Flutter tests for the example code.

This catches regressions in:

- example startup flow
- permission handling on supported platforms
- basic update and remove interactions

### Darwin native Swift tests

The Darwin package also contains native Swift tests in:

`flutter_badge_manager_foundation/darwin/flutter_badge_manager_foundation/Tests/`

These tests validate host-side behavior that is hard to express from Dart,
including:

- plugin registration wiring
- native badge writer dispatch
- Darwin-specific update and remove behavior

## Manual commands

### Root level

```sh
make test-unit
make test-darwin-native
```

### Per-package

```sh
cd flutter_badge_manager && make test-unit
cd flutter_badge_manager_android && make test-unit
cd flutter_badge_manager_foundation && make test-unit
cd flutter_badge_manager_foundation && make test-darwin-native
cd flutter_badge_manager_platform_interface && make test-unit
```

## CI coverage

Current CI behavior:

- Linux jobs run Dart format, analyze, and `flutter test` for packages.
- A macOS job runs Darwin native Swift tests for the foundation package.

The Darwin native tests are intentionally separate from `flutter test` because
they are executed through SwiftPM.

## What native Swift tests do not cover

The native Swift test target does not validate Dart transport generation.

That part is covered by:

- Pigeon generation checks
- Dart-side tests that use generated bindings
- normal Flutter runtime execution

## When Pigeon must be regenerated

Regenerate Pigeon only when the schema changes.

Typical trigger:

- editing `pigeons/flutter_badge_manager.dart`

Typical non-trigger:

- changing native implementation logic only
- changing tests only
- changing CI or Makefiles only
