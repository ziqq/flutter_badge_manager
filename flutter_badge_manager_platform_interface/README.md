# flutter_badge_manager_platform_interface

[![Pub](https://img.shields.io/pub/v/flutter_badge_manager_platform_interface.svg)](https://pub.dartlang.org/packages/flutter_badge_manager_platform_interface)

Common platform interface for the `flutter_badge_manager` family of plugins.

This package defines the abstract API used by:
- Foundation (iOS / macOS) implementation
- Android implementation
- Any future (custom) implementations

## Interface

Extend `FlutterBadgeManagerPlatform` and set your implementation as default:

```dart
class MyBadgeManager extends FlutterBadgeManagerPlatform {
  @override
  Future<bool> isSupported() async => /* platform check */;
  @override
  Future<void> update(int count) async { /* apply badge */ }
  @override
  Future<void> remove() async { /* remove badge */ }
}
```

Registration (typically in your plugin's `registerWith` or static init):

```dart
FlutterBadgeManagerPlatform.instance = MyBadgeManager();
```

The provided MethodChannel implementation (`MethodChannelFlutterBadgeManager`) is used as the default on supported platforms.

## Methods

- `isSupported()` → `bool`
- `update(int count)` (count >= 0)
- `remove()`

Negative counts must throw a `PlatformException` with code `invalid_args`.

## Adding a new platform implementation

1. Create a new package (e.g. `flutter_badge_manager_windows`).
2. Depend on `flutter_badge_manager_platform_interface`.
3. Implement `FlutterBadgeManagerPlatform`.
4. Set `FlutterBadgeManagerPlatform.instance` to your class during plugin registration.

## Breaking changes

Avoid breaking the interface. Prefer adding new optional methods with sensible fallbacks. See Flutter guidance: https://flutter.dev/go/platform-interface-breaking-changes

## License

BSD 3-Clause (see LICENSE).