import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder.dart';

class DataService {
  static const String _remindersKey = 'reminders';

  static DataService? _instance;
  static SharedPreferences? _prefs;

  DataService._();

  static Future<DataService> getInstance() async {
    if (_instance == null) {
      _instance = DataService._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  Future<List<Map<String, dynamic>>> loadReminders() async {
    final String? remindersJson = _prefs?.getString(_remindersKey);
    if (remindersJson == null) return <Map<String, dynamic>>[];

    try {
      final List<dynamic> remindersList = jsonDecode(remindersJson);
      return remindersList.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading reminders: $e');
      }
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> saveReminders(List<Reminder> reminders) async {
    try {
      final List<Map<String, dynamic>> remindersJson =
          reminders.map((r) => r.toJson()).toList();
      await _prefs?.setString(_remindersKey, jsonEncode(remindersJson));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving reminders: $e');
      }
    }
  }

  Future<void> clearAll() async {
    await _prefs?.remove(_remindersKey);
  }
}
