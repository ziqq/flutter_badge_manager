# Changelog

## 0.2.1
- **FIXED**: Aligned the generated Android Pigeon Java output with the `FlutterBadgeManagerPluginPigeon` class name, removing the stale `FlutterBadgeManagerPlugin.g.java` layout that could break Gradle/Javac builds.
- **FIXED**: Updated the Android Pigeon build/check workflow so regenerated bindings are validated against `FlutterBadgeManagerPluginPigeon.java`.

## 0.2.0
- **CHANGED**: Removed the legacy Android `MethodChannel` transport and kept badge operations on the Pigeon host API only.
- **FIXED**: Restored Android plugin registration while keeping the generated bindings in `FlutterBadgeManagerPluginPigeon.java`.
- **FIXED**: Updated the Android example build to use NDK `28.2.13676358`, matching the `integration_test` requirement.

## 0.1.1
- **FIXED**: Republished the `0.1` Android implementation after retracting `0.1.0`, excluding local `pubspec_overrides.yaml` development files from the published archive.

## 0.1.0
- **CHANGED**: Promoted the Android implementation to the 0.1 release line, switched it to the Pigeon-based primary transport, and completed the related API/documentation cleanup while preserving the legacy MethodChannel compatibility path.

## 0.0.6
- **FIXED**: Generated Java class name in Pigeon configuration to match the expected plugin structure. This resolves build issues related to the generated code.

## 0.0.5
- **CHANGED**: Updated documentation and code comments for clarity. No functional changes.

## 0.0.4
- **CHANGED**: Updated dependencies, code cleanup, and minor refactoring. No functional changes.

## 0.0.3
- **FIXED**: Removed empty notification badge
-
## 0.0.2
- **CHANGED**: Refactoring

## 0.0.1
- **ADDED**: Initial Release
