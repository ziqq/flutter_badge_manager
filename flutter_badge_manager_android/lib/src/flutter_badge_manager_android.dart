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
  FlutterBadgeManagerAndroid._({
    @visibleForOverriding MethodChannelFlutterBadgeManager? channel,
  }) : _channel = channel ?? MethodChannelFlutterBadgeManager.instance;

  //  Messaging does not yet support multiple Firebase Apps. Default app only.
  /// Returns an instance using a specified [FirebaseApp].
  factory FlutterBadgeManagerAndroid._instanceFor({
    @visibleForOverriding MethodChannelFlutterBadgeManager? channel,
  }) =>
      FlutterBadgeManagerAndroid._(channel: channel);

  final MethodChannelFlutterBadgeManager _channel;

  /// Returns the default instance
  /// of [FlutterBadgeManagerAndroid].
  static FlutterBadgeManagerAndroid get instance => _instance;

  /// Returns an instance using the default [FlutterBadgeManagerAndroid].
  static final FlutterBadgeManagerAndroid _instance =
      FlutterBadgeManagerAndroid._instanceFor();

  /// Registers this class
  /// as the default instance of [SharedPreferencesAsyncPlatform].
  static void registerWith() {
    FlutterBadgeManagerPlatform.instance = FlutterBadgeManagerAndroid.instance;
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
