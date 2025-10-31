// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_badge_manager_platform_interface/method_channel_flutter_badge_manger.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of flutter_badge_manager must implement.
///
/// Platform implementations should extend this class
/// rather than implement it as `flutter_badge_manager`
/// does not consider newly added methods to be breaking changes.
/// Extending this class (using `extends`) ensures that the subclass
/// will get the default implementation, while platform implementations
/// that `implements` this interface will be broken
/// by newly added [FlutterBadgeManagerPlatform] methods.
abstract class FlutterBadgeManagerPlatform extends PlatformInterface {
  /// Constructs a FlutterBadgeManagerPlatform.
  FlutterBadgeManagerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterBadgeManagerPlatform? _instance;

  /// The current default [FlutterBadgeManagerPlatform] instance.
  ///
  /// It will always default to [MethodChannelFlutterBadgeManager]
  /// if no other implementation was provided.
  static FlutterBadgeManagerPlatform get instance =>
      _instance ??= MethodChannelFlutterBadgeManager.instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [FlutterBadgeManagerPlatform]
  /// when they register themselves.
  static set instance(FlutterBadgeManagerPlatform instance) {
    if (!instance.isMock) PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Only mock implementations should set this to true.
  ///
  /// Mockito mocks are implementing this class with `implements`
  /// which is forbidden for anything other than mocks (see class docs).
  /// This property provides a backdoor for mockito mocks to
  /// skip the verification that the class isn't implemented with `implements`.
  @visibleForTesting
  // @Deprecated('Use MockPlatformInterfaceMixin instead')
  bool get isMock => false;

  /// Checks if the device supports app badges.
  Future<bool> isSupported() async => await instance.isSupported();

  /// Updates the app badge count.
  Future<void> update(int count) async => await instance.update(count);

  /// Removes the app badge.
  Future<void> remove() async => await instance.remove();
}
