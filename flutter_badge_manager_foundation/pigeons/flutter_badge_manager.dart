// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>.
// Use of this source code is governed by an MIT license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/flutter_badge_manager_foundation.g.dart',
  dartTestOut: 'test/test_api.g.dart',
  swiftOut:
      'darwin/flutter_badge_manager_foundation/Sources/flutter_badge_manager_foundation/FlutterBadgeManagerPlugin.g.swift',
  copyrightHeader: 'pigeons/copyright.txt',
))

/// Package-local Pigeon schema for the iOS and macOS implementation.
///
/// This contract intentionally lives in the foundation package because it
/// generates Swift bindings and foundation-specific channel names.
@HostApi(dartHostTestHandler: 'TestFlutterBadgeManagerApi')
abstract class FlutterBadgeManagerApi {
  /// Returns whether the current platform supports badge updates.
  bool? isSupported();

  /// Applies the given badge count.
  void update(int count);

  /// Clears the current badge.
  void remove();
}
