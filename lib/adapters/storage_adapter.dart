import 'dart:async';

/// Abstract storage adapter interface for platform-specific implementations
abstract class StorageAdapter {
  /// Initialize the storage system
  Future<void> initialize();

  /// Save a value with the specified key
  Future<void> save<T>(String key, T value);

  /// Retrieve a value by key with optional type casting
  Future<T?> get<T>(String key);

  /// Check if a key exists in storage
  Future<bool> containsKey(String key);

  /// Remove a specific key and its value
  Future<void> remove(String key);

  /// Clear all stored data
  Future<void> clear();

  /// Get all keys in storage
  Future<List<String>> getKeys();

  /// Get storage size information
  Future<StorageInfo> getStorageInfo();

  /// Batch operations for better performance
  Future<void> batchWrite(Map<String, dynamic> data);

  /// Batch read operations
  Future<Map<String, dynamic>> batchRead(List<String> keys);

  /// Secure storage operations (for sensitive data)
  Future<void> saveSecure(String key, String value);
  Future<String?> getSecure(String key);
  Future<void> removeSecure(String key);

  /// Storage event listeners
  void addListener(StorageListener listener);
  void removeListener(StorageListener listener);

  /// Platform-specific configurations
  StorageConfig get config;

  /// Check storage availability and permissions
  Future<bool> isAvailable();

  /// Backup and restore operations
  Future<String> exportData();
  Future<void> importData(String data);

  /// Dispose resources
  Future<void> dispose();
}

/// Storage configuration for platform-specific settings
abstract class StorageConfig {
  String get name;
  int get version;
  bool get encrypted;
  int? get maxSize;
  StorageLocation get location;
  Map<String, dynamic> get platformSettings;
}

/// Storage location types
enum StorageLocation {
  documents,
  cache,
  temporary,
  secure,
  shared,
}

/// Storage information and statistics
class StorageInfo {
  final int totalSize;
  final int usedSize;
  final int availableSize;
  final int itemCount;
  final DateTime lastModified;
  final StorageLocation location;

  const StorageInfo({
    required this.totalSize,
    required this.usedSize,
    required this.availableSize,
    required this.itemCount,
    required this.lastModified,
    required this.location,
  });

  double get usagePercentage => totalSize > 0 ? (usedSize / totalSize) * 100 : 0;
  
  bool get isNearCapacity => usagePercentage > 85;
}

/// Storage event listener interface
abstract class StorageListener {
  void onValueChanged(String key, dynamic oldValue, dynamic newValue);
  void onValueRemoved(String key, dynamic oldValue);
  void onCleared();
  void onError(StorageException error);
}

/// Storage operation result
class StorageResult<T> {
  final bool success;
  final T? data;
  final String? error;
  final StorageException? exception;

  const StorageResult({
    required this.success,
    this.data,
    this.error,
    this.exception,
  });

  factory StorageResult.success(T data) => StorageResult(success: true, data: data);
  
  factory StorageResult.failure(String error, [StorageException? exception]) => 
      StorageResult(success: false, error: error, exception: exception);
}

/// Storage transaction for atomic operations
abstract class StorageTransaction {
  void put<T>(String key, T value);
  void remove(String key);
  Future<void> commit();
  Future<void> rollback();
}

/// Exception thrown when storage operations fail
class StorageException implements Exception {
  final String message;
  final StorageErrorCode code;
  final dynamic originalError;

  const StorageException(
    this.message, {
    required this.code,
    this.originalError,
  });

  @override
  String toString() => 'StorageException: $message (Code: ${code.name})';
}

/// Storage error codes
enum StorageErrorCode {
  notInitialized,
  permissionDenied,
  notFound,
  quotaExceeded,
  corruptedData,
  networkError,
  encryptionError,
  unknown,
}

/// Encryption configuration for secure storage
class EncryptionConfig {
  final String algorithm;
  final int keySize;
  final bool useDeviceKeystore;
  final Map<String, dynamic> parameters;

  const EncryptionConfig({
    required this.algorithm,
    required this.keySize,
    this.useDeviceKeystore = true,
    this.parameters = const {},
  });

  static const EncryptionConfig defaultConfig = EncryptionConfig(
    algorithm: 'AES',
    keySize: 256,
    useDeviceKeystore: true,
  );
}