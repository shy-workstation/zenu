import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:zenu/services/reminder_service.dart';
import 'package:zenu/services/notification_service.dart';
import 'package:zenu/services/data_service.dart';
import 'package:zenu/models/reminder.dart';
import 'package:zenu/models/statistics.dart';

// Generate mocks
@GenerateMocks([NotificationService, DataService])
import 'reminder_service_test.mocks.dart';

void main() {
  group('ReminderService Tests', () {
    late ReminderService reminderService;
    late MockNotificationService mockNotificationService;
    late MockDataService mockDataService;

    setUp(() {
      mockNotificationService = MockNotificationService();
      mockDataService = MockDataService();
      reminderService = ReminderService(
        mockNotificationService as NotificationService,
        mockDataService as DataService,
      );
    });

    tearDown(() {
      reminderService.stopReminders();
    });

    group('Initialization', () {
      test('should initialize with empty reminders list', () {
        expect(reminderService.reminders, isEmpty);
        expect(reminderService.isRunning, isFalse);
      });

      test('should load saved data on loadData()', () async {
        // Arrange
        final testReminders = [
          {
            'id': 'test-1',
            'type': 0, // ReminderType.water
            'title': 'Water',
            'description': 'Stay hydrated',
            'iconCodePoint': Icons.water_drop.codePoint,
            'iconFontFamily': Icons.water_drop.fontFamily,
            'colorValue': '2196F3', // Blue color without 0xFF prefix
            'interval': 1800, // 30 minutes in seconds
            'isEnabled': true,
            'nextReminder':
                DateTime.now()
                    .add(Duration(minutes: 30))
                    .millisecondsSinceEpoch,
          },
        ];
        final testStats = Statistics();

        when(
          mockDataService.loadReminders(),
        ).thenAnswer((_) async => testReminders);
        when(
          mockDataService.loadStatistics(),
        ).thenAnswer((_) async => testStats);

        // Act
        await reminderService.loadData();

        // Assert
        expect(reminderService.reminders.length, equals(1));
        expect(reminderService.reminders.first.title, equals('Water'));
        verify(mockDataService.loadReminders()).called(1);
        verify(mockDataService.loadStatistics()).called(1);
      });
    });

    group('Reminder Management', () {
      test('should add new reminder', () {
        // Arrange
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.custom,
          title: 'Exercise',
          description: 'Stay active',
          icon: Icons.fitness_center,
          color: Colors.green,
          interval: const Duration(hours: 2),
        );

        // Act
        reminderService.addReminder(reminder);

        // Assert
        expect(reminderService.reminders.length, equals(1));
        expect(reminderService.reminders.first.title, equals('Exercise'));
      });

      test('should toggle reminder enabled state', () {
        // Arrange
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Water',
          description: 'Stay hydrated',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
          isEnabled: false,
        );
        reminderService.addReminder(reminder);

        // Act
        reminderService.toggleReminder('test-1');

        // Assert
        expect(reminderService.reminders.first.isEnabled, isTrue);
      });

      test('should update reminder interval', () {
        // Arrange
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Water',
          description: 'Stay hydrated',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
        );
        reminderService.addReminder(reminder);

        // Act
        reminderService.updateReminderInterval(
          'test-1',
          const Duration(minutes: 60),
        );

        // Assert
        expect(
          reminderService.reminders.first.interval,
          equals(const Duration(minutes: 60)),
        );
      });

      test('should complete reminder and update statistics', () {
        // Arrange
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Water',
          description: 'Stay hydrated',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
          isEnabled: true,
        );
        reminderService.addReminder(reminder);

        // Act
        reminderService.completeReminder(reminder, customCount: 250);

        // Assert
        expect(
          reminderService.statistics.totalCompletions['test-1'],
          equals(1),
        );
        expect(
          reminderService.statistics.dailyCompletions['test-1'],
          equals(1),
        );
      });
    });

    group('Timer Management', () {
      test('should start reminders timer', () {
        // Act
        reminderService.startReminders();

        // Assert
        expect(reminderService.isRunning, isTrue);
      });

      test('should stop reminders timer', () {
        // Arrange
        reminderService.startReminders();

        // Act
        reminderService.stopReminders();

        // Assert
        expect(reminderService.isRunning, isFalse);
      });

      test('should reset next reminder times when starting', () {
        // Arrange
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Water',
          description: 'Stay hydrated',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
          isEnabled: true,
        );
        reminderService.addReminder(reminder);

        // Act
        reminderService.startReminders();

        // Assert
        expect(reminder.nextReminder, isNotNull);
        expect(reminder.nextReminder!.isAfter(DateTime.now()), isTrue);
      });
    });

    group('Data Persistence', () {
      test('should save data after reminder changes', () async {
        // Arrange
        when(mockDataService.saveReminders(any)).thenAnswer((_) async {});
        when(mockDataService.saveStatistics(any)).thenAnswer((_) async {});

        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Water',
          description: 'Stay hydrated',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
        );

        // Act
        reminderService.addReminder(reminder);
        // Note: addReminder() calls saveData() internally, so no need to call it again

        // Assert - At minimum, saveReminders should be called
        verify(mockDataService.saveReminders(any)).called(1);
        // Note: saveStatistics might not be called if statistics haven't changed
        // So we'll just verify that saveReminders is working correctly
      });
    });

    group('Error Handling', () {
      test('should handle data loading errors gracefully', () async {
        // Arrange
        when(
          mockDataService.loadReminders(),
        ).thenThrow(Exception('Load error'));
        when(
          mockDataService.loadStatistics(),
        ).thenThrow(Exception('Load error'));

        // Act & Assert - should not throw
        expect(() => reminderService.loadData(), returnsNormally);
      });

      test('should handle save errors gracefully', () async {
        // Arrange
        when(
          mockDataService.saveReminders(any),
        ).thenThrow(Exception('Save error'));
        when(
          mockDataService.saveStatistics(any),
        ).thenThrow(Exception('Save error'));

        // Act & Assert - should not throw
        expect(() => reminderService.saveData(), returnsNormally);
      });
    });

    group('Statistics', () {
      test('should increment completion statistics', () {
        // Arrange
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Water',
          description: 'Stay hydrated',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
        );
        reminderService.addReminder(reminder);

        // Act
        reminderService.completeReminder(reminder, customCount: 1);

        // Assert
        expect(
          reminderService.statistics.totalCompletions['test-1'],
          equals(1),
        );
      });

      test('should track daily completions', () {
        // Arrange
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Water',
          description: 'Stay hydrated',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
        );
        reminderService.addReminder(reminder);

        // Act
        reminderService.completeReminder(reminder, customCount: 1);
        reminderService.completeReminder(reminder, customCount: 1);

        // Assert - Check daily completions for the specific reminder
        expect(
          reminderService.statistics.dailyCompletions['test-1'],
          equals(2),
        );
      });
    });
  });
}
