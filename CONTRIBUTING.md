# Contributing to flutter_badge_manager

Issues and pull requests are welcome!

## Prerequisites

- Flutter managed via [FVM](https://fvm.app/) (see `.fvmrc`). Always prefix commands with `fvm`.
- GNU Make (ships with macOS / most Linux distros).

## Getting started

```bash
# Clone and enter the repo
git clone https://github.com/ziqq/flutter_badge_manager.git
cd flutter_badge_manager

# Install dependencies for all packages
make get
```

## Project structure

```
flutter_badge_manager/                     # App-facing package (what users depend on)
flutter_badge_manager_platform_interface/   # Platform interface (abstract contract)
flutter_badge_manager_android/              # Android implementation
flutter_badge_manager_foundation/           # iOS & macOS (Darwin) implementation
```

## Build, test, and validate

All commands use `make` targets. Run from the repo root.

| Command              | Description                                |
|----------------------|--------------------------------------------|
| `make get`           | Get dependencies for all packages          |
| `make format`        | Format all packages (line length 80)       |
| `make analyze`       | Analyze all packages                       |
| `make check`         | Analyze + pana for all packages            |
| `make test-unit`     | Run unit tests with coverage               |
| `make all`           | Full pipeline: format + check + test-unit  |
| `make precommit`     | Same as `make all`                         |
| `make publish-check` | Dry-run publish for all packages           |

### Per-package commands

Each package has its own `Makefile` with the same targets:

```bash
cd flutter_badge_manager && make all
cd flutter_badge_manager_platform_interface && make all
cd flutter_badge_manager_android && make all
cd flutter_badge_manager_foundation && make all
```

## Coding rules

- **Dart format**: line length **80**, enforced by `make format`.
- **Linting**: `flutter_lints` with strict casts, strict raw types, strict inference.
- **No `print()`** — use `dart:developer` (`dev.log`).
- **No `dynamic`** in JSON parsing — use pattern matching + `switch`. Errors → `FormatException`.
- **Immutability**: models are immutable, use `copyWith`, `const` constructors where possible.
- **Platform interface**: extend `FlutterBadgeManagerPlatform`, do **not** implement it.
- **Generated files**: never edit `**/generated/**`, `*.g.dart`, `*.gen.dart`.

## Branching and commits

- **Branch**: `author/github-<number>/<description>` or `author/<type>/<description>`.
- **Commits**: [Conventional Commits](https://www.conventionalcommits.org/) — `<type>(github-<number>): <description>`.
- **PR title**: same pattern.

Always run `make precommit` before pushing.

## Submitting changes

1. Fork the repo and create your branch from `main`.
2. Make your changes in the relevant package(s).
3. Add or update tests for the new behavior.
4. Run `make precommit` — all formatting, analysis, and tests must pass.
5. Open a pull request describing the change.

Keep changes non-breaking for the legacy static API (`FlutterBadgeManager.update`). Add new instance methods instead of altering existing signatures.

## License

By contributing, you agree that your contributions will be licensed under the MIT License (see [LICENSE](LICENSE)).
