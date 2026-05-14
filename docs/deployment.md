# Deployment

## Release model

This repository publishes a federated plugin family.

Release order matters when a package updates its dependency constraints.

Current order:

1. `flutter_badge_manager_platform_interface` when its API changes.
2. `flutter_badge_manager_android` or `flutter_badge_manager_foundation` when
	 their implementations change.
3. `flutter_badge_manager` after endorsed implementation constraints are ready.

## Before publishing

Run the standard validation pipeline from the repository root:

```sh
make get
make format
make analyze
make test-unit
make test-darwin-native
```

For a fuller package validation pass:

```sh
make check
make publish-check
```

## Versioning

- Bump the affected package version in its `pubspec.yaml`.
- Add a matching changelog entry in that package's `CHANGELOG.md`.
- Keep app-facing dependency constraints in sync with newly released endorsed
	implementations.

## Monorepo overrides

Local development may use `pubspec_overrides.yaml` files to point package
dependencies at workspace paths.

Those overrides are for repository development and CI validation. The published
package graph must still resolve correctly using released versions.

## Publish workflow

The repository includes a publish workflow triggered from tags or
`workflow_dispatch`.

Before tagging, confirm:

- changelogs match final behavior
- dependency constraints point to released versions or the next release order is
	planned
- generated files are up to date

## Release checklist

1. Regenerate Pigeon if the schema changed.
2. Run package validation.
3. Run Darwin native tests.
4. Update changelogs.
5. Update versions.
6. Confirm dependency constraints.
7. Run publish dry-runs.
8. Tag and publish in dependency order.
