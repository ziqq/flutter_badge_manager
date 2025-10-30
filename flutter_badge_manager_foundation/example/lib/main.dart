import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_badge_manager_foundation/flutter_badge_manager_foundation.dart';

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
  String _supportedString = 'Unknown';
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  Future<void> _initPlatformState() async {
    if (!mounted) return;

    String supportedString;
    try {
      bool isSupported = await FlutterBadgeManagerFoundation.instance
          .isSupported();
      dev.log('isSupported: $isSupported');
      if (isSupported) {
        supportedString = 'Supported';
      } else {
        supportedString = 'Not supported';
      }
    } on PlatformException {
      dev.log('error: PlatformException');
      supportedString = 'Failed to get badge support.';
    } on Object catch (_, _) {
      dev.log('error: Object');
      supportedString = 'Failed to get badge support.';
    }

    setState(() => _supportedString = supportedString);
  }

  void _addBadge() {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    _count++;
    messenger?.clearSnackBars();
    FlutterBadgeManagerFoundation.instance.update(_count);
    messenger?.showSnackBar(
      SnackBar(content: Text('Badge count updated: $_count')),
    );
  }

  void _remove() {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    _count = 0;
    messenger?.clearSnackBars();
    FlutterBadgeManagerFoundation.instance.remove();
    messenger?.showSnackBar(
      SnackBar(content: Text('Badge count updated: $_count')),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Plugin example app')),
    body: SizedBox.expand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 16,
        children: <Widget>[
          Text('Badge supported: $_supportedString\n'),
          ElevatedButton(
            child: const Text('Add badge'),
            onPressed: () => _addBadge(),
          ),
          ElevatedButton(
            child: const Text('Remove badge'),
            onPressed: () => _remove(),
          ),
        ],
      ),
    ),
  );
}
