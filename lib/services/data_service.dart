import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder.dart';
import '../models/statistics.dart';
import '../utils/memory_cache.dart';
import '../utils/error_handler.dart';
import '../utils/performance_utils.dart';
import 'cache_service.dart';
import 'batched_data_service.dart';

class DataService {
  static const String _remindersKey = 'reminders';
  static const String _statisticsKey = 'statistics';

  static DataService? _instance;
  static SharedPreferences? _prefs;
  static final MemoryCache _cache = MemoryCache();
  static final CacheService _cacheService = CacheService();
  static final BatchedDataService _batchedService = BatchedDataService.instance;

  DataService._();

  static Future<DataService> getInstance() async {
    if (_instance == null) {
      _instance = DataService._();
      _prefs = await SharedPreferences.getInstance();
      _cache.initialize();
      _cacheService.initialize();
      await _batchedService.initialize();
    }
    return _instance!;
  }

  Future<List<Map<String, dynamic>>> loadReminders() async {
    return await PerformanceUtils.measureAsync(
      'DataService.loadReminders',
      () async {
        // Use enhanced cache service first
        return await _cacheService.getOrCompute(
          CacheKeys.reminderCalculations,
          () async {
            final String? remindersJson = _prefs?.getString(_remindersKey);
            if (remindersJson == null) return <Map<String, dynamic>>[];

            try {
              final List<dynamic> remindersList = jsonDecode(remindersJson);
              return remindersList.cast<Map<String, dynamic>>();
            } catch (e, stackTrace) {
              await ErrorHandler.handleError(
                e,
                stackTrace,
                context: 'DataService.loadReminders',
                severity: ErrorSeverity.error,
              );
              return <Map<String, dynamic>>[];
            }
          },
          ttl: const Duration(minutes: 10),
        );
      },
    );
  }

  Future<void> saveReminders(List<Reminder> reminders) async {
    await PerformanceUtils.measureAsync('DataService.saveReminders', () async {
      try {
        final List<Map<String, dynamic>> remindersJson =
            reminders.map((r) => r.toJson()).toList();

        // Use batched data service for optimized I/O
        _batchedService.scheduleWrite(_remindersKey, jsonEncode(remindersJson));

        // Update cache systems
        _cache.set(
          _remindersKey,
          remindersJson,
          ttl: const Duration(minutes: 5),
        );
        _cacheService.set(
          CacheKeys.reminderCalculations,
          remindersJson,
          ttl: const Duration(minutes: 10),
        );

        ErrorHandler.logInfo(
          'Successfully scheduled save for ${reminders.length} reminders',
        );
      } catch (e, stackTrace) {
        await ErrorHandler.handleError(
          e,
          stackTrace,
          context: 'DataService.saveReminders',
          severity: ErrorSeverity.critical,
          metadata: {'reminderCount': reminders.length},
        );
        rethrow; // Re-throw for calling code to handle
      }
    });
  }

  Future<Statistics> loadStatistics() async {
    return await PerformanceUtils.measureAsync(
      'DataService.loadStatistics',
      () async {
        // Use enhanced cache service first
        return await _cacheService.getOrCompute(
          CacheKeys.statisticsData,
          () async {
            final String? statisticsJson = _prefs?.getString(_statisticsKey);
            if (statisticsJson == null) return Statistics();

            try {
              final Map<String, dynamic> statsMap = jsonDecode(statisticsJson);
              return Statistics.fromJson(statsMap);
            } catch (e, stackTrace) {
              await ErrorHandler.handleError(
                e,
                stackTrace,
                context: 'DataService.loadStatistics',
                severity: ErrorSeverity.warning,
              );
              return Statistics();
            }
          },
          ttl: const Duration(minutes: 15),
        );
      },
    );
  }

  Future<void> saveStatistics(Statistics statistics) async {
    await PerformanceUtils.measureAsync('DataService.saveStatistics', () async {
      try {
        // Use batched data service for optimized I/O
        _batchedService.scheduleWrite(
          _statisticsKey,
          jsonEncode(statistics.toJson()),
        );

        // Update cache systems
        _cache.set(
          _statisticsKey,
          statistics,
          ttl: const Duration(minutes: 15),
        );
        _cacheService.set(
          CacheKeys.statisticsData,
          statistics,
          ttl: const Duration(minutes: 15),
        );

        ErrorHandler.logInfo('Successfully saved statistics');
      } catch (e, stackTrace) {
        await ErrorHandler.handleError(
          e,
          stackTrace,
          context: 'DataService.saveStatistics',
          severity: ErrorSeverity.error,
        );
      }
    });
  }

  Future<void> clearAll() async {
    await PerformanceUtils.measureAsync('DataService.clearAll', () async {
      try {
        await _prefs?.remove(_remindersKey);
        await _prefs?.remove(_statisticsKey);

        // Clear cache
        _cache.clear();

        ErrorHandler.logInfo('Successfully cleared all data');
      } catch (e, stackTrace) {
        await ErrorHandler.handleError(
          e,
          stackTrace,
          context: 'DataService.clearAll',
          severity: ErrorSeverity.error,
        );
      }
    });
  }

  /// Get cache statistics for debugging
  String getCacheStats() {
    return _cache.stats.toString();
  }

  /// Clear cache manually
  void clearCache() {
    _cache.clear();
    ErrorHandler.logInfo('Manual cache clear completed');
  }

  /// Force flush pending writes (call before app closes)
  Future<void> flushPendingWrites() async {
    await _batchedService.flushPendingWrites();
  }

  /// Get batched data service statistics
  Map<String, dynamic> getBatchedStats() {
    return _batchedService.getStats();
  }
}
