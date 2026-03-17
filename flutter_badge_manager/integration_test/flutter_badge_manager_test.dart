import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

final IntegrationTestWidgetsFlutterBinding $binding =
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

void main() {
  setUpAll(() async {
    $binding; // ignore: unnecessary_statements
  });

  group('end2end -', () {});
}
