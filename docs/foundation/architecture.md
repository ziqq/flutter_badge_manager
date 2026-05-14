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

The Darwin package contains a SwiftPM-compatible native test target.

This exists specifically to test host-side behavior without going through the
Flutter runtime.

Pigeon-generated Swift transport still exists for runtime use. SwiftPM tests use
lightweight shim types instead of the generated transport layer.
