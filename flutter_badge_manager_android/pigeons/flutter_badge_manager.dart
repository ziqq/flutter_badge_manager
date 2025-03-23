// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/flutter_badge_manager_android.g.dart',
  dartTestOut: 'test/test_api.g.dart',
  javaOut:
      'android/src/main/java/flutter/plugins/flutterbadgemanager/generated/FlutterBadgeManager.g.java',
  javaOptions: JavaOptions(
    package: 'flutter.plugins.flutterbadgemanager.generated',
    className: 'FlutterBadgeManager',
  ),
  // kotlinOut: 'android/src/main/kotlin/flutter/plugins/flutterbadgemanager/generated/FlutterBadgeManager.g.kt',
  // kotlinOptions: KotlinOptions(
  //   package: 'flutter.plugins.flutterbadgemanager.generated',
  //   errorClassName: 'FlutterBadgeManagerError',
  // ),
  copyrightHeader: 'pigeons/copyright.txt',
))
@HostApi(dartHostTestHandler: 'TestFlutterBadgeManagerApi')
abstract class FlutterBadgeManagerApi {
  bool? isSupported();
  void update(int count);
  void remove();
}
