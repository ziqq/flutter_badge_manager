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
import 'package:flutter_badge_manager/flutter_badge_manager.dart';

final supported = await FlutterBadgeManager.isSupported();
if (supported) {
  await FlutterBadgeManager.update(3);
  await FlutterBadgeManager.remove();
}
```

## iOS

Requires notification (badge) permission. Request it before updating the badge if you manage permissions manually.

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

- `FlutterBadgeManager.isSupported()`
- `FlutterBadgeManager.update(int count)` (count >= 0)
- `FlutterBadgeManager.remove()`

Negative counts throw `PlatformException(code: 'invalid_args')`.

## Notes

- Badge changes are applied via `UIApplication.shared.applicationIconBadgeNumber` (iOS) and `NSApplication.shared.dockTile.badgeLabel` (macOS).
- Permission prompts are not auto-triggered if you never requested notifications; make sure to request authorization when needed.

## License

BSD 3-Clause (see LICENSE).