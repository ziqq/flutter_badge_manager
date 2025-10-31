# flutter_badge_manager_android

The Android implementation of [`flutter_badge_manager`](https://pub.dev/packages/flutter_badge_manager).

## Usage

This package is endorsed; you normally depend only on `flutter_badge_manager` and this implementation is included automatically. You do not need to add it to `pubspec.yaml` unless you want to import it directly.

If you do import it explicitly:

```yaml
dependencies:
  flutter_badge_manager_android: ^<latest>
```

Then:

```dart
import 'package:flutter_badge_manager_android/flutter_badge_manager_android.dart';

final supported = await FlutterBadgeManagerAndroid.instance.isSupported();
if (supported) {
  await FlutterBadgeManagerAndroid.instance.update(5);
  await FlutterBadgeManagerAndroid.instance.remove();
}
```

## Behavior

- No official Android API for numeric launcher badges.
- Numeric badges work only on supported OEM / third‑party launchers (Samsung, Xiaomi, Huawei, Oppo, etc.).
- Pixel / AOSP stock launcher: only notification dot (no number).
- If `isSupported()` returns false, `update()` silently applies fallback (may rely on notification dot only).
- Negative counts must throw `PlatformException(code: 'invalid_args')`.

## Permissions

For Android 13+ request runtime notification permission before updating:

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> ensureNotificationPermission() async {
  final status = await Permission.notification.status;
  if (!status.isGranted) {
    await Permission.notification.request();
  }
}
```

Optional OEM permissions (place inside `AndroidManifest.xml`) can increase compatibility:

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
<!-- Others -->
<uses-permission android:name="com.anddoes.launcher.permission.UPDATE_COUNT"/>
<uses-permission android:name="com.majeur.launcher.permission.UPDATE_BADGE"/>
```

## Testing

Use a device/emulator with a launcher that supports numeric badges (e.g. Samsung). On Pixel expect only `isSupported()==false` and notification dots.

## License

BSD 3-Clause (see LICENSE).