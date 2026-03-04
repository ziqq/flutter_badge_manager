# flutter_badge_manager

This is a **Flutter plugin** (not an app) to set and clear application badge numbers on Android, iOS and macOS. The codebase follows the [federated plugin architecture](https://flutter.dev/go/federated-plugins) with platform-specific implementations for Android and iOS/macOS, as well as a common Dart platform interface.

**Important**: Before doing anything, always try to clarify everything possible, highlight weak points, corner cases that were not taken into account, and ask a lot of clarifying questions.


## Lint Rules

Include the package in the `analysis_options.yaml` file. Use the following
analysis_options.yaml file as a starting point:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # Add additional lint rules here:
    # avoid_print: false
    # prefer_single_quotes: true
```


## Code Generation

* **Pigeon:** The Android package uses [Pigeon](https://pub.dev/packages/pigeon)
  for type-safe platform channel bindings. Generated files (`*.g.dart`) must
  **not** be edited manually.
* **Running Pigeon:** After modifying pigeon input files, regenerate:
  ```shell
  cd flutter_badge_manager_android
  fvm dart run pigeon --input pigeons/flutter_badge_manager.dart
  ```


## Testing

* **Running Tests:** Use `make test-unit` from any package directory or the
  repo root, otherwise use `fvm flutter test`.
* **Unit Tests:** Use `package:flutter_test` for unit tests.
* **Integration Tests:** Use `package:integration_test` for integration tests.
* **Assertions:** Prefer using `package:checks` for more expressive and readable
  assertions over the default `matchers`.


### Testing Best Practices

* **Convention:** Follow the Arrange-Act-Assert (or Given-When-Then) pattern.
* **Unit Tests:** Write unit tests for platform interface, method channel,
  and each platform implementation.
* **Integration Tests:** For broader validation, use integration tests to verify
  end-to-end badge functionality on a real device.
* **Mocks:** Prefer fakes or stubs over mocks. If mocks are absolutely
  necessary, use `mockito` or `mocktail`. Avoid code generation for mocks.
* **Coverage:** Aim for high test coverage.


## Documentation

* **`dartdoc`:** Write `dartdoc`-style comments for all public APIs.

### Documentation Philosophy

* **Comment wisely:** Use comments to explain _why_ the code is written a
  certain way, not _what_ the code does. The code itself should be
  self-explanatory.
* **Document for the user:** Write documentation with the reader in mind.
* **No useless documentation:** If the documentation only restates the obvious
  from the code's name, it's not helpful. Good documentation provides context
  and explains what isn't immediately apparent.
* **Consistency is key:** Use consistent terminology throughout your
  documentation.

### Commenting Style

* **Use `///` for doc comments:** This allows documentation generation tools to
  pick them up.
* **Start with a single-sentence summary:** The first sentence should be a
  concise, user-centric summary ending with a period.
* **Separate the summary:** Add a blank line after the first sentence to create
  a separate paragraph.
* **Avoid redundancy:** Don't repeat information that's obvious from the code's
  context, like the class name or signature.
* **Important**: Don't delete comments, but feel free to add more if you think
  it would help the reader understand the code better.

### Writing Style

* **Be brief:** Write concisely.
* **Avoid jargon and acronyms:** Don't use abbreviations unless they are widely
  understood.
* **Use Markdown sparingly:** Avoid excessive markdown and never use HTML for
  formatting.
* **Use backticks for code:** Enclose code blocks in backtick fences, and
  specify the language.

### What to Document

* **Public APIs are a priority:** Always document public APIs.
* **Consider private APIs:** It's a good idea to document private APIs as well.
* **Library-level comments are helpful:** Consider adding a doc comment at the
  library level to provide a general overview.
* **Include code samples:** Where appropriate, add code samples to illustrate
  usage.
* **Explain parameters, return values, and exceptions:** Use prose to describe
  what a function expects, what it returns, and what errors it might throw.
* **Place doc comments before annotations:** Documentation should come before
  any metadata annotations.