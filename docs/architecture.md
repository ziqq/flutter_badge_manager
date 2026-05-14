# Architecture

## Overview

`flutter_badge_manager` is a federated Flutter plugin monorepo.

The repository is split into four packages:

- `flutter_badge_manager`: app-facing package used by consumers.
- `flutter_badge_manager_platform_interface`: shared abstract contract.
- `flutter_badge_manager_android`: Android implementation.
- `flutter_badge_manager_foundation`: iOS and macOS implementation.

## Runtime flow

The public API lives in the app-facing package and delegates to the registered
platform implementation.

Flow for a typical call:

1. Dart code calls `FlutterBadgeManager.instance.update(count)`.
2. The app-facing package forwards the call to
	 `FlutterBadgeManagerPlatform.instance`.
3. The endorsed platform package registers itself with the platform interface.
4. The platform package forwards the call through a Pigeon-generated transport.
5. Native Android or Darwin code applies the badge.

## Registration model

The repository no longer uses a legacy fallback `MethodChannel`
implementation in the platform interface.

- If a platform implementation registers successfully, calls are forwarded.
- If nothing registers, the platform interface fails fast with a `StateError`.

## Transport model

The Android and Darwin packages use Pigeon for Flutter runtime transport.

- Generated Dart bindings live under `lib/src/*.g.dart`.
- Generated test bindings live under `test/test_api.g.dart`.
- Generated native bindings live in the platform package output locations.

Do not edit generated files directly.

## Native test split

The Darwin package now has two distinct testing layers:

- Flutter-side tests under `flutter_badge_manager_foundation/test/`.
- Native Swift tests under
	`flutter_badge_manager_foundation/darwin/flutter_badge_manager_foundation/Tests/`.

The native Swift tests run through SwiftPM and use lightweight shim types for
test-only compilation. Those shims are not used by the Flutter runtime.

## Key design constraints

- Public Dart API is instance-first.
- Platform implementations extend the platform interface instead of
	implementing it.
- Negative badge counts are invalid everywhere.
- Android capability depends on launcher support.
- Darwin capability is treated as platform capability, while visibility can
	still depend on system settings.
