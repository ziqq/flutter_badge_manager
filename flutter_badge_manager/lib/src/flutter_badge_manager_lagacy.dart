// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: omit_local_variable_types, always_use_package_imports

import 'package:flutter/services.dart';

import 'flutter_badge_manager.dart' as badge_manager;

/// {@template flutter_badge_manager}
/// A Flutter plugin to manage app badges on Android and iOS.
/// {@endtemplate}
final class FlutterBadgeManager {
  /// {@macro flutter_badge_manager}
  const FlutterBadgeManager._();

  /// Instance делегат (новый стиль): FlutterBadgeManager.instance.update(3)
  static final badge_manager.FlutterBadgeManager instance =
      badge_manager.FlutterBadgeManager.instance;

  static const MethodChannel _channel =
      MethodChannel('github.com/ziqq/flutter_badge_manager');

  /// Updates the app badge count.
  @Deprecated('Use FlutterBadgeManager.instance.update() instead')
  static Future<void> update(int count) =>
      _channel.invokeMethod('update', {'count': count});

  /// Removes the app badge.
  @Deprecated('Use FlutterBadgeManager.instance.remove() instead')
  static Future<void> remove() => _channel.invokeMethod('remove');

  /// Checks if the device supports app badges.
  @Deprecated('Use FlutterBadgeManager.instance.isSupported() instead')
  static Future<bool> isSupported() async {
    final bool? isSupported = await _channel.invokeMethod('isSupported');
    return isSupported ?? false;
  }
}
