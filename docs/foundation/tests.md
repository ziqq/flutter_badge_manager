# Foundation Tests

## Dart tests

The package has normal Flutter-side tests for:

- Dart API forwarding
- registration
- Pigeon transport behavior on the Dart side

Command:

```sh
cd flutter_badge_manager_foundation && make test-unit
```

## Native Darwin tests

The published Swift package follows the official Flutter plugin layout and
depends on the `FlutterFramework` package that Flutter generates at build time.
It has no standalone SwiftPM test target.

Host-side behavior is validated through the Dart tests above and the example
app, per the Flutter Swift Package Manager guide for plugin authors.
