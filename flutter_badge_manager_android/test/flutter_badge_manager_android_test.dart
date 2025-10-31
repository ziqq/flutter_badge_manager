/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 31 October 2025
 */

import 'package:flutter/services.dart';
import 'package:flutter_badge_manager_android/flutter_badge_manager_android.dart';
import 'package:flutter_badge_manager_platform_interface/flutter_badge_manager_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() => group('FlutterBadgeManagerAndroid', () {
      const channel = MethodChannel('github.com/ziqq/flutter_badge_manager');
      final recordedCalls = <MethodCall>[];

      setUp(() {
        TestWidgetsFlutterBinding.ensureInitialized();
        recordedCalls.clear();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
          recordedCalls.add(call);
          switch (call.method) {
            case 'isSupported':
              return true;
            case 'update':
              final count = (call.arguments as Map)['count'] as int;
              if (count < 0) {
                throw PlatformException(code: 'invalid_args', message: 'count');
              }
              return null;
            case 'remove':
              return null;
          }
          throw PlatformException(code: 'unimplemented');
        });
      });

      tearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });

      test('singleton instance stable', () {
        final a = FlutterBadgeManagerAndroid.instance;
        final b = FlutterBadgeManagerAndroid.instance;
        expect(identical(a, b), isTrue);
      });

      test('registerWith sets platform instance', () {
        FlutterBadgeManagerAndroid.registerWith();
        expect(FlutterBadgeManagerPlatform.instance,
            same(FlutterBadgeManagerAndroid.instance));
      });

      test('isSupported delegates', () async {
        final value = await FlutterBadgeManagerAndroid.instance.isSupported();
        expect(value, isTrue);
        expect(recordedCalls.single.method, 'isSupported');
      });

      test('update delegates with count', () async {
        await FlutterBadgeManagerAndroid.instance.update(5);
        expect(recordedCalls.length, 1);
        expect(recordedCalls.first.method, 'update');
        expect((recordedCalls.first.arguments as Map)['count'], 5);
      });

      test('remove delegates', () async {
        await FlutterBadgeManagerAndroid.instance.remove();
        expect(recordedCalls.length, 1);
        expect(recordedCalls.first.method, 'remove');
      });

      test('negative update surfaces PlatformException', () async {
        expect(
          () => FlutterBadgeManagerAndroid.instance.update(-1),
          throwsA(isA<PlatformException>()
              .having((e) => e.code, 'code', equals('invalid_args'))),
        );
        expect(recordedCalls.length, 1);
        expect(recordedCalls.first.method, 'update');
      });
    });
