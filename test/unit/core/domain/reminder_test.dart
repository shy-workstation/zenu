import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenu/models/reminder.dart';

void main() {
  group('Reminder Domain Model Tests', () {
    group('Creation and Initialization', () {
      test('should create reminder with required fields', () {
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Water Reminder',
          description: 'Stay hydrated',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
        );

        expect(reminder.id, equals('test-1'));
        expect(reminder.type, equals(ReminderType.water));
        expect(reminder.title, equals('Water Reminder'));
        expect(reminder.description, equals('Stay hydrated'));
        expect(reminder.icon, equals(Icons.water_drop));
        expect(reminder.color, equals(Colors.blue));
        expect(reminder.interval, equals(const Duration(minutes: 30)));
        expect(reminder.isEnabled, isTrue);
        expect(reminder.nextReminder, isNull);
        expect(reminder.completionLog, isEmpty);
      });

      test('should create reminder with custom enabled state', () {
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.pushUps,
          title: 'Push-ups',
          description: 'Stay active',
          icon: Icons.fitness_center,
          color: Colors.green,
          interval: const Duration(hours: 2),
          isEnabled: false,
        );

        expect(reminder.isEnabled, isFalse);
      });

      test('should create reminder with next reminder time', () {
        final nextTime = DateTime.now().add(const Duration(minutes: 30));

        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.eyeRest,
          title: 'Eye Rest',
          description: 'Look away from screen',
          icon: Icons.remove_red_eye,
          color: Colors.orange,
          interval: const Duration(minutes: 20),
          nextReminder: nextTime,
        );

        expect(reminder.nextReminder, equals(nextTime));
      });
    });

    group('Business Logic', () {
      test('should set next reminder time correctly via resetNextReminder', () {
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Water',
          description: 'Hydrate',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
        );

        final before = DateTime.now();
        reminder.resetNextReminder();
        final after = DateTime.now();

        expect(reminder.nextReminder, isNotNull);
        expect(
          reminder.nextReminder!.isAfter(before.add(const Duration(minutes: 29))),
          isTrue,
        );
        expect(
          reminder.nextReminder!.isBefore(after.add(const Duration(minutes: 31))),
          isTrue,
        );
      });

      test('should determine if reminder is due', () {
        final pastTime = DateTime.now().subtract(const Duration(minutes: 5));
        final futureTime = DateTime.now().add(const Duration(minutes: 5));

        final dueReminder = Reminder(
          id: 'due-1',
          type: ReminderType.water,
          title: 'Due Water',
          description: 'Overdue reminder',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
          nextReminder: pastTime,
        );

        final notDueReminder = Reminder(
          id: 'notdue-1',
          type: ReminderType.water,
          title: 'Future Water',
          description: 'Future reminder',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
          nextReminder: futureTime,
        );

        expect(dueReminder.isDue(), isTrue);
        expect(notDueReminder.isDue(), isFalse);
      });

      test('should handle null next reminder time in isDue check', () {
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Water',
          description: 'Hydrate',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
          nextReminder: null,
        );

        expect(reminder.isDue(), isFalse);
      });

      test('should calculate time until next reminder', () {
        final futureTime = DateTime.now().add(const Duration(minutes: 15));
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Water',
          description: 'Hydrate',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
          nextReminder: futureTime,
        );

        final timeUntil = reminder.timeUntilNext;

        expect(timeUntil, isNotNull);
        if (timeUntil != null) {
          expect(timeUntil.inMinutes, closeTo(15, 1));
        }
      });

      test('should return null for time until next when no next reminder set', () {
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Water',
          description: 'Hydrate',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
        );

        expect(reminder.timeUntilNext, isNull);
      });
    });

    group('Completion Tracking', () {
      test('should log completion with custom count', () {
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Water',
          description: 'Hydrate',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
        );

        reminder.completeReminder(customCount: 250);

        expect(reminder.totalCompleted, equals(1));
        expect(reminder.completionLog.length, equals(1));
        expect(reminder.completionLog.first['qty'], equals(250));
        expect(reminder.todayTotal, equals(250));
        expect(reminder.todayCount, equals(1));
      });

      test('should accumulate multiple completions', () {
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Water',
          description: 'Hydrate',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
        );

        reminder.completeReminder(customCount: 250);
        reminder.completeReminder(customCount: 500);

        expect(reminder.totalCompleted, equals(2));
        expect(reminder.todayTotal, equals(750));
        expect(reminder.todayCount, equals(2));
      });

      test('should prune old entries', () {
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Water',
          description: 'Hydrate',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
          completionLog: [
            {'date': '2020-01-01', 'qty': 100},
            {'date': DateTime.now().toIso8601String().substring(0, 10), 'qty': 200},
          ],
        );

        reminder.pruneOldEntries();

        expect(reminder.completionLog.length, equals(1));
        expect(reminder.completionLog.first['qty'], equals(200));
      });
    });

    group('Serialization', () {
      test('should serialize to JSON correctly', () {
        final nextTime = DateTime(2024, 1, 1, 10, 30, 0);
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Water Reminder',
          description: 'Stay hydrated',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
          isEnabled: true,
          nextReminder: nextTime,
        );

        final json = reminder.toJson();

        expect(json['id'], equals('test-1'));
        expect(json['type'], equals('water'));
        expect(json['title'], equals('Water Reminder'));
        expect(json['description'], equals('Stay hydrated'));
        expect(json['iconCodePoint'], equals(Icons.water_drop.codePoint));
        expect(json['iconFontFamily'], equals(Icons.water_drop.fontFamily));
        expect(json['interval'], equals(1800));
        expect(json['isEnabled'], isTrue);
        expect(json['nextReminder'], equals(nextTime.millisecondsSinceEpoch));
        expect(json['completionLog'], isEmpty);
      });

      test('should deserialize from JSON correctly', () {
        final nextTime = DateTime(2024, 1, 1, 10, 30, 0);
        final json = {
          'id': 'test-1',
          'type': 'water',
          'title': 'Water Reminder',
          'description': 'Stay hydrated',
          'iconCodePoint': Icons.water_drop.codePoint,
          'iconFontFamily': Icons.water_drop.fontFamily,
          'colorValue': 'ff2196f3',
          'interval': 1800,
          'isEnabled': true,
          'nextReminder': nextTime.millisecondsSinceEpoch,
          'completionLog': [
            {'date': '2024-01-01', 'qty': 250},
          ],
        };

        final reminder = Reminder.fromJson(json);

        expect(reminder.id, equals('test-1'));
        expect(reminder.type, equals(ReminderType.water));
        expect(reminder.title, equals('Water Reminder'));
        expect(reminder.interval, equals(const Duration(minutes: 30)));
        expect(reminder.isEnabled, isTrue);
        expect(reminder.nextReminder, equals(nextTime));
        expect(reminder.completionLog.length, equals(1));
      });

      test('should handle old index-based type serialization', () {
        final json = {
          'id': 'test-1',
          'type': 0,
          'title': 'Water',
          'description': 'Hydrate',
          'iconCodePoint': Icons.water_drop.codePoint,
          'iconFontFamily': Icons.water_drop.fontFamily,
          'colorValue': 'ff2196f3',
          'interval': 1800,
        };

        final reminder = Reminder.fromJson(json);
        expect(reminder.type, equals(ReminderType.water));
      });

      test('should handle missing optional fields in JSON deserialization', () {
        final json = {
          'id': 'test-1',
          'type': 'eyeRest',
          'title': 'Eye Rest',
          'description': 'Look away',
          'iconCodePoint': Icons.remove_red_eye.codePoint,
          'iconFontFamily': Icons.remove_red_eye.fontFamily,
          'colorValue': 'ff4caf50',
          'interval': 1200,
        };

        final reminder = Reminder.fromJson(json);

        expect(reminder.isEnabled, isTrue);
        expect(reminder.nextReminder, isNull);
        expect(reminder.completionLog, isEmpty);
      });
    });

    group('ReminderType Enum', () {
      test('should have correct enum values', () {
        expect(ReminderType.values.length, equals(12));
        expect(ReminderType.water.name, equals('water'));
        expect(ReminderType.eyeRest.name, equals('eyeRest'));
        expect(ReminderType.standUp.name, equals('standUp'));
        expect(ReminderType.pushUps.name, equals('pushUps'));
        expect(ReminderType.stretch.name, equals('stretch'));
        expect(ReminderType.deepBreathing.name, equals('deepBreathing'));
        expect(ReminderType.meditation.name, equals('meditation'));
      });
    });

    group('Edge Cases', () {
      test('should handle very short intervals', () {
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Frequent',
          description: 'Very frequent reminder',
          icon: Icons.water_drop,
          color: Colors.red,
          interval: const Duration(seconds: 1),
        );

        expect(reminder.interval.inSeconds, equals(1));
      });

      test('should handle very long intervals', () {
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Rare',
          description: 'Very rare reminder',
          icon: Icons.water_drop,
          color: Colors.red,
          interval: const Duration(days: 7),
        );

        expect(reminder.interval.inDays, equals(7));
      });
    });
  });
}
