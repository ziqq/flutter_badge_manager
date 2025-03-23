import 'package:flutter/services.dart';
import 'package:flutter_badge_manager_platform_interface/flutter_badge_manager_platform_interface.dart';

/// The [MethodChannel] used to interact with the platform side of the plugin.
const _kChannel = MethodChannel('github.com/ziqq/flutter_badge_manager');

///
class MethodChannelFlutterBadgeManager extends FlutterBadgeManagerPlatform {
  /// Checks if the device supports app badges.
  @override
  Future<bool> isSupported() async {
    final respnse = await _kChannel.invokeMethod('isSupported');
    if (respnse case bool? isSupported) return isSupported ?? false;
    return false;
  }

  /// Updates the app badge count.
  @override
  Future<void> update(int count) =>
      _kChannel.invokeMethod('update', {'count': count});

  /// Removes the app badge.
  @override
  Future<void> remove() => _kChannel.invokeMethod('remove');
}
