import 'package:flutter/services.dart';
import 'package:flutter_badge_manager_foundation/src/flutter_badge_manager_foundation.g.dart';
import 'package:flutter_test/flutter_test.dart';

const MethodChannel _localNotificationsChannel = MethodChannel(
  'dexterous.com/flutter/local_notifications',
);

const _prefix =
    // ignore: lines_longer_than_80_chars
    'dev.flutter.pigeon.flutter_badge_manager_foundation.FlutterBadgeManagerApi';

const BasicMessageChannel<Object?> _isSupportedChannel =
    BasicMessageChannel<Object?>(
      '$_prefix.isSupported',
      FlutterBadgeManagerApi.pigeonChannelCodec,
    );

const BasicMessageChannel<Object?> _updateChannel =
    BasicMessageChannel<Object?>(
      '$_prefix.update',
      FlutterBadgeManagerApi.pigeonChannelCodec,
    );

const BasicMessageChannel<Object?> _removeChannel =
    BasicMessageChannel<Object?>(
      '$_prefix.remove',
      FlutterBadgeManagerApi.pigeonChannelCodec,
    );

void setUpBadgeApiMock({
  required List<MethodCall> badgeCalls,
  List<MethodCall>? localNotificationCalls,
  bool? supported = true,
  bool permissionGranted = true,
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

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_localNotificationsChannel, (call) async {
        localNotificationCalls?.add(call);
        if (call.method == 'requestPermissions') {
          return permissionGranted;
        }
        return null;
      });
}

void tearDownBadgeApiMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
    ..setMockDecodedMessageHandler<Object?>(_isSupportedChannel, null)
    ..setMockDecodedMessageHandler<Object?>(_updateChannel, null)
    ..setMockDecodedMessageHandler<Object?>(_removeChannel, null)
    ..setMockMethodCallHandler(_localNotificationsChannel, null);
}
