# Changelog

## 0.2.1
- **FIXED**: Updated the iOS badge writer to use `UNUserNotificationCenter.setBadgeCount` on iOS 16+ with a legacy fallback for older versions, improving badge persistence when the app moves out of the foreground.
- **FIXED**: On iOS 16+ the Foundation implementation now synchronizes badge updates through both `UIApplication.shared.applicationIconBadgeNumber` and `UNUserNotificationCenter.setBadgeCount`, preserving the immediate app-side update while also persisting the system badge state.
- **FIXED**: Restored `isSupported()` to report badge capability on supported Darwin platforms instead of the current notification authorization state.

## 0.2.0
- **CHANGED**: Removed the legacy static `MethodChannel` wrapper and now rely exclusively on federated Pigeon-backed platform implementations.
- **FIXED**: Finalized the instance-first release line by removing the legacy static export, updating the testing factory to `instanceFor`, and switching example coverage to injected platform implementations.

## 0.1.0
- **CHANGED**: Released the first stable Pigeon-based federated API surface, migrated the Android, iOS, and macOS transports to Pigeon, and aligned package documentation around the instance-first migration path while preserving the legacy MethodChannel compatibility path.

## 0.0.6
- **FIXED**: Android plugin Pigeon configuration to generate Java class with the expected name, resolving build issues.

## 0.0.5
- **CHANGED**: Updated documentation and code comments for clarity. No functional changes.

## 0.0.4
- **CHANGED**: Updated dependencies, code cleanup, and minor refactoring. No functional changes.

## 0.0.3
- **CHANGED**: Android plugin implementation
-
## 0.0.2
- **ADDED**: Separation for each supported platform

## 0.0.1
- **ADDED**: Initial Release
