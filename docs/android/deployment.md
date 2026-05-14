# Android Deployment

## When to release

Release the Android package when:

- the Java implementation changes
- Android-facing behavior changes
- Android example behavior changes in a publish-relevant way
- Android dependency constraints change

## Validation

```sh
cd flutter_badge_manager_android && make all
```

From the root:

```sh
make get
make format
make analyze
make test-unit
```

## Notes

- Regenerate Pigeon only if the Android schema changes.
- Keep the app-facing package dependency constraint aligned with the released
	Android version.
