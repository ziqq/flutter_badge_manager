// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>.
// Use of this source code is governed by an MIT license that can be
// found in the LICENSE file.

// ignore_for_file: omit_local_variable_types, always_use_package_imports

import 'package:flutter/services.dart';

import 'flutter_badge_manager.dart' as badge_manager;

/// {@template flutter_badge_manager}
/// A Flutter plugin to manage app badges on Android, iOS and macOS.
///
/// The static methods on this compatibility facade are deprecated. Prefer the
/// instance API exposed via [instance].
/// {@endtemplate}
final class FlutterBadgeManager {
  /// {@macro flutter_badge_manager}
  const FlutterBadgeManager._(); // coverage:ignore-line

  /// Preferred instance-based API entry point.
  ///
  /// This getter is not deprecated. It forwards to the non-legacy instance API
  /// while keeping the historical [FlutterBadgeManager] symbol stable.
  static final badge_manager.FlutterBadgeManager instance =
      badge_manager.FlutterBadgeManager.instance;

  /// Legacy compatibility channel used by the deprecated static methods below.
  static const MethodChannel _channel =
      MethodChannel('github.com/ziqq/flutter_badge_manager');

  /// Updates the app badge count using the legacy static API.
  @Deprecated(
    'Use FlutterBadgeManager.instance.update(count) instead.',
  )
  static Future<void> update(int count) =>
      _channel.invokeMethod('update', {'count': count});

  /// Removes the app badge using the legacy static API.
  @Deprecated('Use FlutterBadgeManager.instance.remove() instead.')
  static Future<void> remove() => _channel.invokeMethod('remove');

  /// Checks whether the current platform supports numeric app badges.
  @Deprecated('Use FlutterBadgeManager.instance.isSupported() instead.')
  static Future<bool> isSupported() async {
    final bool? isSupported = await _channel.invokeMethod('isSupported');
    return isSupported ?? false;
  }
}
