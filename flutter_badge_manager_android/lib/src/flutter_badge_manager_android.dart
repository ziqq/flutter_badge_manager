// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>.
// Use of this source code is governed by an MIT license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter_badge_manager_android/src/flutter_badge_manager_android.g.dart';
import 'package:flutter_badge_manager_platform_interface/flutter_badge_manager_platform_interface.dart';

/// The Android implementation of [FlutterBadgeManagerPlatform].
///
/// This class implements the `package:flutter_badge_manager`
/// functionality for Android through the generated Pigeon host API.
class FlutterBadgeManagerAndroid extends FlutterBadgeManagerPlatform {
  /// Creates a new plugin implementation instance.
  FlutterBadgeManagerAndroid._({
    @visibleForTesting FlutterBadgeManagerApi? api,
  }) : _api = api ?? FlutterBadgeManagerApi();

  /// Returns an instance using the specified [api].
  factory FlutterBadgeManagerAndroid._instanceFor({
    @visibleForTesting FlutterBadgeManagerApi? api,
  }) =>
      FlutterBadgeManagerAndroid._(api: api);

  final FlutterBadgeManagerApi _api;

  /// Returns the default instance
  /// of [FlutterBadgeManagerAndroid].
  static FlutterBadgeManagerAndroid get instance => _instance;

  /// Returns an instance using the default [FlutterBadgeManagerAndroid].
  static final FlutterBadgeManagerAndroid _instance =
      FlutterBadgeManagerAndroid._instanceFor();

  /// Registers this class as the default Android implementation of
  /// [FlutterBadgeManagerPlatform].
  static void registerWith() {
    FlutterBadgeManagerPlatform.instance = FlutterBadgeManagerAndroid.instance;
  }

  /// Checks if the device supports app badges.
  @override
  Future<bool> isSupported() async => await _api.isSupported() ?? false;

  /// Updates the app badge count.
  @override
  Future<void> update(int count) => _api.update(count);

  /// Removes the app badge.
  @override
  Future<void> remove() => _api.remove();
}
