import 'dart:async';

/// Abstract notification adapter interface for platform-specific implementations
abstract class NotificationAdapter {
  /// Initialize the notification system
  Future<void> initialize();

  /// Schedule a notification for a specific reminder
  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    List<NotificationAction>? actions,
  });

  /// Show an immediate notification
  Future<void> showNotification({
    required String id,
    required String title,
    required String body,
    String? payload,
    List<NotificationAction>? actions,
  });

  /// Cancel a specific notification
  Future<void> cancelNotification(String id);

  /// Cancel all notifications
  Future<void> cancelAllNotifications();

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled();

  /// Request notification permissions (iOS/Android)
  Future<bool> requestPermissions();

  /// Get platform-specific configuration
  NotificationConfig get platformConfig;

  /// Handle notification response callbacks
  void setOnNotificationResponse(Function(AppNotificationResponse) callback);

  /// Check if the platform supports notification actions
  bool get supportsActions;

  /// Check if the platform supports scheduled notifications
  bool get supportsScheduling;

  /// Dispose resources
  Future<void> dispose();
}

/// Notification action definition
class NotificationAction {
  final String id;
  final String title;
  final String? icon;
  final NotificationActionType type;

  const NotificationAction({
    required this.id,
    required this.title,
    this.icon,
    this.type = NotificationActionType.button,
  });
}

/// Types of notification actions
enum NotificationActionType {
  button,
  textInput,
  destructive,
}

/// Notification response data
class AppNotificationResponse {
  final String id;
  final String? actionId;
  final String? payload;
  final String? input;
  final AppNotificationResponseType type;

  const AppNotificationResponse({
    required this.id,
    this.actionId,
    this.payload,
    this.input,
    required this.type,
  });
}

/// Types of notification responses
enum AppNotificationResponseType {
  selectedNotification,
  selectedNotificationAction,
}

/// Platform-specific notification configuration
abstract class NotificationConfig {
  String get channelId;
  String get channelName;
  String get channelDescription;
  String get appName;
  String get appIcon;
  bool get enableVibration;
  bool get enableSound;
  NotificationImportance get importance;
}

/// Notification importance levels
enum NotificationImportance {
  min,
  low,
  defaultImportance,
  high,
  max,
}

/// Exception thrown when notification operations fail
class NotificationException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const NotificationException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'NotificationException: $message${code != null ? ' (Code: $code)' : ''}';
}