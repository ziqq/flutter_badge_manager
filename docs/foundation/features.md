# Foundation Features

## Supported operations

- `isSupported()`
- `update(count)`
- `remove()`

## iOS behavior

- Direct badge update for immediate app-side state.
- Notification-center sync on iOS 16+ for improved persistence after
	backgrounding.
- Capability detection is separate from notification authorization state.

## macOS behavior

- Dock tile badge labels are applied through AppKit.

## Important notes

- Notification settings can still affect whether the user sees the badge.
- On tested iOS versions below 26, request badge notification permission before relying on badge display or persistence.
- The package itself does not trigger permission prompts.
- If an app needs notification authorization, that flow belongs to the app.
