// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>.
// Use of this source code is governed by an MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
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
  /// Federated platform packages replace this with their own Pigeon-backed
  /// implementations during registration. If nothing registers an
  /// implementation, platform calls fail fast with a [StateError].
  static FlutterBadgeManagerPlatform get instance =>
      _instance ??= _MissingFlutterBadgeManagerPlatform.instance;

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
  // @Deprecated('Use MockPlatformInterfaceMixin instead')
  @visibleForTesting
  bool get isMock => false;

  /// Checks if the device supports app badges.
  Future<bool> isSupported() {
    throw UnimplementedError('isSupported is not implemented');
  }

  /// Updates the app badge count.
  Future<void> update(int count) {
    throw UnimplementedError('update is not implemented');
  }

  /// Removes the app badge.
  Future<void> remove() {
    throw UnimplementedError('remove is not implemented');
  }
}

final class _MissingFlutterBadgeManagerPlatform
    extends FlutterBadgeManagerPlatform {
  _MissingFlutterBadgeManagerPlatform._();

  static final FlutterBadgeManagerPlatform instance =
      _MissingFlutterBadgeManagerPlatform._();

  static StateError _missingImplementationError() => StateError(
        'No FlutterBadgeManagerPlatform implementation was registered. '
        'Ensure a federated platform package is available for the current '
        'platform or inject a test implementation explicitly.',
      );

  @override
  Future<bool> isSupported() =>
      Future<bool>.error(_missingImplementationError());

  @override
  Future<void> update(int count) =>
      Future<void>.error(_missingImplementationError());

  @override
  Future<void> remove() => Future<void>.error(_missingImplementationError());
}
