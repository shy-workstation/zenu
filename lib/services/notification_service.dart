import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
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

      final initializationSettings = InitializationSettings(
        android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: const DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
        macOS: const DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
        linux: const LinuxInitializationSettings(
          defaultActionName: 'Open',
        ),
        windows: const WindowsInitializationSettings(
          appName: 'Zenu',
          appUserModelId: 'YousofShehada.Zenu',
          guid: 'BE46DC6D-FD4E-4ABB-A08C-68EABDEC1169',
        ),
      );

      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
            _onBackgroundNotificationResponse,
      );

      // Request notification permission on Android 13+ (API 33+)
      if (Platform.isAndroid) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      }

      _instance = NotificationService._(flutterLocalNotificationsPlugin);
    }

    return _instance!;
  }

  void setLocalizations(AppLocalizations localizations) {
    _localizations = localizations;
  }

  static void _onNotificationResponse(NotificationResponse response) {
    _handleNotificationTap(response.payload);
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(NotificationResponse response) {
    _handleNotificationTap(response.payload);
  }

  /// User tapped the notification — bring app to foreground.
  static void _handleNotificationTap(String? payload) async {
    if (payload == null || !payload.startsWith('reminder_')) return;

    final reminderId = payload.substring(9);

    // Dismiss the system notification
    if (_instance != null) {
      final notificationId = reminderId.hashCode.abs();
      await _instance!._flutterLocalNotificationsPlugin.cancel(id: notificationId);
    }

    // Bring app to foreground
    await _bringToForeground();
  }

  /// Bring the app window to the foreground.
  static Future<void> _bringToForeground() async {
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) return;
    try {
      if (await windowManager.isMinimized()) {
        await windowManager.restore();
      }
      await windowManager.show();
      await windowManager.focus();
    } catch (_) {}
  }

  /// Flash the taskbar icon without bringing the window to the foreground.
  static Future<void> _flashTaskbar() async {
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) return;
    try {
      final isFocused = await windowManager.isFocused();
      if (!isFocused) {
        // On Windows, calling focus() on an unfocused window flashes the taskbar
        await windowManager.focus();
      }
    } catch (_) {}
  }

  Future<void> showReminderNotification(Reminder reminder) async {
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'health_reminder_channel',
        _localizations?.healthReminders ?? 'Health Reminders',
        channelDescription: _localizations?.notificationsForHealthReminders ??
            'Notifications for health reminders',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      macOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      linux: const LinuxNotificationDetails(),
      windows: const WindowsNotificationDetails(),
    );

    final notificationId = reminder.id.hashCode.abs();

    if (kDebugMode) {
      debugPrint(
          '📢 Showing notification: id=$notificationId, title=${reminder.title}');
    }

    try {
      await _flutterLocalNotificationsPlugin.show(
        id: notificationId,
        title: reminder.title,
        body: _getNotificationBody(reminder),
        notificationDetails: notificationDetails,
        payload: 'reminder_${reminder.id}',
      );
      // Flash taskbar icon to get user attention
      await _flashTaskbar();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error showing notification: $e');
      }
    }
  }

  String _getNotificationBody(Reminder reminder) {
    if (_localizations == null) {
      return _getDefaultBody(reminder);
    }

    switch (reminder.type) {
      case ReminderType.water:
        return _localizations!.notificationTimeToDrinkWater;
      case ReminderType.eyeRest:
        return _localizations!.notificationTimeToRestEyes;
      case ReminderType.standUp:
        return _localizations!.notificationTimeToStandUp;
      case ReminderType.pushUps:
        return _localizations!.notificationTimeForPushUps(reminder.exerciseCount);
      case ReminderType.pullUps:
        return _localizations!.notificationTimeForPullUps(reminder.exerciseCount);
      case ReminderType.squats:
        return _localizations!.notificationTimeForSquats(reminder.exerciseCount);
      case ReminderType.jumpingJacks:
        return _localizations!.notificationTimeForJumpingJacks(reminder.exerciseCount);
      case ReminderType.burpees:
        return _localizations!.notificationTimeForBurpees(reminder.exerciseCount);
      case ReminderType.stretch:
        return _localizations!.notificationTimeToStretch;
      case ReminderType.planks:
        return _localizations!.notificationTimeForPlanks(reminder.exerciseCount);
      case ReminderType.deepBreathing:
        return _localizations!.notificationTimeForDeepBreathing;
      case ReminderType.meditation:
        return _localizations!.notificationTimeForMeditation;
    }
  }

  String _getDefaultBody(Reminder reminder) {
    switch (reminder.type) {
      case ReminderType.water:
        return 'Don\'t forget to drink water!';
      case ReminderType.eyeRest:
        return 'Time to rest your eyes! Look away from your screen.';
      case ReminderType.standUp:
        return 'Stand up and move around for a few minutes.';
      case ReminderType.pushUps:
        return 'Time for ${reminder.exerciseCount} push-ups!';
      case ReminderType.pullUps:
        return 'Time for ${reminder.exerciseCount} pull-ups!';
      case ReminderType.squats:
        return 'Time for ${reminder.exerciseCount} squats!';
      case ReminderType.jumpingJacks:
        return 'Time for ${reminder.exerciseCount} jumping jacks!';
      case ReminderType.burpees:
        return 'Time for ${reminder.exerciseCount} burpees!';
      case ReminderType.stretch:
        return 'Take a moment to stretch your body.';
      case ReminderType.planks:
        return 'Time for a ${reminder.exerciseCount} second plank!';
      case ReminderType.deepBreathing:
        return 'Take a deep breath and relax.';
      case ReminderType.meditation:
        return 'Take a moment to clear your mind.';
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id: id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
