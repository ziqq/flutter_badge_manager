# flutter_badge_manager

[![Pub](https://img.shields.io/pub/v/flutter_badge_manager.svg)](https://pub.dartlang.org/packages/flutter_badge_manager)


## Description
This plugin for [Flutter](https://flutter.io) adds the ability to change the badge of the app in the launcher.
It supports iOS, macOS, and some Android devices (the official API does not support the feature, even on Oreo).

|             | Android | iOS   | macOS  | Web | Windows     |
|-------------|---------|-------|--------|-----|-------------|
| **Support** | SDK 21+ | 13.0+ | 10.5+ | N/A | N/A         |

<p align="center">
  <img
    src="https://raw.githubusercontent.com/ziqq/flutter_badge_manager/refs/heads/main/.docs/ios.png"
    style="margin:auto" width="600"
    alt="Android badge"
    height="228">
</p>

<p align="center">
  <img
    src="https://raw.githubusercontent.com/ziqq/flutter_badge_manager/refs/heads/main/.docs/android.png"
    style="margin:auto" width="600"
    alt="Android badge"
    height="322">
</p>


## Installation

### Android

Starting with Android 8.0 (API level 26), notification badges—also known as notification
dots—appear on a launcher icon when the associated app has an active notification. Users can
touch & hold the app icon to reveal the notifications, along with any app shortcuts.

https://developer.android.com/develop/ui/views/notifications/badges

Starting With Android13 (API level 33), notification runtime permission should be requested before setting the app badge.

Add the following permissions to `AndroidManifest.xml` according to the system you need to support:
```xml
<!-- Samsung -->
<uses-permission android:name="com.sec.android.provider.badge.permission.READ"/>
<uses-permission android:name="com.sec.android.provider.badge.permission.WRITE"/>

<!-- HTC -->
<uses-permission android:name="com.htc.launcher.permission.READ_SETTINGS"/>
<uses-permission android:name="com.htc.launcher.permission.UPDATE_SHORTCUT"/>

<!-- Sony -->
<uses-permission android:name="com.sonyericsson.home.permission.BROADCAST_BADGE"/>
<uses-permission android:name="com.sonymobile.home.permission.PROVIDER_INSERT_BADGE"/>

<!-- Apex -->
<uses-permission android:name="com.anddoes.launcher.permission.UPDATE_COUNT"/>

<!-- Solid -->
<uses-permission android:name="com.majeur.launcher.permission.UPDATE_BADGE"/>

<!-- Huawei -->
<uses-permission android:name="com.huawei.android.launcher.permission.CHANGE_BADGE" />
<uses-permission android:name="com.huawei.android.launcher.permission.READ_SETTINGS" />
<uses-permission android:name="com.huawei.android.launcher.permission.WRITE_SETTINGS" />
```

### iOS and macOS

Requires notification permission if badge is used together with notifications iOS 13.0+, macOS 10.15+.

### Permissions

Use **[permission_handler](https://pub.dev/packages/permission_handler)** to request:
- Android 13+: Notification permission.
- iOS / macOS: Notification authorization (badge).


## Example

First, you just have to import the package in your dart files with:
```dart
import 'package:flutter_badge_manager/flutter_badge_manager.dart';
```

Then you can add a badge:
```dart
FlutterBadgeManager.update(1);
```

Remove a badge:
```dart
FlutterBadgeManager.remove();
```

Or just check if the device supports this feature with:
```dart
FlutterBadgeManager.isSupported();
```

## Notes
- Pixel / AOSP launcher: numeric badge not shown (only dot based on notifications).
- Set 0 (or remove) to clear the badge.
- Negative values are rejected.

## License
BSD.