import 'dart:async';

import 'package:flutter/services.dart';

/// {@template flutter_badge_manager}
/// A Flutter plugin to manage app badges on Android and iOS.
/// {@endtemplate}
final class FlutterBadgeManager {
  /// {@macro flutter_badge_manager}
  const FlutterBadgeManager._();

  static const MethodChannel _channel =
      MethodChannel('ziqq/flutter_badge_manager');

  /// Updates the app badge count.
  static Future<void> update(int count) =>
      _channel.invokeMethod('update', {'count': count});

  /// Removes the app badge.
  static Future<void> remove() => _channel.invokeMethod('remove');

  /// Checks if the device supports app badges.
  static Future<bool> isSupported() async {
    final bool? isSupported = await _channel.invokeMethod('isSupported');
    return isSupported ?? false;
  }
}
