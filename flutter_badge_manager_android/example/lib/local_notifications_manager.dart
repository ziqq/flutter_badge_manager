// autor - <a.a.ustinoff@gmail.com> Anton Ustinoff
// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';
import 'dart:io' as io;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
void _onTapBackgroundNotification(NotificationResponse? notificationResponse) {}

/// {@template local_notifications_manager}
/// LocalNotificationsManager class
/// {@endtemplate}
final class LocalNotificationsManager {
  static final _instance = LocalNotificationsManager._internal();
  static LocalNotificationsManager get instance => _instance;
  factory LocalNotificationsManager() => _instance;
  LocalNotificationsManager._internal() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _setupLocalNotificationPlugin();
    _setupNotificationChannel();
    _requestPermissions();
  }

  /// The default [AndroidNotificationChannel] for the app.
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'Выводить уведомления', // title
    importance: Importance.max,
  );

  late final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  // FirebaseMessaging get messaging => FirebaseMessaging.instance;

  final StreamController<NotificationResponse?> _notificationsStreamController =
      StreamController<NotificationResponse?>.broadcast();

  /// Stream of selected notifications
  Stream<NotificationResponse?> get notifications =>
      _notificationsStreamController.stream;

  /// Dispose all streams
  void dispose() {
    _notificationsStreamController.close();
  }

  /// Show local notification
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    final details = await _getNotificationDetails();
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Get [NotificationDetails]
  Future<NotificationDetails?> _getNotificationDetails() async {
    const androidNotificationDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'Выводить уведомления',
      icon: 'app_icon_rounded',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
      channelShowBadge: true,
      number: 1,
    );
    const darwinNotificationDetails = DarwinNotificationDetails();
    return const NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
      macOS: darwinNotificationDetails,
    );
  }

  /// Initialize [FlutterLocalNotificationsPlugin]
  Future<void> _setupLocalNotificationPlugin() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('app_icon_rounded'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
      /* onDidReceiveLocalNotification: (id, title, body, payload) async {
          _receivedNotificationsStreamController.add(
            ReceivedNotification(
              id: id,
              title: title,
              body: body,
              payload: payload,
            ),
          );
        }, */
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _notificationsStreamController.add,
      onDidReceiveBackgroundNotificationResponse: _onTapBackgroundNotification,
    );
    // await FirebaseMessaging.instance
    //     .setForegroundNotificationPresentationOptions(
    //   alert: true,
    //   badge: true,
    //   sound: true,
    // );
  }

  /// Create notification chanel
  Future<void> _setupNotificationChannel() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  /// Make permission request
  Future<void> _requestPermissions() async {
    if (io.Platform.isIOS || io.Platform.isMacOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (io.Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }
}
