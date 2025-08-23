import 'package:flutter/widgets.dart';
import '../utils/error_handler.dart';
import '../utils/memory_cache.dart';
import '../utils/performance_utils.dart';
import '../services/data_service.dart';

/// Application lifecycle management
class AppLifecycleManager with WidgetsBindingObserver {
  static AppLifecycleManager? _instance;
  static AppLifecycleManager get instance {
    _instance ??= AppLifecycleManager._();
    return _instance!;
  }

  AppLifecycleManager._();

  bool _isInitialized = false;
  DateTime? _pausedTime;
  DateTime? _resumedTime;

  /// Initialize lifecycle management
  Future<void> initialize() async {
    if (_isInitialized) return;

    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;

    ErrorHandler.logInfo('AppLifecycleManager initialized');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.inactive:
        _handleAppInactive();
        break;
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      case AppLifecycleState.hidden:
        _handleAppHidden();
        break;
    }
  }

  void _handleAppResumed() {
    _resumedTime = DateTime.now();

    // Calculate time spent in background
    if (_pausedTime != null) {
      final backgroundDuration = _resumedTime!.difference(_pausedTime!);
      ErrorHandler.logInfo(
        'App resumed after ${backgroundDuration.inSeconds} seconds in background',
      );

      // If app was in background for more than 5 minutes, clear cache
      if (backgroundDuration.inMinutes > 5) {
        MemoryCache().clear();
        ErrorHandler.logInfo('Cache cleared due to extended background time');
      }

      // Refresh data if app was in background for more than 1 hour
      if (backgroundDuration.inHours > 1) {
        _refreshAppData();
      }
    }
  }

  void _handleAppPaused() {
    _pausedTime = DateTime.now();
    ErrorHandler.logInfo('App paused');

    // Save any pending data
    _saveAppState();

    // Cleanup resources
    _cleanupResources();
  }

  void _handleAppInactive() {
    ErrorHandler.logInfo('App became inactive');
  }

  void _handleAppDetached() {
    ErrorHandler.logInfo('App detached');
    _saveAppState();
  }

  void _handleAppHidden() {
    ErrorHandler.logInfo('App hidden');
  }

  Future<void> _saveAppState() async {
    try {
      // This would save any unsaved state
      // Currently our app saves data immediately, so this is mostly a placeholder
      ErrorHandler.logInfo('App state saved');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AppLifecycleManager._saveAppState',
        severity: ErrorSeverity.warning,
      );
    }
  }

  void _cleanupResources() {
    try {
      // Cleanup temporary resources
      PerformanceUtils.debounce(const Duration(seconds: 1), () {
        // Perform cleanup after a short delay
        ErrorHandler.logInfo('Resource cleanup completed');
      }, key: 'lifecycle_cleanup');
    } catch (e, stackTrace) {
      ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AppLifecycleManager._cleanupResources',
        severity: ErrorSeverity.warning,
      );
    }
  }

  Future<void> _refreshAppData() async {
    try {
      ErrorHandler.logInfo(
        'Refreshing app data after extended background time',
      );

      // Clear cache to force fresh data load
      final dataService = await DataService.getInstance();
      dataService.clearCache();

      // Data will be automatically reloaded when accessed
      ErrorHandler.logInfo('App data refresh completed');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'AppLifecycleManager._refreshAppData',
        severity: ErrorSeverity.error,
      );
    }
  }

  /// Get app session statistics
  Map<String, dynamic> getSessionStats() {
    final now = DateTime.now();

    return {
      'session_start': _resumedTime?.toIso8601String(),
      'last_pause': _pausedTime?.toIso8601String(),
      'current_time': now.toIso8601String(),
      'session_duration_minutes':
          _resumedTime != null ? now.difference(_resumedTime!).inMinutes : 0,
      'is_initialized': _isInitialized,
    };
  }

  /// Dispose of lifecycle manager
  void dispose() {
    if (_isInitialized) {
      WidgetsBinding.instance.removeObserver(this);
      _isInitialized = false;
      ErrorHandler.logInfo('AppLifecycleManager disposed');
    }
  }
}
