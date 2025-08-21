import 'dart:async';
import 'package:flutter/foundation.dart';

/// Async data loader to move heavy operations off the main thread
class AsyncDataLoader {
  static final Map<String, Completer<dynamic>> _pendingOperations = {};

  /// Load data asynchronously without blocking UI
  static Future<T> loadAsync<T>(
    String operationKey,
    Future<T> Function() operation, {
    Duration? timeout,
  }) async {
    // Prevent duplicate operations
    if (_pendingOperations.containsKey(operationKey)) {
      return await _pendingOperations[operationKey]!.future as T;
    }

    final completer = Completer<T>();
    _pendingOperations[operationKey] = completer;

    try {
      T result;

      if (timeout != null) {
        result = await operation().timeout(timeout);
      } else {
        result = await operation();
      }

      completer.complete(result);
      return result;
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _pendingOperations.remove(operationKey);
    }
  }

  /// Execute heavy computation in isolate (for CPU-intensive tasks)
  static Future<R> computeInIsolate<T, R>(
    ComputeCallback<T, R> callback,
    T message, {
    String? debugLabel,
  }) async {
    if (kIsWeb) {
      // Web doesn't support isolates, run on main thread
      return callback(message);
    }

    return await compute(callback, message, debugLabel: debugLabel);
  }

  /// Batch multiple async operations
  static Future<List<T>> batchLoad<T>(
    List<Future<T> Function()> operations, {
    int? concurrency,
    Duration? timeout,
  }) async {
    if (concurrency != null && concurrency > 0) {
      // Limit concurrent operations
      final results = <T>[];
      for (int i = 0; i < operations.length; i += concurrency) {
        final batch =
            operations.skip(i).take(concurrency).map((op) => op()).toList();

        final batchResults = await Future.wait(batch);
        results.addAll(batchResults);
      }
      return results;
    } else {
      // Run all operations concurrently
      final futures = operations.map((op) => op()).toList();

      if (timeout != null) {
        return await Future.wait(futures).timeout(timeout);
      } else {
        return await Future.wait(futures);
      }
    }
  }

  /// Progressive loading with UI updates
  static Stream<LoadingProgress<T>> loadProgressively<T>(
    List<Future<T> Function()> operations,
    String operationName,
  ) async* {
    final total = operations.length;
    final results = <T>[];

    for (int i = 0; i < operations.length; i++) {
      try {
        final result = await operations[i]();
        results.add(result);

        yield LoadingProgress(
          completed: i + 1,
          total: total,
          results: List.from(results),
          operationName: operationName,
          isComplete: i == operations.length - 1,
        );
      } catch (e) {
        yield LoadingProgress.error(
          completed: i,
          total: total,
          results: List.from(results),
          operationName: operationName,
          error: e,
        );
        break;
      }
    }
  }

  /// Cancel pending operations
  static void cancelOperation(String operationKey) {
    final completer = _pendingOperations[operationKey];
    if (completer != null && !completer.isCompleted) {
      completer.completeError(
        OperationCancelledException('Operation $operationKey was cancelled'),
      );
      _pendingOperations.remove(operationKey);
    }
  }

  /// Cancel all pending operations
  static void cancelAllOperations() {
    for (final key in _pendingOperations.keys.toList()) {
      cancelOperation(key);
    }
  }

  /// Check if operation is pending
  static bool isOperationPending(String operationKey) {
    return _pendingOperations.containsKey(operationKey);
  }
}

/// Progress tracking for long-running operations
class LoadingProgress<T> {
  final int completed;
  final int total;
  final List<T> results;
  final String operationName;
  final bool isComplete;
  final dynamic error;

  LoadingProgress({
    required this.completed,
    required this.total,
    required this.results,
    required this.operationName,
    this.isComplete = false,
    this.error,
  });

  LoadingProgress.error({
    required this.completed,
    required this.total,
    required this.results,
    required this.operationName,
    required this.error,
  }) : isComplete = false;

  double get progress => total > 0 ? completed / total : 0.0;
  bool get hasError => error != null;

  @override
  String toString() =>
      'LoadingProgress($operationName: $completed/$total, ${(progress * 100).toStringAsFixed(1)}%)';
}

/// Exception for cancelled operations
class OperationCancelledException implements Exception {
  final String message;
  OperationCancelledException(this.message);

  @override
  String toString() => 'OperationCancelledException: $message';
}
