# Features

## Public API

The plugin exposes three primary operations:

- `isSupported()`
- `update(int count)`
- `remove()`

The API is intentionally small and stable.

## Cross-platform behavior

### Android

- Uses launcher badge integrations through the Android implementation.
- Numeric badges are launcher-dependent.
- Stock Pixel or AOSP launchers typically expose dots instead of badge counts.

### iOS

- Applies the badge through `UIApplication.shared.applicationIconBadgeNumber`.
- On iOS 16 and newer, also synchronizes through
	`UNUserNotificationCenter.setBadgeCount` to improve persistence when the app
	leaves the foreground.

### macOS

- Applies the badge through `NSApplication.shared.dockTile.badgeLabel`.

## Support semantics

- On Android, `isSupported()` reflects launcher support.
- On Darwin, `isSupported()` reflects platform badge capability.
- Notification settings can still affect whether the badge is visible, but they
	do not redefine platform capability.

## Error handling

- Negative counts throw immediately.
- Missing platform registration throws a fail-fast `StateError`.
- Unsupported launchers may ignore numeric badge changes even when the call
	itself succeeds.
