import 'dart:async';
import 'platform_adapter_factory.dart';
import 'notification_adapter.dart';
import 'storage_adapter.dart';
import 'system_adapter.dart';
import '../utils/error_handler.dart';

/// Service class that provides a unified interface to all platform adapters
class AdapterService {
  static AdapterService? _instance;
  late final PlatformAdapters _adapters;
  bool _initialized = false;

  AdapterService._();

  /// Get singleton instance of the adapter service
  static Future<AdapterService> getInstance() async {
    if (_instance == null) {
      _instance = AdapterService._();
      await _instance!._initialize();
    }
    return _instance!;
  }

  /// Initialize the adapter service with platform-specific adapters
  Future<void> _initialize() async {
    if (_initialized) return;

    try {
      // Get platform information
      final platformInfo = PlatformAdapterFactory.getPlatformInfo();
      ErrorHandler.logInfo('Initializing adapters for platform: ${platformInfo.operatingSystem}');
      ErrorHandler.logInfo('Platform capabilities: ${platformInfo.capabilities.toString()}');

      // Create platform-specific adapters
      _adapters = PlatformAdapterFactory.createAllAdapters(
        notificationConfig: PlatformAdapterFactory.getDefaultNotificationConfig(),
        storageConfig: PlatformAdapterFactory.getDefaultStorageConfig(),
        systemConfig: PlatformAdapterFactory.getDefaultSystemConfig(),
        preferredStorageType: StorageAdapterType.sharedPreferences,
      );

      // Initialize all adapters
      await _adapters.initializeAll();

      _initialized = true;
      ErrorHandler.logInfo('AdapterService initialized successfully');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AdapterService._initialize',
        severity: ErrorSeverity.critical,
      );
      throw AdapterException('Failed to initialize adapter service', originalError: e);
    }
  }

  /// Get the notification adapter
  NotificationAdapter get notifications {
    _ensureInitialized();
    return _adapters.notification;
  }

  /// Get the storage adapter
  StorageAdapter get storage {
    _ensureInitialized();
    return _adapters.storage;
  }

  /// Get the system adapter (null on mobile platforms)
  SystemAdapter? get system {
    _ensureInitialized();
    return _adapters.system;
  }

  /// Get platform capabilities
  PlatformCapabilities get capabilities => PlatformAdapterFactory.getPlatformCapabilities();

  /// Get platform information
  PlatformInfo get platformInfo => PlatformAdapterFactory.getPlatformInfo();

  /// Check if a specific adapter type is supported
  bool supportsAdapter(AdapterType type) => PlatformAdapterFactory.supportsAdapterType(type);

  // High-level convenience methods

  /// Show a notification with automatic platform handling
  Future<void> showNotification({
    required String id,
    required String title,
    required String body,
    String? payload,
    List<NotificationAction>? actions,
  }) async {
    try {
      await notifications.showNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
        actions: actions,
      );
      ErrorHandler.logInfo('Notification shown: $title');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AdapterService.showNotification',
        severity: ErrorSeverity.error,
        metadata: {'title': title, 'id': id},
      );
      rethrow;
    }
  }

  /// Schedule a notification with automatic platform handling
  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    List<NotificationAction>? actions,
  }) async {
    try {
      if (!capabilities.supportsScheduledNotifications) {
        throw AdapterException('Scheduled notifications not supported on this platform');
      }

      await notifications.scheduleNotification(
        id: id,
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        payload: payload,
        actions: actions,
      );
      ErrorHandler.logInfo('Notification scheduled: $title for ${scheduledTime.toIso8601String()}');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AdapterService.scheduleNotification',
        severity: ErrorSeverity.error,
        metadata: {'title': title, 'scheduledTime': scheduledTime.toIso8601String()},
      );
      rethrow;
    }
  }

  /// Save data with automatic serialization
  Future<void> saveData<T>(String key, T value) async {
    try {
      await storage.save(key, value);
      ErrorHandler.logInfo('Data saved: $key');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AdapterService.saveData',
        severity: ErrorSeverity.error,
        metadata: {'key': key, 'valueType': T.toString()},
      );
      rethrow;
    }
  }

  /// Load data with automatic deserialization
  Future<T?> loadData<T>(String key) async {
    try {
      final value = await storage.get<T>(key);
      if (value != null) {
        ErrorHandler.logInfo('Data loaded: $key');
      }
      return value;
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AdapterService.loadData',
        severity: ErrorSeverity.warning,
        metadata: {'key': key, 'expectedType': T.toString()},
      );
      return null;
    }
  }

  /// Save secure data (encrypted if supported)
  Future<void> saveSecureData(String key, String value) async {
    try {
      await storage.saveSecure(key, value);
      ErrorHandler.logInfo('Secure data saved: $key');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AdapterService.saveSecureData',
        severity: ErrorSeverity.error,
        metadata: {'key': key},
      );
      rethrow;
    }
  }

  /// Load secure data
  Future<String?> loadSecureData(String key) async {
    try {
      final value = await storage.getSecure(key);
      if (value != null) {
        ErrorHandler.logInfo('Secure data loaded: $key');
      }
      return value;
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AdapterService.loadSecureData',
        severity: ErrorSeverity.warning,
        metadata: {'key': key},
      );
      return null;
    }
  }

  /// Show window (desktop only)
  Future<void> showWindow() async {
    if (system == null) {
      ErrorHandler.logWarning('System adapter not available on this platform');
      return;
    }

    try {
      await system!.showWindow();
      ErrorHandler.logInfo('Window shown');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AdapterService.showWindow',
        severity: ErrorSeverity.warning,
      );
      rethrow;
    }
  }

  /// Hide window (desktop only)
  Future<void> hideWindow() async {
    if (system == null) {
      ErrorHandler.logWarning('System adapter not available on this platform');
      return;
    }

    try {
      await system!.hideWindow();
      ErrorHandler.logInfo('Window hidden');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AdapterService.hideWindow',
        severity: ErrorSeverity.warning,
      );
      rethrow;
    }
  }

  /// Minimize to system tray (desktop only)
  Future<void> minimizeToTray() async {
    if (system == null) {
      ErrorHandler.logWarning('System adapter not available on this platform');
      return;
    }

    try {
      if (!capabilities.supportsSystemTray) {
        ErrorHandler.logWarning('System tray not supported on this platform');
        await hideWindow();
        return;
      }

      await system!.minimizeToTray();
      ErrorHandler.logInfo('Minimized to system tray');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AdapterService.minimizeToTray',
        severity: ErrorSeverity.warning,
      );
      // Fallback to hiding window
      await hideWindow();
    }
  }

  /// Setup system tray with menu (desktop only)
  Future<void> setupSystemTray({
    String? tooltip,
    String? icon,
    List<SystemTrayMenuItem>? menu,
  }) async {
    if (system == null || !capabilities.supportsSystemTray) {
      ErrorHandler.logWarning('System tray not supported on this platform');
      return;
    }

    try {
      await system!.createSystemTray();
      await system!.updateSystemTray(
        tooltip: tooltip,
        icon: icon,
        menu: menu,
      );
      ErrorHandler.logInfo('System tray setup completed');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AdapterService.setupSystemTray',
        severity: ErrorSeverity.warning,
      );
      rethrow;
    }
  }

  /// Export all storage data
  Future<String> exportAllData() async {
    try {
      return await storage.exportData();
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AdapterService.exportAllData',
        severity: ErrorSeverity.error,
      );
      rethrow;
    }
  }

  /// Import storage data
  Future<void> importAllData(String data) async {
    try {
      await storage.importData(data);
      ErrorHandler.logInfo('Data import completed');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AdapterService.importAllData',
        severity: ErrorSeverity.error,
      );
      rethrow;
    }
  }

  /// Get storage information and statistics
  Future<StorageInfo> getStorageInfo() async {
    try {
      return await storage.getStorageInfo();
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AdapterService.getStorageInfo',
        severity: ErrorSeverity.warning,
      );
      rethrow;
    }
  }

  /// Clear all stored data
  Future<void> clearAllData() async {
    try {
      await storage.clear();
      ErrorHandler.logInfo('All data cleared');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AdapterService.clearAllData',
        severity: ErrorSeverity.error,
      );
      rethrow;
    }
  }

  /// Setup notification response handlers
  void setupNotificationHandlers({
    required Function(AppNotificationResponse) onNotificationResponse,
  }) {
    try {
      notifications.setOnNotificationResponse(onNotificationResponse);
      ErrorHandler.logInfo('Notification handlers setup completed');
    } catch (e, stackTrace) {
      ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AdapterService.setupNotificationHandlers',
        severity: ErrorSeverity.warning,
      );
    }
  }

  /// Setup window event handlers (desktop only)
  void setupWindowHandlers({
    Function(WindowEvent)? onWindowEvent,
  }) {
    if (system == null) {
      return;
    }

    try {
      if (onWindowEvent != null) {
        system!.setOnWindowEvent(onWindowEvent);
      }
      ErrorHandler.logInfo('Window handlers setup completed');
    } catch (e, stackTrace) {
      ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AdapterService.setupWindowHandlers',
        severity: ErrorSeverity.warning,
      );
    }
  }

  /// Dispose all adapters and clean up resources
  Future<void> dispose() async {
    if (!_initialized) return;

    try {
      await _adapters.disposeAll();
      _initialized = false;
      _instance = null;
      ErrorHandler.logInfo('AdapterService disposed');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AdapterService.dispose',
        severity: ErrorSeverity.warning,
      );
    }
  }

  // Private helper methods
  void _ensureInitialized() {
    if (!_initialized) {
      throw AdapterException('AdapterService not initialized. Call getInstance() first.');
    }
  }
}

/// Exception thrown when adapter operations fail
class AdapterException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AdapterException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AdapterException: $message${code != null ? ' (Code: $code)' : ''}';
}