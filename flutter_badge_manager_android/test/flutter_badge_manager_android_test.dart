/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 31 October 2025
 */

import 'package:flutter/services.dart';
import 'package:flutter_badge_manager_android/flutter_badge_manager_android.dart';
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
      throw PlatformException(code: 'invalid_args', message: 'count');
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

void main() => group('FlutterBadgeManagerAndroid', () {
      late _TestApi api;

      setUp(() {
        TestWidgetsFlutterBinding.ensureInitialized();
        api = _TestApi();
        TestFlutterBadgeManagerApi.setUp(api);
      });

      tearDown(() {
        TestFlutterBadgeManagerApi.setUp(null);
      });

      test('singleton instance stable', () {
        final a = FlutterBadgeManagerAndroid.instance;
        final b = FlutterBadgeManagerAndroid.instance;
        expect(identical(a, b), isTrue);
      });

      test('registerWith sets platform instance', () {
        FlutterBadgeManagerAndroid.registerWith();
        expect(
          FlutterBadgeManagerPlatform.instance,
          same(FlutterBadgeManagerAndroid.instance),
        );
      });

      test('isSupported delegates', () async {
        final value = await FlutterBadgeManagerAndroid.instance.isSupported();
        expect(value, isTrue);
        expect(api.calls.single, 'isSupported');
      });

      test('update delegates with count', () async {
        await FlutterBadgeManagerAndroid.instance.update(5);
        expect(api.calls, ['update']);
        expect(api.lastUpdated, 5);
      });

      test('remove delegates', () async {
        await FlutterBadgeManagerAndroid.instance.remove();
        expect(api.calls, ['remove']);
        expect(api.removeCalled, isTrue);
      });

      test('negative update surfaces PlatformException', () async {
        expect(
          () => FlutterBadgeManagerAndroid.instance.update(-1),
          throwsA(
            isA<PlatformException>().having(
              (e) => e.code,
              'code',
              equals('invalid_args'),
            ),
          ),
        );
        expect(api.calls, ['update']);
        expect(api.lastUpdated, -1);
      });

      test('update with zero count is valid', () async {
        await FlutterBadgeManagerAndroid.instance.update(0);
        expect(api.calls, ['update']);
        expect(api.lastUpdated, 0);
      });

      test('update with large count is accepted', () async {
        await FlutterBadgeManagerAndroid.instance.update(999999);
        expect(api.calls, ['update']);
        expect(api.lastUpdated, 999999);
      });

      test('instance is FlutterBadgeManagerPlatform', () {
        expect(
          FlutterBadgeManagerAndroid.instance,
          isA<FlutterBadgeManagerPlatform>(),
        );
      });

      test('multiple sequential calls order', () async {
        await FlutterBadgeManagerAndroid.instance.update(1);
        await FlutterBadgeManagerAndroid.instance.update(2);
        await FlutterBadgeManagerAndroid.instance.remove();
        expect(api.calls, ['update', 'update', 'remove']);
      });

      test('isSupported returns false when host returns false', () async {
        api.supported = false;
        final value = await FlutterBadgeManagerAndroid.instance.isSupported();
        expect(value, isFalse);
      });

      test('isSupported returns false when host returns null', () async {
        api.supported = null;

        final value = await FlutterBadgeManagerAndroid.instance.isSupported();

        expect(value, isFalse);
      });

      test('isSupported surfaces PlatformException from host', () async {
        api.isSupportedError = PlatformException(code: 'support_failed');

        await expectLater(
          FlutterBadgeManagerAndroid.instance.isSupported(),
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
          FlutterBadgeManagerAndroid.instance.remove(),
          throwsA(
            isA<PlatformException>().having(
              (e) => e.code,
              'code',
              'remove_failed',
            ),
          ),
        );
      });

      test('update surfaces PlatformException from host', () async {
        api.updateError = PlatformException(code: 'write_failed');

        await expectLater(
          FlutterBadgeManagerAndroid.instance.update(8),
          throwsA(
            isA<PlatformException>().having(
              (e) => e.code,
              'code',
              'write_failed',
            ),
          ),
        );
      });
    });
