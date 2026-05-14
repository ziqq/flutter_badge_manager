# Roadmap

## Near term

- Keep the instance-first API stable.
- Maintain platform-specific correctness for badge persistence.
- Expand CI so native behavior regressions are caught earlier.

## Android

- Continue documenting launcher-specific limitations.
- Keep compatibility with supported launcher ecosystems.

## Darwin

- Preserve iOS badge persistence behavior across OS changes.
- Keep native Swift tests aligned with the host implementation.
- Expand native assertions when Darwin-specific behavior grows.

## Platform interface

- Keep the contract minimal.
- Add new interface methods only when multiple implementations need them.

## Tooling

- Keep Pigeon generation deterministic.
- Keep monorepo validation simple enough to run locally.
