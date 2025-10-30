import 'package:flutter_badge_manager_platform_interface/flutter_badge_manager_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock platform implementation for testing.
class _MockPlatform extends FlutterBadgeManagerPlatform {
  bool verifyCalled = false;

  @override
  bool get isMock => true; // bypass token verification for mock

  @override
  Future<bool> isSupported() async => true;

  @override
  Future<void> update(int count) async {}

  @override
  Future<void> remove() async {}
}

/// Top-level stub without overrides
/// to trigger UnimplementedError for base methods.
class _StubPlatform extends FlutterBadgeManagerPlatform {}

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

      test('unimplemented methods throw via stub subclass', () async {
        final stub = _StubPlatform();
        expect(stub.isSupported, throwsA(isA<UnimplementedError>()));
        expect(() => stub.update(1), throwsA(isA<UnimplementedError>()));
        expect(stub.remove, throwsA(isA<UnimplementedError>()));
      });
    });
