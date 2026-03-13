// ignore_for_file: deprecated_member_use_from_same_package

/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 04 November 2025
 * Tests legacy static API wrapper (deprecated) that uses direct MethodChannel.
 */

import 'package:flutter/services.dart';
import 'package:flutter_badge_manager/flutter_badge_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() => group('FlutterBadgeManager -', () {
      const channelName = 'github.com/ziqq/flutter_badge_manager';
      const methodChannel = MethodChannel(channelName);
      final calls = <MethodCall>[];

      setUp(() {
        TestWidgetsFlutterBinding.ensureInitialized();
        calls.clear();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (call) async {
          calls.add(call);
          switch (call.method) {
            case 'isSupported':
              return true;
            case 'update':
              final count = (call.arguments as Map)['count'] as int;
              if (count < 0) {
                throw PlatformException(code: 'invalid_args');
              }
              return null;
            case 'remove':
              return null;
            default:
              throw PlatformException(code: 'unimplemented');
          }
        });
      });

      tearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, null);
      });

      test('isSupported returns channel value', () async {
        final ok = await FlutterBadgeManager.isSupported();
        expect(ok, isTrue);
        expect(calls.single.method, 'isSupported');
      });

      test('isSupported returns false when channel returns false', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (call) async {
          calls.add(call);
          return false;
        });
        final ok = await FlutterBadgeManager.isSupported();
        expect(ok, isFalse);
      });

      test('isSupported returns false when channel returns null', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (call) async {
          calls.add(call);
          return null;
        });
        final ok = await FlutterBadgeManager.isSupported();
        expect(ok, isFalse);
      });

      test('update sends count', () async {
        await FlutterBadgeManager.update(5);
        expect(calls.length, 1);
        expect(calls.first.method, 'update');
        expect((calls.first.arguments as Map)['count'], 5);
      });

      test('update sends zero count', () async {
        await FlutterBadgeManager.update(0);
        expect(calls.length, 1);
        expect(calls.first.method, 'update');
        expect((calls.first.arguments as Map)['count'], 0);
      });

      test('negative update throws PlatformException', () async {
        expect(
          () => FlutterBadgeManager.update(-1),
          throwsA(isA<PlatformException>()),
        );
      });

      test('isSupported surfaces PlatformException', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (call) async {
          calls.add(call);
          throw PlatformException(code: 'support_failed');
        });

        expect(
          FlutterBadgeManager.isSupported,
          throwsA(
            isA<PlatformException>().having(
              (e) => e.code,
              'code',
              'support_failed',
            ),
          ),
        );
      });

      test('update surfaces PlatformException from channel', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (call) async {
          calls.add(call);
          throw PlatformException(code: 'write_failed');
        });

        expect(
          () => FlutterBadgeManager.update(8),
          throwsA(
            isA<PlatformException>().having(
              (e) => e.code,
              'code',
              'write_failed',
            ),
          ),
        );
      });

      test('remove calls channel', () async {
        await FlutterBadgeManager.remove();
        expect(calls.length, 1);
        expect(calls.first.method, 'remove');
      });

      test('remove surfaces PlatformException from channel', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (call) async {
          calls.add(call);
          throw PlatformException(code: 'remove_failed');
        });

        expect(
          FlutterBadgeManager.remove,
          throwsA(
            isA<PlatformException>().having(
              (e) => e.code,
              'code',
              'remove_failed',
            ),
          ),
        );
      });

      test('instance getter returns new API FlutterBadgeManager', () {
        final instance = FlutterBadgeManager.instance;
        expect(instance, isNotNull);
      });

      test('instance delegate forwards calls through public package API',
          () async {
        final dynamic instance = FlutterBadgeManager.instance;

        expect(await instance.isSupported(), isTrue);
        await instance.update(3);
        await instance.remove();

        expect(
          calls.map((call) => call.method).toList(growable: false),
          ['isSupported', 'update', 'remove'],
        );
      });

      test('instance delegate rejects negative count before channel call',
          () async {
        final dynamic instance = FlutterBadgeManager.instance;

        expect(() => instance.update(-1), throwsA(isA<ArgumentError>()));
        expect(calls, isEmpty);
      });

      test('package exports FlutterBadgeManagerPlatform symbol', () {
        expect(FlutterBadgeManagerPlatform.instance, isNotNull);
      });

      test('multiple sequential calls', () async {
        await FlutterBadgeManager.update(1);
        await FlutterBadgeManager.update(2);
        await FlutterBadgeManager.remove();
        expect(
          calls.map((c) => c.method).toList(),
          ['update', 'update', 'remove'],
        );
      });
    });
