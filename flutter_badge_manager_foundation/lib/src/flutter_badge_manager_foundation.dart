// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter_badge_manager_platform_interface/flutter_badge_manager_platform_interface.dart';
import 'package:flutter_badge_manager_platform_interface/method_channel_flutter_badge_manger.dart';

/// The iOS and macOS implementation of [FlutterBadgeManagerPlatform].
///
/// This class implements the `package:flutter_badge_manager`
/// functionality for iOS and macOS.
class FlutterBadgeManagerFoundation extends FlutterBadgeManagerPlatform {
  /// Creates a new plugin for iOS and macOS implementation instance.
  FlutterBadgeManagerFoundation._({
    @visibleForOverriding MethodChannelFlutterBadgeManager? channel,
  }) : _channel = channel ?? MethodChannelFlutterBadgeManager.instance;

  /// Returns an instance using a specified [MethodChannelFlutterBadgeManager].
  factory FlutterBadgeManagerFoundation._instanceFor({
    @visibleForOverriding MethodChannelFlutterBadgeManager? channel,
  }) => FlutterBadgeManagerFoundation._(channel: channel);

  /// Returns the default instance
  /// of [FlutterBadgeManagerFoundation].
  static FlutterBadgeManagerFoundation get instance => _instance;

  /// Returns an instance using the default [FlutterBadgeManagerFoundation].
  static final FlutterBadgeManagerFoundation _instance =
      FlutterBadgeManagerFoundation._instanceFor();

  /// The channel used to interact with the platform side of the plugin.
  final MethodChannelFlutterBadgeManager _channel;

  /// Registers this class
  /// as the default instance of [FlutterBadgeManagerPlatform].
  static void registerWith() {
    FlutterBadgeManagerPlatform.instance =
        FlutterBadgeManagerFoundation.instance;
  }

  /// Checks if the device supports app badges.
  @override
  Future<bool> isSupported() => _channel.isSupported();

  /// Updates the app badge count.
  @override
  Future<void> update(int count) => _channel.update(count);

  /// Removes the app badge.
  @override
  Future<void> remove() => _channel.remove();
}
