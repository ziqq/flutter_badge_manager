# flutter_badge_manager_foundation

The iOS and macOS implementation of [`flutter_badge_manager`](https://pub.dev/packages/flutter_badge_manager).

## Usage

This is the federated foundation (Darwin) implementation. You normally just depend on `flutter_badge_manager` and this package is pulled in automatically. You do not need to add it to `pubspec.yaml` unless you want to import it directly.

If you do import it explicitly, add to your `pubspec.yaml`:
```yaml
dependencies:
  flutter_badge_manager_foundation: ^<latest>
```

Then:
```dart
import 'package:flutter_badge_manager_foundation/flutter_badge_manager_foundation.dart';

final supported = await FlutterBadgeManagerFoundation.instance.isSupported();
if (supported) {
  await FlutterBadgeManagerFoundation.instance.update(3);
  await FlutterBadgeManagerFoundation.instance.remove();
}
```

## iOS

Badge visibility can still be affected by the app's notification settings. For the tested iOS flow, request badge notification authorization on iOS versions below 26 before relying on badge display or persistence. If your app also posts notifications, do that through your normal notification flow.

Add (if you need remote notifications background refresh):
```xml
<!-- ios/Runner/Info.plist -->
<key>UIBackgroundModes</key>
<array>
  <string>remote-notification</string>
</array>
```

Minimum iOS version: 13.0.

## macOS

Requires user notification authorization for badge display.

Optional Info.plist key to ensure banner style:
```xml
<!-- macos/Runner/Info.plist -->
<key>NSUserNotificationAlertStyle</key>
<string>banner</string>
```

Minimum macOS version: 10.15.

## API (via main plugin)

- `FlutterBadgeManagerFoundation.instance.isSupported()`
- `FlutterBadgeManagerFoundation.instance.update(int count)` (count >= 0)
- `FlutterBadgeManagerFoundation.instance.remove()`

Negative counts throw `PlatformException(code: 'invalid_args')`.

## Notes

- This package uses a generated Pigeon host API for Dart-to-native calls.
- Badge changes are applied via `UIApplication.shared.applicationIconBadgeNumber` on all supported iOS versions and additionally synchronized through `UNUserNotificationCenter.setBadgeCount` on iOS 16+ so the system badge state persists after the app leaves the foreground. On macOS the package uses `NSApplication.shared.dockTile.badgeLabel`.
- `isSupported()` reports whether the Darwin platform implementation supports badges at all. Notification permission still affects whether the badge is shown, but it does not change capability detection.
- Permission prompts are not triggered by this package. Request notification authorization only if your app's own notification flow needs it.
- The package example requests badge permission through `flutter_local_notifications` so it behaves predictably on iOS and macOS versions that require an explicit notification authorization flow before showing badge changes. On tested iOS versions below 26, that permission request is required for reliable badge behavior.

## License

MIT License (see LICENSE).