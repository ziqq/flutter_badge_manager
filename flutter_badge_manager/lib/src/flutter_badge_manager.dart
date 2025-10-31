// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: sort_constructors_first

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_badge_manager/flutter_badge_manager.dart';

/// {@template flutter_badge_manager}
/// A Flutter plugin to manage app badges on Android, iOS and macOS.
/// {@endtemplate}
final class FlutterBadgeManager {
  /// Use [SharePlus.instance] to access the [share] method.
  FlutterBadgeManager._(this._platform);

  /// Platform interface
  final FlutterBadgeManagerPlatform _platform;

  /// Singleton instance (instance API).
  static FlutterBadgeManager? _instance;

  /// The default instance of [FlutterBadgeManager].
  static final FlutterBadgeManager instance =
      _instance ??= FlutterBadgeManager._(FlutterBadgeManagerPlatform.instance);

  /// Create a custom instance of [FlutterBadgeManager].
  /// Use this constructor for testing purposes only.
  @visibleForTesting
  factory FlutterBadgeManager.custom(FlutterBadgeManagerPlatform platform) =>
      FlutterBadgeManager._(platform);

  /// Check if the device supports app badges.
  Future<bool> isSupported() async => await _platform.isSupported();

  /// Update the app badge.
  Future<void> update(int count) async {
    if (count < 0) throw ArgumentError('count must be non-negative');
    await _platform.update(count);
  }

  /// Removes the app badge.
  Future<void> remove() async {
    await _platform.remove();
  }
}
