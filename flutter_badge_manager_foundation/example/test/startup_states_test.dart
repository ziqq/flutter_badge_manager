import 'package:flutter/services.dart';
import 'package:flutter_badge_manager_example/main.dart' as example_app;
import 'package:flutter_test/flutter_test.dart';

void main() {
  const badgeChannel = MethodChannel('github.com/ziqq/flutter_badge_manager');
  final badgeCalls = <MethodCall>[];

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    badgeCalls.clear();

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
        .setMockMethodCallHandler(badgeChannel, null);
  });

  group('App startup -', () {
    testWidgets('guarded main renders the app', (tester) async {
      example_app.main();
      await tester.pumpAndSettle();

      expect(find.text('Plugin example app'), findsOneWidget);
      expect(find.textContaining('Badge supported: Supported'), findsOneWidget);
      expect(badgeCalls.single.method, 'isSupported');
    });
  });
}
