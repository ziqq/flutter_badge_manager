// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>.
// Use of this source code is governed by an MIT license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/flutter_badge_manager_android.g.dart',
  dartTestOut: 'test/test_api.g.dart',
  javaOut:
      'android/src/main/java/flutter/plugins/flutterbadgemanager/FlutterBadgeManagerPlugin.g.java',
  javaOptions: JavaOptions(
    package: 'flutter.plugins.flutterbadgemanager',
    className: 'FlutterBadgeManagerPluginPigeon',
  ),
  copyrightHeader: 'pigeons/copyright.txt',
))

/// Package-local Pigeon schema for the Android implementation.
///
/// This contract intentionally lives in the Android package because it
/// generates Android-specific bindings and Android-specific channel names.
@HostApi(dartHostTestHandler: 'TestFlutterBadgeManagerApi')
abstract class FlutterBadgeManagerApi {
  /// Returns whether the current launcher supports numeric badges.
  bool? isSupported();

  /// Applies the given badge count.
  void update(int count);

  /// Clears the current badge.
  void remove();
}
