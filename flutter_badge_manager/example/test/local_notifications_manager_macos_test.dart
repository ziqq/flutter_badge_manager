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
    MacOSFlutterLocalNotificationsPlugin.registerWith();
    calls.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(localNotificationsChannel, (call) async {
          calls.add(call);
          switch (call.method) {
            case 'initialize':
              return true;
            case 'createNotificationChannel':
            case 'requestPermissions':
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
    'darwin singleton requests darwin permissions and disposes stream',
    (tester) async {
      final manager = LocalNotificationsManager.instance;

      await tester.pump();
      await tester.pump();

      expect(identical(LocalNotificationsManager(), manager), isTrue);
      expect(manager.notifications.isBroadcast, isTrue);

      await manager.showNotification(title: 'title');

      expect(calls.map((call) => call.method), contains('initialize'));
      expect(calls.map((call) => call.method), contains('requestPermissions'));
      expect(
        calls.map((call) => call.method),
        isNot(contains('requestNotificationsPermission')),
      );
      expect(calls.map((call) => call.method), contains('show'));

      final done = Completer<void>();
      manager.notifications.listen((_) {}, onDone: done.complete);
      manager.dispose();

      await done.future;
    },
    variant: const TargetPlatformVariant(<TargetPlatform>{
      TargetPlatform.macOS,
    }),
  );
}
