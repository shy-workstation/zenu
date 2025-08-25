import 'package:flutter/material.dart';

enum ReminderType {
  eyeRest,
  standUp,
  pullUps,
  pushUps,
  water,
  stretch,
  squats, // Kniebeugen
  jumpingJacks,
  planks,
  burpees,
  exercise, // Added missing exercise type
  stretching, // Added missing stretching type
  custom, // New custom type
}

class ReminderTemplate {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int minQuantity;
  final int maxQuantity;
  final int stepSize;
  final String unit;
  final Duration defaultInterval;

  const ReminderTemplate({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.minQuantity,
    required this.maxQuantity,
    required this.stepSize,
    required this.unit,
    required this.defaultInterval,
  });
}

class Reminder {
  final String id;
  final ReminderType type;
  final String title;
  final String description;
  final Duration interval;
  final IconData icon;
  final Color color;
  bool isEnabled;
  DateTime? nextReminder;
  int exerciseCount;
  int totalCompleted;

  // Dynamic properties for custom reminders
  final int minQuantity;
  final int maxQuantity;
  final int stepSize;
  final String unit;

  Reminder({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.interval,
    required this.icon,
    required this.color,
    this.isEnabled = true,
    this.nextReminder,
    this.exerciseCount = 0,
    this.totalCompleted = 0,
    this.minQuantity = 1,
    this.maxQuantity = 100,
    this.stepSize = 1,
    this.unit = 'reps',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.index,
    'title': title,
    'description': description,
    'interval': interval.inSeconds,
    'isEnabled': isEnabled,
    'nextReminder': nextReminder?.millisecondsSinceEpoch,
    'exerciseCount': exerciseCount,
    'totalCompleted': totalCompleted,
    'minQuantity': minQuantity,
    'maxQuantity': maxQuantity,
    'stepSize': stepSize,
    'unit': unit,
    'iconCodePoint': icon.codePoint,
    'iconFontFamily': icon.fontFamily,
    'colorValue':
        (color.a * 255).round().toRadixString(16).padLeft(2, '0') +
        (color.r * 255).round().toRadixString(16).padLeft(2, '0') +
        (color.g * 255).round().toRadixString(16).padLeft(2, '0') +
        (color.b * 255).round().toRadixString(16).padLeft(2, '0'),
  };

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      type: ReminderType.values[json['type']],
      title: json['title'],
      description: json['description'],
      interval: Duration(seconds: json['interval']),
      icon: IconData(
        json['iconCodePoint'] ?? Icons.fitness_center.codePoint,
        fontFamily: json['iconFontFamily'] ?? Icons.fitness_center.fontFamily,
      ),
      color: Color(int.parse(json['colorValue'] ?? 'ff2196f3', radix: 16)),
      isEnabled: json['isEnabled'] ?? true,
      nextReminder:
          json['nextReminder'] != null
              ? DateTime.fromMillisecondsSinceEpoch(json['nextReminder'])
              : null,
      exerciseCount: json['exerciseCount'] ?? 0,
      totalCompleted: json['totalCompleted'] ?? 0,
      minQuantity: json['minQuantity'] ?? 1,
      maxQuantity: json['maxQuantity'] ?? 100,
      stepSize: json['stepSize'] ?? 1,
      unit: json['unit'] ?? 'reps',
    );
  }

  void resetNextReminder() {
    nextReminder = DateTime.now().add(interval);
  }

  void completeReminder() {
    totalCompleted++;
    resetNextReminder();
  }

  Duration? get timeUntilNext {
    if (nextReminder == null) return null;
    final diff = nextReminder!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  // Add missing methods
  void scheduleNext() {
    nextReminder = DateTime.now().add(interval);
  }

  bool isDue() {
    if (!isEnabled || nextReminder == null) return false;
    return DateTime.now().isAfter(nextReminder!);
  }
}
