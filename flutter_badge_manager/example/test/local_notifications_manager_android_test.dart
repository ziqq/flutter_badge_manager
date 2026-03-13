import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_badge_manager_example/local_notifications_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const localNotificationsChannel = MethodChannel(
    'dexterous.com/flutter/local_notifications',
  );
  final calls = <MethodCall>[];

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    calls.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(localNotificationsChannel, (call) async {
          calls.add(call);
          switch (call.method) {
            case 'initialize':
              return true;
            case 'createNotificationChannel':
            case 'requestNotificationsPermission':
            case 'show':
              return null;
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(localNotificationsChannel, null);
  });

  testWidgets(
    'android singleton initializes, shows notifications and disposes stream',
    (tester) async {
      final manager = LocalNotificationsManager.instance;

      await tester.pump();
      await tester.pump();

      expect(identical(LocalNotificationsManager(), manager), isTrue);
      expect(manager.notifications.isBroadcast, isTrue);

      await manager.showNotification(
        id: 7,
        title: 'title',
        body: 'body',
        payload: 'payload',
      );

      expect(
        calls.map((call) => call.method),
        containsAll(<String>[
          'initialize',
          'createNotificationChannel',
          'requestNotificationsPermission',
          'show',
        ]),
      );

      final done = Completer<void>();
      manager.notifications.listen((_) {}, onDone: done.complete);
      manager.dispose();

      await done.future;
    },
    variant: const TargetPlatformVariant(<TargetPlatform>{
      TargetPlatform.android,
    }),
  );
}
