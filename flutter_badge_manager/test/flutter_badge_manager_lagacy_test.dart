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

  @override
  Future<bool> isSupported() async => supported;

  @override
  Future<void> update(int count) async {
    lastUpdated = count;
  }

  @override
  Future<void> remove() async {
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
        manager =
            FlutterBadgeManager.custom(FlutterBadgeManagerPlatform.instance);
      });

      test('custom instance uses injected platform', () async {
        expect(await manager.isSupported(), isTrue);
        platform.supported = false;
        expect(await manager.isSupported(), isFalse);
      });

      group('isSupported -', () {
        test('forwards result', () async {
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

        test('negative throws and does not call platform', () async {
          expect(
            () => manager.update(-1),
            throwsA(isA<ArgumentError>()),
          );
          expect(platform.lastUpdated, isNull);
        });
      });

      group('update -', () {
        test('delegates to platform', () async {
          expect(platform.removeCalled, isFalse);
          await manager.remove();
          expect(platform.removeCalled, isTrue);
        });
      });
    });
