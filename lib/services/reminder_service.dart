import 'package:flutter/foundation.dart';
import '../models/reminder.dart';
import 'notification_service.dart';
import 'data_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/global_timer_service.dart';

class ReminderService extends ChangeNotifier {
  final NotificationService _notificationService;
  final DataService _dataService;

  String? _timerSubscriptionId;
  final List<Reminder> _reminders = [];
  bool _isRunning = false;

  // Remaining durations stored on pause, keyed by reminder id
  final Map<String, Duration> _pausedRemaining = {};

  // Track which reminders have already triggered notifications to prevent duplicates
  final Set<String> _triggeredNotifications = {};

  ReminderService(this._notificationService, this._dataService);

  void setLocalizations(AppLocalizations localizations) {
    _notificationService.setLocalizations(localizations);
  }

  List<Reminder> get reminders => _reminders;
  bool get isRunning => _isRunning;

  Future<void> loadData() async {
    try {
      final savedReminders = await _dataService.loadReminders();
      for (var savedReminder in savedReminders) {
        final index = _reminders.indexWhere((r) => r.id == savedReminder['id']);
        if (index != -1) {
          _reminders[index] = Reminder.fromJson(savedReminder);
        } else {
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
              completionLog: reminder.completionLog,
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

      for (var reminder in _reminders) {
        reminder.pruneOldEntries();
      }
      await saveData();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading data: $e');
      }
    }
  }

  Future<void> saveData() async {
    try {
      await _dataService.saveReminders(_reminders);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving data: $e');
      }
    }
  }

  /// Triggers a rebuild of widgets listening to this service.
  void refresh() {
    notifyListeners();
  }

  void startReminders() {
    if (_isRunning) return;

    _isRunning = true;
    final now = DateTime.now();

    for (var reminder in _reminders) {
      if (reminder.isEnabled) {
        final remaining = _pausedRemaining.remove(reminder.id);
        if (remaining != null) {
          // Resume from where we paused
          reminder.nextReminder = now.add(remaining);
        } else {
          reminder.resetNextReminder();
        }
      }
    }
    _pausedRemaining.clear();

    _timerSubscriptionId = GlobalTimerService.instance.subscribe(
      const Duration(seconds: 1),
      _checkReminders,
      id: 'reminder_service',
    );

    notifyListeners();
  }

  void stopReminders() {
    _isRunning = false;

    if (_timerSubscriptionId != null) {
      GlobalTimerService.instance.unsubscribe(_timerSubscriptionId!);
      _timerSubscriptionId = null;
    }

    final now = DateTime.now();
    _pausedRemaining.clear();
    for (var reminder in _reminders) {
      if (reminder.isEnabled && reminder.nextReminder != null) {
        final remaining = reminder.nextReminder!.difference(now);
        if (!remaining.isNegative) {
          _pausedRemaining[reminder.id] = remaining;
        }
      }
      reminder.nextReminder = null;
    }

    notifyListeners();
  }

  /// Clears all paused timers and resets to full intervals on next start.
  void clearTimers() {
    _pausedRemaining.clear();
    _triggeredNotifications.clear();
    if (_isRunning) {
      for (var reminder in _reminders) {
        if (reminder.isEnabled) {
          reminder.resetNextReminder();
        }
      }
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
        _triggerReminder(reminder);
        hasChanges = true;
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  void _triggerReminder(Reminder reminder) {
    if (_triggeredNotifications.contains(reminder.id)) return;

    _triggeredNotifications.add(reminder.id);
    _notificationService.showReminderNotification(reminder);
    notifyListeners();
  }

  void completeReminder(Reminder reminder, {int? customCount}) {
    reminder.completeReminder(customCount: customCount);
    _triggeredNotifications.remove(reminder.id);
    saveData();
    notifyListeners();
  }

  /// Clear the triggered notification flag for a reminder
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
    saveData();
    notifyListeners();
  }

  void updateReminder(Reminder updatedReminder) {
    final index = _reminders.indexWhere((r) => r.id == updatedReminder.id);
    if (index != -1) {
      final oldReminder = _reminders[index];
      final wasEnabled = oldReminder.isEnabled;
      final intervalChanged = oldReminder.interval != updatedReminder.interval;
      _reminders[index] = updatedReminder;

      // Clear stale paused state when interval changes
      if (intervalChanged) {
        _pausedRemaining.remove(updatedReminder.id);
      }

      if (_isRunning) {
        if (updatedReminder.isEnabled &&
            (!wasEnabled || intervalChanged || updatedReminder.nextReminder == null)) {
          _reminders[index].resetNextReminder();
        } else if (!updatedReminder.isEnabled) {
          _reminders[index].nextReminder = null;
        }
      }

      saveData();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (_timerSubscriptionId != null) {
      GlobalTimerService.instance.unsubscribe(_timerSubscriptionId!);
      _timerSubscriptionId = null;
    }
    super.dispose();
  }
}
