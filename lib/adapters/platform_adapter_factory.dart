import 'dart:io';
import 'notification_adapter.dart';
import 'storage_adapter.dart';
import 'system_adapter.dart';
import 'implementations/android_notification_adapter.dart';
import 'implementations/ios_notification_adapter.dart';
import 'implementations/desktop_notification_adapter.dart';
import 'implementations/shared_preferences_storage_adapter.dart';
import 'implementations/desktop_system_adapter.dart';
import '../utils/error_handler.dart';

/// Factory class for creating platform-specific adapter implementations
class PlatformAdapterFactory {
  static const String _logContext = 'PlatformAdapterFactory';

  /// Creates a notification adapter based on the current platform
  static NotificationAdapter createNotificationAdapter({
    NotificationConfig? config,
  }) {
    try {
      if (Platform.isAndroid) {
        ErrorHandler.logInfo('Creating Android notification adapter');
        return AndroidNotificationAdapter(
          config as AndroidNotificationConfig?,
        );
      } else if (Platform.isIOS) {
        ErrorHandler.logInfo('Creating iOS notification adapter');
        return IOSNotificationAdapter(
          config as IOSNotificationConfig?,
        );
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        ErrorHandler.logInfo('Creating desktop notification adapter for ${Platform.operatingSystem}');
        return DesktopNotificationAdapter(
          config as DesktopNotificationConfig?,
        );
      } else {
        ErrorHandler.logWarning('Unsupported platform for notifications: ${Platform.operatingSystem}');
        throw UnsupportedError('Notifications not supported on ${Platform.operatingSystem}');
      }
    } catch (e, stackTrace) {
      ErrorHandler.handleError(
        e,
        stackTrace,
        context: '$_logContext.createNotificationAdapter',
        severity: ErrorSeverity.error,
      );
      rethrow;
    }
  }

  /// Creates a storage adapter based on the current platform and preferences
  static StorageAdapter createStorageAdapter({
    StorageConfig? config,
    StorageAdapterType? preferredType,
  }) {
    try {
      final adapterType = preferredType ?? _getDefaultStorageAdapterType();
      
      switch (adapterType) {
        case StorageAdapterType.sharedPreferences:
          ErrorHandler.logInfo('Creating SharedPreferences storage adapter');
          return SharedPreferencesStorageAdapter(
            config as SharedPreferencesStorageConfig?,
          );
        
        // Add other storage adapter types here as needed
        // case StorageAdapterType.sqflite:
        //   return SqfliteStorageAdapter(config);
        // case StorageAdapterType.hive:
        //   return HiveStorageAdapter(config);
        // case StorageAdapterType.secureStorage:
        //   return SecureStorageAdapter(config);
        
        default:
          ErrorHandler.logWarning('Unknown storage adapter type: $adapterType, falling back to SharedPreferences');
          return SharedPreferencesStorageAdapter(
            config as SharedPreferencesStorageConfig?,
          );
      }
    } catch (e, stackTrace) {
      ErrorHandler.handleError(
        e,
        stackTrace,
        context: '$_logContext.createStorageAdapter',
        severity: ErrorSeverity.error,
      );
      rethrow;
    }
  }

  /// Creates a system adapter based on the current platform
  static SystemAdapter? createSystemAdapter({
    SystemAdapterConfig? config,
  }) {
    try {
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        ErrorHandler.logInfo('Creating desktop system adapter for ${Platform.operatingSystem}');
        return DesktopSystemAdapter(
          config as DesktopSystemAdapterConfig?,
        );
      } else if (Platform.isAndroid || Platform.isIOS) {
        ErrorHandler.logInfo('System adapter not available for mobile platforms (${Platform.operatingSystem})');
        return null; // Mobile platforms don't need system adapters for window management
      } else {
        ErrorHandler.logWarning('Unsupported platform for system adapter: ${Platform.operatingSystem}');
        return null;
      }
    } catch (e, stackTrace) {
      ErrorHandler.handleError(
        e,
        stackTrace,
        context: '$_logContext.createSystemAdapter',
        severity: ErrorSeverity.error,
      );
      return null;
    }
  }

  /// Creates all supported adapters for the current platform
  static PlatformAdapters createAllAdapters({
    NotificationConfig? notificationConfig,
    StorageConfig? storageConfig,
    SystemAdapterConfig? systemConfig,
    StorageAdapterType? preferredStorageType,
  }) {
    try {
      ErrorHandler.logInfo('Creating all platform adapters for ${Platform.operatingSystem}');
      
      return PlatformAdapters(
        notification: createNotificationAdapter(config: notificationConfig),
        storage: createStorageAdapter(
          config: storageConfig,
          preferredType: preferredStorageType,
        ),
        system: createSystemAdapter(config: systemConfig),
      );
    } catch (e, stackTrace) {
      ErrorHandler.handleError(
        e,
        stackTrace,
        context: '$_logContext.createAllAdapters',
        severity: ErrorSeverity.error,
      );
      rethrow;
    }
  }

  /// Gets the default notification configuration for the current platform
  static NotificationConfig getDefaultNotificationConfig() {
    if (Platform.isAndroid) {
      return AndroidNotificationConfig.defaultConfig;
    } else if (Platform.isIOS) {
      return IOSNotificationConfig.defaultConfig;
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return DesktopNotificationConfig.defaultConfig;
    } else {
      throw UnsupportedError('No default notification config for ${Platform.operatingSystem}');
    }
  }

  /// Gets the default storage configuration for the current platform
  static StorageConfig getDefaultStorageConfig() {
    return SharedPreferencesStorageConfig.defaultConfig;
  }

  /// Gets the default system configuration for the current platform
  static SystemAdapterConfig? getDefaultSystemConfig() {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return DesktopSystemAdapterConfig.defaultConfig;
    }
    return null; // Mobile platforms don't have system configs
  }

  /// Checks if the current platform supports the specified adapter type
  static bool supportsAdapterType(AdapterType type) {
    switch (type) {
      case AdapterType.notification:
        return Platform.isAndroid || Platform.isIOS || _isDesktop();
      case AdapterType.storage:
        return true; // All platforms support storage
      case AdapterType.system:
        return _isDesktop(); // Only desktop platforms support system adapters
    }
  }

  /// Gets platform-specific capabilities
  static PlatformCapabilities getPlatformCapabilities() {
    return PlatformCapabilities(
      hasNotifications: supportsAdapterType(AdapterType.notification),
      hasStorage: supportsAdapterType(AdapterType.storage),
      hasSystemIntegration: supportsAdapterType(AdapterType.system),
      supportsScheduledNotifications: _supportsScheduledNotifications(),
      supportsNotificationActions: _supportsNotificationActions(),
      supportsSystemTray: _supportsSystemTray(),
      supportsWindowManagement: _supportsWindowManagement(),
      supportsAutoStart: _supportsAutoStart(),
      supportsFileDialog: _supportsFileDialog(),
      platform: _getCurrentPlatform(),
    );
  }

  /// Gets detailed platform information
  static PlatformInfo getPlatformInfo() {
    return PlatformInfo(
      operatingSystem: Platform.operatingSystem,
      operatingSystemVersion: Platform.operatingSystemVersion,
      isDesktop: _isDesktop(),
      isMobile: _isMobile(),
      isAndroid: Platform.isAndroid,
      isIOS: Platform.isIOS,
      isWindows: Platform.isWindows,
      isMacOS: Platform.isMacOS,
      isLinux: Platform.isLinux,
      capabilities: getPlatformCapabilities(),
    );
  }

  // Private helper methods

  static bool _isDesktop() => 
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  static bool _isMobile() => 
      Platform.isAndroid || Platform.isIOS;

  static StorageAdapterType _getDefaultStorageAdapterType() {
    // For now, we only have SharedPreferences
    // In the future, you might choose different storage types based on platform
    return StorageAdapterType.sharedPreferences;
  }

  static bool _supportsScheduledNotifications() {
    return Platform.isAndroid || Platform.isIOS || _isDesktop();
  }

  static bool _supportsNotificationActions() {
    return Platform.isAndroid || Platform.isIOS || _isDesktop();
  }

  static bool _supportsSystemTray() {
    return _isDesktop();
  }

  static bool _supportsWindowManagement() {
    return _isDesktop();
  }

  static bool _supportsAutoStart() {
    return _isDesktop();
  }

  static bool _supportsFileDialog() {
    return _isDesktop();
  }

  static PlatformType _getCurrentPlatform() {
    if (Platform.isAndroid) return PlatformType.android;
    if (Platform.isIOS) return PlatformType.ios;
    if (Platform.isWindows) return PlatformType.windows;
    if (Platform.isMacOS) return PlatformType.macos;
    if (Platform.isLinux) return PlatformType.linux;
    return PlatformType.unknown;
  }
}

/// Container class for all platform adapters
class PlatformAdapters {
  final NotificationAdapter notification;
  final StorageAdapter storage;
  final SystemAdapter? system;

  const PlatformAdapters({
    required this.notification,
    required this.storage,
    this.system,
  });

  /// Initializes all adapters
  Future<void> initializeAll() async {
    await notification.initialize();
    await storage.initialize();
    await system?.initialize();
    
    ErrorHandler.logInfo('All platform adapters initialized successfully');
  }

  /// Disposes all adapters
  Future<void> disposeAll() async {
    await notification.dispose();
    await storage.dispose();
    await system?.dispose();
    
    ErrorHandler.logInfo('All platform adapters disposed');
  }
}

/// Platform capabilities information
class PlatformCapabilities {
  final bool hasNotifications;
  final bool hasStorage;
  final bool hasSystemIntegration;
  final bool supportsScheduledNotifications;
  final bool supportsNotificationActions;
  final bool supportsSystemTray;
  final bool supportsWindowManagement;
  final bool supportsAutoStart;
  final bool supportsFileDialog;
  final PlatformType platform;

  const PlatformCapabilities({
    required this.hasNotifications,
    required this.hasStorage,
    required this.hasSystemIntegration,
    required this.supportsScheduledNotifications,
    required this.supportsNotificationActions,
    required this.supportsSystemTray,
    required this.supportsWindowManagement,
    required this.supportsAutoStart,
    required this.supportsFileDialog,
    required this.platform,
  });
}

/// Detailed platform information
class PlatformInfo {
  final String operatingSystem;
  final String operatingSystemVersion;
  final bool isDesktop;
  final bool isMobile;
  final bool isAndroid;
  final bool isIOS;
  final bool isWindows;
  final bool isMacOS;
  final bool isLinux;
  final PlatformCapabilities capabilities;

  const PlatformInfo({
    required this.operatingSystem,
    required this.operatingSystemVersion,
    required this.isDesktop,
    required this.isMobile,
    required this.isAndroid,
    required this.isIOS,
    required this.isWindows,
    required this.isMacOS,
    required this.isLinux,
    required this.capabilities,
  });

  @override
  String toString() {
    return 'PlatformInfo(os: $operatingSystem, version: $operatingSystemVersion, '
           'desktop: $isDesktop, mobile: $isMobile)';
  }
}

/// Supported adapter types
enum AdapterType {
  notification,
  storage,
  system,
}

/// Supported storage adapter types
enum StorageAdapterType {
  sharedPreferences,
  sqflite,
  hive,
  secureStorage,
}

/// Platform types
enum PlatformType {
  android,
  ios,
  windows,
  macos,
  linux,
  unknown,
}