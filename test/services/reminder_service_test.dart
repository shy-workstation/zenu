import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:zenu/services/reminder_service.dart';
import 'package:zenu/services/notification_service.dart';
import 'package:zenu/services/data_service.dart';
import 'package:zenu/models/reminder.dart';

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
        final testReminders = [
          {
            'id': 'test-1',
            'type': 'water',
            'title': 'Water',
            'description': 'Stay hydrated',
            'iconCodePoint': Icons.water_drop.codePoint,
            'iconFontFamily': Icons.water_drop.fontFamily,
            'colorValue': 'ff2196f3',
            'interval': 1800,
            'isEnabled': true,
            'nextReminder':
                DateTime.now()
                    .add(const Duration(minutes: 30))
                    .millisecondsSinceEpoch,
          },
        ];

        when(mockDataService.loadReminders())
            .thenAnswer((_) async => testReminders);
        when(mockDataService.saveReminders(any)).thenAnswer((_) async {});

        await reminderService.loadData();

        expect(reminderService.reminders.length, equals(1));
        expect(reminderService.reminders.first.title, equals('Water'));
        verify(mockDataService.loadReminders()).called(1);
      });
    });

    group('Reminder Management', () {
      setUp(() {
        when(mockDataService.saveReminders(any)).thenAnswer((_) async {});
      });

      test('should add new reminder', () {
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.pushUps,
          title: 'Push-ups',
          description: 'Stay active',
          icon: Icons.fitness_center,
          color: Colors.green,
          interval: const Duration(hours: 2),
        );

        reminderService.addReminder(reminder);

        expect(reminderService.reminders.length, equals(1));
        expect(reminderService.reminders.first.title, equals('Push-ups'));
      });

      test('should toggle reminder enabled state', () {
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

        reminderService.toggleReminder('test-1');

        expect(reminderService.reminders.first.isEnabled, isTrue);
      });

      test('should complete reminder and log to completionLog', () {
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

        reminderService.completeReminder(reminder, customCount: 250);

        expect(reminder.totalCompleted, equals(1));
        expect(reminder.completionLog.length, equals(1));
        expect(reminder.completionLog.first['qty'], equals(250));
      });

      test('should remove reminder', () {
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

        reminderService.removeReminder('test-1');

        expect(reminderService.reminders, isEmpty);
      });
    });

    group('Timer Management', () {
      test('should start reminders timer', () {
        reminderService.startReminders();
        expect(reminderService.isRunning, isTrue);
      });

      test('should stop reminders timer', () {
        reminderService.startReminders();
        reminderService.stopReminders();
        expect(reminderService.isRunning, isFalse);
      });

      test('should set next reminder times when starting', () {
        when(mockDataService.saveReminders(any)).thenAnswer((_) async {});

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

        reminderService.startReminders();

        expect(reminder.nextReminder, isNotNull);
        expect(reminder.nextReminder!.isAfter(DateTime.now()), isTrue);
      });

      test('should preserve timer state on pause and resume', () {
        when(mockDataService.saveReminders(any)).thenAnswer((_) async {});

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

        reminderService.startReminders();
        final originalNext = reminder.nextReminder!;
        final remainingBefore = originalNext.difference(DateTime.now());

        reminderService.stopReminders();
        expect(reminder.nextReminder, isNull);

        reminderService.startReminders();
        expect(reminder.nextReminder, isNotNull);
        final remainingAfter = reminder.nextReminder!.difference(DateTime.now());

        // Should resume close to original remaining (within 2 sec tolerance)
        expect(
          (remainingAfter.inSeconds - remainingBefore.inSeconds).abs(),
          lessThan(2),
        );
      });

      test('clearTimers should reset all timers to full interval', () {
        when(mockDataService.saveReminders(any)).thenAnswer((_) async {});

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
        reminderService.startReminders();

        reminderService.clearTimers();

        expect(reminder.nextReminder, isNotNull);
        final remaining = reminder.nextReminder!.difference(DateTime.now());
        // Should be close to full 30-minute interval
        expect(remaining.inSeconds, greaterThan(29 * 60));
      });
    });

    group('Data Persistence', () {
      test('should save data after reminder changes', () {
        when(mockDataService.saveReminders(any)).thenAnswer((_) async {});

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

        verify(mockDataService.saveReminders(any)).called(1);
      });
    });

    group('Error Handling', () {
      test('should handle data loading errors gracefully', () async {
        when(mockDataService.loadReminders())
            .thenThrow(Exception('Load error'));

        expect(() => reminderService.loadData(), returnsNormally);
      });

      test('should handle save errors gracefully', () {
        when(mockDataService.saveReminders(any))
            .thenThrow(Exception('Save error'));

        expect(() => reminderService.saveData(), returnsNormally);
      });
    });
  });
}
