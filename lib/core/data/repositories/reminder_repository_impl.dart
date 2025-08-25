import 'dart:async';
import 'dart:convert';
import '../../domain/entities/reminder_entity.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../../infrastructure/adapters/storage_adapter.dart';

/// Implementation of ReminderRepository using StorageAdapter
/// 
/// Handles data persistence and retrieval for reminders using
/// the injected storage adapter (platform-agnostic)
class ReminderRepositoryImpl implements ReminderRepository {
  final StorageAdapter _storageAdapter;
  static const String _remindersKey = 'reminders';
  static const String _reminderPrefix = 'reminder_';

  final StreamController<List<ReminderEntity>> _remindersController =
      StreamController.broadcast();

  ReminderRepositoryImpl(this._storageAdapter);

  @override
  Future<List<ReminderEntity>> getAllReminders() async {
    try {
      final reminderData = await _storageAdapter.get<String>(_remindersKey);
      if (reminderData == null || reminderData.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(reminderData);
      return jsonList.map((json) => _fromJson(json)).toList();
    } catch (e) {
      // Fallback: try to get individual reminders
      return await _getAllRemindersFromIndividualKeys();
    }
  }

  @override
  Future<ReminderEntity?> getReminderById(String id) async {
    try {
      final reminderData = await _storageAdapter.get<String>('$_reminderPrefix$id');
      if (reminderData == null) return null;

      final json = jsonDecode(reminderData);
      return _fromJson(json);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveReminder(ReminderEntity reminder) async {
    // Save individual reminder
    await _storageAdapter.save(
      '$_reminderPrefix${reminder.id}',
      jsonEncode(_toJson(reminder)),
    );

    // Update the main reminders list
    await _updateMainRemindersList();

    // Notify listeners
    _notifyRemindersChanged();
  }

  @override
  Future<void> deleteReminder(String id) async {
    await _storageAdapter.remove('$_reminderPrefix$id');
    await _updateMainRemindersList();
    _notifyRemindersChanged();
  }

  @override
  Future<List<ReminderEntity>> getRemindersByType(ReminderType type) async {
    final allReminders = await getAllReminders();
    return allReminders.where((r) => r.type == type).toList();
  }

  @override
  Future<List<ReminderEntity>> getEnabledReminders() async {
    final allReminders = await getAllReminders();
    return allReminders.where((r) => r.isEnabled).toList();
  }

  @override
  Future<List<ReminderEntity>> getRemindersDueAt(DateTime time) async {
    final enabledReminders = await getEnabledReminders();
    return enabledReminders.where((r) => r.shouldTrigger(time)).toList();
  }

  @override
  Future<void> saveMultipleReminders(List<ReminderEntity> reminders) async {
    // Save each reminder individually
    for (final reminder in reminders) {
      await _storageAdapter.save(
        '$_reminderPrefix${reminder.id}',
        jsonEncode(_toJson(reminder)),
      );
    }

    // Update the main list
    await _updateMainRemindersList();
    _notifyRemindersChanged();
  }

  @override
  Future<void> deleteMultipleReminders(List<String> ids) async {
    for (final id in ids) {
      await _storageAdapter.remove('$_reminderPrefix$id');
    }

    await _updateMainRemindersList();
    _notifyRemindersChanged();
  }

  @override
  Future<List<ReminderEntity>> searchReminders(String query) async {
    final allReminders = await getAllReminders();
    final lowerQuery = query.toLowerCase();

    return allReminders.where((reminder) {
      return reminder.title.toLowerCase().contains(lowerQuery) ||
          reminder.description.toLowerCase().contains(lowerQuery) ||
          reminder.tags.any((tag) => tag.contains(lowerQuery));
    }).toList();
  }

  @override
  Future<List<ReminderEntity>> getRemindersByTag(String tag) async {
    final allReminders = await getAllReminders();
    final lowerTag = tag.toLowerCase();

    return allReminders
        .where((reminder) => reminder.tags.any((t) => t == lowerTag))
        .toList();
  }

  @override
  Future<int> getTotalReminderCount() async {
    final reminders = await getAllReminders();
    return reminders.length;
  }

  @override
  Future<int> getActiveReminderCount() async {
    final reminders = await getEnabledReminders();
    return reminders.length;
  }

  @override
  Stream<List<ReminderEntity>> watchReminders() {
    // Initialize with current data
    getAllReminders().then((reminders) {
      _remindersController.add(reminders);
    });

    return _remindersController.stream;
  }

  @override
  Stream<ReminderEntity?> watchReminderById(String id) async* {
    await for (final reminders in watchReminders()) {
      try {
        final reminder = reminders.firstWhere(
          (r) => r.id == id,
        );
        yield reminder;
      } catch (e) {
        yield null;
      }
    }
  }

  // Private helper methods
  Future<List<ReminderEntity>> _getAllRemindersFromIndividualKeys() async {
    final allKeys = await _storageAdapter.getAllKeys();
    final reminderKeys = allKeys.where((key) => key.startsWith(_reminderPrefix));

    final reminders = <ReminderEntity>[];
    for (final key in reminderKeys) {
      final reminderData = await _storageAdapter.get<String>(key);
      if (reminderData != null) {
        try {
          final json = jsonDecode(reminderData);
          reminders.add(_fromJson(json));
        } catch (e) {
          // Skip invalid reminders
          continue;
        }
      }
    }

    return reminders;
  }

  Future<void> _updateMainRemindersList() async {
    final reminders = await _getAllRemindersFromIndividualKeys();
    final jsonList = reminders.map((r) => _toJson(r)).toList();
    await _storageAdapter.save(_remindersKey, jsonEncode(jsonList));
  }

  void _notifyRemindersChanged() {
    getAllReminders().then((reminders) {
      if (!_remindersController.isClosed) {
        _remindersController.add(reminders);
      }
    });
  }

  // JSON serialization methods
  Map<String, dynamic> _toJson(ReminderEntity reminder) {
    return {
      'id': reminder.id,
      'title': reminder.title,
      'description': reminder.description,
      'interval': reminder.interval.inMilliseconds,
      'isEnabled': reminder.isEnabled,
      'createdAt': reminder.createdAt.millisecondsSinceEpoch,
      'lastTriggered': reminder.lastTriggered?.millisecondsSinceEpoch,
      'tags': reminder.tags,
      'type': reminder.type.name,
    };
  }

  ReminderEntity _fromJson(Map<String, dynamic> json) {
    return ReminderEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      interval: Duration(milliseconds: json['interval'] as int),
      isEnabled: json['isEnabled'] as bool,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      lastTriggered: json['lastTriggered'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastTriggered'] as int)
          : null,
      tags: List<String>.from(json['tags'] as List),
      type: ReminderType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReminderType.general,
      ),
    );
  }

  // Cleanup
  void dispose() {
    _remindersController.close();
  }
}