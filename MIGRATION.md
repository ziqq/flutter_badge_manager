# Migration Guide

This repository now uses Pigeon as the only supported transport for the
federated Android and Foundation implementations.

For app developers, the main migration is from the removed static API to the
instance API.

## Consumer Migration

Recommended:

```dart
final badge = FlutterBadgeManager.instance;
if (await badge.isSupported()) {
  await badge.update(3);
  await badge.remove();
}
```

Removed in `0.2.0`:

```dart
await FlutterBadgeManager.update(3);
await FlutterBadgeManager.remove();
final supported = await FlutterBadgeManager.isSupported();
```
Replace those calls with `FlutterBadgeManager.instance`.

### What changed

- `FlutterBadgeManager.instance` is the preferred API surface.
- The old static wrapper is no longer exported by `flutter_badge_manager`.
- `FlutterBadgeManager.instanceFor(...)` is the supported way to bind a test
  instance to an injected platform implementation.
- Android and Foundation implementations now use generated Pigeon bindings for
  Dart-to-native transport.
- If no federated implementation is registered, platform calls now fail fast
  with a `StateError`.

### What did not change

- The public `FlutterBadgeManager` symbol stays the same.
- Negative counts are still invalid.
- Platform behavior stays the same: Android launcher support is device-specific,
  while iOS and macOS rely on notification authorization.

## Maintainer Migration

If you maintain this plugin or write tests against the federated packages:

- Bind tests to an injected platform with `FlutterBadgeManager.instanceFor(...)`
  instead of assuming the shared singleton will stay attached to the same test
  double across cases.
- Prefer testing Android and Foundation through the generated Pigeon test
  handlers instead of mocking plugin transport channels directly.
- Keep the package-local Pigeon schemas in the platform packages.
- Keep generated Dart bindings out of the generic format check and validate
  them through the package `make pigeon` / `make pigeon-check` flow instead.

The small `FlutterBadgeManagerApi` contract appears in both platform packages on
purpose. Each package generates a different set of bindings and uses a distinct
channel namespace:

- Android generates Dart test bindings and Java host bindings.
- Foundation generates Dart test bindings and Swift host bindings.

Moving that schema into `flutter_badge_manager_platform_interface` would couple
the interface package to platform-specific code generation concerns and make the
package-local generation workflow less self-contained.

The duplicated copyright header files are also intentional for the same reason:
each federated package should be able to regenerate its bindings from inside the
package directory without depending on files outside that package.