import 'dart:async';
import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../models/statistics.dart';
import 'notification_service.dart';
import 'in_app_notification_service.dart';
import 'data_service.dart';
import '../l10n/app_localizations.dart';

class ReminderService extends ChangeNotifier {
  final NotificationService _notificationService;
  final DataService _dataService;
  InAppNotificationService? _inAppNotificationService;

  Timer? _mainTimer;
  List<Reminder> _reminders = [];
  Statistics _statistics = Statistics();
  bool _isRunning = false;

  ReminderService(this._notificationService, this._dataService) {
    _initializeReminders();
  }

  void setInAppNotificationService(InAppNotificationService service) {
    _inAppNotificationService = service;
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

      // Update reminders with saved data
      for (var savedReminder in savedReminders) {
        final index = _reminders.indexWhere((r) => r.id == savedReminder['id']);
        if (index != -1) {
          _reminders[index] = Reminder.fromJson(savedReminder);
        } else {
          // This is a new reminder that was saved but not in our default list
          _reminders.add(Reminder.fromJson(savedReminder));
        }
      }

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

  void startReminders() {
    if (_isRunning) return;

    _isRunning = true;

    // Reset next reminder times for enabled reminders
    for (var reminder in _reminders) {
      if (reminder.isEnabled) {
        reminder.resetNextReminder();
      }
    }

    // Start the main timer
    _mainTimer = Timer.periodic(const Duration(seconds: 1), _checkReminders);

    notifyListeners();
  }

  void stopReminders() {
    _isRunning = false;
    _mainTimer?.cancel();
    _mainTimer = null;

    // Clear next reminder times
    for (var reminder in _reminders) {
      reminder.nextReminder = null;
    }

    notifyListeners();
  }

  void _checkReminders(Timer timer) {
    final now = DateTime.now();
    bool hasChanges = false;

    for (var reminder in _reminders) {
      if (reminder.isEnabled &&
          reminder.nextReminder != null &&
          now.isAfter(reminder.nextReminder!)) {
        _triggerReminder(reminder);
        hasChanges = true;
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  void _triggerReminder(Reminder reminder) {
    // Always show system notification first (works even when app is minimized)
    _notificationService.showReminderNotification(reminder);
    
    // Also show in-app notification if available (when app is open)
    if (_inAppNotificationService != null) {
      // Pause the timer while waiting for user interaction
      _pauseTimer();
      
      _inAppNotificationService!.showReminderDialog(reminder, (quantity) {
        if (quantity > 0) {
          // User confirmed completion with specific quantity
          completeReminder(reminder, customCount: quantity);
        } else {
          // User skipped - set next reminder time
          reminder.resetNextReminder();
          notifyListeners();
        }
        // Resume the timer after user interaction
        _resumeTimer();
      });
    } else {
      // No in-app notification service available, just reset reminder time
      reminder.resetNextReminder();
      notifyListeners();
    }
  }

  void _pauseTimer() {
    _mainTimer?.cancel();
    _mainTimer = null;
  }

  void _resumeTimer() {
    if (_isRunning && _mainTimer == null) {
      _mainTimer = Timer.periodic(const Duration(seconds: 1), _checkReminders);
    }
  }

  void completeReminder(Reminder reminder, {int? customCount}) {
    // Always count as 1 completion, regardless of the quantity/amount
    reminder.completeReminder();
    _statistics.incrementCount(reminder.id, 1); // Always increment by 1

    // The customCount parameter represents the quantity/amount performed,
    // but for completion tracking, we only count it as 1 completed reminder
    saveData();
    notifyListeners();
  }

  void snoozeReminder(Reminder reminder, Duration snoozeDuration) {
    // Reset the next reminder time to the snooze duration from now
    reminder.nextReminder = DateTime.now().add(snoozeDuration);
    saveData();
    notifyListeners();
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
    final duplicate = Reminder(
      id: '${original.id}_copy_${DateTime.now().millisecondsSinceEpoch}',
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
    _mainTimer?.cancel();
    super.dispose();
  }
}
