// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>.
// Use of this source code is governed by an MIT license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter_badge_manager_foundation/src/flutter_badge_manager_foundation.g.dart';
import 'package:flutter_badge_manager_platform_interface/flutter_badge_manager_platform_interface.dart';

/// The iOS and macOS implementation of [FlutterBadgeManagerPlatform].
///
/// This class implements the `package:flutter_badge_manager`
/// functionality for iOS and macOS through the generated Pigeon host API.
class FlutterBadgeManagerFoundation extends FlutterBadgeManagerPlatform {
  /// Creates a new plugin for iOS and macOS implementation instance.
  FlutterBadgeManagerFoundation._({
    @visibleForTesting FlutterBadgeManagerApi? api,
  }) : _api = api ?? FlutterBadgeManagerApi();

  /// Returns an instance using a specified [api].
  factory FlutterBadgeManagerFoundation._instanceFor({
    @visibleForTesting FlutterBadgeManagerApi? api,
  }) =>
      FlutterBadgeManagerFoundation._(api: api);

  /// Returns the default instance
  /// of [FlutterBadgeManagerFoundation].
  static FlutterBadgeManagerFoundation get instance => _instance;

  /// Returns an instance using the default [FlutterBadgeManagerFoundation].
  static final FlutterBadgeManagerFoundation _instance =
      FlutterBadgeManagerFoundation._instanceFor();

  /// The API used to interact with the platform side of the plugin.
  final FlutterBadgeManagerApi _api;

  /// Registers this class as the default Darwin implementation of
  /// [FlutterBadgeManagerPlatform].
  static void registerWith() {
    FlutterBadgeManagerPlatform.instance =
        FlutterBadgeManagerFoundation.instance;
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
