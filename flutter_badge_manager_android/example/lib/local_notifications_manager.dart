// autor - <a.a.ustinoff@gmail.com> Anton Ustinoff
// ignore_for_file: sort_constructors_first

import 'dart:async';
import 'dart:io' as io;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
void _onTapBackgroundNotification(NotificationResponse? notificationResponse) {}

/// {@template local_notifications_manager}
/// LocalNotificationsManager class
/// {@endtemplate}
final class LocalNotificationsManager {
  static final _internalSingleton = LocalNotificationsManager._internal();
  static LocalNotificationsManager get instance => _internalSingleton;
  factory LocalNotificationsManager() => _internalSingleton;
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

  // final StreamController<ReceivedNotification?> _receivedNotificationsStreamController = StreamController<ReceivedNotification?>.broadcast();
  // Stream<ReceivedNotification?> get didReceivedNotifications => _receivedNotificationsStreamController.stream;

  final StreamController<NotificationResponse?> _notificationsStreamController =
      StreamController<NotificationResponse?>.broadcast();

  /// Stream of selected notifications
  Stream<NotificationResponse?> get notifications =>
      _notificationsStreamController.stream;

  /// Dispose all streams
  void dispose() {
    _notificationsStreamController.close();
    // _receivedNotificationsStreamController.close();
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

  /// Update badge count on Android
  /// Used only to silently update badge count
  /// Used because of the lack of a way to update the badge count on Android
  /* Future<void> updateBadgeCount$Android(int count) async {
    final androidDetails = AndroidNotificationDetails(
      'badge_channel_id',
      'Badge Channel',
      channelDescription: 'Used only to silently update badge count',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: false,
      playSound: false,
      enableVibration: false,
      channelShowBadge: true,
      number: count,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: true,
        badgeNumber: count,
        presentSound: false,
      ),
    );

    await _flutterLocalNotificationsPlugin.show(
      9999,
      ' ',
      null,
      notificationDetails,
    );
  } */

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
    );
  }

  /// Initialize [FlutterLocalNotificationsPlugin]
  Future<void> _setupLocalNotificationPlugin() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('app_icon_rounded'),
      iOS: DarwinInitializationSettings(),
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
      onDidReceiveNotificationResponse: (details) {
        _notificationsStreamController.add(details);
        /* switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            _notificationsStreamController.add(notificationResponse.payload);
            break;
          case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == navigationActionId) {
              _notificationsStreamController.add(notificationResponse.payload);
            }
            break;
        } */
      },
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
