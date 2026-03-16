# Changelog

## 0.2.0
- **CHANGED**: Removed the legacy `MethodChannelFlutterBadgeManager` fallback. Platform implementations must now register a Pigeon-backed implementation explicitly.
- **FIXED**: Fail fast when no federated implementation is registered, instead of silently falling back to the removed legacy channel implementation.

## 0.1.1
- **FIXED**: Republished the `0.1` platform interface after retracting `0.1.0`, excluding local `pubspec_overrides.yaml` development files from the published archive.

## 0.1.0
- **CHANGED**: Updated the platform interface for the Pigeon-based federated release: documented federated registration, and marked the old `MethodChannelFlutterBadgeManager` implementation as a deprecated legacy fallback.

## 0.0.4
- **CHANGED**: Updated documentation and code comments for clarity. No functional changes.

## 0.0.3
- **CHANGED**: Documentation updates, code cleanup, and minor refactors. No functional changes.
-
## 0.0.2
- **CHANGED**: Refactoring
-
## 0.0.1
- **ADDED**: Initial Release
