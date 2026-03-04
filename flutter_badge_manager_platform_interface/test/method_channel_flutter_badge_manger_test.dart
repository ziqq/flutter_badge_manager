import 'package:flutter/services.dart';
import 'package:flutter_badge_manager_platform_interface/method_channel_flutter_badge_manger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() => group('MethodChannelFlutterBadgeManager', () {
      const channelName = 'github.com/ziqq/flutter_badge_manager';
      const testChannel = MethodChannel(channelName);

      TestWidgetsFlutterBinding.ensureInitialized();

      final manager = MethodChannelFlutterBadgeManager.instance;
      final calls = <MethodCall>[];

      setUp(() {
        calls.clear();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(testChannel, (call) async {
          calls.add(call);
          switch (call.method) {
            case 'isSupported':
              return true;
            case 'update':
              final count = (call.arguments as Map)['count'] as int?;
              if (count == null) throw PlatformException(code: 'invalid_args');
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
            .setMockMethodCallHandler(testChannel, null);
      });

      test('singleton instance is stable', () {
        final a = MethodChannelFlutterBadgeManager.instance;
        final b = MethodChannelFlutterBadgeManager.instance;
        expect(identical(a, b), isTrue);
      });

      test('isSupported returns bool true', () async {
        final supported = await manager.isSupported();
        expect(supported, isTrue);
        expect(calls.single.method, 'isSupported');
      });

      test('isSupported returns false when channel returns false', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(testChannel, (call) async {
          calls.add(call);
          return false;
        });
        final supported = await manager.isSupported();
        expect(supported, isFalse);
      });

      test('isSupported returns false when channel returns null', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(testChannel, (call) async {
          calls.add(call);
          return null;
        });
        final supported = await manager.isSupported();
        expect(supported, isFalse);
      });

      test('update sends count argument', () async {
        await manager.update(42);
        expect(calls.single.method, 'update');
        expect((calls.single.arguments as Map)['count'], 42);
      });

      test('update with zero count', () async {
        await manager.update(0);
        expect(calls.single.method, 'update');
        expect((calls.single.arguments as Map)['count'], 0);
      });

      test('update with large count', () async {
        await manager.update(1000000);
        expect(calls.single.method, 'update');
        expect((calls.single.arguments as Map)['count'], 1000000);
      });

      test('remove invokes remove', () async {
        await manager.remove();
        expect(calls.single.method, 'remove');
      });

      test('multiple sequential calls order', () async {
        await manager.update(1);
        await manager.update(2);
        await manager.remove();
        expect(calls.map((c) => c.method).toList(growable: false),
            ['update', 'update', 'remove']);
      });

      test('remove then update sequence', () async {
        await manager.remove();
        await manager.update(10);
        expect(
          calls.map((c) => c.method).toList(),
          ['remove', 'update'],
        );
      });
    });
