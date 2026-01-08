// lib/core/services/notification_permission_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionService {
  static final NotificationPermissionService _instance =
      NotificationPermissionService._internal();

  factory NotificationPermissionService() => _instance;

  NotificationPermissionService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize notifications
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Check if notification permission is granted
  Future<bool> isPermissionGranted() async {
    if (await Permission.notification.isGranted) {
      return true;
    }
    return false;
  }

  // Request notification permission
  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();

    if (status.isGranted || status.isLimited) {
      // Also request for iOS additional permissions
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
      return true;
    }
    return false;
  }

  // Show permission request dialog (for in-app guidance)
  Future<bool> showPermissionDialog({
    required Function() onGranted,
    required Function() onDenied,
  }) async {
    final isGranted = await requestPermission();

    if (isGranted) {
      onGranted();
    } else {
      onDenied();
    }

    return isGranted;
  }

  // Show local notification (for testing)
  Future<void> showLocalNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'devkazi_channel_id',
          'DevKazi Notifications',
          channelDescription: 'DevKazi team notifications channel',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }
}
