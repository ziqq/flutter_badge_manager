/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 30 October 2025
 */

import 'package:flutter/services.dart';
import 'package:flutter_badge_manager_foundation/flutter_badge_manager_foundation.dart';
import 'package:flutter_badge_manager_platform_interface/flutter_badge_manager_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_api.g.dart';

class _TestApi extends TestFlutterBadgeManagerApi {
  bool? supported = true;
  int? lastUpdated;
  bool removeCalled = false;
  final calls = <String>[];
  PlatformException? isSupportedError;
  PlatformException? updateError;
  PlatformException? removeError;

  @override
  bool? isSupported() {
    calls.add('isSupported');
    if (isSupportedError case final PlatformException error) {
      throw error;
    }
    return supported;
  }

  @override
  void update(int count) {
    calls.add('update');
    lastUpdated = count;
    if (count < 0) {
      throw PlatformException(code: 'invalid_args');
    }
    if (updateError case final PlatformException error) {
      throw error;
    }
  }

  @override
  void remove() {
    calls.add('remove');
    if (removeError case final PlatformException error) {
      throw error;
    }
    removeCalled = true;
  }
}

void main() => group('FlutterBadgeManagerFoundation', () {
      late _TestApi api;

      setUp(() {
        TestWidgetsFlutterBinding.ensureInitialized();
        api = _TestApi();
        TestFlutterBadgeManagerApi.setUp(api);
        FlutterBadgeManagerFoundation.registerWith();
      });

      tearDown(() {
        TestFlutterBadgeManagerApi.setUp(null);
      });

      test('isSupported returns true', () async {
        final result =
            await FlutterBadgeManagerFoundation.instance.isSupported();
        expect(result, isTrue);
        expect(api.calls.single, 'isSupported');
      });

      test('update sends count', () async {
        await FlutterBadgeManagerFoundation.instance.update(5);
        expect(api.calls.single, 'update');
        expect(api.lastUpdated, 5);
      });

      test('remove clears badge', () async {
        await FlutterBadgeManagerFoundation.instance.remove();
        expect(api.calls.single, 'remove');
        expect(api.removeCalled, isTrue);
      });

      test('negative badge throws error', () async {
        try {
          await FlutterBadgeManagerFoundation.instance.update(-1);
          fail('Should have thrown');
        } on PlatformException catch (e) {
          expect(e.code, 'invalid_args');
        }
      });

      test('multiple calls order', () async {
        await FlutterBadgeManagerFoundation.instance.update(2);
        await FlutterBadgeManagerFoundation.instance.remove();
        expect(api.calls, ['update', 'remove']);
      });

      test('singleton instance is stable', () {
        final a = FlutterBadgeManagerFoundation.instance;
        final b = FlutterBadgeManagerFoundation.instance;
        expect(identical(a, b), isTrue);
      });

      test('registerWith sets platform instance', () {
        FlutterBadgeManagerFoundation.registerWith();
        expect(
          FlutterBadgeManagerPlatform.instance,
          same(FlutterBadgeManagerFoundation.instance),
        );
      });

      test('instance is FlutterBadgeManagerPlatform', () {
        expect(
          FlutterBadgeManagerFoundation.instance,
          isA<FlutterBadgeManagerPlatform>(),
        );
      });

      test('update with zero count is valid', () async {
        await FlutterBadgeManagerFoundation.instance.update(0);
        expect(api.calls.single, 'update');
        expect(api.lastUpdated, 0);
      });

      test('update with large count', () async {
        await FlutterBadgeManagerFoundation.instance.update(999999);
        expect(api.calls.single, 'update');
        expect(api.lastUpdated, 999999);
      });

      test('isSupported returns false when host returns false', () async {
        api.supported = false;
        final result =
            await FlutterBadgeManagerFoundation.instance.isSupported();
        expect(result, isFalse);
      });

      test('isSupported returns false when host returns null', () async {
        api.supported = null;

        final result =
            await FlutterBadgeManagerFoundation.instance.isSupported();

        expect(result, isFalse);
      });

      test('isSupported surfaces PlatformException from host', () async {
        api.isSupportedError = PlatformException(code: 'support_failed');

        await expectLater(
          FlutterBadgeManagerFoundation.instance.isSupported(),
          throwsA(
            isA<PlatformException>().having(
              (e) => e.code,
              'code',
              'support_failed',
            ),
          ),
        );
      });

      test('remove surfaces PlatformException from host', () async {
        api.removeError = PlatformException(code: 'remove_failed');

        await expectLater(
          FlutterBadgeManagerFoundation.instance.remove(),
          throwsA(
            isA<PlatformException>().having(
              (e) => e.code,
              'code',
              'remove_failed',
            ),
          ),
        );
      });

      test('sequential update remove update', () async {
        await FlutterBadgeManagerFoundation.instance.update(1);
        await FlutterBadgeManagerFoundation.instance.remove();
        await FlutterBadgeManagerFoundation.instance.update(3);
        expect(api.calls, ['update', 'remove', 'update']);
      });
    });
