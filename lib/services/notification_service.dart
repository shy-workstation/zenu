import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/reminder.dart';
import '../l10n/app_localizations.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  static NotificationService? _instance;
  AppLocalizations? _localizations;

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
          appName: 'Zenu', // Will be localized in the UI context
          appUserModelId: 'com.example.healthreminder',
          guid: '12345678-1234-5678-9012-123456789012',
        ),
      );

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      _instance = NotificationService._(flutterLocalNotificationsPlugin);
    }

    return _instance!;
  }

  void setLocalizations(AppLocalizations localizations) {
    _localizations = localizations;
  }

  Future<void> showReminderNotification(Reminder reminder) async {
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'health_reminder_channel',
        _localizations?.healthReminders ?? 'Health Reminders',
        channelDescription:
            _localizations?.notificationsForHealthReminders ??
            'Notifications for health reminders',
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
    if (_localizations == null) {
      // Fallback to English if localizations not set
      switch (reminder.type) {
        case ReminderType.eyeRest:
          return 'Time to rest your eyes! Look away from your screen.';
        case ReminderType.standUp:
          return 'Stand up and move around for a few minutes.';
        case ReminderType.pullUps:
          return 'Time for ${reminder.exerciseCount} pull-ups!';
        case ReminderType.pushUps:
          return 'Time for ${reminder.exerciseCount} push-ups!';
        case ReminderType.squats:
          return 'Time for ${reminder.exerciseCount} squats!';
        case ReminderType.jumpingJacks:
          return 'Time for ${reminder.exerciseCount} jumping jacks!';
        case ReminderType.planks:
          return 'Time for a ${reminder.exerciseCount} second plank!';
        case ReminderType.burpees:
          return 'Time for ${reminder.exerciseCount} burpees!';
        case ReminderType.water:
          return 'Don\'t forget to drink water!';
        case ReminderType.stretch:
          return 'Take a moment to stretch your body.';
        case ReminderType.custom:
          return reminder.description;
      }
    }

    switch (reminder.type) {
      case ReminderType.eyeRest:
        return _localizations!.notificationTimeToRestEyes;
      case ReminderType.standUp:
        return _localizations!.notificationTimeToStandUp;
      case ReminderType.pullUps:
        return _localizations!.notificationTimeForPullUps(
          reminder.exerciseCount,
        );
      case ReminderType.pushUps:
        return _localizations!.notificationTimeForPushUps(
          reminder.exerciseCount,
        );
      case ReminderType.squats:
        return _localizations!.notificationTimeForSquats(
          reminder.exerciseCount,
        );
      case ReminderType.jumpingJacks:
        return _localizations!.notificationTimeForJumpingJacks(
          reminder.exerciseCount,
        );
      case ReminderType.planks:
        return _localizations!.notificationTimeForPlanks(
          reminder.exerciseCount,
        );
      case ReminderType.burpees:
        return _localizations!.notificationTimeForBurpees(
          reminder.exerciseCount,
        );
      case ReminderType.water:
        return _localizations!.notificationTimeToDrinkWater;
      case ReminderType.stretch:
        return _localizations!.notificationTimeToStretch;
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
