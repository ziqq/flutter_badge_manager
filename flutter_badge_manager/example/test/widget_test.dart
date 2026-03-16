import 'package:flutter/services.dart';
import 'package:flutter_badge_manager/flutter_badge_manager.dart'
    show FlutterBadgeManagerPlatform;
import 'package:flutter_badge_manager_example/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBadgePlatform extends FlutterBadgeManagerPlatform {
  bool supported = true;
  PlatformException? isSupportedError;
  final calls = <MethodCall>[];

  @override
  bool get isMock => true;

  @override
  Future<bool> isSupported() async {
    calls.add(const MethodCall('isSupported'));
    if (isSupportedError case final PlatformException error) {
      throw error;
    }
    return supported;
  }

  @override
  Future<void> update(int count) async {
    calls.add(MethodCall('update', {'count': count}));
  }

  @override
  Future<void> remove() async {
    calls.add(const MethodCall('remove'));
  }
}

void main() {
  const permissionChannel = MethodChannel(
    'flutter.baseflow.com/permissions/methods',
  );
  const localNotificationsChannel = MethodChannel(
    'dexterous.com/flutter/local_notifications',
  );

  final permissionCalls = <MethodCall>[];
  final notificationCalls = <MethodCall>[];
  late _FakeBadgePlatform badgePlatform;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    AndroidFlutterLocalNotificationsPlugin.registerWith();

    permissionCalls.clear();
    notificationCalls.clear();
    badgePlatform = _FakeBadgePlatform();
    FlutterBadgeManagerPlatform.instance = badgePlatform;

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
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(localNotificationsChannel, null);
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
        expect(badgePlatform.calls.single.method, 'isSupported');
      },
      variant: const TargetPlatformVariant(<TargetPlatform>{
        TargetPlatform.android,
      }),
    );

    testWidgets(
      'shows not supported state when platform returns false',
      (tester) async {
        badgePlatform.supported = false;

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
        badgePlatform.isSupportedError = PlatformException(code: 'boom');

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
          badgePlatform.calls
              .where((call) => call.method == 'update')
              .single
              .arguments,
          {'count': 1},
        );
        expect(notificationCalls.any((call) => call.method == 'show'), isTrue);
        expect(find.text('Badge count updated: 1'), findsOneWidget);

        await tester.tap(find.text('Remove badge'));
        await tester.pump();

        expect(badgePlatform.calls.last.method, 'remove');
        expect(find.text('Badge count updated: 0'), findsOneWidget);
      },
      variant: const TargetPlatformVariant(<TargetPlatform>{
        TargetPlatform.android,
      }),
    );
  });
}
