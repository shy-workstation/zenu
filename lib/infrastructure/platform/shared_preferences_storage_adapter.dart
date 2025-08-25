import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../adapters/storage_adapter.dart';

/// SharedPreferences implementation of StorageAdapter
/// 
/// Provides cross-platform storage using Flutter's SharedPreferences
class SharedPreferencesStorageAdapter implements StorageAdapter {
  SharedPreferences? _prefs;
  final StreamController<Map<String, dynamic>> _watchController = StreamController.broadcast();
  final Map<String, StreamController<String>> _keyWatchers = {};

  @override
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('Storage adapter not initialized. Call initialize() first.');
    }
    return _prefs!;
  }

  @override
  Future<void> save<T>(String key, T value) async {
    if (value == null) {
      await prefs.remove(key);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else {
      // For complex objects, serialize to JSON
      final jsonString = jsonEncode(_serializeValue(value));
      await prefs.setString(key, jsonString);
    }

    // Notify watchers
    _notifyKeyWatchers(key);
    _notifyAllWatchers();
  }

  @override
  Future<T?> get<T>(String key) async {
    if (!await containsKey(key)) {
      return null;
    }

    final value = prefs.get(key);
    
    if (value is T) {
      return value;
    }
    
    // Handle JSON deserialization for complex objects
    if (value is String && T != String) {
      try {
        final decoded = jsonDecode(value);
        return _deserializeValue<T>(decoded);
      } catch (e) {
        // If JSON parsing fails, return the string value if T allows it
        if (value is T) return value as T?;
        return null;
      }
    }
    
    return value as T?;
  }

  @override
  Future<void> remove(String key) async {
    await prefs.remove(key);
    _notifyKeyWatchers(key);
    _notifyAllWatchers();
  }

  @override
  Future<bool> containsKey(String key) async {
    return prefs.containsKey(key);
  }

  @override
  Future<List<String>> getAllKeys() async {
    return prefs.getKeys().toList();
  }

  @override
  Future<void> clear() async {
    await prefs.clear();
    _notifyAllWatchers();
    
    // Notify all key watchers
    for (final controller in _keyWatchers.values) {
      controller.add('');
    }
  }

  @override
  Future<void> saveBatch(Map<String, dynamic> data) async {
    for (final entry in data.entries) {
      await save(entry.key, entry.value);
    }
  }

  @override
  Future<Map<String, dynamic>> getBatch(List<String> keys) async {
    final result = <String, dynamic>{};
    for (final key in keys) {
      final value = await get<dynamic>(key);
      if (value != null) {
        result[key] = value;
      }
    }
    return result;
  }

  @override
  Future<void> removeBatch(List<String> keys) async {
    for (final key in keys) {
      await remove(key);
    }
  }

  @override
  Stream<String> watchKey(String key) {
    if (!_keyWatchers.containsKey(key)) {
      _keyWatchers[key] = StreamController<String>.broadcast();
    }
    return _keyWatchers[key]!.stream;
  }

  @override
  Stream<Map<String, dynamic>> watchAll() {
    return _watchController.stream;
  }

  @override
  Future<int> getStorageSize() async {
    // SharedPreferences doesn't provide direct size info
    // This is an approximation based on key-value pairs
    final keys = await getAllKeys();
    int totalSize = 0;
    
    for (final key in keys) {
      final value = prefs.get(key);
      totalSize += key.length;
      totalSize += _estimateValueSize(value);
    }
    
    return totalSize;
  }

  @override
  Future<Map<String, dynamic>> getStorageInfo() async {
    final keys = await getAllKeys();
    final size = await getStorageSize();
    
    return {
      'type': 'SharedPreferences',
      'keyCount': keys.length,
      'estimatedSize': size,
      'keys': keys,
    };
  }

  @override
  Future<void> cleanup() async {
    // For SharedPreferences, we might want to remove old or unused keys
    // This is a placeholder for future implementation
  }

  @override
  Future<void> dispose() async {
    await _watchController.close();
    
    for (final controller in _keyWatchers.values) {
      await controller.close();
    }
    _keyWatchers.clear();
  }

  // Helper methods
  void _notifyKeyWatchers(String key) {
    if (_keyWatchers.containsKey(key)) {
      _keyWatchers[key]!.add(key);
    }
  }

  void _notifyAllWatchers() {
    if (!_watchController.isClosed) {
      // Create a snapshot of current data
      final data = <String, dynamic>{};
      for (final key in prefs.getKeys()) {
        data[key] = prefs.get(key);
      }
      _watchController.add(data);
    }
  }

  dynamic _serializeValue(dynamic value) {
    if (value == null ||
        value is String ||
        value is num ||
        value is bool ||
        value is List ||
        value is Map) {
      return value;
    }
    
    // For custom objects, try to call toJson() if available
    try {
      if (value is Object && value.runtimeType.toString().contains('Entity')) {
        // This is a simplified approach - in real implementation,
        // you'd have proper serialization interfaces
        return value.toString();
      }
    } catch (e) {
      // Fall back to string representation
    }
    
    return value.toString();
  }

  T? _deserializeValue<T>(dynamic value) {
    if (value is T) return value;
    return null;
  }

  int _estimateValueSize(dynamic value) {
    if (value == null) return 0;
    if (value is String) return value.length * 2; // Unicode characters
    if (value is num) return 8;
    if (value is bool) return 1;
    if (value is List) return value.length * 10; // Rough estimate
    return value.toString().length * 2;
  }
}