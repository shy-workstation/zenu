import '../entities/reminder_entity.dart';

/// Abstract repository interface for reminder data operations
/// 
/// This interface defines the contract for data operations without
/// depending on specific storage implementations
abstract class ReminderRepository {
  /// Retrieve all reminders
  Future<List<ReminderEntity>> getAllReminders();

  /// Get a specific reminder by ID
  Future<ReminderEntity?> getReminderById(String id);

  /// Save or update a reminder
  Future<void> saveReminder(ReminderEntity reminder);

  /// Delete a reminder
  Future<void> deleteReminder(String id);

  /// Get reminders by type
  Future<List<ReminderEntity>> getRemindersByType(ReminderType type);

  /// Get enabled reminders only
  Future<List<ReminderEntity>> getEnabledReminders();

  /// Get reminders that should trigger at the given time
  Future<List<ReminderEntity>> getRemindersDueAt(DateTime time);

  /// Bulk operations
  Future<void> saveMultipleReminders(List<ReminderEntity> reminders);
  Future<void> deleteMultipleReminders(List<String> ids);

  /// Search operations
  Future<List<ReminderEntity>> searchReminders(String query);
  Future<List<ReminderEntity>> getRemindersByTag(String tag);

  /// Statistics
  Future<int> getTotalReminderCount();
  Future<int> getActiveReminderCount();
  
  /// Stream for real-time updates
  Stream<List<ReminderEntity>> watchReminders();
  Stream<ReminderEntity?> watchReminderById(String id);
}