import 'package:flutter_badge_manager_platform_interface/flutter_badge_manager_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock platform implementation for testing.
class _MockPlatform extends FlutterBadgeManagerPlatform {
  int? lastUpdated;
  bool removeCalled = false;
  bool verifyCalled = false;

  @override
  bool get isMock => true; // bypass token verification for mock

  @override
  Future<bool> isSupported() async => true;

  @override
  Future<void> update(int count) async {
    lastUpdated = count;
  }

  @override
  Future<void> remove() async {
    removeCalled = true;
  }
}

/// A second mock to test re-assignment.
class _AnotherMockPlatform extends FlutterBadgeManagerPlatform {
  @override
  bool get isMock => true;

  @override
  Future<bool> isSupported() async => false;

  @override
  Future<void> update(int count) async {}

  @override
  Future<void> remove() async {}
}

/// Top-level stub without overrides
/// to trigger UnimplementedError for base methods.
class _StubPlatform extends FlutterBadgeManagerPlatform {}

class _InvalidPlatform implements FlutterBadgeManagerPlatform {
  @override
  bool get isMock => false;

  @override
  Future<bool> isSupported() async => true;

  @override
  Future<void> remove() async {}

  @override
  Future<void> update(int count) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() => group('FlutterBadgeManagerPlatform interface', () {
      test('default instance is MethodChannelFlutterBadgeManager', () {
        expect(FlutterBadgeManagerPlatform.instance.runtimeType.toString(),
            contains('MethodChannelFlutterBadgeManager'));
      });

      test('can replace instance with mock (isMock bypass)', () async {
        final mock = _MockPlatform();
        FlutterBadgeManagerPlatform.instance = mock; // should not throw
        expect(FlutterBadgeManagerPlatform.instance, mock);
        expect(
            await FlutterBadgeManagerPlatform.instance.isSupported(), isTrue);
      });

      test('can re-assign instance to another mock', () async {
        final mock1 = _MockPlatform();
        final mock2 = _AnotherMockPlatform();
        FlutterBadgeManagerPlatform.instance = mock1;
        expect(FlutterBadgeManagerPlatform.instance, same(mock1));

        FlutterBadgeManagerPlatform.instance = mock2;
        expect(FlutterBadgeManagerPlatform.instance, same(mock2));
        expect(
            await FlutterBadgeManagerPlatform.instance.isSupported(), isFalse);
      });

      test('rejects implementations that do not extend platform interface', () {
        expect(
          () => FlutterBadgeManagerPlatform.instance = _InvalidPlatform(),
          throwsA(isA<AssertionError>()),
        );
      });

      test('mock delegates update and remove correctly', () async {
        final mock = _MockPlatform();
        FlutterBadgeManagerPlatform.instance = mock;

        await FlutterBadgeManagerPlatform.instance.update(10);
        expect(mock.lastUpdated, 10);

        await FlutterBadgeManagerPlatform.instance.remove();
        expect(mock.removeCalled, isTrue);
      });

      test('isMock returns false by default on base class', () {
        final stub = _StubPlatform();
        expect(stub.isMock, isFalse);
      });

      group('unimplemented methods -', () {
        late _StubPlatform stub;

        setUp(() {
          stub = _StubPlatform();
        });

        test('isSupported throws UnimplementedError', () async {
          expect(stub.isSupported, throwsA(isA<UnimplementedError>()));
        });

        test('update throws UnimplementedError', () async {
          expect(() => stub.update(1), throwsA(isA<UnimplementedError>()));
        });

        test('remove throws UnimplementedError', () async {
          expect(stub.remove, throwsA(isA<UnimplementedError>()));
        });

        test('isSupported error message is descriptive', () {
          expect(
            stub.isSupported,
            throwsA(
              isA<UnimplementedError>().having(
                (e) => e.message,
                'message',
                contains('isSupported'),
              ),
            ),
          );
        });

        test('update error message is descriptive', () {
          expect(
            () => stub.update(1),
            throwsA(
              isA<UnimplementedError>().having(
                (e) => e.message,
                'message',
                contains('update'),
              ),
            ),
          );
        });

        test('remove error message is descriptive', () {
          expect(
            stub.remove,
            throwsA(
              isA<UnimplementedError>().having(
                (e) => e.message,
                'message',
                contains('remove'),
              ),
            ),
          );
        });
      });
    });
