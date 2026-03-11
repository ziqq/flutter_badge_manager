// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>.
// Use of this source code is governed by an MIT license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_badge_manager_platform_interface/flutter_badge_manager_platform_interface.dart';

/// The entry point for accessing an app badge.
///
/// You can get an instance
/// by calling [MethodChannelFlutterBadgeManager.instance].
class MethodChannelFlutterBadgeManager extends FlutterBadgeManagerPlatform {
  /// Create an instance of [MethodChannelFlutterBadgeManager].
  MethodChannelFlutterBadgeManager._();

  /// Returns the default instance
  /// of [MethodChannelFlutterBadgeManager].
  static MethodChannelFlutterBadgeManager get instance => _instance;

  /// The singleton instance of [MethodChannelFlutterBadgeManager].
  static final MethodChannelFlutterBadgeManager _instance =
      MethodChannelFlutterBadgeManager._();

  /// The [MethodChannel] used to interact with the platform side of the plugin.
  static const MethodChannel _channel = MethodChannel(
    'github.com/ziqq/flutter_badge_manager',
  );

  /// Checks if the device supports app badges.
  @override
  Future<bool> isSupported() async {
    final response = await _channel.invokeMethod('isSupported');
    if (response case bool? isSupported) return isSupported ?? false;
    return false;
  }

  /// Updates the app badge count.
  @override
  Future<void> update(int count) =>
      _channel.invokeMethod('update', {'count': count});

  /// Removes the app badge.
  @override
  Future<void> remove() => _channel.invokeMethod('remove');
}
