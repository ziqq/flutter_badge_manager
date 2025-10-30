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

      test('isSupported returns bool true', () async {
        final supported = await manager.isSupported();
        expect(supported, isTrue);
        expect(calls.single.method, 'isSupported');
      });

      test('update sends count argument', () async {
        await manager.update(42);
        expect(calls.single.method, 'update');
        expect((calls.single.arguments as Map)['count'], 42);
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
    });
