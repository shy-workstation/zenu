import 'dart:async';
import 'package:flutter/foundation.dart'; // For VoidCallback

/// Abstract system integration adapter for desktop-specific features
abstract class SystemAdapter {
  /// Initialize the system adapter
  Future<void> initialize();

  /// Window management operations
  Future<void> minimizeToTray();
  Future<void> showWindow();
  Future<void> hideWindow();
  Future<void> maximizeWindow();
  Future<void> restoreWindow();
  Future<void> centerWindow();
  Future<void> setWindowSize(int width, int height);
  Future<void> setWindowPosition(int x, int y);
  
  /// Window state queries
  Future<bool> isWindowVisible();
  Future<bool> isWindowMinimized();
  Future<bool> isWindowMaximized();
  Future<bool> isWindowFocused();
  Future<WindowInfo> getWindowInfo();

  /// System tray operations
  Future<void> createSystemTray();
  Future<void> updateSystemTray({
    String? tooltip,
    String? icon,
    List<SystemTrayMenuItem>? menu,
  });
  Future<void> removeSystemTray();
  Future<void> showTrayNotification({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  });

  /// Auto-start functionality
  Future<void> enableAutoStart();
  Future<void> disableAutoStart();
  Future<bool> isAutoStartEnabled();

  /// System notifications and alerts
  Future<void> showSystemDialog({
    required String title,
    required String message,
    SystemDialogType type = SystemDialogType.info,
    List<String> buttons = const ['OK'],
  });

  /// File system integration
  Future<void> openInFileExplorer(String path);
  Future<String?> selectFile({
    String? title,
    List<String>? allowedExtensions,
    String? initialDirectory,
  });
  Future<String?> selectDirectory({
    String? title,
    String? initialDirectory,
  });

  /// URL and protocol handling
  Future<void> registerProtocolHandler(String protocol);
  Future<void> unregisterProtocolHandler(String protocol);
  Future<void> openUrl(String url);

  /// System information
  Future<SystemInfo> getSystemInfo();
  Future<String> getPlatformVersion();
  Future<bool> isDarkModeEnabled();

  /// Power management
  Future<void> preventSleep();
  Future<void> allowSleep();
  Future<bool> isSleepPrevented();

  /// Hardware integration
  Future<void> playSystemSound(SystemSound sound);
  Future<void> vibrate({Duration duration = const Duration(milliseconds: 500)});

  /// Window event listeners
  void setOnWindowEvent(Function(WindowEvent) callback);
  void setOnSystemTrayEvent(Function(SystemTrayEvent) callback);

  /// Platform capabilities
  bool get supportsSystemTray;
  bool get supportsAutoStart;
  bool get supportsWindowManagement;
  bool get supportsPowerManagement;
  bool get supportsFileDialog;

  /// Configuration
  SystemAdapterConfig get config;

  /// Dispose resources
  Future<void> dispose();
}

/// Window information data class
class WindowInfo {
  final int x;
  final int y;
  final int width;
  final int height;
  final bool isVisible;
  final bool isMinimized;
  final bool isMaximized;
  final bool isFocused;
  final String title;

  const WindowInfo({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.isVisible,
    required this.isMinimized,
    required this.isMaximized,
    required this.isFocused,
    required this.title,
  });
}

/// System tray menu item definition
class SystemTrayMenuItem {
  final String id;
  final String label;
  final String? icon;
  final bool enabled;
  final bool visible;
  final SystemTrayMenuType type;
  final List<SystemTrayMenuItem>? submenu;
  final VoidCallback? onTap;

  const SystemTrayMenuItem({
    required this.id,
    required this.label,
    this.icon,
    this.enabled = true,
    this.visible = true,
    this.type = SystemTrayMenuType.normal,
    this.submenu,
    this.onTap,
  });

  factory SystemTrayMenuItem.separator() => const SystemTrayMenuItem(
        id: 'separator',
        label: '',
        type: SystemTrayMenuType.separator,
      );

  factory SystemTrayMenuItem.submenu({
    required String id,
    required String label,
    required List<SystemTrayMenuItem> items,
    String? icon,
    bool enabled = true,
  }) =>
      SystemTrayMenuItem(
        id: id,
        label: label,
        icon: icon,
        enabled: enabled,
        type: SystemTrayMenuType.submenu,
        submenu: items,
      );
}

/// System tray menu item types
enum SystemTrayMenuType {
  normal,
  separator,
  submenu,
  checkbox,
  radio,
}

/// System dialog types
enum SystemDialogType {
  info,
  warning,
  error,
  question,
}

/// System sounds
enum SystemSound {
  beep,
  error,
  warning,
  success,
  notification,
}

/// Window events
class WindowEvent {
  final WindowEventType type;
  final Map<String, dynamic>? data;

  const WindowEvent(this.type, [this.data]);
}

enum WindowEventType {
  shown,
  hidden,
  minimized,
  maximized,
  restored,
  moved,
  resized,
  focused,
  unfocused,
  closing,
  closed,
}

/// System tray events
class SystemTrayEvent {
  final SystemTrayEventType type;
  final String? menuItemId;
  final Map<String, dynamic>? data;

  const SystemTrayEvent(this.type, [this.menuItemId, this.data]);
}

enum SystemTrayEventType {
  leftClick,
  rightClick,
  doubleClick,
  menuItemSelected,
}

/// System information
class SystemInfo {
  final String operatingSystem;
  final String operatingSystemVersion;
  final String hostname;
  final int numberOfProcessors;
  final String pathSeparator;
  final Map<String, String> environment;
  final bool isDarkMode;
  final String locale;

  const SystemInfo({
    required this.operatingSystem,
    required this.operatingSystemVersion,
    required this.hostname,
    required this.numberOfProcessors,
    required this.pathSeparator,
    required this.environment,
    required this.isDarkMode,
    required this.locale,
  });
}

/// System adapter configuration
abstract class SystemAdapterConfig {
  String get appId;
  String get appName;
  String get appVersion;
  String get trayIconPath;
  Map<String, dynamic> get platformSettings;
}

/// Exception thrown when system operations fail
class SystemException implements Exception {
  final String message;
  final SystemErrorCode code;
  final dynamic originalError;

  const SystemException(
    this.message, {
    required this.code,
    this.originalError,
  });

  @override
  String toString() => 'SystemException: $message (Code: ${code.name})';
}

/// System error codes
enum SystemErrorCode {
  notSupported,
  permissionDenied,
  notInitialized,
  windowNotFound,
  trayUnavailable,
  fileNotFound,
  invalidArgument,
  unknown,
}