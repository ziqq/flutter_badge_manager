import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_badge_manager_foundation/flutter_badge_manager_foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  Widget build(BuildContext context) => const MaterialApp(
    title: 'Plugin Foundation Example',
    home: _HomeScreen(),
  );
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
  final _plugin = FlutterLocalNotificationsPlugin();
  late ScaffoldMessengerState? _messenger;

  String _supportedString = 'Unknown';
  bool isSupported = false;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    Future<void>(() async {
      if (!mounted) return;

      String supportedString;
      try {
        final ensure = await _ensureBadgePermission();

        isSupported = await FlutterBadgeManagerFoundation.instance
            .isSupported();
        isSupported &= ensure == true;
        dev.log('isSupported: $isSupported');
        if (isSupported) {
          supportedString = 'Supported';
        } else {
          supportedString = 'Not supported';
        }
      } on PlatformException catch (e, _) {
        dev.log('PlatformException | isSupported error: $e');
        supportedString = 'Failed to get badge support.';
      } on Object catch (e, _) {
        dev.log('error: $e');
        supportedString = 'Failed to get badge support. $e';
      }

      setState(() => _supportedString = supportedString);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messenger = ScaffoldMessenger.maybeOf(context);
  }

  /// Requests notification permission on platforms that require it
  /// for badge display for iOS versions 18 and bellow.
  Future<bool?> _ensureBadgePermission() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return await _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: false, badge: true, sound: false);
      }

      if (defaultTargetPlatform == TargetPlatform.macOS) {
        return await _plugin
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: false, badge: true, sound: false);
      }
      return false;
    } on Object catch (e, s) {
      dev.log('Failed to request badge permission: $e', stackTrace: s);
      return null;
    }
  }

  Future<void> _add() async {
    if (!mounted) return;
    _count++;
    await FlutterBadgeManagerFoundation.instance.update(_count);
    _messenger
      ?..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text('Badge count updated: $_count')));
  }

  Future<void> _remove() async {
    if (!mounted) return;
    await FlutterBadgeManagerFoundation.instance.remove();
    _count = 0;
    _messenger
      ?..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text('Badge count updated: $_count')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Badge plugin example (foundation)')),
    body: SizedBox.expand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 16,
        children: <Widget>[
          Text('Badge supported: $_supportedString\n'),
          ElevatedButton(onPressed: _add, child: const Text('Add badge')),
          ElevatedButton(onPressed: _remove, child: const Text('Remove badge')),
        ],
      ),
    ),
  );
}
