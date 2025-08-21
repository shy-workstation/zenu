import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized error handling and logging system
class ErrorHandler {
  static const String _logKey = 'app_error_logs';
  static const int _maxLogEntries = 100;

  static final StreamController<AppError> _errorStreamController =
      StreamController<AppError>.broadcast();

  /// Stream of errors for UI consumption
  static Stream<AppError> get errorStream => _errorStreamController.stream;

  /// Handle and log errors
  static Future<void> handleError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    ErrorSeverity severity = ErrorSeverity.error,
    Map<String, dynamic>? metadata,
  }) async {
    final appError = AppError(
      error: error,
      stackTrace: stackTrace,
      context: context,
      severity: severity,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    // Log to console in debug mode
    if (kDebugMode) {
      _logToConsole(appError);
    }

    // Store error for later analysis
    await _persistError(appError);

    // Emit to stream for UI handling
    _errorStreamController.add(appError);
  }

  /// Log info messages
  static void logInfo(String message, {Map<String, dynamic>? metadata}) {
    if (kDebugMode) {
      debugPrint('ℹ️ INFO: $message');
      if (metadata != null) {
        debugPrint('   Metadata: $metadata');
      }
    }
  }

  /// Log warnings
  static void logWarning(String message, {Map<String, dynamic>? metadata}) {
    if (kDebugMode) {
      debugPrint('⚠️ WARNING: $message');
      if (metadata != null) {
        debugPrint('   Metadata: $metadata');
      }
    }
  }

  /// Get stored error logs
  static Future<List<AppError>> getErrorLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getStringList(_logKey) ?? [];

      return logsJson.map((json) => AppError.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Failed to retrieve error logs: $e');
      return [];
    }
  }

  /// Clear error logs
  static Future<void> clearLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_logKey);
    } catch (e) {
      debugPrint('Failed to clear error logs: $e');
    }
  }

  static void _logToConsole(AppError error) {
    final emoji = error.severity.emoji;
    debugPrint('$emoji ${error.severity.name.toUpperCase()}: ${error.error}');
    if (error.context != null) {
      debugPrint('   Context: ${error.context}');
    }
    if (error.stackTrace != null) {
      debugPrint('   Stack: ${error.stackTrace}');
    }
    if (error.metadata != null) {
      debugPrint('   Metadata: ${error.metadata}');
    }
  }

  static Future<void> _persistError(AppError error) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingLogs = prefs.getStringList(_logKey) ?? [];

      // Add new log
      existingLogs.add(error.toJson());

      // Keep only recent logs
      if (existingLogs.length > _maxLogEntries) {
        existingLogs.removeRange(0, existingLogs.length - _maxLogEntries);
      }

      await prefs.setStringList(_logKey, existingLogs);
    } catch (e) {
      debugPrint('Failed to persist error: $e');
    }
  }
}

/// Application error model
class AppError {
  final dynamic error;
  final StackTrace? stackTrace;
  final String? context;
  final ErrorSeverity severity;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  AppError({
    required this.error,
    this.stackTrace,
    this.context,
    required this.severity,
    required this.timestamp,
    this.metadata,
  });

  String toJson() {
    return '''
    {
      "error": "${error.toString().replaceAll('"', '\\"')}",
      "context": "${context ?? ''}",
      "severity": "${severity.name}",
      "timestamp": "${timestamp.toIso8601String()}",
      "metadata": ${metadata?.toString() ?? '{}'}
    }
    ''';
  }

  static AppError fromJson(String json) {
    // Simple JSON parsing for error logs
    // In a production app, you'd use proper JSON parsing
    final lines = json.split('\n').map((l) => l.trim()).toList();

    String extractValue(String key) {
      final line = lines.firstWhere(
        (l) => l.startsWith('"$key":'),
        orElse: () => '"$key": ""',
      );
      return line
          .split(':')
          .skip(1)
          .join(':')
          .trim()
          .replaceAll('"', '')
          .replaceAll(',', '');
    }

    return AppError(
      error: extractValue('error'),
      context: extractValue('context').isEmpty ? null : extractValue('context'),
      severity: ErrorSeverity.values.firstWhere(
        (s) => s.name == extractValue('severity'),
        orElse: () => ErrorSeverity.error,
      ),
      timestamp: DateTime.tryParse(extractValue('timestamp')) ?? DateTime.now(),
    );
  }
}

/// Error severity levels
enum ErrorSeverity {
  info('ℹ️'),
  warning('⚠️'),
  error('❌'),
  critical('🚨');

  const ErrorSeverity(this.emoji);
  final String emoji;
}
