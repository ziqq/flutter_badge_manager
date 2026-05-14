# Android Features

## Supported operations

- check launcher badge support
- update badge count
- remove badge count

## Behavior notes

- Numeric badge support is not part of the stock Android platform contract.
- Some OEM launchers support numbers.
- Pixel and AOSP usually show notification dots instead of numeric badges.
- Android 13 and newer may require notification permission depending on the app
	flow.

## Constraints

- Negative values are invalid.
- A successful call does not guarantee the launcher will render a number.
