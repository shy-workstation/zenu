import 'package:equatable/equatable.dart';

/// Core business entity for reminders
/// 
/// This is platform-agnostic and contains only business logic
class ReminderEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final Duration interval;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime? lastTriggered;
  final List<String> tags;
  final ReminderType type;

  const ReminderEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.interval,
    required this.isEnabled,
    required this.createdAt,
    this.lastTriggered,
    this.tags = const [],
    this.type = ReminderType.general,
  });

  /// Business rule: Check if reminder should trigger
  bool shouldTrigger(DateTime now) {
    if (!isEnabled) return false;
    
    final triggerTime = lastTriggered ?? createdAt;
    return now.difference(triggerTime) >= interval;
  }

  /// Business rule: Calculate next trigger time
  DateTime getNextTriggerTime() {
    final lastTrigger = lastTriggered ?? createdAt;
    return lastTrigger.add(interval);
  }

  /// Business rule: Check if reminder is overdue
  bool isOverdue(DateTime now) {
    return now.isAfter(getNextTriggerTime());
  }

  ReminderEntity copyWith({
    String? id,
    String? title,
    String? description,
    Duration? interval,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? lastTriggered,
    List<String>? tags,
    ReminderType? type,
  }) {
    return ReminderEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      interval: interval ?? this.interval,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      lastTriggered: lastTriggered ?? this.lastTriggered,
      tags: tags ?? this.tags,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        interval,
        isEnabled,
        createdAt,
        lastTriggered,
        tags,
        type,
      ];
}

enum ReminderType {
  exercise,
  hydration,
  eyeRest,
  posture,
  general,
}