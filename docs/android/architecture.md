# Android Architecture

## Package role

`flutter_badge_manager_android` is the endorsed Android implementation of the
plugin family.

It extends the shared platform interface and registers itself as the default
Android package for `flutter_badge_manager`.

## Runtime path

1. Dart code calls the app-facing package.
2. The platform interface forwards to `FlutterBadgeManagerAndroid`.
3. The Android package uses generated Pigeon bindings.
4. Native Java code applies or clears the launcher badge.

## Native implementation

The Android host implementation lives in Java and currently relies on launcher
badge support through `ShortcutBadger`.

This means the package can be technically available on Android while numeric
badge support still varies by launcher vendor.
