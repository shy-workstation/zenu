import 'dart:async';
import 'package:flutter/foundation.dart';

/// Performance monitoring and optimization utilities
class PerformanceUtils {
  static const bool _enableProfiling = kDebugMode;

  /// Measures execution time of a function
  static Future<T> measureAsync<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    if (!_enableProfiling) return await operation();

    final stopwatch = Stopwatch()..start();
    try {
      final result = await operation();
      stopwatch.stop();
      debugPrint('⏱️ $operationName took ${stopwatch.elapsedMilliseconds}ms');
      return result;
    } catch (e) {
      stopwatch.stop();
      debugPrint(
        '❌ $operationName failed after ${stopwatch.elapsedMilliseconds}ms: $e',
      );
      rethrow;
    }
  }

  /// Measures execution time of a synchronous function
  static T measure<T>(String operationName, T Function() operation) {
    if (!_enableProfiling) return operation();

    final stopwatch = Stopwatch()..start();
    try {
      final result = operation();
      stopwatch.stop();
      debugPrint('⏱️ $operationName took ${stopwatch.elapsedMilliseconds}ms');
      return result;
    } catch (e) {
      stopwatch.stop();
      debugPrint(
        '❌ $operationName failed after ${stopwatch.elapsedMilliseconds}ms: $e',
      );
      rethrow;
    }
  }

  /// Memory usage monitoring
  static void logMemoryUsage(String context) {
    if (!_enableProfiling) return;
    // Note: Actual memory monitoring would require platform channels
    debugPrint('📊 Memory check at: $context');
  }

  /// Debounces rapid function calls
  static void debounce(
    Duration delay,
    VoidCallback action, {
    required String key,
  }) {
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(delay, action);
  }

  static final Map<String, Timer> _debounceTimers = {};
}
