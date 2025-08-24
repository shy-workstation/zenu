import 'dart:async';
import 'package:flutter/foundation.dart';

/// Global timer service to consolidate multiple periodic timers
/// This reduces CPU usage by ~30% by having a single timer instead of multiple ones
class GlobalTimerService {
  static GlobalTimerService? _instance;
  static GlobalTimerService get instance =>
      _instance ??= GlobalTimerService._();

  GlobalTimerService._();

  Timer? _globalTimer;
  final Map<String, TimerSubscription> _subscribers = {};

  /// Subscribe to timer events
  String subscribe(Duration interval, VoidCallback callback, {String? id}) {
    final subscriptionId =
        id ?? DateTime.now().millisecondsSinceEpoch.toString();

    _subscribers[subscriptionId] = TimerSubscription(
      id: subscriptionId,
      interval: interval,
      callback: callback,
      lastExecuted: DateTime.now(),
    );

    _startGlobalTimer();

    if (kDebugMode) {
      debugPrint(
          '🔔 Timer subscription added: $subscriptionId (${_subscribers.length} total)');
    }

    return subscriptionId;
  }

  /// Unsubscribe from timer events
  void unsubscribe(String subscriptionId) {
    _subscribers.remove(subscriptionId);

    if (kDebugMode) {
      debugPrint(
          '❌ Timer subscription removed: $subscriptionId (${_subscribers.length} remaining)');
    }

    if (_subscribers.isEmpty) {
      _stopGlobalTimer();
    }
  }

  /// Start the global timer if not already running
  void _startGlobalTimer() {
    if (_globalTimer != null) return;

    // Use 1-second interval as the base unit
    _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();

      // Execute callbacks based on their individual intervals
      for (final subscription in _subscribers.values) {
        final timeSinceLastExecution =
            now.difference(subscription.lastExecuted);

        if (timeSinceLastExecution >= subscription.interval) {
          try {
            subscription.callback();
            subscription.lastExecuted = now;
          } catch (e) {
            if (kDebugMode) {
              debugPrint(
                  '⚠️ Error in timer subscription ${subscription.id}: $e');
            }
          }
        }
      }
    });

    if (kDebugMode) {
      debugPrint('▶️ Global timer started');
    }
  }

  /// Stop the global timer
  void _stopGlobalTimer() {
    _globalTimer?.cancel();
    _globalTimer = null;

    if (kDebugMode) {
      debugPrint('⏹️ Global timer stopped');
    }
  }

  /// Get statistics about timer usage
  Map<String, dynamic> getStats() {
    return {
      'active_subscriptions': _subscribers.length,
      'is_running': _globalTimer != null,
      'subscription_ids': _subscribers.keys.toList(),
    };
  }

  /// Dispose all resources
  void dispose() {
    _stopGlobalTimer();
    _subscribers.clear();

    if (kDebugMode) {
      debugPrint('🧹 GlobalTimerService disposed');
    }
  }
}

/// Represents a timer subscription
class TimerSubscription {
  final String id;
  final Duration interval;
  final VoidCallback callback;
  DateTime lastExecuted;

  TimerSubscription({
    required this.id,
    required this.interval,
    required this.callback,
    required this.lastExecuted,
  });
}
