import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../notification_adapter.dart';
import '../../utils/error_handler.dart';

/// iOS-specific notification adapter implementation
class IOSNotificationAdapter implements NotificationAdapter {
  late final FlutterLocalNotificationsPlugin _plugin;
  late final IOSNotificationConfig _config;
  Function(AppNotificationResponse)? _onNotificationResponse;
  bool _initialized = false;

  IOSNotificationAdapter([IOSNotificationConfig? config]) {
    _config = config ?? IOSNotificationConfig.defaultConfig;
    _plugin = FlutterLocalNotificationsPlugin();
  }

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final initializationSettings = DarwinInitializationSettings(
        requestAlertPermission: _config.requestAlertPermission,
        requestBadgePermission: _config.requestBadgePermission,
        requestSoundPermission: _config.requestSoundPermission,
        requestCriticalPermission: _config.requestCriticalPermission,
        requestProvisionalPermission: _config.requestProvisionalPermission,
        defaultPresentAlert: _config.defaultPresentAlert,
        defaultPresentBadge: _config.defaultPresentBadge,
        defaultPresentSound: _config.defaultPresentSound,
        notificationCategories: _config.categories.map(_mapCategory).toList(),
      );

      await _plugin.initialize(
        InitializationSettings(iOS: initializationSettings),
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

      _initialized = true;
      ErrorHandler.logInfo('IOSNotificationAdapter initialized successfully');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'IOSNotificationAdapter.initialize',
        severity: ErrorSeverity.error,
      );
      throw NotificationException('Failed to initialize iOS notifications',
          originalError: e);
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
      final iosDetails = DarwinNotificationDetails(
        presentAlert: _config.defaultPresentAlert,
        presentBadge: _config.defaultPresentBadge,
        presentSound: _config.defaultPresentSound,
        sound: _config.enableSound ? _config.soundPath : null,
        badgeNumber: _config.badgeNumber,
        categoryIdentifier:
            actions != null ? _getCategoryIdentifier(actions) : null,
        interruptionLevel: _mapInterruptionLevel(_config.interruptionLevel),
      );

      await _plugin.zonedSchedule(
        id.hashCode,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        NotificationDetails(iOS: iosDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      ErrorHandler.logInfo(
          'Scheduled iOS notification for ${scheduledTime.toIso8601String()}');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'IOSNotificationAdapter.scheduleNotification',
        severity: ErrorSeverity.error,
      );
      throw NotificationException('Failed to schedule notification',
          originalError: e);
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
      final iosDetails = DarwinNotificationDetails(
        presentAlert: _config.defaultPresentAlert,
        presentBadge: _config.defaultPresentBadge,
        presentSound: _config.defaultPresentSound,
        sound: _config.enableSound ? _config.soundPath : null,
        badgeNumber: _config.badgeNumber,
        categoryIdentifier:
            actions != null ? _getCategoryIdentifier(actions) : null,
        interruptionLevel: _mapInterruptionLevel(_config.interruptionLevel),
      );

      await _plugin.show(
        id.hashCode,
        title,
        body,
        NotificationDetails(iOS: iosDetails),
        payload: payload,
      );

      ErrorHandler.logInfo('Showed iOS notification: $title');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'IOSNotificationAdapter.showNotification',
        severity: ErrorSeverity.error,
      );
      throw NotificationException('Failed to show notification',
          originalError: e);
    }
  }

  @override
  Future<void> cancelNotification(String id) async {
    await _ensureInitialized();

    try {
      await _plugin.cancel(id.hashCode);
      ErrorHandler.logInfo('Cancelled iOS notification: $id');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'IOSNotificationAdapter.cancelNotification',
        severity: ErrorSeverity.warning,
      );
      throw NotificationException('Failed to cancel notification',
          originalError: e);
    }
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _ensureInitialized();

    try {
      await _plugin.cancelAll();
      ErrorHandler.logInfo('Cancelled all iOS notifications');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'IOSNotificationAdapter.cancelAllNotifications',
        severity: ErrorSeverity.warning,
      );
      throw NotificationException('Failed to cancel all notifications',
          originalError: e);
    }
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    await _ensureInitialized();

    try {
      final iosImplementation = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation != null) {
        final settings = await iosImplementation.checkPermissions();
        return settings?.isEnabled ?? false;
      }
      return false;
    } catch (e) {
      ErrorHandler.logWarning('Could not check iOS notification status: $e');
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    await _ensureInitialized();

    try {
      final iosImplementation = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation != null) {
        final result = await iosImplementation.requestPermissions(
          alert: _config.requestAlertPermission,
          badge: _config.requestBadgePermission,
          sound: _config.requestSoundPermission,
          critical: _config.requestCriticalPermission,
          provisional: _config.requestProvisionalPermission,
        );

        ErrorHandler.logInfo('iOS notification permissions result: $result');
        return result ?? false;
      }
      return false;
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'IOSNotificationAdapter.requestPermissions',
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
    // iOS plugin doesn't require explicit disposal
    _initialized = false;
    _onNotificationResponse = null;
    ErrorHandler.logInfo('IOSNotificationAdapter disposed');
  }

  // Private helper methods
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  DarwinNotificationCategory _mapCategory(IOSNotificationCategory category) {
    return DarwinNotificationCategory(
      category.identifier,
      actions: category.actions
          .map((action) => DarwinNotificationAction.plain(
                action.id,
                action.title,
                options: _mapActionOptions(action),
              ))
          .toList(),
      options: _mapCategoryOptions(category),
    );
  }

  Set<DarwinNotificationActionOption> _mapActionOptions(
      IOSNotificationActionConfig action) {
    final options = <DarwinNotificationActionOption>{};

    if (action.destructive) {
      options.add(DarwinNotificationActionOption.destructive);
    }
    if (action.foreground) {
      options.add(DarwinNotificationActionOption.foreground);
    }
    if (action.authenticationRequired) {
      options.add(DarwinNotificationActionOption.authenticationRequired);
    }

    return options;
  }

  Set<DarwinNotificationCategoryOption> _mapCategoryOptions(
      IOSNotificationCategory category) {
    final options = <DarwinNotificationCategoryOption>{};

    if (category.allowInCarPlay) {
      options.add(DarwinNotificationCategoryOption.allowInCarPlay);
    }
    if (category.allowAnnouncement) {
      options.add(DarwinNotificationCategoryOption.allowAnnouncement);
    }
    // Note: hiddenPreviewsShowTitle and hiddenPreviewsShowSubtitle are not available in current API

    return options;
  }

  InterruptionLevel _mapInterruptionLevel(IOSInterruptionLevel level) {
    switch (level) {
      case IOSInterruptionLevel.passive:
        return InterruptionLevel.passive;
      case IOSInterruptionLevel.active:
        return InterruptionLevel.active;
      case IOSInterruptionLevel.timeSensitive:
        return InterruptionLevel.timeSensitive;
      case IOSInterruptionLevel.critical:
        return InterruptionLevel.critical;
    }
  }

  String? _getCategoryIdentifier(List<NotificationAction> actions) {
    // Generate a category identifier based on actions
    final actionIds = actions.map((a) => a.id).join('_');
    return 'category_$actionIds';
  }
}

/// iOS-specific notification configuration
class IOSNotificationConfig implements NotificationConfig {
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

  // iOS-specific properties
  final bool requestAlertPermission;
  final bool requestBadgePermission;
  final bool requestSoundPermission;
  final bool requestCriticalPermission;
  final bool requestProvisionalPermission;
  final bool defaultPresentAlert;
  final bool defaultPresentBadge;
  final bool defaultPresentSound;
  final String? soundPath;
  final int? badgeNumber;
  final IOSInterruptionLevel interruptionLevel;
  final List<IOSNotificationCategory> categories;

  const IOSNotificationConfig({
    required this.channelId,
    required this.channelName,
    required this.channelDescription,
    required this.appName,
    required this.appIcon,
    this.enableVibration = true,
    this.enableSound = true,
    this.importance = NotificationImportance.high,
    this.requestAlertPermission = true,
    this.requestBadgePermission = true,
    this.requestSoundPermission = true,
    this.requestCriticalPermission = false,
    this.requestProvisionalPermission = false,
    this.defaultPresentAlert = true,
    this.defaultPresentBadge = true,
    this.defaultPresentSound = true,
    this.soundPath,
    this.badgeNumber,
    this.interruptionLevel = IOSInterruptionLevel.active,
    this.categories = const [],
  });

  static const IOSNotificationConfig defaultConfig = IOSNotificationConfig(
    channelId: 'health_reminder_channel',
    channelName: 'Health Reminders',
    channelDescription: 'Notifications for health and wellness reminders',
    appName: 'Zenu',
    appIcon: 'app_icon',
  );
}

/// iOS notification category configuration
class IOSNotificationCategory {
  final String identifier;
  final List<IOSNotificationActionConfig> actions;
  final bool allowInCarPlay;
  final bool allowAnnouncement;
  final bool hiddenPreviewsShowTitle;
  final bool hiddenPreviewsShowSubtitle;

  const IOSNotificationCategory({
    required this.identifier,
    required this.actions,
    this.allowInCarPlay = false,
    this.allowAnnouncement = true,
    this.hiddenPreviewsShowTitle = false,
    this.hiddenPreviewsShowSubtitle = false,
  });
}

/// iOS notification action configuration
class IOSNotificationActionConfig {
  final String id;
  final String title;
  final bool destructive;
  final bool foreground;
  final bool authenticationRequired;

  const IOSNotificationActionConfig({
    required this.id,
    required this.title,
    this.destructive = false,
    this.foreground = false,
    this.authenticationRequired = false,
  });
}

/// iOS interruption levels
enum IOSInterruptionLevel {
  passive,
  active,
  timeSensitive,
  critical,
}
