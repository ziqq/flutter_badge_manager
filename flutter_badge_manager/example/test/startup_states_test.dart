import 'package:flutter/services.dart';
import 'package:flutter_badge_manager/flutter_badge_manager.dart'
    show FlutterBadgeManagerPlatform;
import 'package:flutter_badge_manager_example/main.dart' as example_app;
import 'package:flutter_test/flutter_test.dart';

class _FakeBadgePlatform extends FlutterBadgeManagerPlatform {
  bool supported = true;
  PlatformException? isSupportedError;
  final calls = <String>[];

  @override
  bool get isMock => true;

  @override
  Future<bool> isSupported() async {
    calls.add('isSupported');
    if (isSupportedError case final PlatformException error) {
      throw error;
    }
    return supported;
  }

  @override
  Future<void> update(int count) async {
    calls.add('update');
  }

  @override
  Future<void> remove() async {
    calls.add('remove');
  }
}

void main() {
  const permissionChannel = MethodChannel(
    'flutter.baseflow.com/permissions/methods',
  );

  final permissionCalls = <MethodCall>[];
  late _FakeBadgePlatform badgePlatform;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    permissionCalls.clear();
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
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
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

        expect(find.text('Badge Manager Example'), findsOneWidget);
        expect(
          find.textContaining('Badge supported: Supported'),
          findsOneWidget,
        );
        expect(
          permissionCalls.map((call) => call.method),
          containsAll(<String>['checkPermissionStatus', 'requestPermissions']),
        );
        expect(badgePlatform.calls.single, 'isSupported');
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
        badgePlatform.isSupportedError = PlatformException(code: 'boom');

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
