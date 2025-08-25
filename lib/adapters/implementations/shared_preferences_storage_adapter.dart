import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../storage_adapter.dart';
import '../../utils/error_handler.dart';

/// SharedPreferences-based storage adapter implementation
class SharedPreferencesStorageAdapter implements StorageAdapter {
  late final SharedPreferences _prefs;
  late final SharedPreferencesStorageConfig _config;
  final List<StorageListener> _listeners = [];
  bool _initialized = false;

  SharedPreferencesStorageAdapter([SharedPreferencesStorageConfig? config]) {
    _config = config ?? SharedPreferencesStorageConfig.defaultConfig;
  }

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
      
      ErrorHandler.logInfo('SharedPreferencesStorageAdapter initialized successfully');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'SharedPreferencesStorageAdapter.initialize',
        severity: ErrorSeverity.error,
      );
      throw StorageException(
        'Failed to initialize SharedPreferences storage',
        code: StorageErrorCode.notInitialized,
        originalError: e,
      );
    }
  }

  @override
  Future<void> save<T>(String key, T value) async {
    await _ensureInitialized();
    
    try {
      final oldValue = await get<T>(key);
      bool success = false;

      if (value == null) {
        success = await _prefs.remove(key);
      } else if (value is String) {
        success = await _prefs.setString(key, value);
      } else if (value is int) {
        success = await _prefs.setInt(key, value);
      } else if (value is double) {
        success = await _prefs.setDouble(key, value);
      } else if (value is bool) {
        success = await _prefs.setBool(key, value);
      } else if (value is List<String>) {
        success = await _prefs.setStringList(key, value);
      } else {
        // Serialize complex objects to JSON
        final jsonString = jsonEncode(_serializeValue(value));
        success = await _prefs.setString('${key}_json', jsonString);
      }

      if (success) {
        _notifyListeners((listener) => listener.onValueChanged(key, oldValue, value));
        ErrorHandler.logInfo('Saved value for key: $key');
      } else {
        throw StorageException(
          'Failed to save value for key: $key',
          code: StorageErrorCode.unknown,
        );
      }
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'SharedPreferencesStorageAdapter.save',
        severity: ErrorSeverity.error,
        metadata: {'key': key, 'valueType': T.toString()},
      );
      
      _notifyListeners((listener) => listener.onError(StorageException(
        'Failed to save value',
        code: StorageErrorCode.unknown,
        originalError: e,
      )));
      
      rethrow;
    }
  }

  @override
  Future<T?> get<T>(String key) async {
    await _ensureInitialized();

    try {
      // First try to get as JSON (for complex objects)
      if (_prefs.containsKey('${key}_json')) {
        final jsonString = _prefs.getString('${key}_json');
        if (jsonString != null) {
          final decodedValue = jsonDecode(jsonString);
          return _deserializeValue<T>(decodedValue);
        }
      }

      // Try primitive types
      if (!_prefs.containsKey(key)) {
        return null;
      }

      final value = _prefs.get(key);
      
      if (value is T) {
        return value;
      } else if (value != null) {
        // Try to cast the value to the expected type
        return _castValue<T>(value);
      }
      
      return null;
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'SharedPreferencesStorageAdapter.get',
        severity: ErrorSeverity.warning,
        metadata: {'key': key, 'expectedType': T.toString()},
      );
      
      _notifyListeners((listener) => listener.onError(StorageException(
        'Failed to retrieve value',
        code: StorageErrorCode.corruptedData,
        originalError: e,
      )));
      
      return null;
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    await _ensureInitialized();
    return _prefs.containsKey(key) || _prefs.containsKey('${key}_json');
  }

  @override
  Future<void> remove(String key) async {
    await _ensureInitialized();
    
    try {
      final oldValue = await get(key);
      bool removed = false;

      if (_prefs.containsKey(key)) {
        removed = await _prefs.remove(key);
      }
      
      if (_prefs.containsKey('${key}_json')) {
        await _prefs.remove('${key}_json');
        removed = true;
      }

      if (removed) {
        _notifyListeners((listener) => listener.onValueRemoved(key, oldValue));
        ErrorHandler.logInfo('Removed value for key: $key');
      }
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'SharedPreferencesStorageAdapter.remove',
        severity: ErrorSeverity.warning,
        metadata: {'key': key},
      );
      
      _notifyListeners((listener) => listener.onError(StorageException(
        'Failed to remove value',
        code: StorageErrorCode.unknown,
        originalError: e,
      )));
    }
  }

  @override
  Future<void> clear() async {
    await _ensureInitialized();
    
    try {
      await _prefs.clear();
      _notifyListeners((listener) => listener.onCleared());
      ErrorHandler.logInfo('Cleared all SharedPreferences data');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'SharedPreferencesStorageAdapter.clear',
        severity: ErrorSeverity.error,
      );
      
      _notifyListeners((listener) => listener.onError(StorageException(
        'Failed to clear storage',
        code: StorageErrorCode.unknown,
        originalError: e,
      )));
    }
  }

  @override
  Future<List<String>> getKeys() async {
    await _ensureInitialized();
    
    try {
      final allKeys = _prefs.getKeys().toList();
      // Remove internal JSON keys from the public key list
      return allKeys.where((key) => !key.endsWith('_json')).toList();
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'SharedPreferencesStorageAdapter.getKeys',
        severity: ErrorSeverity.warning,
      );
      return [];
    }
  }

  @override
  Future<StorageInfo> getStorageInfo() async {
    await _ensureInitialized();

    try {
      final keys = await getKeys();
      int totalSize = 0;
      
      // Estimate size (this is approximate)
      for (final key in keys) {
        final value = await get(key);
        totalSize += _estimateValueSize(key, value);
      }

      return StorageInfo(
        totalSize: _config.maxSize ?? 10 * 1024 * 1024, // 10MB default estimate
        usedSize: totalSize,
        availableSize: (_config.maxSize ?? 10 * 1024 * 1024) - totalSize,
        itemCount: keys.length,
        lastModified: DateTime.now(),
        location: _config.location,
      );
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'SharedPreferencesStorageAdapter.getStorageInfo',
        severity: ErrorSeverity.warning,
      );
      
      return StorageInfo(
        totalSize: 0,
        usedSize: 0,
        availableSize: 0,
        itemCount: 0,
        lastModified: DateTime.now(),
        location: _config.location,
      );
    }
  }

  @override
  Future<void> batchWrite(Map<String, dynamic> data) async {
    await _ensureInitialized();

    try {
      for (final entry in data.entries) {
        await save(entry.key, entry.value);
      }
      
      ErrorHandler.logInfo('Completed batch write of ${data.length} items');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'SharedPreferencesStorageAdapter.batchWrite',
        severity: ErrorSeverity.error,
        metadata: {'itemCount': data.length},
      );
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> batchRead(List<String> keys) async {
    await _ensureInitialized();

    try {
      final result = <String, dynamic>{};
      
      for (final key in keys) {
        result[key] = await get(key);
      }
      
      ErrorHandler.logInfo('Completed batch read of ${keys.length} items');
      return result;
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'SharedPreferencesStorageAdapter.batchRead',
        severity: ErrorSeverity.error,
        metadata: {'keyCount': keys.length},
      );
      return {};
    }
  }

  @override
  Future<void> saveSecure(String key, String value) async {
    // SharedPreferences doesn't provide encryption, so this is a basic implementation
    // In a production app, you should use flutter_secure_storage for sensitive data
    await save('secure_$key', value);
    ErrorHandler.logWarning('Secure storage not implemented for SharedPreferences - use flutter_secure_storage for sensitive data');
  }

  @override
  Future<String?> getSecure(String key) async {
    // SharedPreferences doesn't provide encryption
    final value = await get<String>('secure_$key');
    if (value != null) {
      ErrorHandler.logWarning('Secure storage not implemented for SharedPreferences - use flutter_secure_storage for sensitive data');
    }
    return value;
  }

  @override
  Future<void> removeSecure(String key) async {
    await remove('secure_$key');
  }

  @override
  void addListener(StorageListener listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(StorageListener listener) {
    _listeners.remove(listener);
  }

  @override
  StorageConfig get config => _config;

  @override
  Future<bool> isAvailable() async {
    try {
      await initialize();
      return _initialized;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String> exportData() async {
    await _ensureInitialized();
    
    try {
      final keys = await getKeys();
      final data = await batchRead(keys);
      return jsonEncode(data);
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'SharedPreferencesStorageAdapter.exportData',
        severity: ErrorSeverity.error,
      );
      throw StorageException(
        'Failed to export data',
        code: StorageErrorCode.unknown,
        originalError: e,
      );
    }
  }

  @override
  Future<void> importData(String data) async {
    await _ensureInitialized();
    
    try {
      final Map<String, dynamic> importedData = jsonDecode(data);
      await batchWrite(importedData);
      ErrorHandler.logInfo('Successfully imported ${importedData.length} items');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'SharedPreferencesStorageAdapter.importData',
        severity: ErrorSeverity.error,
      );
      throw StorageException(
        'Failed to import data',
        code: StorageErrorCode.corruptedData,
        originalError: e,
      );
    }
  }

  @override
  Future<void> dispose() async {
    _listeners.clear();
    _initialized = false;
    ErrorHandler.logInfo('SharedPreferencesStorageAdapter disposed');
  }

  // Private helper methods
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  void _notifyListeners(void Function(StorageListener) action) {
    for (final listener in _listeners) {
      try {
        action(listener);
      } catch (e) {
        ErrorHandler.logWarning('Error notifying storage listener: $e');
      }
    }
  }

  dynamic _serializeValue(dynamic value) {
    if (value == null ||
        value is String ||
        value is int ||
        value is double ||
        value is bool ||
        value is List ||
        value is Map) {
      return value;
    }
    
    // For custom objects, try to call toJson() if available
    try {
      if (value is Object && value.runtimeType.toString().contains('toJson')) {
        return (value as dynamic).toJson();
      }
    } catch (e) {
      // Fallback to string representation
      return value.toString();
    }
    
    return value.toString();
  }

  T? _deserializeValue<T>(dynamic value) {
    if (value is T) {
      return value;
    }
    
    return _castValue<T>(value);
  }

  T? _castValue<T>(dynamic value) {
    try {
      if (T == String) {
        return value?.toString() as T?;
      } else if (T == int) {
        if (value is String) {
          return int.tryParse(value) as T?;
        } else if (value is double) {
          return value.toInt() as T;
        }
      } else if (T == double) {
        if (value is String) {
          return double.tryParse(value) as T?;
        } else if (value is int) {
          return value.toDouble() as T;
        }
      } else if (T == bool) {
        if (value is String) {
          return (value.toLowerCase() == 'true') as T;
        }
      }
      
      return value as T?;
    } catch (e) {
      return null;
    }
  }

  int _estimateValueSize(String key, dynamic value) {
    int size = key.length * 2; // UTF-16 encoding approximation
    
    if (value is String) {
      size += value.length * 2;
    } else if (value is int) {
      size += 8;
    } else if (value is double) {
      size += 8;
    } else if (value is bool) {
      size += 1;
    } else if (value is List) {
      size += value.length * 8; // Rough estimate
    } else {
      size += 100; // Default estimate for complex objects
    }
    
    return size;
  }
}

/// SharedPreferences-specific storage configuration
class SharedPreferencesStorageConfig implements StorageConfig {
  @override
  final String name;

  @override
  final int version;

  @override
  final bool encrypted;

  @override
  final int? maxSize;

  @override
  final StorageLocation location;

  @override
  final Map<String, dynamic> platformSettings;

  const SharedPreferencesStorageConfig({
    required this.name,
    this.version = 1,
    this.encrypted = false,
    this.maxSize,
    this.location = StorageLocation.documents,
    this.platformSettings = const {},
  });

  static const SharedPreferencesStorageConfig defaultConfig = SharedPreferencesStorageConfig(
    name: 'zenu_preferences',
    version: 1,
    encrypted: false,
    location: StorageLocation.documents,
  );
}