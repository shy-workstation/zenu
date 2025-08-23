import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/reminder.dart';
import '../l10n/app_localizations.dart';
import 'reminder_service.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  static NotificationService? _instance;
  static ReminderService? _reminderService;
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
          appName: 'Zenu',
          appUserModelId: 'YousofShehada.Zenu',
          guid: 'BE46DC6D-FD4E-4ABB-A08C-68EABDEC1169',
        ),
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
            _onBackgroundNotificationResponse,
      );
      _instance = NotificationService._(flutterLocalNotificationsPlugin);
    }

    return _instance!;
  }

  void setLocalizations(AppLocalizations localizations) {
    _localizations = localizations;
  }

  void setReminderService(ReminderService reminderService) {
    _reminderService = reminderService;
  }

  static void _onNotificationResponse(NotificationResponse response) {
    _handleNotificationAction(response.actionId, response.payload);
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(NotificationResponse response) {
    _handleNotificationAction(response.actionId, response.payload);
  }

  static void _handleNotificationAction(String? actionId, String? payload) {
    // Debug logging
    print('Notification action received - ActionId: $actionId, Payload: $payload');
    
    if (_reminderService == null) {
      print('ERROR: ReminderService is null in notification handler');
      return;
    }

    // Handle different platforms and response formats
    String? reminderId;
    String? action;

    // Try to extract action and reminderId from actionId (Android format)
    if (actionId != null && actionId.contains('_')) {
      final parts = actionId.split('_');
      if (parts.length >= 2) {
        action = parts[0];
        reminderId = parts.sublist(1).join('_');
        print('Extracted from actionId - Action: $action, ReminderId: $reminderId');
      }
    }

    // If no actionId, check payload (notification tap without action)
    if (action == null && payload != null) {
      if (payload.startsWith('reminder_')) {
        reminderId = payload.substring(9);
        action = 'open'; // Default to open when notification is tapped
        print('Extracted from payload - Action: $action, ReminderId: $reminderId');
      } else if (payload.contains('_')) {
        // Windows might put the action in the payload
        final parts = payload.split('_');
        if (parts.length >= 2) {
          action = parts[0];
          reminderId = parts.sublist(1).join('_');
          print('Extracted from payload with action - Action: $action, ReminderId: $reminderId');
        }
      }
    }

    if (reminderId == null || action == null) {
      print('ERROR: Could not extract reminder ID or action - ReminderId: $reminderId, Action: $action');
      return;
    }

    print('Processing action: $action for reminder: $reminderId');

    final reminders = _reminderService!.reminders;
    final reminderIndex = reminders.indexWhere((r) => r.id == reminderId);
    
    if (reminderIndex == -1) {
      print('ERROR: Reminder not found with ID: $reminderId');
      return;
    }

    final reminder = reminders[reminderIndex];

    if (action == 'skip') {
      print('Skipping reminder: ${reminder.title}');
      // User chose to skip the reminder - just reset the next reminder time
      reminder.resetNextReminder();
      _reminderService!.saveData();
    } else if (action == 'open') {
      print('Opening app for reminder: ${reminder.title}');
      // User chose to open app - reset reminder time 
      reminder.resetNextReminder();
      _reminderService!.saveData();
      // WindowsActivationType.foreground should bring the app to foreground automatically
      print('App should be brought to foreground by Windows activation');
      // For "Open App", also show the in-app reminder dialog
      _reminderService!.triggerTestReminder(reminder);
    }

    print('Action completed successfully');
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
        actions: [
          AndroidNotificationAction(
            'skip_${reminder.id}',
            _localizations?.skip ?? 'Skip',
          ),
          AndroidNotificationAction('open_${reminder.id}', 'Open App'),
        ],
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      windows: WindowsNotificationDetails(
        actions: [
          WindowsAction(
            content: _localizations?.skip ?? 'Skip',
            arguments: 'skip_${reminder.id}',
            activationType: WindowsActivationType.protocol,
          ),
          WindowsAction(
            content: 'Open App',
            arguments: 'open_${reminder.id}',
            activationType: WindowsActivationType.foreground,
            afterActivationBehavior: WindowsAfterActivationBehavior.pendingUpdate,
          ),
        ],
        // Set the main notification click to also activate foreground
        arguments: 'open_${reminder.id}',
        activationType: WindowsActivationType.foreground,
      ),
    );

    await _flutterLocalNotificationsPlugin.show(
      reminder.type.index,
      reminder.title,
      _getNotificationBody(reminder),
      notificationDetails,
      payload: 'reminder_${reminder.id}',
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
