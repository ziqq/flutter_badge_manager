import 'package:flutter/services.dart';
import 'package:flutter_badge_manager_example/main.dart' as example_app;
import 'package:flutter_test/flutter_test.dart';

void main() {
  const badgeChannel = MethodChannel('github.com/ziqq/flutter_badge_manager');
  const permissionChannel = MethodChannel(
    'flutter.baseflow.com/permissions/methods',
  );

  final badgeCalls = <MethodCall>[];
  final permissionCalls = <MethodCall>[];

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    badgeCalls.clear();
    permissionCalls.clear();

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
        .setMockMethodCallHandler(badgeChannel, null);
  });

  group('App startup -', () {
    testWidgets(
      'guarded main requests permission when notifications are denied',
      (tester) async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(permissionChannel, (call) async {
              permissionCalls.add(call);
              switch (call.method) {
                case 'checkPermissionStatus':
                  return 0;
                case 'requestPermissions':
                  return <int, int>{17: 1};
                default:
                  return null;
              }
            });

        example_app.main();
        await tester.pumpAndSettle();

        expect(find.text('Plugin Android Example'), findsOneWidget);
        expect(
          find.textContaining('Badge supported: Supported'),
          findsOneWidget,
        );
        expect(
          permissionCalls.map((call) => call.method),
          containsAll(<String>['checkPermissionStatus', 'requestPermissions']),
        );
        expect(badgeCalls.single.method, 'isSupported');
      },
      variant: const TargetPlatformVariant(<TargetPlatform>{
        TargetPlatform.android,
      }),
    );

    testWidgets(
      'shows generic failure state on non-platform errors',
      (tester) async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(permissionChannel, (call) async {
              permissionCalls.add(call);
              switch (call.method) {
                case 'checkPermissionStatus':
                  return 'bad-status';
                case 'requestPermissions':
                  return <int, int>{17: 1};
                default:
                  return null;
              }
            });

        await tester.pumpWidget(const example_app.App());
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
  });
}
