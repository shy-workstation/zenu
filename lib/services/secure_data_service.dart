import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder.dart';
import '../models/statistics.dart';
import '../utils/error_handler.dart';
import '../utils/performance_utils.dart';

/// Simplified data service using SharedPreferences
/// (Secure storage disabled due to missing dependencies)
class SecureDataService {
  static const String _remindersKey = 'reminders';
  static const String _statisticsKey = 'statistics';

  static SecureDataService? _instance;
  static SharedPreferences? _prefs;

  SecureDataService._();

  static Future<SecureDataService> getInstance() async {
    if (_instance == null) {
      _instance = SecureDataService._();
      await _instance!._initialize();
    }
    return _instance!;
  }

  Future<void> _initialize() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      ErrorHandler.logInfo(
        'SecureDataService initialized with SharedPreferences',
      );
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'SecureDataService._initialize',
        severity: ErrorSeverity.error,
      );
    }
  }

  /// Save reminders to storage
  Future<void> saveReminders(List<Reminder> reminders) async {
    try {
      await _performanceTrace('saveReminders', () async {
        final jsonString = jsonEncode(
          reminders.map((r) => r.toJson()).toList(),
        );

        if (_prefs != null) {
          await _prefs!.setString(_remindersKey, jsonString);
        }
      });

      ErrorHandler.logInfo('Reminders saved successfully');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'SecureDataService.saveReminders',
        severity: ErrorSeverity.error,
      );
      rethrow;
    }
  }

  /// Load reminders from storage
  Future<List<Reminder>> loadReminders() async {
    try {
      return await _performanceTrace('loadReminders', () async {
        if (_prefs == null) return [];

        final jsonString = _prefs!.getString(_remindersKey);
        if (jsonString == null) return [];

        final List<dynamic> jsonList = jsonDecode(jsonString);
        final reminders =
            jsonList.map((json) => Reminder.fromJson(json)).toList();

        return reminders;
      });
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'SecureDataService.loadReminders',
        severity: ErrorSeverity.error,
      );
      return [];
    }
  }

  /// Save statistics to storage
  Future<void> saveStatistics(Statistics statistics) async {
    try {
      final jsonString = jsonEncode(statistics.toJson());

      if (_prefs != null) {
        await _prefs!.setString(_statisticsKey, jsonString);
      }

      ErrorHandler.logInfo('Statistics saved successfully');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'SecureDataService.saveStatistics',
        severity: ErrorSeverity.error,
      );
    }
  }

  /// Load statistics from storage
  Future<Statistics?> loadStatistics() async {
    try {
      if (_prefs == null) return null;

      final jsonString = _prefs!.getString(_statisticsKey);
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString);
      return Statistics.fromJson(json);
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'SecureDataService.loadStatistics',
        severity: ErrorSeverity.error,
      );
      return null;
    }
  }

  /// Clear all stored data
  Future<void> clearAllData() async {
    try {
      if (_prefs != null) {
        await _prefs!.remove(_remindersKey);
        await _prefs!.remove(_statisticsKey);
      }

      ErrorHandler.logInfo('All data cleared successfully');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'SecureDataService.clearAllData',
        severity: ErrorSeverity.warning,
      );
    }
  }

  /// Performance tracing wrapper
  Future<T> _performanceTrace<T>(
    String operation,
    Future<T> Function() function,
  ) async {
    return await PerformanceUtils.measureAsync(operation, function);
  }

  /// Check if data exists
  Future<bool> hasReminders() async {
    try {
      if (_prefs == null) return false;
      return _prefs!.containsKey(_remindersKey);
    } catch (e) {
      return false;
    }
  }

  /// Check if statistics exist
  Future<bool> hasStatistics() async {
    try {
      if (_prefs == null) return false;
      return _prefs!.containsKey(_statisticsKey);
    } catch (e) {
      return false;
    }
  }

  /// Export data as JSON
  Future<Map<String, dynamic>> exportData() async {
    try {
      final reminders = await loadReminders();
      final statistics = await loadStatistics();

      return {
        'reminders': reminders.map((r) => r.toJson()).toList(),
        'statistics': statistics?.toJson(),
        'exportDate': DateTime.now().toIso8601String(),
      };
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'SecureDataService.exportData',
        severity: ErrorSeverity.error,
      );
      return {};
    }
  }

  /// Import data from JSON
  Future<bool> importData(Map<String, dynamic> data) async {
    try {
      if (data['reminders'] != null) {
        final reminders =
            (data['reminders'] as List)
                .map((json) => Reminder.fromJson(json))
                .toList();
        await saveReminders(reminders);
      }

      if (data['statistics'] != null) {
        final statistics = Statistics.fromJson(data['statistics']);
        await saveStatistics(statistics);
      }

      ErrorHandler.logInfo('Data imported successfully');
      return true;
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'SecureDataService.importData',
        severity: ErrorSeverity.error,
      );
      return false;
    }
  }
}
