/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 30 October 2025
 */

import 'package:flutter/services.dart';
import 'package:flutter_badge_manager_foundation/flutter_badge_manager_foundation.dart';
import 'package:flutter_badge_manager_platform_interface/flutter_badge_manager_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() => group('FlutterBadgeManagerFoundation', () {
      const testChannel =
          MethodChannel('github.com/ziqq/flutter_badge_manager');

      final log = <MethodCall>[];

      setUp(() {
        TestWidgetsFlutterBinding.ensureInitialized();
        log.clear();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(testChannel, (methodCall) async {
          log.add(methodCall);
          switch (methodCall.method) {
            case 'isSupported':
              return true;
            case 'update':
              final count = (methodCall.arguments as Map)['count'] as int?;
              if (count == null || count < 0) {
                throw PlatformException(code: 'invalid_args');
              }
              return null;
            case 'remove':
              return null;
            default:
              throw PlatformException(code: 'unimplemented');
          }
        });
        // Register dart side implementation explicitly if not already.
        FlutterBadgeManagerFoundation.registerWith();
      });

      test('isSupported returns true', () async {
        final result =
            await FlutterBadgeManagerFoundation.instance.isSupported();
        expect(result, isTrue);
        expect(log.single.method, 'isSupported');
      });

      test('update sends count', () async {
        await FlutterBadgeManagerFoundation.instance.update(5);
        expect(log.single.method, 'update');
        expect((log.single.arguments as Map)['count'], 5);
      });

      test('remove clears badge', () async {
        await FlutterBadgeManagerFoundation.instance.remove();
        expect(log.single.method, 'remove');
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
        expect(log.map((e) => e.method).toList(), ['update', 'remove']);
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
        expect(log.single.method, 'update');
        expect((log.single.arguments as Map)['count'], 0);
      });

      test('update with large count', () async {
        await FlutterBadgeManagerFoundation.instance.update(999999);
        expect(log.single.method, 'update');
        expect((log.single.arguments as Map)['count'], 999999);
      });

      test('isSupported returns false when channel returns false', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(testChannel, (methodCall) async {
          log.add(methodCall);
          return false;
        });
        final result =
            await FlutterBadgeManagerFoundation.instance.isSupported();
        expect(result, isFalse);
      });

      test('sequential update remove update', () async {
        await FlutterBadgeManagerFoundation.instance.update(1);
        await FlutterBadgeManagerFoundation.instance.remove();
        await FlutterBadgeManagerFoundation.instance.update(3);
        expect(
          log.map((e) => e.method).toList(),
          ['update', 'remove', 'update'],
        );
      });
    });
