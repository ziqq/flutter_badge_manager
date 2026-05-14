# Changelog

## 0.2.2
- **FIXED**: Improved iOS badge compatibility by updating the modern notification-center badge sync only when badge authorization is enabled.
- **FIXED**: Updated the Darwin example app to request badge permission through a notification permission flow, restoring confirmed badge behavior on iOS 18+ and 26+ test devices.

## 0.2.1
- **FIXED**: Updated the iOS badge writer to use `UNUserNotificationCenter.setBadgeCount` on iOS 16+ with a legacy fallback for older versions, improving badge persistence when the app moves out of the foreground.
- **FIXED**: On iOS 16+ the Foundation implementation now synchronizes badge updates through both `UIApplication.shared.applicationIconBadgeNumber` and `UNUserNotificationCenter.setBadgeCount`, preserving the immediate app-side update while also persisting the system badge state.
- **FIXED**: Restored `isSupported()` to report badge capability on supported Darwin platforms instead of the current notification authorization state.

## 0.2.0
- **CHANGED**: Removed the legacy Darwin `FlutterMethodChannel` transport and kept badge operations on the Pigeon host API only.
- **FIXED**: Aligned the Foundation package tests and package verification flow with the current Pigeon-backed implementation.

## 0.1.1
- **FIXED**: Republished the `0.1` iOS and macOS implementation after retracting `0.1.0`, excluding local `pubspec_overrides.yaml` development files from the published archive.

## 0.1.0
- **CHANGED**: Promoted the iOS and macOS implementation to the 0.1 release line, migrated it to the Pigeon-based primary transport, and completed the related API/documentation cleanup while retaining the legacy MethodChannel compatibility path.

## 0.0.3
- **CHANGED**: Updated documentation and code comments for clarity. No functional changes.

## 0.0.2
- **CHANGED**: Refactoring

## 0.0.1
- **ADDED**: Initial Release
