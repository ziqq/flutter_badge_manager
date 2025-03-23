// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter_badge_manager_platform_interface/flutter_badge_manager_platform_interface.dart';
import 'package:flutter_badge_manager_platform_interface/method_channel_flutter_badge_manger.dart';

/// The Android implementation of [FlutterBadgeManagerPlatform].
///
/// This class implements the `package:flutter_badge_manager`
/// functionality for Android.
class FlutterBadgeManagerAndroid extends FlutterBadgeManagerPlatform {
  /// Creates a new plugin implementation instance.
  FlutterBadgeManagerAndroid({
    @visibleForOverriding MethodChannelFlutterBadgeManager? methodChannel,
  }) : _methodChannel = methodChannel ?? MethodChannelFlutterBadgeManager();

  final MethodChannelFlutterBadgeManager _methodChannel;

  /// Registers this class
  /// as the default instance of [FlutterBadgeManagerPlatform].
  static void registerWith() {
    FlutterBadgeManagerPlatform.instance = FlutterBadgeManagerAndroid();
  }

  /// Checks if the device supports app badges.
  @override
  Future<bool> isSupported() => _methodChannel.isSupported();

  /// Updates the app badge count.
  @override
  Future<void> update(int count) => _methodChannel.update(count);

  /// Removes the app badge.
  @override
  Future<void> remove() => _methodChannel.remove();
}
