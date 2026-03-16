# flutter_badge_manager

This is a **Flutter plugin** (not an app) to set and clear application badge numbers on Android, iOS and macOS. It follows the [federated plugin architecture](https://flutter.dev/go/federated-plugins) with platform-specific implementations for Android and iOS/macOS, as well as a common Dart platform interface.


## Environment setup

- **Flutter version**: managed via [FVM](https://fvm.app/) (see `.fvmrc`). Always prefix Flutter/Dart commands with `fvm`.

```sh
fvm flutter pub get
```

To run the example app:

```sh
cd flutter_badge_manager/example
fvm flutter run
```


## Project Structure

Full project tree: see `README.md` → **Project Structure**.

```
flutter_badge_manager/                     # App-facing package (what users depend on)
flutter_badge_manager_platform_interface/   # Platform interface (abstract contract)
flutter_badge_manager_android/              # Android implementation
flutter_badge_manager_foundation/           # iOS & macOS (Darwin) implementation
```


## Build, test, and validate

All commands use `make` targets. Always run `make get` first if dependencies might be stale.

### Key commands (root level)

```sh
make get              # Get dependencies for all packages
make format           # Format all packages (line length 80)
make analyze          # Analyze all packages
make check            # Analyze + pana for all packages
make test-unit        # Run unit tests for all packages
make all              # Full pipeline: format + check + test-unit
make precommit        # Same as `make all`
```

### Per-package commands

Each package (`flutter_badge_manager/`, `flutter_badge_manager_platform_interface/`, `flutter_badge_manager_android/`, `flutter_badge_manager_foundation/`) has its own `Makefile` with the same targets. Run from within the package directory:

```sh
cd flutter_badge_manager && make all
cd flutter_badge_manager_platform_interface && make all
cd flutter_badge_manager_android && make all
cd flutter_badge_manager_foundation && make all
```

### Test structure

Each package has a `test/` directory with unit tests. The main test file matches the package name (e.g., `flutter_badge_manager_test.dart`). Use `make test-unit` to run tests with coverage.


## Key conventions

### Do not edit

- `**/generated/**`, `*.g.dart`, `*.gen.dart` — generated files.

### Coding rules

- **No `print()`** — use `dart:developer` (`dev.log`).
- **No `dynamic`** in JSON parsing — use pattern matching + `switch`. Errors → `FormatException`.
- **Immutability**: models are immutable, use `copyWith`, `const` constructors where possible.
- **Platform interface**: extend `FlutterBadgeManagerPlatform`, do **not** implement it.
- **Transport**: use the federated Pigeon-backed platform implementations. Do not reintroduce a `MethodChannelFlutterBadgeManager` fallback.
- **Dart format**: line length **80**, enforced via `make format`.
- **Linting**: `flutter_lints` with strict casts, strict raw types, strict inference.

### Branching and commits

- Branch: `author/github-<number>/<description>` or `author/<type>/<description>`.
- Commits: Conventional Commits — `<type>(github-<number>): <description>`.
- PR title: same pattern. Always run `make precommit` before submitting.


## Configuration files

| File | Purpose |
|---|---|
| `<package>/pubspec.yaml` | Package dependencies and metadata |
| `<package>/analysis_options.yaml` | Lint rules (`flutter_lints` + custom), analyzer excludes |
| `<package>/Makefile` | Per-package build/test/format/analyze targets |
| `.fvmrc` | FVM Flutter version configuration |
| `Makefile` | Root-level orchestration targets |


## Agent behavior expectations

Before doing anything:
1. **Clarify** everything unclear — ask clarifying questions.
2. **Highlight** weak points, corner cases that were not accounted for.
3. Read `README.md` for project overview and usage.


## Critical rules

- Before substantial work, read `CLAUDE.md` and `AGENTS.md` for full conventions.
- Never edit: `**/generated/**`, `*.g.dart`, `*.gen.dart`.
- When you've made a major change and completed a task, update the patch version in the relevant `pubspec.yaml` and add a note to the corresponding `CHANGELOG.md`.


## Before writing code

For trivial fixes (typos, one-line changes, simple renames), skip discussion and just do it.

For anything non-trivial, do NOT start implementation until all open questions are resolved. First:

1. **Challenge the approach** — point out flaws, missed edge cases, and risks. Be direct.
2. **Ask about unknowns** — if anything is ambiguous, ask. Do not guess or assume.
3. **Propose alternatives** — if there is a simpler or more robust way, say so and explain why.
4. **List edge cases** — enumerate what can break.
5. **Wait for confirmation** — do not write code until the user explicitly approves the plan.

Do only what was asked. Do not refactor surrounding code, add comments to code you did not change, or introduce abstractions for hypothetical future needs.


## After writing code

Do not consider a task done until verified:

- `make format` — no formatting issues
- `make analyze` — no analyzer warnings
- `make test-unit` — all tests pass

If tests or analysis fail, fix the issue before reporting completion.