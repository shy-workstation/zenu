import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:zenu/models/reminder.dart';
import 'package:zenu/models/statistics.dart';
import '../../../fixtures/test_data.dart';
import '../../../mocks/mock_adapters.dart';

/// Mock use case classes for testing business logic
class ReminderUseCases {
  const ReminderUseCases({
    required this.notificationAdapter,
    required this.storageAdapter,
  });

  final MockNotificationAdapter notificationAdapter;
  final MockSharedPreferencesAdapter storageAdapter;

  /// Use case: Create a new reminder
  Future<Reminder> createReminder({
    required String title,
    required String description,
    required ReminderType type,
    required Duration interval,
    IconData? icon,
    Color? color,
  }) async {
    // Business logic validation
    if (title.isEmpty) {
      throw ArgumentError('Title cannot be empty');
    }
    
    if (interval.inSeconds < 1) {
      throw ArgumentError('Interval must be at least 1 second');
    }

    // Create reminder
    final reminder = Reminder(
      id: 'reminder-${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      title: title,
      description: description,
      icon: icon ?? _getDefaultIcon(type),
      color: color ?? _getDefaultColor(type),
      interval: interval,
      isEnabled: true,
    );

    // Schedule initial notification
    await _scheduleReminder(reminder);
    
    return reminder;
  }

  /// Use case: Update reminder settings
  Future<Reminder> updateReminder(
    Reminder reminder, {
    String? title,
    String? description,
    Duration? interval,
    bool? isEnabled,
  }) async {
    final updatedReminder = Reminder(
      id: reminder.id,
      type: reminder.type,
      title: title ?? reminder.title,
      description: description ?? reminder.description,
      icon: reminder.icon,
      color: reminder.color,
      interval: interval ?? reminder.interval,
      isEnabled: isEnabled ?? reminder.isEnabled,
      nextReminder: reminder.nextReminder,
    );

    // Reschedule if interval changed or enabling/disabling
    if (interval != null || isEnabled != null) {
      if (updatedReminder.isEnabled) {
        await _scheduleReminder(updatedReminder);
      } else {
        await _cancelReminder(updatedReminder);
      }
    }

    return updatedReminder;
  }

  /// Use case: Complete a reminder and update statistics
  Future<void> completeReminder(
    Reminder reminder,
    Statistics statistics, {
    int customCount = 1,
  }) async {
    // Update statistics
    statistics.addCompletion(reminder.id, DateTime.now());
    statistics.incrementDailyCompletion(reminder.id);
    statistics.incrementWeeklyCompletion(reminder.id);
    statistics.incrementMonthlyCompletion(reminder.id);

    // Schedule next reminder
    reminder.scheduleNext();
    await _scheduleReminder(reminder);

    // Show completion feedback
    await notificationAdapter.showNotification(
      id: reminder.id.hashCode,
      title: 'Great job!',
      body: 'You completed: ${reminder.title}',
    );
  }

  /// Use case: Start reminder system
  Future<void> startReminders(List<Reminder> reminders) async {
    for (final reminder in reminders) {
      if (reminder.isEnabled) {
        // Set next reminder time if not already set
        if (reminder.nextReminder == null) {
          reminder.scheduleNext();
        }
        await _scheduleReminder(reminder);
      }
    }
  }

  /// Use case: Stop all reminders
  Future<void> stopReminders(List<Reminder> reminders) async {
    await notificationAdapter.cancelAllNotifications();
    
    for (final reminder in reminders) {
      reminder.nextReminder = null;
    }
  }

  /// Use case: Get reminders that are due
  List<Reminder> getDueReminders(List<Reminder> reminders) {
    return reminders
        .where((reminder) => reminder.isEnabled && reminder.isDue())
        .toList();
  }

  /// Use case: Get next reminder time across all reminders
  DateTime? getNextReminderTime(List<Reminder> reminders) {
    final enabledReminders = reminders
        .where((r) => r.isEnabled && r.nextReminder != null)
        .toList();

    if (enabledReminders.isEmpty) return null;

    return enabledReminders
        .map((r) => r.nextReminder!)
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  /// Use case: Validate reminder configuration
  List<String> validateReminderConfiguration(Reminder reminder) {
    final errors = <String>[];

    if (reminder.title.isEmpty) {
      errors.add('Title is required');
    }

    if (reminder.title.length > 50) {
      errors.add('Title must be 50 characters or less');
    }

    if (reminder.description.length > 200) {
      errors.add('Description must be 200 characters or less');
    }

    if (reminder.interval.inSeconds < 1) {
      errors.add('Interval must be at least 1 second');
    }

    if (reminder.interval.inDays > 365) {
      errors.add('Interval cannot exceed 1 year');
    }

    return errors;
  }

  // Private helper methods
  Future<void> _scheduleReminder(Reminder reminder) async {
    if (reminder.nextReminder == null) return;

    await notificationAdapter.scheduleNotification(
      id: reminder.id.hashCode,
      title: reminder.title,
      body: reminder.description,
      scheduledDate: reminder.nextReminder!,
    );
  }

  Future<void> _cancelReminder(Reminder reminder) async {
    await notificationAdapter.cancelNotification(reminder.id.hashCode);
  }

  IconData _getDefaultIcon(ReminderType type) {
    switch (type) {
      case ReminderType.water:
        return Icons.water_drop;
      case ReminderType.exercise:
        return Icons.fitness_center;
      case ReminderType.eyeRest:
        return Icons.visibility;
      case ReminderType.stretching:
        return Icons.accessibility_new;
      case ReminderType.custom:
        return Icons.notifications;
      case ReminderType.standUp:
        return Icons.airline_seat_recline_normal;
      case ReminderType.pullUps:
      case ReminderType.pushUps:
      case ReminderType.squats:
      case ReminderType.jumpingJacks:
      case ReminderType.planks:
      case ReminderType.burpees:
        return Icons.fitness_center;
      case ReminderType.stretch:
        return Icons.accessibility_new;
    }
  }

  Color _getDefaultColor(ReminderType type) {
    switch (type) {
      case ReminderType.water:
        return Colors.blue;
      case ReminderType.exercise:
        return Colors.green;
      case ReminderType.eyeRest:
        return Colors.orange;
      case ReminderType.stretching:
        return Colors.purple;
      case ReminderType.custom:
        return Colors.grey;
      case ReminderType.standUp:
        return Colors.teal;
      case ReminderType.pullUps:
      case ReminderType.pushUps:
      case ReminderType.squats:
      case ReminderType.jumpingJacks:
      case ReminderType.planks:
      case ReminderType.burpees:
        return Colors.indigo;
      case ReminderType.stretch:
        return Colors.purple;
    }
  }
}

void main() {
  group('Reminder Use Cases Tests', () {
    late ReminderUseCases useCases;
    late MockNotificationAdapter mockNotificationAdapter;
    late MockSharedPreferencesAdapter mockStorageAdapter;

    setUp(() {
      mockNotificationAdapter = MockNotificationAdapter();
      mockStorageAdapter = MockSharedPreferencesAdapter();
      
      useCases = ReminderUseCases(
        notificationAdapter: mockNotificationAdapter,
        storageAdapter: mockStorageAdapter,
      );

      // Setup default mock behaviors
      when(mockNotificationAdapter.initialize()).thenAnswer((_) async => true);
    });

    group('Create Reminder Use Case', () {
      test('should create reminder with valid data', () async {
        // Act
        final reminder = await useCases.createReminder(
          title: 'Water Break',
          description: 'Time to drink water',
          type: ReminderType.water,
          interval: const Duration(minutes: 30),
        );

        // Assert
        expect(reminder.title, equals('Water Break'));
        expect(reminder.description, equals('Time to drink water'));
        expect(reminder.type, equals(ReminderType.water));
        expect(reminder.interval, equals(const Duration(minutes: 30)));
        expect(reminder.isEnabled, isTrue);
        expect(reminder.id, isNotEmpty);
        
        // Verify notification was scheduled  
        verify(mockNotificationAdapter.scheduleNotification).called(1);
      });

      test('should throw error for empty title', () async {
        // Act & Assert
        expect(
          () => useCases.createReminder(
            title: '',
            description: 'Description',
            type: ReminderType.water,
            interval: const Duration(minutes: 30),
          ),
          throwsArgumentError,
        );
      });

      test('should throw error for invalid interval', () async {
        // Act & Assert
        expect(
          () => useCases.createReminder(
            title: 'Title',
            description: 'Description',
            type: ReminderType.water,
            interval: const Duration(seconds: 0),
          ),
          throwsArgumentError,
        );
      });

      test('should use custom icon and color when provided', () async {
        // Act
        final reminder = await useCases.createReminder(
          title: 'Custom Reminder',
          description: 'Custom description',
          type: ReminderType.custom,
          interval: const Duration(hours: 1),
          icon: Icons.star,
          color: Colors.pink,
        );

        // Assert
        expect(reminder.icon, equals(Icons.star));
        expect(reminder.color, equals(Colors.pink));
      });
    });

    group('Update Reminder Use Case', () {
      test('should update reminder title and description', () async {
        // Arrange
        final originalReminder = TestReminders.water;

        // Act
        final updatedReminder = await useCases.updateReminder(
          originalReminder,
          title: 'Updated Water',
          description: 'Updated description',
        );

        // Assert
        expect(updatedReminder.title, equals('Updated Water'));
        expect(updatedReminder.description, equals('Updated description'));
        expect(updatedReminder.id, equals(originalReminder.id));
        expect(updatedReminder.type, equals(originalReminder.type));
      });

      test('should reschedule when interval changes', () async {
        // Arrange
        final originalReminder = TestReminders.water;

        // Act
        await useCases.updateReminder(
          originalReminder,
          interval: const Duration(hours: 1),
        );

        // Assert
        verify(mockNotificationAdapter.scheduleNotification).called(1);
      });

      test('should cancel notification when disabling reminder', () async {
        // Arrange
        final originalReminder = TestReminders.water;

        // Act
        await useCases.updateReminder(
          originalReminder,
          isEnabled: false,
        );

        // Assert
        verify(mockNotificationAdapter.cancelNotification).called(1);
      });
    });

    group('Complete Reminder Use Case', () {
      test('should update statistics and schedule next reminder', () async {
        // Arrange
        final reminder = TestReminders.water;
        final statistics = Statistics();

        // Act
        await useCases.completeReminder(reminder, statistics);

        // Assert
        expect(statistics.totalCompletions[reminder.id], equals(1));
        expect(statistics.dailyCompletions[reminder.id], equals(1));
        
        // Verify notification was shown
        verify(mockNotificationAdapter.showNotification).called(1);

        // Verify next reminder was scheduled
        verify(mockNotificationAdapter.scheduleNotification).called(1);
      });

      test('should handle custom completion count', () async {
        // Arrange
        final reminder = TestReminders.water;
        final statistics = Statistics();

        // Act
        await useCases.completeReminder(reminder, statistics, customCount: 3);

        // Assert
        expect(statistics.totalCompletions[reminder.id], equals(3));
      });
    });

    group('Start Reminders Use Case', () {
      test('should schedule all enabled reminders', () async {
        // Arrange
        final reminders = [
          TestReminders.water,
          TestReminders.exercise,
          TestReminders.stretching, // disabled
        ];

        // Act
        await useCases.startReminders(reminders);

        // Assert - should only schedule enabled reminders
        verify(mockNotificationAdapter.scheduleNotification).called(2); // water and exercise only
      });

      test('should set next reminder time if not already set', () async {
        // Arrange
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Water',
          description: 'Hydrate',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
          isEnabled: true,
          nextReminder: null, // Not set
        );

        // Act
        await useCases.startReminders([reminder]);

        // Assert
        expect(reminder.nextReminder, isNotNull);
        expect(reminder.nextReminder!.isAfter(DateTime.now()), isTrue);
      });
    });

    group('Stop Reminders Use Case', () {
      test('should cancel all notifications and clear next reminder times', () async {
        // Arrange
        final reminders = TestReminders.enabled;

        // Act
        await useCases.stopReminders(reminders);

        // Assert
        verify(mockNotificationAdapter.cancelAllNotifications()).called(1);
        
        for (final reminder in reminders) {
          expect(reminder.nextReminder, isNull);
        }
      });
    });

    group('Get Due Reminders Use Case', () {
      test('should return only due and enabled reminders', () {
        // Arrange
        final now = DateTime.now();
        final dueReminder = Reminder(
          id: 'due-1',
          type: ReminderType.water,
          title: 'Due Water',
          description: 'Overdue',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
          isEnabled: true,
          nextReminder: now.subtract(const Duration(minutes: 5)),
        );

        final notDueReminder = Reminder(
          id: 'notdue-1',
          type: ReminderType.exercise,
          title: 'Not Due Exercise',
          description: 'Future',
          icon: Icons.fitness_center,
          color: Colors.green,
          interval: const Duration(hours: 2),
          isEnabled: true,
          nextReminder: now.add(const Duration(minutes: 30)),
        );

        final disabledReminder = Reminder(
          id: 'disabled-1',
          type: ReminderType.stretching,
          title: 'Disabled',
          description: 'Disabled',
          icon: Icons.accessibility_new,
          color: Colors.purple,
          interval: const Duration(hours: 1),
          isEnabled: false,
          nextReminder: now.subtract(const Duration(minutes: 10)),
        );

        final reminders = [dueReminder, notDueReminder, disabledReminder];

        // Act
        final dueReminders = useCases.getDueReminders(reminders);

        // Assert
        expect(dueReminders.length, equals(1));
        expect(dueReminders.first.id, equals('due-1'));
      });
    });

    group('Get Next Reminder Time Use Case', () {
      test('should return earliest next reminder time', () {
        // Arrange
        final now = DateTime.now();
        final reminder1 = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Water',
          description: 'Hydrate',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
          isEnabled: true,
          nextReminder: now.add(const Duration(minutes: 45)),
        );

        final reminder2 = Reminder(
          id: 'test-2',
          type: ReminderType.exercise,
          title: 'Exercise',
          description: 'Move',
          icon: Icons.fitness_center,
          color: Colors.green,
          interval: const Duration(hours: 2),
          isEnabled: true,
          nextReminder: now.add(const Duration(minutes: 30)), // Earlier
        );

        final reminders = [reminder1, reminder2];

        // Act
        final nextTime = useCases.getNextReminderTime(reminders);

        // Assert
        expect(nextTime, isNotNull);
        expect(nextTime, equals(reminder2.nextReminder));
      });

      test('should return null when no enabled reminders', () {
        // Arrange
        final reminders = [TestReminders.stretching]; // disabled

        // Act
        final nextTime = useCases.getNextReminderTime(reminders);

        // Assert
        expect(nextTime, isNull);
      });
    });

    group('Validate Reminder Configuration Use Case', () {
      test('should return no errors for valid reminder', () {
        // Arrange
        final reminder = TestReminders.water;

        // Act
        final errors = useCases.validateReminderConfiguration(reminder);

        // Assert
        expect(errors, isEmpty);
      });

      test('should return error for empty title', () {
        // Arrange
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: '', // Empty
          description: 'Description',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
        );

        // Act
        final errors = useCases.validateReminderConfiguration(reminder);

        // Assert
        expect(errors, contains('Title is required'));
      });

      test('should return error for title too long', () {
        // Arrange
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'A' * 51, // Too long
          description: 'Description',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
        );

        // Act
        final errors = useCases.validateReminderConfiguration(reminder);

        // Assert
        expect(errors, contains('Title must be 50 characters or less'));
      });

      test('should return error for invalid interval', () {
        // Arrange
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Title',
          description: 'Description',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(seconds: 0), // Invalid
        );

        // Act
        final errors = useCases.validateReminderConfiguration(reminder);

        // Assert
        expect(errors, contains('Interval must be at least 1 second'));
      });

      test('should return multiple errors for multiple issues', () {
        // Arrange
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: '', // Empty
          description: 'A' * 201, // Too long
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(days: 400), // Too long
        );

        // Act
        final errors = useCases.validateReminderConfiguration(reminder);

        // Assert
        expect(errors.length, equals(3));
        expect(errors, contains('Title is required'));
        expect(errors, contains('Description must be 200 characters or less'));
        expect(errors, contains('Interval cannot exceed 1 year'));
      });
    });
  });
}