# Platform Interface Architecture

## Role

`flutter_badge_manager_platform_interface` defines the shared contract used by
all implementations.

It is intentionally small and does not contain platform transport logic.

## Design rules

- Implementations must extend `FlutterBadgeManagerPlatform`.
- They should not `implements` the interface directly.
- The interface fails fast when no implementation registers.

## Contract surface

- `isSupported()`
- `update(int count)`
- `remove()`

This package should change only when the shared API contract actually changes.
