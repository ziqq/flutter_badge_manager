import 'package:flutter/services.dart';
import 'package:flutter_badge_manager_example/main.dart' as example_app;
import 'package:flutter_test/flutter_test.dart';

import 'badge_api_mock.dart';

void main() {
  final badgeCalls = <MethodCall>[];

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    badgeCalls.clear();
    setUpBadgeApiMock(badgeCalls: badgeCalls);
  });

  tearDown(() {
    tearDownBadgeApiMock();
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
