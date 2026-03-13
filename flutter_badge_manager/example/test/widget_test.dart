import 'package:flutter/services.dart';
import 'package:flutter_badge_manager_example/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const badgeChannel = MethodChannel('github.com/ziqq/flutter_badge_manager');
  const permissionChannel = MethodChannel(
    'flutter.baseflow.com/permissions/methods',
  );
  const localNotificationsChannel = MethodChannel(
    'dexterous.com/flutter/local_notifications',
  );

  final badgeCalls = <MethodCall>[];
  final permissionCalls = <MethodCall>[];
  final notificationCalls = <MethodCall>[];

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    AndroidFlutterLocalNotificationsPlugin.registerWith();

    badgeCalls.clear();
    permissionCalls.clear();
    notificationCalls.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (call) async {
          permissionCalls.add(call);
          switch (call.method) {
            case 'checkPermissionStatus':
              return 1;
            case 'requestPermissions':
              return <int, int>{17: 1};
            default:
              return null;
          }
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(localNotificationsChannel, (call) async {
          notificationCalls.add(call);
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

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(badgeChannel, (call) async {
          badgeCalls.add(call);
          switch (call.method) {
            case 'isSupported':
              return true;
            case 'update':
            case 'remove':
              return null;
            default:
              throw PlatformException(code: 'unimplemented');
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(localNotificationsChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(badgeChannel, null);
  });

  group('Widget_tests -', () {
    testWidgets(
      'shows supported state after startup',
      (tester) async {
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Badge supported: Supported'),
          findsOneWidget,
        );
        expect(
          permissionCalls.map((call) => call.method),
          contains('checkPermissionStatus'),
        );
        expect(badgeCalls.single.method, 'isSupported');
      },
      variant: const TargetPlatformVariant(<TargetPlatform>{
        TargetPlatform.android,
      }),
    );

    testWidgets(
      'shows not supported state when platform returns false',
      (tester) async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(badgeChannel, (call) async {
              badgeCalls.add(call);
              if (call.method == 'isSupported') return false;
              return null;
            });

        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Badge supported: Not supported'),
          findsOneWidget,
        );
      },
      variant: const TargetPlatformVariant(<TargetPlatform>{
        TargetPlatform.android,
      }),
    );

    testWidgets(
      'shows failure state on PlatformException',
      (tester) async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(badgeChannel, (call) async {
              badgeCalls.add(call);
              throw PlatformException(code: 'boom');
            });

        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Badge supported: Failed to get badge support.'),
          findsOneWidget,
        );
      },
      variant: const TargetPlatformVariant(<TargetPlatform>{
        TargetPlatform.android,
      }),
    );

    testWidgets(
      'add and remove buttons update badge and snackbar',
      (tester) async {
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Add badge'));
        await tester.pump();

        expect(
          badgeCalls.where((call) => call.method == 'update').single.arguments,
          {'count': 1},
        );
        expect(notificationCalls.any((call) => call.method == 'show'), isTrue);
        expect(find.text('Badge count updated: 1'), findsOneWidget);

        await tester.tap(find.text('Remove badge'));
        await tester.pump();

        expect(badgeCalls.last.method, 'remove');
        expect(find.text('Badge count updated: 0'), findsOneWidget);
      },
      variant: const TargetPlatformVariant(<TargetPlatform>{
        TargetPlatform.android,
      }),
    );
  });
}
