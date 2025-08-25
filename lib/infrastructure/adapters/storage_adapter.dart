/// Abstract adapter for storage operations
/// 
/// Provides a consistent interface for different storage mechanisms
/// across platforms (SharedPreferences, SQLite, etc.)
abstract class StorageAdapter {
  /// Initialize the storage system
  Future<void> initialize();

  /// Save a value by key
  Future<void> save<T>(String key, T value);

  /// Retrieve a value by key
  Future<T?> get<T>(String key);

  /// Remove a value by key
  Future<void> remove(String key);

  /// Check if a key exists
  Future<bool> containsKey(String key);

  /// Get all keys
  Future<List<String>> getAllKeys();

  /// Clear all data
  Future<void> clear();

  /// Batch operations for performance
  Future<void> saveBatch(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getBatch(List<String> keys);
  Future<void> removeBatch(List<String> keys);

  /// Stream for watching changes
  Stream<String> watchKey(String key);
  Stream<Map<String, dynamic>> watchAll();

  /// Storage info
  Future<int> getStorageSize();
  Future<Map<String, dynamic>> getStorageInfo();

  /// Cleanup operations
  Future<void> cleanup();
  Future<void> dispose();
}