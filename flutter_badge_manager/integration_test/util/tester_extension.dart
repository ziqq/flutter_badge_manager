import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data' as td;
import 'dart:ui' as ui;
import 'dart:ui' show Size;

import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/widgets.dart' show WidgetsApp;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

extension WidgetTesterExtension on WidgetTester {
  static const _duration = Duration(milliseconds: 500);

  /// Set size of the screen.
  Future<void> setSize(Size size) async {
    view.physicalSize = size;
    view.devicePixelRatio = 1.0;
    // Rebuild the widget after the screen size change.
    await pumpAndSettle();
  }

  /// Sleep for `duration`.
  Future<void> sleep([Duration duration = _duration]) =>
      Future<void>.delayed(duration);

  /// Pump the widget tree, wait and then pumps a frame again.
  Future<void> pumpAndPause([Duration duration = _duration]) async {
    await pump();
    await sleep(duration);
    await pump();
  }

  /// Pump the widget tree and wait until there are no more frames scheduled.
  Future<void> pupmTime([Duration duration = _duration]) =>
      pumpAndSettle(duration);

  /// Try to pump and find some widget few times.
  Future<Finder> asyncFinder({
    required Finder Function() finder,
    Duration limit = const Duration(milliseconds: 15000),
  }) async {
    final stopwatch = Stopwatch()..start();
    var result = finder();
    try {
      while (stopwatch.elapsed <= limit) {
        await pumpAndSettle(
          const Duration(milliseconds: 100),
        ).timeout(limit - stopwatch.elapsed);

        result = finder();

        if (result.evaluate().isNotEmpty) return result;
      }
      return result;
    } on TimeoutException {
      return result;
    } on Object {
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  /// Returns a function that takes a screenshot
  /// of the current state of the app.
  Future<List<int>> takeScreenshot({
    /// The [_$pixelRatio] describes the scale between the logical pixels
    /// and the size of the output image. It is independent of the
    /// [dart:ui.FlutterView.devicePixelRatio] for the device, so specifying 1.0
    /// (the default) will give you a 1:1 mapping between logical pixels and the
    /// output pixels in the image.
    double pixelRatio = 1,

    /// Screenshot name. If null, the screenshot will be taken
    /// but not saved to a file.
    String? name,

    /// If provided, the screenshot will be get
    /// with standard [IntegrationTestWidgetsFlutterBinding.takeScreenshot] on
    /// Android and iOS devices.
    IntegrationTestWidgetsFlutterBinding? binding,
  }) async {
    await pump();
    if (binding != null &&
        name != null &&
        (io.Platform.isAndroid || io.Platform.isIOS)) {
      if (io.Platform.isAndroid) {
        await binding.convertFlutterSurfaceToImage();
      }
      return await binding.takeScreenshot(name);
    } else {
      final element = firstElement(find.byType(WidgetsApp));
      RenderRepaintBoundary? boundary;
      element.visitAncestorElements((element) {
        final renderObject = element.renderObject;
        if (renderObject is RenderRepaintBoundary) boundary = renderObject;
        return true;
      });
      if (boundary == null) {
        throw StateError('No RenderRepaintBoundary found');
      }
      final image = await boundary!.toImage(pixelRatio: pixelRatio);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes is! td.ByteData) {
        throw StateError('Error converting image to bytes');
      }
      return bytes.buffer.asUint8List();
    }
  }
}
