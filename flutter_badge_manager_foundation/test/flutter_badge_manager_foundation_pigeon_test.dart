import 'package:flutter/services.dart';
import 'package:flutter_badge_manager_foundation/src/flutter_badge_manager_foundation.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const suffix = 'test';
  const channelPrefix =
      // ignore: lines_longer_than_80_chars
      'dev.flutter.pigeon.flutter_badge_manager_foundation.FlutterBadgeManagerApi';

  BasicMessageChannel<Object?> channel(
    String method,
    TestDefaultBinaryMessenger messenger,
  ) =>
      BasicMessageChannel<Object?>(
        '$channelPrefix.$method.$suffix',
        FlutterBadgeManagerApi.pigeonChannelCodec,
        binaryMessenger: messenger,
      );

  late TestDefaultBinaryMessenger messenger;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  });

  tearDown(() {
    for (final method in ['isSupported', 'update', 'remove']) {
      messenger.setMockDecodedMessageHandler<Object?>(
        channel(method, messenger),
        null,
      );
    }
  });

  group('FlutterBadgeManagerFoundationApi generated wrapper', () {
    test('wrapResponse encodes success, error and empty replies', () {
      expect(wrapResponse(result: false), [false]);
      expect(wrapResponse(empty: true), isEmpty);
      expect(
        wrapResponse(
          error: PlatformException(
            code: 'support_failed',
            message: 'boom',
            details: 'details',
          ),
        ),
        ['support_failed', 'boom', 'details'],
      );
    });

    test('isSupported throws channel-error when host is disconnected',
        () async {
      final api = FlutterBadgeManagerApi(
        binaryMessenger: messenger,
        messageChannelSuffix: suffix,
      );

      await expectLater(
        api.isSupported(),
        throwsA(
          isA<PlatformException>()
              .having((e) => e.code, 'code', 'channel-error')
              .having(
                (e) => e.message,
                'message',
                contains('$channelPrefix.isSupported.$suffix'),
              ),
        ),
      );
    });

    test('update sends count over the suffixed channel', () async {
      Object? capturedMessage;
      messenger.setMockDecodedMessageHandler<Object?>(
        channel('update', messenger),
        (message) async {
          capturedMessage = message;
          return wrapResponse(empty: true);
        },
      );

      final api = FlutterBadgeManagerApi(
        binaryMessenger: messenger,
        messageChannelSuffix: suffix,
      );

      await api.update(24);

      expect(capturedMessage, [24]);
    });

    test('update throws channel-error when host is disconnected', () async {
      final api = FlutterBadgeManagerApi(
        binaryMessenger: messenger,
        messageChannelSuffix: suffix,
      );

      await expectLater(
        api.update(24),
        throwsA(
          isA<PlatformException>()
              .having((e) => e.code, 'code', 'channel-error')
              .having(
                (e) => e.message,
                'message',
                contains('$channelPrefix.update.$suffix'),
              ),
        ),
      );
    });

    test('remove surfaces encoded host errors', () async {
      messenger.setMockDecodedMessageHandler<Object?>(
        channel('remove', messenger),
        (_) async => wrapResponse(
          error: PlatformException(
            code: 'remove_failed',
            message: 'not now',
            details: {'retryable': false},
          ),
        ),
      );

      final api = FlutterBadgeManagerApi(
        binaryMessenger: messenger,
        messageChannelSuffix: suffix,
      );

      await expectLater(
        api.remove(),
        throwsA(
          isA<PlatformException>()
              .having((e) => e.code, 'code', 'remove_failed')
              .having(
            (e) => e.details,
            'details',
            {'retryable': false},
          ),
        ),
      );
    });

    test('remove throws channel-error when host is disconnected', () async {
      final api = FlutterBadgeManagerApi(
        binaryMessenger: messenger,
        messageChannelSuffix: suffix,
      );

      await expectLater(
        api.remove(),
        throwsA(
          isA<PlatformException>()
              .having((e) => e.code, 'code', 'channel-error')
              .having(
                (e) => e.message,
                'message',
                contains('$channelPrefix.remove.$suffix'),
              ),
        ),
      );
    });
  });
}
