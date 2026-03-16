# Migration Guide

This repository now uses Pigeon as the primary transport for the federated
Android and Foundation implementations.

For app developers, the main migration is from the deprecated static API to the
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

Deprecated, but still supported for compatibility:

```dart
await FlutterBadgeManager.update(3);
await FlutterBadgeManager.remove();
final supported = await FlutterBadgeManager.isSupported();
```
> Will be removed in a future release. Please migrate to the instance API.

### What changed

- `FlutterBadgeManager.instance` is the preferred API surface.
- The static methods on `FlutterBadgeManager` are deprecated compatibility
  shims.
- Android and Foundation implementations now use generated Pigeon bindings for
  their primary Dart-to-native transport.
- The old `MethodChannel` transport is still present as a fallback to avoid
  breaking existing behavior when no federated implementation has registered.

### What did not change

- The public `FlutterBadgeManager` symbol stays the same.
- Existing static calls still work.
- Negative counts are still invalid.
- Platform behavior stays the same: Android launcher support is device-specific,
  while iOS and macOS rely on notification authorization.

## Maintainer Migration

If you maintain this plugin or write tests against the federated packages:

- Prefer testing Android and Foundation through the generated Pigeon test
  handlers instead of mocking the legacy `MethodChannel` directly.
- Keep the package-local Pigeon schemas in the platform packages.

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