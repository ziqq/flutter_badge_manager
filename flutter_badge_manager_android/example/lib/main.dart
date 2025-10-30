import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_badge_manager_android/flutter_badge_manager_android.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(home: _HomeScreen());
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
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    String supportedString;
    try {
      bool isSupported =
          await FlutterBadgeManagerAndroid.instance.isSupported();
      log('isSupported: $isSupported');
      if (isSupported) {
        supportedString = 'Supported';
      } else {
        supportedString = 'Not supported';
      }
    } on PlatformException {
      log('error: PlatformException');
      supportedString = 'Failed to get badge support.';
    } on Object catch (_, __) {
      log('error: Object');
      supportedString = 'Failed to get badge support.';
    }

    setState(() => _supportedString = supportedString);
  }

  void _addBadge() {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    _count++;
    messenger?.clearSnackBars();
    FlutterBadgeManagerAndroid.instance.update(_count);
    messenger
        ?.showSnackBar(SnackBar(content: Text('Badge count updated: $_count')));
  }

  void _remove() {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    _count = 0;
    messenger?.clearSnackBars();
    FlutterBadgeManagerAndroid.instance.remove();
    messenger
        ?.showSnackBar(SnackBar(content: Text('Badge count updated: $_count')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
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
