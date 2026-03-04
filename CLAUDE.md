# flutter_badge_manager

A Flutter plugin to set and clear application badge numbers on Android, iOS and macOS. Federated plugin monorepo.

## Structure

```
flutter_badge_manager/                     # App-facing package (what users depend on)
flutter_badge_manager_platform_interface/   # Platform interface (abstract contract)
flutter_badge_manager_android/              # Android implementation
flutter_badge_manager_foundation/           # iOS & macOS (Darwin) implementation
```

- `flutter_badge_manager/lib/src/flutter_badge_manager.dart` — `FlutterBadgeManager` class, delegates to `FlutterBadgeManagerPlatform`
- `flutter_badge_manager/lib/src/flutter_badge_manager_lagacy.dart` — deprecated static API wrapper
- `flutter_badge_manager_platform_interface/lib/` — `FlutterBadgeManagerPlatform`, `MethodChannelFlutterBadgeManager`
- `flutter_badge_manager_android/lib/src/` — `FlutterBadgeManagerAndroid` extends `FlutterBadgeManagerPlatform`
- `flutter_badge_manager_foundation/lib/src/` — `FlutterBadgeManagerFoundation` extends `FlutterBadgeManagerPlatform`

## Key Commands

```bash
# Setup
make get                               # Get dependencies for all packages

# Build & validate
make all                               # Full pipeline: format + check + test-unit
make precommit                         # Same as `make all`
make format                            # Format all packages (line length 80)
make analyze                           # Analyze all packages
make check                             # Analyze + pana for all packages
make test-unit                         # Unit tests for all packages
```

### Per-package

```bash
cd flutter_badge_manager && make all
cd flutter_badge_manager_platform_interface && make all
cd flutter_badge_manager_android && make all
cd flutter_badge_manager_foundation && make all
```

## Conventions

- **Commits**: Conventional Commits — `<type>(github-<number>): <description>`
- **Flutter version**: managed via FVM (see `.fvmrc`). Always prefix commands with `fvm`
- **Dart format**: line length **80**, enforced by `make format`
- **No `print()`** — use `dart:developer` (`dev.log`)
- **No `dynamic`** in JSON parsing — pattern matching + `switch`, errors → `FormatException`
- **Immutability**: models are immutable, use `copyWith`, `const` constructors
- **Platform interface**: extend `FlutterBadgeManagerPlatform`, do **not** implement it

## Critical Rules

- Before substantial work, read `CLAUDE.md` and `AGENTS.md` for full conventions.
- Never edit: `**/generated/**`, `*.g.dart`, `*.gen.dart`.
- When you've made a major change and completed a task, update the patch version in the relevant `pubspec.yaml` (e.g. `0.0.3` → `0.0.4`) and add a note to the corresponding `CHANGELOG.md`.

## Before Writing Code

For trivial fixes (typos, one-line changes, simple renames), skip discussion and just do it.

For anything non-trivial, do NOT start implementation until all open questions are resolved. First:

1. **Challenge the approach** — point out flaws, missed edge cases, and risks. Be direct.
2. **Ask about unknowns** — if anything is ambiguous, ask. Do not guess or assume.
3. **Propose alternatives** — if there is a simpler or more robust way, say so and explain why.
4. **List edge cases** — enumerate what can break.
5. **Wait for confirmation** — do not write code until the user explicitly approves the plan.

Do only what was asked. Do not refactor surrounding code, add comments to code you did not change, or introduce abstractions for hypothetical future needs.

## After Writing Code

Do not consider a task done until verified:

- `make format` — no formatting issues
- `make analyze` — no analyzer warnings
- `make test-unit` — all tests pass

If tests or analysis fail, fix the issue before reporting completion.

