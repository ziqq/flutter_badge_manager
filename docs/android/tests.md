# Android Tests

## Coverage

The Android package is primarily covered through Flutter-side Dart tests.

These tests validate:

- Dart-to-Pigeon forwarding
- registration behavior
- Android package semantics exposed through the Dart API

## Commands

```sh
cd flutter_badge_manager_android && make test-unit
```

## Current gap

There is no separate native Android unit test target wired into this repository
at the moment. The package relies on Flutter-side tests and integration through
the plugin runtime.
