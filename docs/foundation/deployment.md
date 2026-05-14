# Foundation Deployment

## When to release

Release `flutter_badge_manager_foundation` when:

- Swift implementation changes
- Darwin runtime behavior changes
- foundation package docs or changelog changes are publish-relevant
- app-facing package needs a newer endorsed foundation version

## Validation

```sh
cd flutter_badge_manager_foundation && make all
cd flutter_badge_manager_foundation && make test-darwin-native
```

## Pigeon note

Do not regenerate Pigeon for implementation-only changes.

Regenerate only when the schema changes in:

`flutter_badge_manager_foundation/pigeons/flutter_badge_manager.dart`

## Release order

Publish the foundation package before publishing the app-facing package when the
app-facing package updates its foundation dependency constraint.
