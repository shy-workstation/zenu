import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';
import '../models/reminder.dart';
import '../l10n/app_localizations.dart';
import 'reminder_service.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  static NotificationService? _instance;
  static ReminderService? _reminderService;
  AppLocalizations? _localizations;
  
  // Debounce mechanism to prevent duplicate activations
  static DateTime? _lastActivationTime;
  static const Duration _debounceDelay = Duration(milliseconds: 1000);

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

  static void _handleNotificationAction(String? actionId, String? payload) async {
    if (_reminderService == null) return;

    // Debounce rapid duplicate notifications
    final now = DateTime.now();
    if (_lastActivationTime != null && 
        now.difference(_lastActivationTime!) < _debounceDelay) {
      return; // Ignore duplicate activation within debounce period
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
      }
    }

    // If no actionId, check payload (notification tap without action)
    if (action == null && payload != null) {
      if (payload.startsWith('reminder_')) {
        reminderId = payload.substring(9);
        action = 'open'; // Default to open when notification is tapped
      } else if (payload.contains('_')) {
        // Windows might put the action in the payload
        final parts = payload.split('_');
        if (parts.length >= 2) {
          action = parts[0];
          reminderId = parts.sublist(1).join('_');
        }
      }
    }

    if (reminderId == null || action == null) return;

    final reminders = _reminderService!.reminders;
    final reminderIndex = reminders.indexWhere((r) => r.id == reminderId);
    
    if (reminderIndex == -1) return;

    final reminder = reminders[reminderIndex];

    if (action == 'skip') {
      // Update debounce time
      _lastActivationTime = now;
      
      // User chose to skip the reminder - just reset the next reminder time
      reminder.resetNextReminder();
      _reminderService!.saveData();
    } else if (action == 'open') {
      // Update debounce time
      _lastActivationTime = now;
      
      // User chose to open app - reset reminder time 
      reminder.resetNextReminder();
      _reminderService!.saveData();
      
      // Use professional window manager to bring app to foreground
      await _professionalWindowActivation();
      
      // For "Open App", show the in-app reminder dialog
      _reminderService!.triggerTestReminder(reminder);
    }
  }

  /// Professional window activation using window_manager
  /// This is the industry standard approach used by Discord, VS Code, etc.
  static Future<void> _professionalWindowActivation() async {
    try {
      // Stop any ongoing flashing when user opens the app
      await _stopTaskbarFlashing();
      
      // Restore if minimized
      if (await windowManager.isMinimized()) {
        await windowManager.restore();
      }
      
      // Show and focus the window
      await windowManager.show();
      await windowManager.focus();
      
      // Bring window to front (temporarily set always on top to bypass Windows focus stealing prevention)
      await windowManager.setAlwaysOnTop(true);
      await Future.delayed(const Duration(milliseconds: 100));
      await windowManager.setAlwaysOnTop(false);
      
      // Final focus to ensure visibility
      await windowManager.focus();
      
    } catch (e) {
      // Fallback to basic window manager methods
      try {
        await windowManager.show();
        await windowManager.focus();
      } catch (fallbackError) {
        // Silent fallback failure
      }
    }
  }

  /// Start flashing taskbar to get user attention (like Discord, Teams, etc.)
  static Future<void> _startTaskbarFlashing() async {
    if (!Platform.isWindows) return;
    
    try {
      // Bring window to attention without flashing (flash method not available)
      if (!await windowManager.isFocused()) {
        // Show and focus window to get user attention
        await windowManager.show();
      }
    } catch (e) {
      // Silent fallback failure
    }
  }

  /// Stop taskbar flashing
  static Future<void> _stopTaskbarFlashing() async {
    if (!Platform.isWindows) return;
    
    try {
      // Window manager handles this automatically when window gets focus
      await windowManager.focus();
    } catch (e) {
      // Silent failure
    }
  }


  Future<void> showReminderNotification(Reminder reminder) async {
    // Start flashing taskbar to get user attention (like Discord, Teams, etc.)
    await _startTaskbarFlashing();
    
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
          ),
        ],
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
