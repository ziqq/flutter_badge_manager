# Foundation Architecture

## Package role

`flutter_badge_manager_foundation` is the endorsed Darwin implementation for
iOS and macOS.

It registers itself as the default package for both platforms in the
app-facing plugin.

## Runtime path

1. Dart calls the app-facing package or the foundation package directly.
2. Generated Pigeon bindings forward the call to native Darwin code.
3. Swift host code applies the badge on iOS or macOS.

## Darwin split

### iOS

- updates `UIApplication.shared.applicationIconBadgeNumber`
- also syncs via `UNUserNotificationCenter.setBadgeCount` on iOS 16+

### macOS

- updates `NSApplication.shared.dockTile.badgeLabel`

## Native test support

The published Swift package follows the official Flutter plugin layout and
depends on the `FlutterFramework` package that Flutter generates at build time.

It has no standalone SwiftPM test target. Host-side behavior is validated through
the Dart tests and the example app, per the Flutter Swift Package Manager guide
for plugin authors.
