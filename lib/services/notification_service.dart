import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(settings, onDidReceiveNotificationResponse: (payload) {
      // lidar com toque
    });

    const androidChannel = AndroidNotificationChannel(
      'gastos_channel',
      'Alertas de contas',
      description: 'Notificações sobre contas vencidas e a vencer',
      importance: Importance.max,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  NotificationDetails _buildDetails() {
    final androidDetails = AndroidNotificationDetails(
      'gastos_channel',
      'Alertas de contas',
      channelDescription: 'Notificações sobre contas vencidas e a vencer',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    final iosDetails = DarwinNotificationDetails();
    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  Future<void> showImmediate({
    required int id,
    required String title,
    required String body,
  }) async {
    final details = _buildDetails();
    await _plugin.show(id, title, body, details);
  }

  Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    final details = _buildDetails();
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  tz.TZDateTime tzFromDateTime(DateTime dt) => tz.TZDateTime.from(dt, tz.local);
}