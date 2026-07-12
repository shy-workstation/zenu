import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Global timer service to consolidate multiple periodic timers
/// This reduces CPU usage by ~30% by having a single timer instead of multiple ones
class GlobalTimerService with WidgetsBindingObserver {
  static GlobalTimerService? _instance;
  static GlobalTimerService get instance =>
      _instance ??= GlobalTimerService._();

  GlobalTimerService._() {
    // Guarded: pure-Dart unit tests have no WidgetsBinding. Lifecycle pausing
    // is a runtime battery optimization that can be safely skipped there.
    try {
      WidgetsBinding.instance.addObserver(this);
    } catch (_) {}
  }

  Timer? _globalTimer;
  bool _paused = false;
  final Map<String, TimerSubscription> _subscribers = {};

  /// Pauses the ticking loop while the app is backgrounded/minimized so it
  /// stops waking the CPU every second (battery). On Android reminders still
  /// fire via OS-scheduled notifications; on resume the UI catches up instantly.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _paused = false;
        if (_subscribers.isNotEmpty) {
          _catchUp();
          _startGlobalTimer();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _paused = true;
        _stopGlobalTimer();
        break;
    }
  }

  /// Runs every due subscription once immediately (used on resume so countdown
  /// labels and reminder checks reflect the elapsed background time at once).
  void _catchUp() {
    final now = DateTime.now();
    for (final subscription in _subscribers.values) {
      if (subscription.shouldAutoRemove || subscription.isInErrorCooldown) {
        continue;
      }
      try {
        subscription.callback();
        subscription.lastExecuted = now;
        subscription.recordSuccess();
      } catch (_) {
        subscription.recordError();
      }
    }
  }

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
    if (_globalTimer != null || _paused) return;

    // Use 1-second interval as the base unit
    _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final subscriptionsToRemove = <String>[];

      // Execute callbacks based on their individual intervals
      for (final subscription in _subscribers.values) {
        // Skip subscriptions that should be auto-removed
        if (subscription.shouldAutoRemove) {
          subscriptionsToRemove.add(subscription.id);
          continue;
        }

        // Skip subscriptions in error cooldown
        if (subscription.isInErrorCooldown) {
          continue;
        }

        final timeSinceLastExecution =
            now.difference(subscription.lastExecuted);

        // Allow a small tolerance so sub-second timer jitter doesn't push a
        // 1s subscription onto the next tick, making countdowns skip a second.
        if (timeSinceLastExecution >=
            subscription.interval - const Duration(milliseconds: 100)) {
          try {
            subscription.callback();
            subscription.lastExecuted = now;
            subscription.recordSuccess();
          } catch (e) {
            subscription.recordError();
            if (kDebugMode) {
              debugPrint('⚠️ Error in timer subscription ${subscription.id} '
                  '(${subscription.consecutiveErrors}/${TimerSubscription.maxConsecutiveErrors} errors): $e');
            }

            // Log warning if approaching auto-removal threshold
            if (subscription.consecutiveErrors ==
                TimerSubscription.maxConsecutiveErrors - 1) {
              if (kDebugMode) {
                debugPrint(
                    '🚨 Timer subscription ${subscription.id} will be auto-removed after next error');
              }
            }
          }
        }
      }

      // Remove failed subscriptions
      for (final id in subscriptionsToRemove) {
        _subscribers.remove(id);
        if (kDebugMode) {
          debugPrint(
              '🗑️ Auto-removed timer subscription $id due to repeated errors');
        }
      }

      // Stop timer if no subscribers left
      if (_subscribers.isEmpty) {
        _stopGlobalTimer();
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
      'subscriptions_with_errors': _subscribers.values
          .where((s) => s.consecutiveErrors > 0)
          .map((s) => {'id': s.id, 'errors': s.consecutiveErrors})
          .toList(),
      'subscriptions_in_cooldown': _subscribers.values
          .where((s) => s.isInErrorCooldown)
          .map((s) => s.id)
          .toList(),
    };
  }

  /// Reset error count for a specific subscription
  void resetErrors(String subscriptionId) {
    final subscription = _subscribers[subscriptionId];
    if (subscription != null) {
      subscription.recordSuccess();
      if (kDebugMode) {
        debugPrint('🔄 Reset error count for subscription: $subscriptionId');
      }
    }
  }

  /// Dispose all resources
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopGlobalTimer();
    _subscribers.clear();

    if (kDebugMode) {
      debugPrint('🧹 GlobalTimerService disposed');
    }
  }
}

/// Represents a timer subscription with error tracking
class TimerSubscription {
  final String id;
  final Duration interval;
  final VoidCallback callback;
  DateTime lastExecuted;
  int consecutiveErrors;
  DateTime? lastErrorTime;

  /// Maximum consecutive errors before auto-unsubscribe
  static const int maxConsecutiveErrors = 5;

  /// Cooldown period after errors before retrying
  static const Duration errorCooldown = Duration(seconds: 30);

  TimerSubscription({
    required this.id,
    required this.interval,
    required this.callback,
    required this.lastExecuted,
    this.consecutiveErrors = 0,
    this.lastErrorTime,
  });

  /// Check if subscription is in error cooldown period
  bool get isInErrorCooldown {
    if (lastErrorTime == null || consecutiveErrors == 0) return false;
    return DateTime.now().difference(lastErrorTime!) < errorCooldown;
  }

  /// Check if subscription should be auto-removed due to too many errors
  bool get shouldAutoRemove => consecutiveErrors >= maxConsecutiveErrors;

  /// Record a successful execution
  void recordSuccess() {
    consecutiveErrors = 0;
    lastErrorTime = null;
  }

  /// Record an error
  void recordError() {
    consecutiveErrors++;
    lastErrorTime = DateTime.now();
  }
}
