import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenu/models/reminder.dart';

void main() {
  group('Reminder Domain Model Tests', () {
    group('Creation and Initialization', () {
      test('should create reminder with required fields', () {
        // Arrange & Act
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Water Reminder',
          description: 'Stay hydrated',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
        );

        // Assert
        expect(reminder.id, equals('test-1'));
        expect(reminder.type, equals(ReminderType.water));
        expect(reminder.title, equals('Water Reminder'));
        expect(reminder.description, equals('Stay hydrated'));
        expect(reminder.icon, equals(Icons.water_drop));
        expect(reminder.color, equals(Colors.blue));
        expect(reminder.interval, equals(const Duration(minutes: 30)));
        expect(reminder.isEnabled, isTrue); // Default value
        expect(reminder.nextReminder, isNull); // Default value
      });

      test('should create reminder with custom enabled state', () {
        // Arrange & Act
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.exercise,
          title: 'Exercise',
          description: 'Stay active',
          icon: Icons.fitness_center,
          color: Colors.green,
          interval: const Duration(hours: 2),
          isEnabled: false,
        );

        // Assert
        expect(reminder.isEnabled, isFalse);
      });

      test('should create reminder with next reminder time', () {
        // Arrange
        final nextTime = DateTime.now().add(const Duration(minutes: 30));

        // Act
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.eyeRest,
          title: 'Eye Rest',
          description: 'Look away from screen',
          icon: Icons.visibility,
          color: Colors.orange,
          interval: const Duration(minutes: 20),
          nextReminder: nextTime,
        );

        // Assert
        expect(reminder.nextReminder, equals(nextTime));
      });
    });

    group('Business Logic', () {
      test('should calculate next reminder time correctly', () {
        // Arrange
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Water',
          description: 'Hydrate',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
        );

        // Act
        reminder.scheduleNext();

        // Assert
        expect(
          reminder.nextReminder,
          equals(DateTime(2024, 1, 1, 10, 30, 0)),
        );
      });

      test('should determine if reminder is due', () {
        // Arrange
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

        // Assert
        expect(dueReminder.isDue(), isTrue);
        expect(notDueReminder.isDue(), isFalse);
      });

      test('should handle null next reminder time in isDue check', () {
        // Arrange
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

        // Act & Assert
        expect(reminder.isDue(), isFalse);
      });

      test('should calculate time until next reminder', () {
        // Arrange
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

        // Act
        final timeUntil = reminder.timeUntilNext;

        // Assert
        expect(timeUntil, isNotNull);
        if (timeUntil != null) {
          expect(timeUntil.inMinutes, closeTo(15, 1)); // Within 1 minute tolerance
        }
      });

      test('should return null for time until next when no next reminder set', () {
        // Arrange
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Water',
          description: 'Hydrate',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
        );

        // Act
        final timeUntil = reminder.timeUntilNext;

        // Assert
        expect(timeUntil, isNull);
      });
    });

    group('Serialization', () {
      test('should serialize to JSON correctly', () {
        // Arrange
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

        // Act
        final json = reminder.toJson();

        // Assert
        expect(json['id'], equals('test-1'));
        expect(json['type'], equals(0)); // ReminderType.water.index
        expect(json['title'], equals('Water Reminder'));
        expect(json['description'], equals('Stay hydrated'));
        expect(json['iconCodePoint'], equals(Icons.water_drop.codePoint));
        expect(json['iconFontFamily'], equals(Icons.water_drop.fontFamily));
        expect(json['colorValue'], equals('FF2196F3')); // Blue color hex
        expect(json['interval'], equals(1800)); // 30 minutes in seconds
        expect(json['isEnabled'], isTrue);
        expect(json['nextReminder'], equals(nextTime.millisecondsSinceEpoch));
      });

      test('should deserialize from JSON correctly', () {
        // Arrange
        final nextTime = DateTime(2024, 1, 1, 10, 30, 0);
        final json = {
          'id': 'test-1',
          'type': 0, // ReminderType.water
          'title': 'Water Reminder',
          'description': 'Stay hydrated',
          'iconCodePoint': Icons.water_drop.codePoint,
          'iconFontFamily': Icons.water_drop.fontFamily,
          'colorValue': 'FF2196F3',
          'interval': 1800,
          'isEnabled': true,
          'nextReminder': nextTime.millisecondsSinceEpoch,
        };

        // Act
        final reminder = Reminder.fromJson(json);

        // Assert
        expect(reminder.id, equals('test-1'));
        expect(reminder.type, equals(ReminderType.water));
        expect(reminder.title, equals('Water Reminder'));
        expect(reminder.description, equals('Stay hydrated'));
        expect(reminder.icon.codePoint, equals(Icons.water_drop.codePoint));
        expect(reminder.color, equals(Colors.blue));
        expect(reminder.interval, equals(const Duration(minutes: 30)));
        expect(reminder.isEnabled, isTrue);
        expect(reminder.nextReminder, equals(nextTime));
      });

      test('should handle missing optional fields in JSON deserialization', () {
        // Arrange
        final json = {
          'id': 'test-1',
          'type': 1, // ReminderType.exercise
          'title': 'Exercise',
          'description': 'Stay active',
          'iconCodePoint': Icons.fitness_center.codePoint,
          'iconFontFamily': Icons.fitness_center.fontFamily,
          'colorValue': 'FF4CAF50',
          'interval': 7200, // 2 hours
          // Missing isEnabled and nextReminder
        };

        // Act
        final reminder = Reminder.fromJson(json);

        // Assert
        expect(reminder.isEnabled, isTrue); // Default value
        expect(reminder.nextReminder, isNull); // Default value
      });
    });

    group('Equality and Hash Code', () {
      test('should be equal when all fields match', () {
        // Arrange
        final reminder1 = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Water',
          description: 'Hydrate',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
        );

        final reminder2 = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Water',
          description: 'Hydrate',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
        );

        // Act & Assert
        expect(reminder1, equals(reminder2));
        expect(reminder1.hashCode, equals(reminder2.hashCode));
      });

      test('should not be equal when IDs differ', () {
        // Arrange
        final reminder1 = Reminder(
          id: 'test-1',
          type: ReminderType.water,
          title: 'Water',
          description: 'Hydrate',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
        );

        final reminder2 = Reminder(
          id: 'test-2',
          type: ReminderType.water,
          title: 'Water',
          description: 'Hydrate',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
        );

        // Act & Assert
        expect(reminder1, isNot(equals(reminder2)));
      });
    });

    group('Edge Cases', () {
      test('should handle very short intervals', () {
        // Arrange & Act
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.custom,
          title: 'Frequent',
          description: 'Very frequent reminder',
          icon: Icons.notifications,
          color: Colors.red,
          interval: const Duration(seconds: 1),
        );

        // Assert
        expect(reminder.interval.inSeconds, equals(1));
      });

      test('should handle very long intervals', () {
        // Arrange & Act
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.custom,
          title: 'Rare',
          description: 'Very rare reminder',
          icon: Icons.notifications,
          color: Colors.red,
          interval: const Duration(days: 7),
        );

        // Assert
        expect(reminder.interval.inDays, equals(7));
      });

      test('should handle special characters in title and description', () {
        // Arrange & Act
        final reminder = Reminder(
          id: 'test-1',
          type: ReminderType.custom,
          title: 'Title with émojis 🚰 and spéciäl chârs',
          description: 'Description with\nnewlines and\ttabs',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
        );

        // Assert
        expect(reminder.title, contains('émojis'));
        expect(reminder.title, contains('🚰'));
        expect(reminder.description, contains('\n'));
        expect(reminder.description, contains('\t'));
      });
    });

    group('ReminderType Enum', () {
      test('should have correct enum values', () {
        expect(ReminderType.values.length, equals(5));
        expect(ReminderType.water.index, equals(0));
        expect(ReminderType.exercise.index, equals(1));
        expect(ReminderType.eyeRest.index, equals(2));
        expect(ReminderType.stretching.index, equals(3));
        expect(ReminderType.custom.index, equals(4));
      });

      test('should convert enum to string correctly', () {
        expect(ReminderType.water.toString(), equals('ReminderType.water'));
        expect(ReminderType.exercise.toString(), equals('ReminderType.exercise'));
        expect(ReminderType.eyeRest.toString(), equals('ReminderType.eyeRest'));
        expect(ReminderType.stretching.toString(), equals('ReminderType.stretching'));
        expect(ReminderType.custom.toString(), equals('ReminderType.custom'));
      });
    });
  });
}