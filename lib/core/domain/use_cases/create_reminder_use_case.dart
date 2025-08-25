import 'package:uuid/uuid.dart';
import '../entities/reminder_entity.dart';
import '../repositories/reminder_repository.dart';

/// Use case for creating a new reminder
/// 
/// Encapsulates business logic for reminder creation including
/// validation and business rules
class CreateReminderUseCase {
  final ReminderRepository _repository;
  final Uuid _uuid = const Uuid();

  CreateReminderUseCase(this._repository);

  Future<ReminderEntity> execute({
    required String title,
    required String description,
    required Duration interval,
    ReminderType type = ReminderType.general,
    List<String> tags = const [],
    bool isEnabled = true,
  }) async {
    // Business validation
    _validateInput(title, description, interval);

    // Create entity with business rules
    final reminder = ReminderEntity(
      id: _uuid.v4(),
      title: title.trim(),
      description: description.trim(),
      interval: interval,
      type: type,
      tags: _sanitizeTags(tags),
      isEnabled: isEnabled,
      createdAt: DateTime.now(),
    );

    // Persist
    await _repository.saveReminder(reminder);

    return reminder;
  }

  void _validateInput(String title, String description, Duration interval) {
    if (title.trim().isEmpty) {
      throw ArgumentError('Reminder title cannot be empty');
    }

    if (title.length > 100) {
      throw ArgumentError('Reminder title cannot exceed 100 characters');
    }

    if (description.length > 500) {
      throw ArgumentError('Reminder description cannot exceed 500 characters');
    }

    if (interval.inSeconds < 60) {
      throw ArgumentError('Reminder interval cannot be less than 1 minute');
    }

    if (interval.inDays > 30) {
      throw ArgumentError('Reminder interval cannot exceed 30 days');
    }
  }

  List<String> _sanitizeTags(List<String> tags) {
    return tags
        .where((tag) => tag.trim().isNotEmpty)
        .map((tag) => tag.trim().toLowerCase())
        .toSet()
        .take(10) // Max 10 tags
        .toList();
  }
}