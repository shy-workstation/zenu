import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/reminder.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  static NotificationService? _instance;

  NotificationService._(this._flutterLocalNotificationsPlugin);

  static Future<NotificationService> getInstance() async {
    if (_instance == null) {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
        windows: WindowsInitializationSettings(
          appName: 'Health Reminder App',
          appUserModelId: 'com.example.healthreminder',
          guid: '12345678-1234-5678-9012-123456789012',
        ),
      );

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      _instance = NotificationService._(flutterLocalNotificationsPlugin);
    }

    return _instance!;
  }

  Future<void> showReminderNotification(Reminder reminder) async {
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'health_reminder_channel',
        'Health Reminders',
        channelDescription: 'Notifications for health reminders',
        importance: Importance.high,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('notification'),
        enableVibration: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _flutterLocalNotificationsPlugin.show(
      reminder.type.index,
      reminder.title,
      _getNotificationBody(reminder),
      notificationDetails,
    );
  }

  String _getNotificationBody(Reminder reminder) {
    switch (reminder.type) {
      case ReminderType.eyeRest:
        return 'Time to rest your eyes! Look away from your screen.';
      case ReminderType.standUp:
        return 'Stand up and move around for a few minutes.';
      case ReminderType.pullUps:
        return 'Time for ${reminder.exerciseCount} pull-ups!';
      case ReminderType.pushUps:
        return 'Time for ${reminder.exerciseCount} push-ups!';
      case ReminderType.water:
        return 'Don\'t forget to drink water!';
      case ReminderType.stretch:
        return 'Take a moment to stretch your body.';
      case ReminderType.custom:
        return reminder.description;
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
