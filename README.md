# flutter_badge_manager

[![Pub](https://img.shields.io/pub/v/flutter_badge_manager.svg)](https://pub.dartlang.org/packages/flutter_badge_manager)


## Description
This plugin for [Flutter](https://flutter.io) adds the ability to change the badge of the app in the launcher.
It supports iOS, macOS, and some Android devices (the official API does not support the feature, even on Oreo).

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

### iOS

On iOS, the notification permission is required to update the badge.
It is automatically asked when the badge is added or removed.

Please also add the following to your <your project>/ios/Runner/Info.plist:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

### macOS

On macOS, the notification permission is required to update the badge.
It is automatically asked when the badge is added or removed.

Please also add the following to your <your project>/macos/Runner/Info.plist:
```xml
<key>NSUserNotificationAlertStyle</key>
<string>banner</string>
```

### Android

On Android, no official API exists to show a badge in the launcher. But some devices (Samsung, HTC...) support the feature.
Thanks to the [Shortcut Badger library](https://github.com/leolin310148/ShortcutBadger/), ~ 16 launchers are supported.


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
