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

## Manual commands

### Root level

```sh
make test-unit
```

### Per-package

```sh
cd flutter_badge_manager && make test-unit
cd flutter_badge_manager_android && make test-unit
cd flutter_badge_manager_foundation && make test-unit
cd flutter_badge_manager_platform_interface && make test-unit
```

## CI coverage

Current CI behavior:

- Linux jobs run Dart format, analyze, and `flutter test` for packages.

## Transport generation coverage

Dart transport generation is covered by:

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
