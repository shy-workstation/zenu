import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../notification_adapter.dart';
import '../../utils/error_handler.dart';

/// Android-specific notification adapter implementation
class AndroidNotificationAdapter implements NotificationAdapter {
  late final FlutterLocalNotificationsPlugin _plugin;
  late final AndroidNotificationConfig _config;
  Function(AppNotificationResponse)? _onNotificationResponse;
  bool _initialized = false;

  AndroidNotificationAdapter([AndroidNotificationConfig? config]) {
    _config = config ?? AndroidNotificationConfig.defaultConfig;
    _plugin = FlutterLocalNotificationsPlugin();
  }

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      const initializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      await _plugin.initialize(
        InitializationSettings(android: initializationSettings),
        onDidReceiveNotificationResponse: (response) {
          _onNotificationResponse?.call(AppNotificationResponse(
            id: response.id.toString(),
            actionId: response.actionId,
            payload: response.payload,
            input: response.input,
            type: response.actionId != null
                ? AppNotificationResponseType.selectedNotificationAction
                : AppNotificationResponseType.selectedNotification,
          ));
        },
      );

      // Request notification permissions for Android 13+
      if (Platform.isAndroid) {
        await _plugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      }

      _initialized = true;
      ErrorHandler.logInfo('AndroidNotificationAdapter initialized successfully');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AndroidNotificationAdapter.initialize',
        severity: ErrorSeverity.error,
      );
      throw NotificationException('Failed to initialize Android notifications', originalError: e);
    }
  }

  @override
  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    List<NotificationAction>? actions,
  }) async {
    await _ensureInitialized();

    try {
      final androidDetails = AndroidNotificationDetails(
        _config.channelId,
        _config.channelName,
        channelDescription: _config.channelDescription,
        importance: _mapImportance(_config.importance),
        priority: _mapPriority(_config.importance),
        enableVibration: _config.enableVibration,
        sound: _config.enableSound ? const RawResourceAndroidNotificationSound('notification') : null,
        actions: actions?.map(_mapAction).toList(),
      );

      await _plugin.zonedSchedule(
        id.hashCode,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      ErrorHandler.logInfo('Scheduled Android notification for ${scheduledTime.toIso8601String()}');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AndroidNotificationAdapter.scheduleNotification',
        severity: ErrorSeverity.error,
      );
      throw NotificationException('Failed to schedule notification', originalError: e);
    }
  }

  @override
  Future<void> showNotification({
    required String id,
    required String title,
    required String body,
    String? payload,
    List<NotificationAction>? actions,
  }) async {
    await _ensureInitialized();

    try {
      final androidDetails = AndroidNotificationDetails(
        _config.channelId,
        _config.channelName,
        channelDescription: _config.channelDescription,
        importance: _mapImportance(_config.importance),
        priority: _mapPriority(_config.importance),
        enableVibration: _config.enableVibration,
        sound: _config.enableSound ? const RawResourceAndroidNotificationSound('notification') : null,
        actions: actions?.map(_mapAction).toList(),
      );

      await _plugin.show(
        id.hashCode,
        title,
        body,
        NotificationDetails(android: androidDetails),
        payload: payload,
      );

      ErrorHandler.logInfo('Showed Android notification: $title');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AndroidNotificationAdapter.showNotification',
        severity: ErrorSeverity.error,
      );
      throw NotificationException('Failed to show notification', originalError: e);
    }
  }

  @override
  Future<void> cancelNotification(String id) async {
    await _ensureInitialized();

    try {
      await _plugin.cancel(id.hashCode);
      ErrorHandler.logInfo('Cancelled Android notification: $id');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AndroidNotificationAdapter.cancelNotification',
        severity: ErrorSeverity.warning,
      );
      throw NotificationException('Failed to cancel notification', originalError: e);
    }
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _ensureInitialized();

    try {
      await _plugin.cancelAll();
      ErrorHandler.logInfo('Cancelled all Android notifications');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AndroidNotificationAdapter.cancelAllNotifications',
        severity: ErrorSeverity.warning,
      );
      throw NotificationException('Failed to cancel all notifications', originalError: e);
    }
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    await _ensureInitialized();

    try {
      final androidImplementation = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation != null) {
        return await androidImplementation.areNotificationsEnabled() ?? false;
      }
      return false;
    } catch (e) {
      ErrorHandler.logWarning('Could not check notification status: $e');
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    await _ensureInitialized();

    try {
      final androidImplementation = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final result = await androidImplementation.requestNotificationsPermission();
        ErrorHandler.logInfo('Android notification permissions result: $result');
        return result ?? false;
      }
      return false;
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AndroidNotificationAdapter.requestPermissions',
        severity: ErrorSeverity.warning,
      );
      return false;
    }
  }

  @override
  NotificationConfig get platformConfig => _config;

  @override
  void setOnNotificationResponse(Function(AppNotificationResponse) callback) {
    _onNotificationResponse = callback;
  }

  @override
  bool get supportsActions => true;

  @override
  bool get supportsScheduling => true;

  @override
  Future<void> dispose() async {
    // Android plugin doesn't require explicit disposal
    _initialized = false;
    _onNotificationResponse = null;
    ErrorHandler.logInfo('AndroidNotificationAdapter disposed');
  }

  // Private helper methods
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  AndroidNotificationAction _mapAction(NotificationAction action) {
    return AndroidNotificationAction(
      action.id,
      action.title,
      icon: action.icon != null ? DrawableResourceAndroidBitmap(action.icon!) : null,
      inputs: action.type == NotificationActionType.textInput 
          ? [const AndroidNotificationActionInput(label: 'Reply')]
          : <AndroidNotificationActionInput>[],
    );
  }

  Importance _mapImportance(NotificationImportance importance) {
    switch (importance) {
      case NotificationImportance.min:
        return Importance.min;
      case NotificationImportance.low:
        return Importance.low;
      case NotificationImportance.defaultImportance:
        return Importance.defaultImportance;
      case NotificationImportance.high:
        return Importance.high;
      case NotificationImportance.max:
        return Importance.max;
    }
  }

  Priority _mapPriority(NotificationImportance importance) {
    switch (importance) {
      case NotificationImportance.min:
        return Priority.min;
      case NotificationImportance.low:
        return Priority.low;
      case NotificationImportance.defaultImportance:
        return Priority.defaultPriority;
      case NotificationImportance.high:
        return Priority.high;
      case NotificationImportance.max:
        return Priority.max;
    }
  }
}

/// Android-specific notification configuration
class AndroidNotificationConfig implements NotificationConfig {
  @override
  final String channelId;

  @override
  final String channelName;

  @override
  final String channelDescription;

  @override
  final String appName;

  @override
  final String appIcon;

  @override
  final bool enableVibration;

  @override
  final bool enableSound;

  @override
  final NotificationImportance importance;

  final bool enableLights;
  final String? ledColor;
  final String? soundPath;
  final bool showBadge;

  const AndroidNotificationConfig({
    required this.channelId,
    required this.channelName,
    required this.channelDescription,
    required this.appName,
    required this.appIcon,
    this.enableVibration = true,
    this.enableSound = true,
    this.importance = NotificationImportance.high,
    this.enableLights = true,
    this.ledColor,
    this.soundPath,
    this.showBadge = true,
  });

  static const AndroidNotificationConfig defaultConfig = AndroidNotificationConfig(
    channelId: 'health_reminder_channel',
    channelName: 'Health Reminders',
    channelDescription: 'Notifications for health and wellness reminders',
    appName: 'Zenu',
    appIcon: '@mipmap/ic_launcher',
  );
}