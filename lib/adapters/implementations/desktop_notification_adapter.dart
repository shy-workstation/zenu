import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../notification_adapter.dart';
import '../../utils/error_handler.dart';

/// Desktop-specific notification adapter implementation (Windows, macOS, Linux)
class DesktopNotificationAdapter implements NotificationAdapter {
  late final FlutterLocalNotificationsPlugin _plugin;
  late final DesktopNotificationConfig _config;
  Function(AppNotificationResponse)? _onNotificationResponse;
  bool _initialized = false;

  DesktopNotificationAdapter([DesktopNotificationConfig? config]) {
    _config = config ?? DesktopNotificationConfig.defaultConfig;
    _plugin = FlutterLocalNotificationsPlugin();
  }

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      InitializationSettings? initializationSettings;

      if (Platform.isWindows) {
        initializationSettings = InitializationSettings(
          windows: WindowsInitializationSettings(
            appName: _config.appName,
            appUserModelId: _config.appUserModelId ?? _config.appName,
            guid: _config.guid ?? 'com.zenuwellness.app',
          ),
        );
      } else if (Platform.isMacOS) {
        initializationSettings = InitializationSettings(
          macOS: DarwinInitializationSettings(
            requestAlertPermission: _config.requestPermissions,
            requestBadgePermission: _config.requestPermissions,
            requestSoundPermission: _config.requestPermissions,
            defaultPresentAlert: true,
            defaultPresentBadge: true,
            defaultPresentSound: true,
          ),
        );
      } else if (Platform.isLinux) {
        initializationSettings = InitializationSettings(
          linux: LinuxInitializationSettings(
            defaultActionName: 'Open App',
            defaultIcon: AssetsLinuxIcon(_config.appIcon),
          ),
        );
      }

      if (initializationSettings != null) {
        await _plugin.initialize(
          initializationSettings,
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
        ErrorHandler.logInfo('DesktopNotificationAdapter initialized successfully for ${Platform.operatingSystem}');
      } else {
        throw NotificationException('Unsupported desktop platform: ${Platform.operatingSystem}');
      }
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'DesktopNotificationAdapter.initialize',
        severity: ErrorSeverity.error,
      );
      throw NotificationException('Failed to initialize desktop notifications', originalError: e);
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
      NotificationDetails? notificationDetails;

      if (Platform.isWindows) {
        notificationDetails = NotificationDetails(
          windows: WindowsNotificationDetails(
            actions: actions?.map(_mapWindowsAction).toList() ?? <WindowsAction>[],
            // Note: duration and icon parameters may not be available in current API
          ),
        );
      } else if (Platform.isMacOS) {
        notificationDetails = NotificationDetails(
          macOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: _config.enableSound,
            sound: _config.enableSound ? _config.soundPath : null,
          ),
        );
      } else if (Platform.isLinux) {
        notificationDetails = NotificationDetails(
          linux: LinuxNotificationDetails(
            actions: actions?.map(_mapLinuxAction).toList() ?? <LinuxNotificationAction>[],
            icon: AssetsLinuxIcon(_config.appIcon),
            sound: _config.enableSound 
                ? AssetsLinuxSound(_config.soundPath ?? 'sounds/notification.wav')
                : null,
            timeout: LinuxNotificationTimeout.fromDuration(_config.duration),
          ),
        );
      }

      if (notificationDetails != null) {
        await _plugin.zonedSchedule(
          id.hashCode,
          title,
          body,
          tz.TZDateTime.from(scheduledTime, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: payload,
        );

        ErrorHandler.logInfo('Scheduled desktop notification for ${scheduledTime.toIso8601String()}');
      }
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'DesktopNotificationAdapter.scheduleNotification',
        severity: ErrorSeverity.error,
      );
      throw NotificationException('Failed to schedule desktop notification', originalError: e);
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
      NotificationDetails? notificationDetails;

      if (Platform.isWindows) {
        notificationDetails = NotificationDetails(
          windows: WindowsNotificationDetails(
            actions: actions?.map(_mapWindowsAction).toList() ?? <WindowsAction>[],
            // Note: duration and icon parameters may not be available in current API
          ),
        );
      } else if (Platform.isMacOS) {
        notificationDetails = NotificationDetails(
          macOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: _config.enableSound,
            sound: _config.enableSound ? _config.soundPath : null,
          ),
        );
      } else if (Platform.isLinux) {
        notificationDetails = NotificationDetails(
          linux: LinuxNotificationDetails(
            actions: actions?.map(_mapLinuxAction).toList() ?? <LinuxNotificationAction>[],
            icon: AssetsLinuxIcon(_config.appIcon),
            sound: _config.enableSound 
                ? AssetsLinuxSound(_config.soundPath ?? 'sounds/notification.wav')
                : null,
            timeout: LinuxNotificationTimeout.fromDuration(_config.duration),
          ),
        );
      }

      if (notificationDetails != null) {
        await _plugin.show(
          id.hashCode,
          title,
          body,
          notificationDetails,
          payload: payload,
        );

        ErrorHandler.logInfo('Showed desktop notification: $title');
      }
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'DesktopNotificationAdapter.showNotification',
        severity: ErrorSeverity.error,
      );
      throw NotificationException('Failed to show desktop notification', originalError: e);
    }
  }

  @override
  Future<void> cancelNotification(String id) async {
    await _ensureInitialized();

    try {
      await _plugin.cancel(id.hashCode);
      ErrorHandler.logInfo('Cancelled desktop notification: $id');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'DesktopNotificationAdapter.cancelNotification',
        severity: ErrorSeverity.warning,
      );
      throw NotificationException('Failed to cancel desktop notification', originalError: e);
    }
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _ensureInitialized();

    try {
      await _plugin.cancelAll();
      ErrorHandler.logInfo('Cancelled all desktop notifications');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'DesktopNotificationAdapter.cancelAllNotifications',
        severity: ErrorSeverity.warning,
      );
      throw NotificationException('Failed to cancel all desktop notifications', originalError: e);
    }
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    await _ensureInitialized();

    try {
      // Desktop platforms typically don't have a reliable way to check notification permissions
      // We assume they're enabled if initialization was successful
      return _initialized;
    } catch (e) {
      ErrorHandler.logWarning('Could not check desktop notification status: $e');
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    await _ensureInitialized();

    try {
      if (Platform.isMacOS) {
        final macosImplementation = _plugin.resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>();

        if (macosImplementation != null) {
          final result = await macosImplementation.requestPermissions(
            alert: _config.requestPermissions,
            badge: _config.requestPermissions,
            sound: _config.requestPermissions,
          );
          
          ErrorHandler.logInfo('macOS notification permissions result: $result');
          return result ?? true;
        }
      }
      
      // For Windows and Linux, permissions are typically granted by default
      return true;
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'DesktopNotificationAdapter.requestPermissions',
        severity: ErrorSeverity.warning,
      );
      return true; // Assume granted for desktop platforms
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
    _initialized = false;
    _onNotificationResponse = null;
    ErrorHandler.logInfo('DesktopNotificationAdapter disposed');
  }

  // Private helper methods
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  WindowsAction _mapWindowsAction(NotificationAction action) {
    return WindowsAction(
      content: action.title,
      arguments: action.id,
      activationType: action.type == NotificationActionType.textInput
          ? WindowsActivationType.protocol
          : WindowsActivationType.foreground,
    );
  }

  LinuxNotificationAction _mapLinuxAction(NotificationAction action) {
    return LinuxNotificationAction(
      key: action.id,
      label: action.title,
    );
  }
}

/// Desktop-specific notification configuration
class DesktopNotificationConfig implements NotificationConfig {
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

  // Desktop-specific properties
  final String? appUserModelId;
  final String? guid;
  final bool requestPermissions;
  final Duration duration;
  final String? largeIcon;
  final String? image;
  final String? soundPath;

  const DesktopNotificationConfig({
    required this.channelId,
    required this.channelName,
    required this.channelDescription,
    required this.appName,
    required this.appIcon,
    this.enableVibration = false, // Not supported on desktop
    this.enableSound = true,
    this.importance = NotificationImportance.high,
    this.appUserModelId,
    this.guid,
    this.requestPermissions = true,
    this.duration = const Duration(seconds: 5),
    this.largeIcon,
    this.image,
    this.soundPath,
  });

  static const DesktopNotificationConfig defaultConfig = DesktopNotificationConfig(
    channelId: 'health_reminder_channel',
    channelName: 'Health Reminders',
    channelDescription: 'Notifications for health and wellness reminders',
    appName: 'Zenu',
    appIcon: 'assets/icon/app_icon_zenu.png',
    appUserModelId: 'YousofShehada.Zenu',
    guid: 'BE46DC6D-FD4E-4ABB-A08C-68EABDEC1169',
  );
}