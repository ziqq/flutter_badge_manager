/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 31 October 2025
 */

import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_badge_manager/flutter_badge_manager.dart';
import 'package:flutter_badge_manager_example/local_notifications_manager.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runZonedGuarded<void>(
  () => runApp(const App()),
  (e, s) => dev.log('Top level exception: $e\n$s'),
);

/// {@template app}
/// App widget.
/// {@endtemplate}
class App extends StatelessWidget {
  /// {@macro app}
  const App({super.key});

  @override
  Widget build(BuildContext context) =>
      const MaterialApp(title: 'Badge Manager Example', home: _HomeScreen());
}

/// {@template main}
/// _HomeScreen widget.
/// {@endtemplate}
class _HomeScreen extends StatefulWidget {
  /// {@macro main}
  const _HomeScreen({
    super.key, // ignore: unused_element_parameter
  });

  @override
  State<_HomeScreen> createState() => __HomeScreenState();
}

/// State for widget _HomeScreen.
class __HomeScreenState extends State<_HomeScreen> {
  String _supportedString = 'Unknown';
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  /// Ensure notification permission is granted
  /// on Android 13+.
  Future<void> _ensureNotificationPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  Future<void> _initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    String result;
    try {
      await _ensureNotificationPermission();

      bool isSupported = await FlutterBadgeManager.isSupported();
      dev.log('isSupported: $isSupported');
      result = isSupported ? 'Supported' : 'Not supported';
    } on PlatformException {
      dev.log('error: PlatformException');
      result = 'Failed to get badge support.';
    } on Object catch (_, _) {
      dev.log('error: Object');
      result = 'Failed to get badge support.';
    }

    setState(() => _supportedString = result);
  }

  void _addBadge() {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    _count++;
    messenger?.clearSnackBars();
    LocalNotificationsManager.instance
        .showNotification(
          id: Random().nextInt(1 << 31),
          body: 'This is body',
          title: 'This is title',
          payload: 'This is payload',
        )
        .ignore();
    FlutterBadgeManager.update(_count);
    messenger?.showSnackBar(
      SnackBar(content: Text('Badge count updated: $_count')),
    );
  }

  void _remove() {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    _count = 0;
    messenger?.clearSnackBars();
    FlutterBadgeManager.remove();
    messenger?.showSnackBar(
      SnackBar(content: Text('Badge count updated: $_count')),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Badge Manager Example')),
    body: SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('Badge supported: $_supportedString\n'),
          ElevatedButton(
            child: const Text('Add badge'),
            onPressed: () => _addBadge(),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            child: const Text('Remove badge'),
            onPressed: () => _remove(),
          ),
        ],
      ),
    ),
  );
}
