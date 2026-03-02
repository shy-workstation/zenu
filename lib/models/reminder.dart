import 'package:flutter/material.dart';

enum ReminderType {
  // Health
  water,
  eyeRest,
  standUp,
  // Exercise
  pushUps,
  pullUps,
  squats,
  jumpingJacks,
  burpees,
  // Mind & Body
  stretch,
  planks,
  deepBreathing,
  meditation,
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
  List<Map<String, dynamic>> completionLog;

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
    List<Map<String, dynamic>>? completionLog,
    this.minQuantity = 1,
    this.maxQuantity = 100,
    this.stepSize = 1,
    this.unit = 'reps',
  }) : completionLog = completionLog ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
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
    'colorValue': color.toARGB32().toRadixString(16).padLeft(8, '0'),
    'completionLog': completionLog,
  };

  factory Reminder.fromJson(Map<String, dynamic> json) {
    // Support both old index-based and new name-based type serialization
    final ReminderType type;
    if (json['type'] is int) {
      type = ReminderType.values[json['type']];
    } else {
      type = ReminderType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ReminderType.stretch,
      );
    }

    return Reminder(
      id: json['id'],
      type: type,
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
      completionLog: (json['completionLog'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }

  void resetNextReminder() {
    nextReminder = DateTime.now().add(interval);
  }

  void completeReminder({int? customCount}) {
    totalCompleted++;
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    completionLog.add({'date': todayStr, 'qty': customCount ?? 1});
    resetNextReminder();
  }

  void pruneOldEntries() {
    final cutoffStr = DateTime.now()
        .subtract(const Duration(days: 30))
        .toIso8601String()
        .substring(0, 10);
    completionLog.removeWhere(
      (e) => (e['date'] as String).compareTo(cutoffStr) < 0,
    );
  }

  List<Map<String, dynamic>> get todayCompletions {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    return completionLog.where((e) => e['date'] == todayStr).toList();
  }

  int get todayTotal =>
      todayCompletions.fold(0, (sum, e) => sum + (e['qty'] as int));

  int get todayCount => todayCompletions.length;

  Map<String, int> get dailyTotals {
    final map = <String, int>{};
    for (final e in completionLog) {
      final date = e['date'] as String;
      map[date] = (map[date] ?? 0) + (e['qty'] as int);
    }
    return map;
  }

  Duration? get timeUntilNext {
    if (nextReminder == null) return null;
    final diff = nextReminder!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  bool isDue() {
    if (!isEnabled || nextReminder == null) return false;
    return DateTime.now().isAfter(nextReminder!);
  }
}
