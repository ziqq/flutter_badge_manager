import 'package:flutter/services.dart';
import 'package:flutter_badge_manager_android/src/flutter_badge_manager_android.g.dart';
import 'package:flutter_test/flutter_test.dart';

const _channelPrefix =
    'dev.flutter.pigeon.flutter_badge_manager_android.FlutterBadgeManagerApi';

const BasicMessageChannel<Object?> _isSupportedChannel =
    BasicMessageChannel<Object?>(
      '$_channelPrefix.isSupported',
      FlutterBadgeManagerApi.pigeonChannelCodec,
    );

const BasicMessageChannel<Object?> _updateChannel =
    BasicMessageChannel<Object?>(
      '$_channelPrefix.update',
      FlutterBadgeManagerApi.pigeonChannelCodec,
    );

const BasicMessageChannel<Object?> _removeChannel =
    BasicMessageChannel<Object?>(
      '$_channelPrefix.remove',
      FlutterBadgeManagerApi.pigeonChannelCodec,
    );

void setUpBadgeApiMock({
  required List<MethodCall> badgeCalls,
  bool? supported = true,
  PlatformException? isSupportedError,
  PlatformException? updateError,
  PlatformException? removeError,
}) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
    ..setMockDecodedMessageHandler<Object?>(_isSupportedChannel, (
      message,
    ) async {
      badgeCalls.add(const MethodCall('isSupported'));
      if (isSupportedError case final PlatformException error) {
        return wrapResponse(error: error);
      }
      return <Object?>[supported];
    })
    ..setMockDecodedMessageHandler<Object?>(_updateChannel, (message) async {
      final arguments = (message as List<Object?>?)!;
      final count = arguments.single! as int;
      badgeCalls.add(MethodCall('update', <String, Object?>{'count': count}));
      if (updateError case final PlatformException error) {
        return wrapResponse(error: error);
      }
      return wrapResponse(empty: true);
    })
    ..setMockDecodedMessageHandler<Object?>(_removeChannel, (message) async {
      badgeCalls.add(const MethodCall('remove'));
      if (removeError case final PlatformException error) {
        return wrapResponse(error: error);
      }
      return wrapResponse(empty: true);
    });
}

void tearDownBadgeApiMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
    ..setMockDecodedMessageHandler<Object?>(_isSupportedChannel, null)
    ..setMockDecodedMessageHandler<Object?>(_updateChannel, null)
    ..setMockDecodedMessageHandler<Object?>(_removeChannel, null);
}
