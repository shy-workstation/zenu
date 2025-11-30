import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/reminder.dart';
import '../models/statistics.dart';
import 'notification_service.dart';
import 'data_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/global_timer_service.dart';

const _uuid = Uuid();

class ReminderService extends ChangeNotifier {
  final NotificationService _notificationService;
  final DataService _dataService;

  String? _timerSubscriptionId;
  List<Reminder> _reminders = [];
  Statistics _statistics = Statistics();
  bool _isRunning = false;

  // Track which reminders have already triggered notifications to prevent duplicates
  final Set<String> _triggeredNotifications = {};

  // Optimized notification system - no modals, card-based notifications
  final ValueNotifier<String?> _activeNotificationId = ValueNotifier(null);
  final List<String> _notificationQueue = [];

  ValueNotifier<String?> get activeNotificationId => _activeNotificationId;
  String? get activeNotification => _activeNotificationId.value;

  ReminderService(this._notificationService, this._dataService) {
    _initializeReminders();
  }

  void setLocalizations(AppLocalizations localizations) {
    _notificationService.setLocalizations(localizations);
    _notificationService.setReminderService(this);
  }

  // Method to manually trigger a reminder for testing
  void triggerTestReminder(Reminder reminder) {
    _triggerReminder(reminder);
  }

  List<Reminder> get reminders => _reminders;
  Statistics get statistics => _statistics;
  bool get isRunning => _isRunning;

  void _initializeReminders() {
    // Start with empty list - users can add their own reminders
    _reminders = [];
  }

  Future<void> loadData() async {
    try {
      final savedReminders = await _dataService.loadReminders();
      final savedStats = await _dataService.loadStatistics();

      _statistics = savedStats;
      _statistics.resetDailyStats();
      _statistics.resetWeeklyStats();

      // Update reminders with saved data and migrate water reminders
      for (var savedReminder in savedReminders) {
        final index = _reminders.indexWhere((r) => r.id == savedReminder['id']);
        if (index != -1) {
          _reminders[index] = Reminder.fromJson(savedReminder);
        } else {
          // This is a new reminder that was saved but not in our default list
          final reminder = Reminder.fromJson(savedReminder);

          // Migrate old water reminders to new 0-1000 ml range
          if (reminder.type == ReminderType.water &&
              reminder.maxQuantity == 10 &&
              reminder.unit == 'glasses') {
            final migratedReminder = Reminder(
              id: reminder.id,
              type: reminder.type,
              title: reminder.title,
              description: reminder.description,
              interval: reminder.interval,
              icon: reminder.icon,
              color: reminder.color,
              isEnabled: reminder.isEnabled,
              nextReminder: reminder.nextReminder,
              exerciseCount: reminder.exerciseCount,
              totalCompleted: reminder.totalCompleted,
              minQuantity: 0,
              maxQuantity: 1000,
              stepSize: 25,
              unit: 'ml',
            );
            _reminders.add(migratedReminder);
          } else {
            _reminders.add(reminder);
          }
        }
      }

      // Save migrated data
      await saveData();
      notifyListeners();
    } catch (e) {
      // Error loading data, continue with defaults
    }
  }

  Future<void> saveData() async {
    try {
      await _dataService.saveReminders(_reminders);
      await _dataService.saveStatistics(_statistics);
    } catch (e) {
      // Error saving data, fail silently
    }
  }

  /// Triggers a rebuild of widgets listening to this service.
  /// This is a public method to allow external callers to refresh the UI
  /// after modifying reminder state directly (e.g., resetting next reminder time).
  void refresh() {
    notifyListeners();
  }

  void startReminders() {
    if (_isRunning) return;

    _isRunning = true;

    // Reset next reminder times for enabled reminders
    for (var reminder in _reminders) {
      if (reminder.isEnabled) {
        reminder.resetNextReminder();
      }
    }

    // Subscribe to global timer service
    _timerSubscriptionId = GlobalTimerService.instance.subscribe(
      const Duration(seconds: 1),
      _checkReminders,
      id: 'reminder_service',
    );

    notifyListeners();
  }

  void stopReminders() {
    _isRunning = false;

    // Unsubscribe from global timer
    if (_timerSubscriptionId != null) {
      GlobalTimerService.instance.unsubscribe(_timerSubscriptionId!);
      _timerSubscriptionId = null;
    }

    // Clear next reminder times
    for (var reminder in _reminders) {
      reminder.nextReminder = null;
    }

    notifyListeners();
  }

  void _checkReminders() {
    final now = DateTime.now();
    bool hasChanges = false;

    for (var reminder in _reminders) {
      if (reminder.isEnabled &&
          reminder.nextReminder != null &&
          now.isAfter(reminder.nextReminder!)) {
        if (kDebugMode) {
          debugPrint('⏰ Reminder ready to trigger: ${reminder.title}, nextReminder: ${reminder.nextReminder}, now: $now');
        }
        _triggerReminder(reminder);
        hasChanges = true;
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  void _triggerReminder(Reminder reminder) {
    // Prevent duplicate notifications for the same trigger event
    if (_triggeredNotifications.contains(reminder.id)) {
      if (kDebugMode) {
        debugPrint('⚠️ Skipping duplicate notification for ${reminder.title} (already triggered)');
      }
      return; // Already triggered this notification
    }

    if (kDebugMode) {
      debugPrint('🔔 Triggering reminder: ${reminder.title} (id: ${reminder.id})');
    }

    // Mark as triggered
    _triggeredNotifications.add(reminder.id);

    // Always show system notification first (works even when app is minimized)
    _notificationService.showReminderNotification(reminder);

    // The in-app notification is now handled by the SwipeableReminderCard
    // which detects when the reminder time has passed and enters notification state.
    // We don't reset the timer here - the card will handle it when user interacts.
    // The card checks if currentTime is after nextReminder to enter notification state.

    // Note: We intentionally don't call reminder.resetNextReminder() here
    // because the card needs to see that the reminder has triggered
    // (nextReminder is in the past) to show the notification UI.
    // The card will reset the timer when the user clicks Skip or Done.

    notifyListeners();
  }

  void completeReminder(Reminder reminder, {int? customCount}) {
    // Always count as 1 completion, regardless of the quantity/amount
    reminder.completeReminder();
    _statistics.incrementCount(reminder.id, 1); // Always increment by 1

    // Clear triggered notification flag so it can trigger again next time
    _triggeredNotifications.remove(reminder.id);

    // The customCount parameter represents the quantity/amount performed,
    // but for completion tracking, we only count it as 1 completed reminder
    saveData();
    notifyListeners();
  }

  void snoozeReminder(Reminder reminder, Duration snoozeDuration) {
    // Reset the next reminder time to the snooze duration from now
    reminder.nextReminder = DateTime.now().add(snoozeDuration);
    
    // Clear triggered notification flag so it can trigger again after snooze
    _triggeredNotifications.remove(reminder.id);
    
    saveData();
    notifyListeners();
  }

  /// Clear the triggered notification flag for a reminder
  /// Call this when user manually dismisses or interacts with a reminder
  void clearTriggeredNotification(String reminderId) {
    _triggeredNotifications.remove(reminderId);
  }

  void toggleReminder(String reminderId) {
    final index = _reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      _reminders[index].isEnabled = !_reminders[index].isEnabled;

      if (!_reminders[index].isEnabled) {
        _reminders[index].nextReminder = null;
      } else if (_isRunning) {
        _reminders[index].resetNextReminder();
      }

      saveData();
      notifyListeners();
    }
  }

  void updateReminderInterval(String reminderId, Duration newInterval) {
    final index = _reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      final existing = _reminders[index];
      _reminders[index] = Reminder(
        id: existing.id,
        type: existing.type,
        title: existing.title,
        description: existing.description,
        interval: newInterval,
        icon: existing.icon,
        color: existing.color,
        isEnabled: existing.isEnabled,
        exerciseCount: existing.exerciseCount,
        totalCompleted: existing.totalCompleted,
        minQuantity: existing.minQuantity,
        maxQuantity: existing.maxQuantity,
        stepSize: existing.stepSize,
        unit: existing.unit,
      );

      if (_reminders[index].isEnabled && _isRunning) {
        _reminders[index].resetNextReminder();
      }

      saveData();
      notifyListeners();
    }
  }

  void updateExerciseCount(String reminderId, int newCount) {
    final index = _reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      _reminders[index].exerciseCount = newCount;
      saveData();
      notifyListeners();
    }
  }

  // Dynamic reminder management methods
  void addReminder(Reminder reminder) {
    _reminders.add(reminder);

    if (_isRunning && reminder.isEnabled) {
      reminder.resetNextReminder();
    }

    saveData();
    notifyListeners();
  }

  void removeReminder(String reminderId) {
    _reminders.removeWhere((r) => r.id == reminderId);
    _statistics.removeReminderStats(reminderId);

    saveData();
    notifyListeners();
  }

  void updateReminder(Reminder updatedReminder) {
    final index = _reminders.indexWhere((r) => r.id == updatedReminder.id);
    if (index != -1) {
      final wasEnabled = _reminders[index].isEnabled;
      _reminders[index] = updatedReminder;

      // Handle timer state changes
      if (_isRunning) {
        if (updatedReminder.isEnabled &&
            (!wasEnabled || updatedReminder.nextReminder == null)) {
          _reminders[index].resetNextReminder();
        } else if (!updatedReminder.isEnabled) {
          _reminders[index].nextReminder = null;
        }
      }

      saveData();
      notifyListeners();
    }
  }

  void duplicateReminder(String reminderId) {
    final original = _reminders.firstWhere((r) => r.id == reminderId);
    // Use UUID to guarantee unique ID and prevent collisions
    final duplicate = Reminder(
      id: _uuid.v4(),
      type: original.type,
      title: '${original.title} (Copy)',
      description: original.description,
      interval: original.interval,
      icon: original.icon,
      color: original.color,
      isEnabled: original.isEnabled,
      exerciseCount: original.exerciseCount,
      minQuantity: original.minQuantity,
      maxQuantity: original.maxQuantity,
      stepSize: original.stepSize,
      unit: original.unit,
    );

    addReminder(duplicate);
  }

  @override
  void dispose() {
    // Unsubscribe from global timer
    if (_timerSubscriptionId != null) {
      GlobalTimerService.instance.unsubscribe(_timerSubscriptionId!);
      _timerSubscriptionId = null;
    }
    super.dispose();
  }
}
