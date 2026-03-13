import 'package:flutter/services.dart';
import 'package:flutter_badge_manager_example/main.dart';
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

  group('Widget_tests -', () {
    testWidgets('shows supported state after startup', (tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      expect(find.textContaining('Badge supported: Supported'), findsOneWidget);
      expect(badgeCalls.single.method, 'isSupported');
    });

    testWidgets('shows not supported state when platform returns false', (
      tester,
    ) async {
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
    });

    testWidgets('shows failure state on PlatformException', (tester) async {
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
    });

    testWidgets('add and remove buttons call plugin methods', (tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add badge'));
      await tester.pump();

      expect(
        badgeCalls.where((call) => call.method == 'update').single.arguments,
        {'count': 1},
      );
      expect(find.text('Badge count updated: 1'), findsOneWidget);

      await tester.tap(find.text('Remove badge'));
      await tester.pump();

      expect(badgeCalls.last.method, 'remove');
      expect(find.text('Badge count updated: 0'), findsOneWidget);
    });
  });
}
