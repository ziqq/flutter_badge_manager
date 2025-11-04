# flutter_badge_manager

[![Pub](https://img.shields.io/pub/v/flutter_badge_manager.svg)](https://pub.dev/packages/flutter_badge_manager)

Plugin to set / clear application badge numbers on iOS, macOS and supported Android launchers (OEM / third‑party). Stock Android (Pixel / AOSP) only shows a notification dot; numeric badges depend on the launcher.

| Platform | Min Version | Notes |
|----------|-------------|-------|
| Android  | API 21+     | Numeric badge only on supported launchers; request POST_NOTIFICATIONS on API 33+. |
| iOS      | 13.0+       | Uses applicationIconBadgeNumber; needs notification authorization. |
| macOS    | 10.15+      | Uses dockTile.badgeLabel; needs notification authorization. |

<p align="center">
  <img
    src="https://raw.githubusercontent.com/ziqq/flutter_badge_manager/refs/heads/main/.github/images/ios.png"
    style="margin:auto" width="600"
    alt="Android badge"
    height="228">
</p>

<p align="center">
  <img
    src="https://raw.githubusercontent.com/ziqq/flutter_badge_manager/refs/heads/main/.github/images/android.png"
    style="margin:auto" width="600"
    alt="Android badge"
    height="322">
</p>

## Features

- Unified API with automatic federated implementation selection.
- Legacy static calls still work (`FlutterBadgeManager.update(3)`).
- New instance style (`FlutterBadgeManager.instance.update(3)`).
- Fallback to legacy method channel if federated platform not registered.
- Simple support check: `isSupported()`.

## Installation

Add to `pubspec.yaml` (only top-level plugin needed):
```yaml
dependencies:
  flutter_badge_manager: ^<latest>
```

Federated platform packages (Android, iOS/macOS) are auto-included when you build your app.

## iOS Setup

Request notification permission before setting a badge if you also show notifications.

Optional (for remote notification background handling) add to `ios/Runner/Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
  <string>remote-notification</string>
</array>
```

## macOS Setup

Optional banner style in `macos/Runner/Info.plist`:
```xml
<key>NSUserNotificationAlertStyle</key>
<string>banner</string>
```

## Android Notes

No official numeric badge API. Supported via OEM/third‑party launchers (Samsung, Xiaomi, Huawei, Sony, etc.). Pixel shows only dots triggered by notifications.

Android 13+ (API 33): request runtime notification permission before updating badge number.

Optional launcher permissions (add only what you really need) in `AndroidManifest.xml`:
```xml
<!-- Samsung -->
<uses-permission android:name="com.sec.android.provider.badge.permission.READ"/>
<uses-permission android:name="com.sec.android.provider.badge.permission.WRITE"/>
<!-- Huawei -->
<uses-permission android:name="com.huawei.android.launcher.permission.CHANGE_BADGE"/>
<uses-permission android:name="com.huawei.android.launcher.permission.READ_SETTINGS"/>
<uses-permission android:name="com.huawei.android.launcher.permission.WRITE_SETTINGS"/>
<!-- Sony -->
<uses-permission android:name="com.sonyericsson.home.permission.BROADCAST_BADGE"/>
<uses-permission android:name="com.sonymobile.home.permission.PROVIDER_INSERT_BADGE"/>
<!-- HTC / others -->
<uses-permission android:name="com.anddoes.launcher.permission.UPDATE_COUNT"/>
<uses-permission android:name="com.majeur.launcher.permission.UPDATE_BADGE"/>
```

## Usage

Import:
```dart
import 'package:flutter_badge_manager/flutter_badge_manager.dart';
```

Static (legacy style):
```dart
await FlutterBadgeManager.update(5);
await FlutterBadgeManager.remove();
final supported = await FlutterBadgeManager.isSupported();
```

Instance style:
```dart
final badge = FlutterBadgeManager.instance;
if (await badge.isSupported()) {
  await badge.update(7);
  await badge.remove();
}
```

Basic helper:
```dart
Future<void> setUnread(int unread) async {
  if (!await FlutterBadgeManager.isSupported()) return;
  await FlutterBadgeManager.update(unread.clamp(0, 9999));
}
```

## Permissions (recommended flow)

iOS/macOS:
- Request notification authorization (badge) via `permission_handler` or native flow before first update.

Android (API 33+):
```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> ensureNotificationPermission() async {
  final status = await Permission.notification.status;
  if (!status.isGranted) {
    await Permission.notification.request();
  }
}
```

## Constraints

- `count >= 0`; negative values throw `ArgumentError`.
- Unsupported launchers may ignore numeric changes.
- Clearing badge = `remove()` (sets label to blank / 0 depending on platform).

## Troubleshooting

- Returns false on `isSupported()` on Pixel: expected (numeric not available).
- Badge not visible on Android: launcher does not support numeric badges or permission not granted.
- iOS badge not updating: check notification authorization and that app not restricted in settings.

## Contributing

Issues / PRs welcome. Keep changes non-breaking for static API (`FlutterBadgeManager.update`). Add new instance methods instead of altering existing signatures.

## License

BSD 3-Clause (see LICENSE).