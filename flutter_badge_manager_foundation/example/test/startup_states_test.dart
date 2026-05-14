import 'package:flutter/services.dart';
import 'package:flutter_badge_manager_example/main.dart' as example_app;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'badge_api_mock.dart';

void main() {
  final badgeCalls = <MethodCall>[];
  final localNotificationCalls = <MethodCall>[];

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    IOSFlutterLocalNotificationsPlugin.registerWith();
    badgeCalls.clear();
    localNotificationCalls.clear();
    setUpBadgeApiMock(
      badgeCalls: badgeCalls,
      localNotificationCalls: localNotificationCalls,
    );
  });

  tearDown(tearDownBadgeApiMock);

  group('App startup -', () {
    testWidgets(
      'guarded main renders the app',
      (tester) async {
        example_app.main();
        await tester.pumpAndSettle();

        expect(find.text('Badge plugin example (foundation)'), findsOneWidget);
        expect(
          find.textContaining('Badge supported: Supported'),
          findsOneWidget,
        );
        expect(localNotificationCalls, hasLength(1));
        expect(localNotificationCalls.single.method, 'requestPermissions');
        expect(badgeCalls.single.method, 'isSupported');
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  });
}
