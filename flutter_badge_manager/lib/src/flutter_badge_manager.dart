// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>.
// Use of this source code is governed by an MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_badge_manager_platform_interface/flutter_badge_manager_platform_interface.dart';

/// {@template flutter_badge_manager}
/// A Flutter plugin to manage app badges on Android, iOS and macOS.
///
/// Use [FlutterBadgeManager.instance] from the public package export to access
/// this instance-based API.
/// {@endtemplate}
final class FlutterBadgeManager {
  /// Creates a private instance bound to the given [platform].
  FlutterBadgeManager._(this._platform);

  /// Platform interface
  final FlutterBadgeManagerPlatform _platform;

  /// Singleton instance (instance API).
  static FlutterBadgeManager? _instance;

  /// The default instance of [FlutterBadgeManager].
  // ignore: prefer_constructors_over_static_methods
  static FlutterBadgeManager get instance {
    final platform = FlutterBadgeManagerPlatform.instance;
    return _instance ??= FlutterBadgeManager._(platform);
  }

  /// Create a custom instance of [FlutterBadgeManager].
  /// Use this constructor for testing purposes only.
  @visibleForTesting
  // ignore: sort_constructors_first
  factory FlutterBadgeManager.instanceFor(
    FlutterBadgeManagerPlatform platform,
  ) => FlutterBadgeManager._(platform);

  /// Checks whether the current platform can apply numeric app badges.
  Future<bool> isSupported() async => await _platform.isSupported();

  /// Updates the app badge count.
  ///
  /// Throws an [ArgumentError] if [count] is negative.
  Future<void> update(int count) async {
    if (count < 0) throw ArgumentError('count must be non-negative');
    await _platform.update(count);
  }

  /// Removes the app badge.
  Future<void> remove() async {
    await _platform.remove();
  }
}
