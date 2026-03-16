/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 04 November 2025
 */

import 'package:flutter_badge_manager/src/flutter_badge_manager.dart'
    show FlutterBadgeManager;
import 'package:flutter_badge_manager_platform_interface/flutter_badge_manager_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestPlatform extends FlutterBadgeManagerPlatform {
  _TestPlatform({this.supported = true});

  bool supported;
  int? lastUpdated;
  bool removeCalled = false;
  StateError? isSupportedError;
  StateError? updateError;
  StateError? removeError;

  @override
  Future<bool> isSupported() async {
    if (isSupportedError case final StateError error) {
      throw error;
    }
    return supported;
  }

  @override
  Future<void> update(int count) async {
    if (updateError case final StateError error) {
      throw error;
    }
    lastUpdated = count;
  }

  @override
  Future<void> remove() async {
    if (removeError case final StateError error) {
      throw error;
    }
    removeCalled = true;
  }
}

void main() => group('FlutterBadgeManager -', () {
  late FlutterBadgeManager manager;
  late _TestPlatform platform;

  setUp(() {
    platform = _TestPlatform(supported: true);
    // Inject our fake platform implementation.
    FlutterBadgeManagerPlatform.instance = platform;
    // Use custom to bind this platform
    // (DO NOT use singleton which may have cached old stub).
    manager = FlutterBadgeManager.instanceFor(
      FlutterBadgeManagerPlatform.instance,
    );
  });

  test('custom instance uses injected platform', () async {
    expect(await manager.isSupported(), isTrue);
    platform.supported = false;
    expect(await manager.isSupported(), isFalse);
  });

  test('custom instance stays bound to injected platform', () async {
    final firstPlatform = _TestPlatform(supported: true);
    final secondPlatform = _TestPlatform(supported: false);
    final customManager = FlutterBadgeManager.instanceFor(firstPlatform);

    FlutterBadgeManagerPlatform.instance = secondPlatform;

    expect(await customManager.isSupported(), isTrue);
  });

  test('instance singleton is non-null', () {
    final instance = FlutterBadgeManager.instance;
    expect(instance, isNotNull);
    expect(instance, isA<FlutterBadgeManager>());
  });

  group('isSupported -', () {
    test('forwards true', () async {
      platform.supported = true;
      expect(await manager.isSupported(), isTrue);
    });

    test('forwards false', () async {
      platform.supported = false;
      expect(await manager.isSupported(), isFalse);
    });

    test('reflects runtime changes', () async {
      platform.supported = true;
      expect(await manager.isSupported(), isTrue);
      platform.supported = false;
      expect(await manager.isSupported(), isFalse);
    });
  });

  group('update -', () {
    test('delegates to platform', () async {
      await manager.update(42);
      expect(platform.lastUpdated, 42);
    });

    test('zero count is valid boundary', () async {
      await manager.update(0);
      expect(platform.lastUpdated, 0);
    });

    test('large count is accepted', () async {
      await manager.update(999999);
      expect(platform.lastUpdated, 999999);
    });

    test('negative throws ArgumentError with message', () async {
      expect(
        () => manager.update(-1),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.toString(),
            'message',
            contains('count must be non-negative'),
          ),
        ),
      );
      expect(platform.lastUpdated, isNull);
    });

    test('negative does not call platform', () async {
      try {
        await manager.update(-100);
      } on Object catch (_) {}
      expect(platform.lastUpdated, isNull);
    });
  });

  group('remove -', () {
    test('delegates to platform', () async {
      expect(platform.removeCalled, isFalse);
      await manager.remove();
      expect(platform.removeCalled, isTrue);
    });

    test('can be called multiple times', () async {
      await manager.remove();
      await manager.remove();
      expect(platform.removeCalled, isTrue);
    });
  });

  group('error propagation -', () {
    test('isSupported surfaces platform errors', () async {
      platform.isSupportedError = StateError('support check failed');

      await expectLater(manager.isSupported(), throwsA(isA<StateError>()));
    });

    test('update surfaces platform errors for valid count', () async {
      platform.updateError = StateError('update failed');

      await expectLater(manager.update(7), throwsA(isA<StateError>()));
      expect(platform.lastUpdated, isNull);
    });

    test('remove surfaces platform errors', () async {
      platform.removeError = StateError('remove failed');

      await expectLater(manager.remove(), throwsA(isA<StateError>()));
      expect(platform.removeCalled, isFalse);
    });
  });

  group('sequential operations -', () {
    test('update then remove', () async {
      await manager.update(5);
      expect(platform.lastUpdated, 5);
      await manager.remove();
      expect(platform.removeCalled, isTrue);
    });

    test('multiple updates track last value', () async {
      await manager.update(1);
      await manager.update(2);
      await manager.update(3);
      expect(platform.lastUpdated, 3);
    });

    test('update after remove works', () async {
      await manager.remove();
      await manager.update(10);
      expect(platform.lastUpdated, 10);
      expect(platform.removeCalled, isTrue);
    });
  });
});
