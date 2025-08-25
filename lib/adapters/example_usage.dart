import 'dart:async';
import 'adapter_service.dart';
import 'notification_adapter.dart';
import 'storage_adapter.dart';
import 'system_adapter.dart';
import '../models/reminder.dart';
import '../utils/error_handler.dart';

/// Example usage of the platform adapter pattern
class AdapterUsageExample {
  late final AdapterService _adapterService;
  StreamSubscription<void>? _storageListener;

  /// Initialize the adapter service and setup handlers
  Future<void> initialize() async {
    try {
      // Get the adapter service instance
      _adapterService = await AdapterService.getInstance();

      // Setup notification handlers
      _setupNotificationHandlers();

      // Setup window handlers (desktop only)
      _setupWindowHandlers();

      // Setup storage listeners
      _setupStorageListeners();

      // Setup system tray (desktop only)
      await _setupSystemTray();

      ErrorHandler.logInfo('AdapterUsageExample initialized successfully');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AdapterUsageExample.initialize',
        severity: ErrorSeverity.error,
      );
      rethrow;
    }
  }

  /// Example: Working with notifications
  Future<void> demonstrateNotifications() async {
    ErrorHandler.logInfo('=== Notification Examples ===');

    try {
      // Check if notifications are supported
      if (!_adapterService.capabilities.hasNotifications) {
        ErrorHandler.logInfo('Notifications not supported on this platform');
        return;
      }

      // Request notification permissions
      final permissionGranted = await _adapterService.notifications.requestPermissions();
      ErrorHandler.logInfo('Notification permissions granted: $permissionGranted');

      // Show an immediate notification
      await _adapterService.showNotification(
        id: 'test_notification',
        title: 'Test Notification',
        body: 'This is a test notification from the adapter pattern!',
        payload: 'test_payload',
        actions: [
          const NotificationAction(
            id: 'action_ok',
            title: 'OK',
            type: NotificationActionType.button,
          ),
          const NotificationAction(
            id: 'action_cancel',
            title: 'Cancel',
            type: NotificationActionType.button,
          ),
        ],
      );

      // Schedule a notification for the future (if supported)
      if (_adapterService.capabilities.supportsScheduledNotifications) {
        final futureTime = DateTime.now().add(const Duration(minutes: 1));
        await _adapterService.scheduleNotification(
          id: 'scheduled_notification',
          title: 'Scheduled Notification',
          body: 'This notification was scheduled!',
          scheduledTime: futureTime,
        );
        ErrorHandler.logInfo('Notification scheduled for: ${futureTime.toIso8601String()}');
      }

      // Create a health reminder notification
      await _createHealthReminderNotification();

    } catch (e) {
      ErrorHandler.logInfo('Error demonstrating notifications: $e');
    }
  }

  /// Example: Working with storage
  Future<void> demonstrateStorage() async {
    ErrorHandler.logInfo('\n=== Storage Examples ===');

    try {
      // Save different types of data
      await _adapterService.saveData('user_name', 'John Doe');
      await _adapterService.saveData('user_age', 30);
      await _adapterService.saveData('is_premium', true);
      await _adapterService.saveData('settings', {
        'theme': 'dark',
        'language': 'en',
        'notifications_enabled': true,
      });

      // Save a list
      await _adapterService.saveData('favorite_colors', ['blue', 'green', 'red']);

      ErrorHandler.logInfo('Various data types saved successfully');

      // Load data back
      final userName = await _adapterService.loadData<String>('user_name');
      final userAge = await _adapterService.loadData<int>('user_age');
      final isPremium = await _adapterService.loadData<bool>('is_premium');
      final settings = await _adapterService.loadData<Map<String, dynamic>>('settings');
      final favoriteColors = await _adapterService.loadData<List<String>>('favorite_colors');

      ErrorHandler.logInfo('Loaded data:');
      ErrorHandler.logInfo('  Name: $userName');
      ErrorHandler.logInfo('  Age: $userAge');
      ErrorHandler.logInfo('  Premium: $isPremium');
      ErrorHandler.logInfo('  Settings: $settings');
      ErrorHandler.logInfo('  Colors: $favoriteColors');

      // Work with secure data
      await _adapterService.saveSecureData('api_key', 'super_secret_api_key_123');
      final apiKey = await _adapterService.loadSecureData('api_key');
      ErrorHandler.logInfo('Secure API key loaded: ${apiKey?.substring(0, 10)}...');

      // Batch operations
      await _demonstrateBatchOperations();

      // Storage information
      final storageInfo = await _adapterService.getStorageInfo();
      ErrorHandler.logInfo('Storage info: ${storageInfo.usedSize} bytes used, ${storageInfo.itemCount} items');

    } catch (e) {
      ErrorHandler.logInfo('Error demonstrating storage: $e');
    }
  }

  /// Example: Working with system integration (desktop only)
  Future<void> demonstrateSystemIntegration() async {
    ErrorHandler.logInfo('\n=== System Integration Examples ===');

    try {
      if (!_adapterService.capabilities.hasSystemIntegration) {
        ErrorHandler.logInfo('System integration not available on this platform');
        return;
      }

      final system = _adapterService.system!;

      // Window management
      ErrorHandler.logInfo('Current window state:');
      final windowInfo = await system.getWindowInfo();
      ErrorHandler.logInfo('  Position: (${windowInfo.x}, ${windowInfo.y})');
      ErrorHandler.logInfo('  Size: ${windowInfo.width}x${windowInfo.height}');
      ErrorHandler.logInfo('  Visible: ${windowInfo.isVisible}');
      ErrorHandler.logInfo('  Focused: ${windowInfo.isFocused}');

      // System information
      final systemInfo = await system.getSystemInfo();
      ErrorHandler.logInfo('System info:');
      ErrorHandler.logInfo('  OS: ${systemInfo.operatingSystem} ${systemInfo.operatingSystemVersion}');
      ErrorHandler.logInfo('  Hostname: ${systemInfo.hostname}');
      ErrorHandler.logInfo('  CPUs: ${systemInfo.numberOfProcessors}');
      ErrorHandler.logInfo('  Dark mode: ${systemInfo.isDarkMode}');

      // Auto-start management (if supported)
      if (_adapterService.capabilities.supportsAutoStart) {
        final autoStartEnabled = await system.isAutoStartEnabled();
        ErrorHandler.logInfo('Auto-start enabled: $autoStartEnabled');
      }

      // File system operations (if supported)
      if (_adapterService.capabilities.supportsFileDialog) {
        ErrorHandler.logInfo('File dialog support available');
        // await system.selectFile(title: 'Select a file');
        // await system.selectDirectory(title: 'Select a directory');
      }

    } catch (e) {
      ErrorHandler.logInfo('Error demonstrating system integration: $e');
    }
  }

  /// Example: Platform capabilities detection
  void demonstratePlatformDetection() {
    ErrorHandler.logInfo('\n=== Platform Detection Examples ===');

    final platformInfo = _adapterService.platformInfo;
    final capabilities = _adapterService.capabilities;

    ErrorHandler.logInfo('Platform Information:');
    ErrorHandler.logInfo('  OS: ${platformInfo.operatingSystem}');
    ErrorHandler.logInfo('  Version: ${platformInfo.operatingSystemVersion}');
    ErrorHandler.logInfo('  Desktop: ${platformInfo.isDesktop}');
    ErrorHandler.logInfo('  Mobile: ${platformInfo.isMobile}');

    ErrorHandler.logInfo('\nCapabilities:');
    ErrorHandler.logInfo('  Notifications: ${capabilities.hasNotifications}');
    ErrorHandler.logInfo('  Scheduled Notifications: ${capabilities.supportsScheduledNotifications}');
    ErrorHandler.logInfo('  Notification Actions: ${capabilities.supportsNotificationActions}');
    ErrorHandler.logInfo('  Storage: ${capabilities.hasStorage}');
    ErrorHandler.logInfo('  System Integration: ${capabilities.hasSystemIntegration}');
    ErrorHandler.logInfo('  System Tray: ${capabilities.supportsSystemTray}');
    ErrorHandler.logInfo('  Window Management: ${capabilities.supportsWindowManagement}');
    ErrorHandler.logInfo('  Auto Start: ${capabilities.supportsAutoStart}');
    ErrorHandler.logInfo('  File Dialog: ${capabilities.supportsFileDialog}');

    // Conditional feature usage based on capabilities
    if (capabilities.supportsSystemTray) {
      ErrorHandler.logInfo('\n✓ System tray features available - can minimize to tray');
    } else {
      ErrorHandler.logInfo('\n✗ System tray not available - will hide window instead');
    }

    if (capabilities.supportsScheduledNotifications) {
      ErrorHandler.logInfo('✓ Scheduled notifications available - can set reminders');
    } else {
      ErrorHandler.logInfo('✗ Scheduled notifications not available - will use immediate notifications');
    }
  }

  /// Example: Error handling and recovery
  Future<void> demonstrateErrorHandling() async {
    ErrorHandler.logInfo('\n=== Error Handling Examples ===');

    try {
      // Try to use a feature that might not be supported
      await _adapterService.notifications.scheduleNotification(
        id: 'test_schedule',
        title: 'Test',
        body: 'Test',
        scheduledTime: DateTime.now().add(const Duration(seconds: 30)),
      );
      ErrorHandler.logInfo('✓ Scheduled notification created successfully');
    } on NotificationException catch (e) {
      ErrorHandler.logInfo('✗ Notification error: ${e.message}');
      // Handle notification-specific error
    } on AdapterException catch (e) {
      ErrorHandler.logInfo('✗ Adapter error: ${e.message}');
      // Handle general adapter error
    } catch (e) {
      ErrorHandler.logInfo('✗ Unexpected error: $e');
      // Handle unexpected errors
    }

    // Graceful degradation example
    try {
      if (_adapterService.capabilities.supportsSystemTray) {
        await _adapterService.minimizeToTray();
        ErrorHandler.logInfo('✓ Minimized to system tray');
      } else {
        await _adapterService.hideWindow();
        ErrorHandler.logInfo('✓ Hidden window (tray not available)');
      }
    } catch (e) {
      ErrorHandler.logInfo('✗ Window management failed: $e');
      // Could fall back to just minimizing
    }
  }

  /// Run all demonstration examples
  Future<void> runAllExamples() async {
    await initialize();
    
    demonstratePlatformDetection();
    await demonstrateNotifications();
    await demonstrateStorage();
    await demonstrateSystemIntegration();
    await demonstrateErrorHandling();
    
    ErrorHandler.logInfo('\n=== All Examples Completed ===');
  }

  // Private helper methods

  void _setupNotificationHandlers() {
    _adapterService.setupNotificationHandlers(
      onNotificationResponse: (response) {
        ErrorHandler.logInfo('Notification response received:');
        ErrorHandler.logInfo('  ID: ${response.id}');
        ErrorHandler.logInfo('  Action: ${response.actionId}');
        ErrorHandler.logInfo('  Payload: ${response.payload}');
        ErrorHandler.logInfo('  Input: ${response.input}');

        _handleNotificationResponse(response);
      },
    );
  }

  void _setupWindowHandlers() {
    if (!_adapterService.capabilities.hasSystemIntegration) return;

    _adapterService.setupWindowHandlers(
      onWindowEvent: (event) {
        ErrorHandler.logInfo('Window event: ${event.type.name}');
        _handleWindowEvent(event);
      },
    );
  }

  void _setupStorageListeners() {
    // Add storage listener for data changes
    _adapterService.storage.addListener(_StorageListener());
  }

  Future<void> _setupSystemTray() async {
    if (!_adapterService.capabilities.supportsSystemTray) return;

    try {
      await _adapterService.setupSystemTray(
        tooltip: 'Zenu - Personal Wellness Assistant',
        icon: 'assets/icon/app_icon_zenu.ico',
        menu: [
          SystemTrayMenuItem(
            id: 'show',
            label: 'Show Window',
            onTap: () => _adapterService.showWindow(),
          ),
          SystemTrayMenuItem(
            id: 'hide',
            label: 'Hide Window',
            onTap: () => _adapterService.hideWindow(),
          ),
          SystemTrayMenuItem.separator(),
          SystemTrayMenuItem(
            id: 'exit',
            label: 'Exit',
            onTap: () => _exitApplication(),
          ),
        ],
      );
      ErrorHandler.logInfo('System tray setup completed');
    } catch (e) {
      ErrorHandler.logInfo('Failed to setup system tray: $e');
    }
  }

  Future<void> _createHealthReminderNotification() async {
    // Create a reminder-specific notification
    await _adapterService.showNotification(
      id: 'health_reminder_water',
      title: '💧 Hydration Reminder',
      body: 'Time to drink some water! Stay healthy and hydrated.',
      payload: 'reminder_water_${DateTime.now().millisecondsSinceEpoch}',
      actions: [
        const NotificationAction(
          id: 'action_done',
          title: '✓ Done',
          type: NotificationActionType.button,
        ),
        const NotificationAction(
          id: 'action_snooze',
          title: '⏰ Snooze',
          type: NotificationActionType.button,
        ),
        const NotificationAction(
          id: 'action_skip',
          title: '⏭️ Skip',
          type: NotificationActionType.button,
        ),
      ],
    );
  }

  Future<void> _demonstrateBatchOperations() async {
    // Batch write
    final batchData = {
      'batch_item_1': 'value1',
      'batch_item_2': 42,
      'batch_item_3': {'nested': 'object'},
    };
    
    await _adapterService.storage.batchWrite(batchData);
    ErrorHandler.logInfo('Batch write completed: ${batchData.length} items');

    // Batch read
    final keys = ['batch_item_1', 'batch_item_2', 'batch_item_3'];
    final batchResults = await _adapterService.storage.batchRead(keys);
    ErrorHandler.logInfo('Batch read completed: ${batchResults.length} items loaded');
  }

  void _handleNotificationResponse(AppNotificationResponse response) {
    if (response.payload?.startsWith('reminder_') == true) {
      // Handle reminder notification responses
      switch (response.actionId) {
        case 'action_done':
          ErrorHandler.logInfo('User completed the reminder');
          // Mark reminder as completed
          break;
        case 'action_snooze':
          ErrorHandler.logInfo('User snoozed the reminder');
          // Reschedule reminder for later
          break;
        case 'action_skip':
          ErrorHandler.logInfo('User skipped the reminder');
          // Skip this reminder instance
          break;
        default:
          ErrorHandler.logInfo('User tapped the notification');
          // Show the app
          _adapterService.showWindow();
      }
    }
  }

  void _handleWindowEvent(WindowEvent event) {
    switch (event.type) {
      case WindowEventType.closing:
        ErrorHandler.logInfo('Window is closing - could minimize to tray instead');
        break;
      case WindowEventType.minimized:
        ErrorHandler.logInfo('Window minimized');
        break;
      case WindowEventType.focused:
        ErrorHandler.logInfo('Window gained focus');
        break;
      case WindowEventType.unfocused:
        ErrorHandler.logInfo('Window lost focus');
        break;
      default:
        ErrorHandler.logInfo('Window event: ${event.type.name}');
    }
  }

  Future<void> _exitApplication() async {
    try {
      await _adapterService.dispose();
      ErrorHandler.logInfo('Application cleanup completed');
      // exit(0); // Uncomment to actually exit
    } catch (e) {
      ErrorHandler.logInfo('Error during cleanup: $e');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _storageListener?.cancel();
    await _adapterService.dispose();
  }
}

/// Example storage listener implementation
class _StorageListener implements StorageListener {
  @override
  void onValueChanged(String key, dynamic oldValue, dynamic newValue) {
    ErrorHandler.logInfo('Storage value changed: $key = $newValue (was: $oldValue)');
  }

  @override
  void onValueRemoved(String key, dynamic oldValue) {
    ErrorHandler.logInfo('Storage value removed: $key (was: $oldValue)');
  }

  @override
  void onCleared() {
    ErrorHandler.logInfo('Storage cleared');
  }

  @override
  void onError(StorageException error) {
    ErrorHandler.logInfo('Storage error: ${error.message}');
  }
}

/// Example function to demonstrate usage in main.dart
Future<void> exampleMainUsage() async {
  ErrorHandler.logInfo('Initializing Zenu with Platform Adapters...');
  
  try {
    // Create and run the example
    final example = AdapterUsageExample();
    await example.runAllExamples();
    
    // In a real app, you would keep the adapters running
    // and dispose them when the app shuts down
    // await example.dispose();
    
  } catch (e) {
    ErrorHandler.logInfo('Error running adapter examples: $e');
  }
}

/// Example integration with existing reminder service
class ReminderServiceWithAdapters {
  late final AdapterService _adapters;
  
  Future<void> initialize() async {
    _adapters = await AdapterService.getInstance();
    
    // Setup notification handling for reminders
    _adapters.setupNotificationHandlers(
      onNotificationResponse: _handleReminderNotification,
    );
  }
  
  Future<void> showReminder(Reminder reminder) async {
    await _adapters.showNotification(
      id: reminder.id,
      title: reminder.title,
      body: _getReminderDescription(reminder),
      payload: 'reminder_${reminder.id}',
      actions: [
        const NotificationAction(
          id: 'complete',
          title: 'Complete',
          type: NotificationActionType.button,
        ),
        const NotificationAction(
          id: 'snooze',
          title: 'Snooze 5min',
          type: NotificationActionType.button,
        ),
      ],
    );
  }
  
  Future<void> saveReminders(List<Reminder> reminders) async {
    final reminderData = reminders.map((r) => r.toJson()).toList();
    await _adapters.saveData('reminders', reminderData);
  }
  
  Future<List<Reminder>> loadReminders() async {
    final data = await _adapters.loadData<List<dynamic>>('reminders');
    if (data == null) return [];
    
    return data.map((json) => Reminder.fromJson(json)).toList();
  }
  
  String _getReminderDescription(Reminder reminder) {
    switch (reminder.type) {
      case ReminderType.water:
        return 'Time to drink water! Stay hydrated.';
      case ReminderType.eyeRest:
        return 'Rest your eyes by looking away from the screen.';
      case ReminderType.standUp:
        return 'Stand up and move around for better circulation.';
      default:
        return reminder.description;
    }
  }
  
  void _handleReminderNotification(AppNotificationResponse response) {
    if (response.payload?.startsWith('reminder_') != true) return;
    
    final reminderId = response.payload!.substring(9);
    
    switch (response.actionId) {
      case 'complete':
        // Mark reminder as completed
        ErrorHandler.logInfo('Reminder $reminderId marked as completed');
        break;
      case 'snooze':
        // Snooze reminder for 5 minutes
        ErrorHandler.logInfo('Reminder $reminderId snoozed for 5 minutes');
        break;
      default:
        // Show app when notification is tapped
        _adapters.showWindow();
    }
  }
}

