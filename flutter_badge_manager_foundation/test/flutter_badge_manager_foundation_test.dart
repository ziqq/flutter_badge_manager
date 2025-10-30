/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 30 October 2025
 */

import 'package:flutter/services.dart';
import 'package:flutter_badge_manager_foundation/flutter_badge_manager_foundation.dart';
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
    });
