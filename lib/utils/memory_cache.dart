import 'dart:async';
import 'package:flutter/foundation.dart';

/// Memory cache for frequently accessed data
class MemoryCache {
  static final MemoryCache _instance = MemoryCache._internal();
  factory MemoryCache() => _instance;
  MemoryCache._internal();

  final Map<String, _CacheEntry> _cache = {};
  Timer? _cleanupTimer;

  static const Duration _defaultTtl = Duration(minutes: 10);
  static const int _maxEntries = 100;

  /// Initialize cleanup timer
  void initialize() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _cleanup(),
    );
  }

  /// Get cached value
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    entry.lastAccessed = DateTime.now();
    return entry.value as T?;
  }

  /// Set cached value
  void set<T>(String key, T value, {Duration? ttl}) {
    // Remove oldest entries if cache is full
    if (_cache.length >= _maxEntries) {
      _removeOldestEntry();
    }

    _cache[key] = _CacheEntry(
      value: value,
      expiryTime: DateTime.now().add(ttl ?? _defaultTtl),
      lastAccessed: DateTime.now(),
    );
  }

  /// Remove specific entry
  void remove(String key) {
    _cache.remove(key);
  }

  /// Clear all cached data
  void clear() {
    _cache.clear();
  }

  /// Get cache statistics
  CacheStats get stats {
    final expired = _cache.values.where((e) => e.isExpired).length;
    final active = _cache.length - expired;

    return CacheStats(
      totalEntries: _cache.length,
      activeEntries: active,
      expiredEntries: expired,
      hitRate: _hitCount / (_hitCount + _missCount),
      memoryUsage: _estimateMemoryUsage(),
    );
  }

  void _cleanup() {
    _cache.removeWhere((key, entry) => entry.isExpired);

    if (kDebugMode) {
      debugPrint(
        '🧹 Cache cleanup completed. Active entries: ${_cache.length}',
      );
    }
  }

  void _removeOldestEntry() {
    if (_cache.isEmpty) return;

    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _cache.entries) {
      if (oldestTime == null || entry.value.lastAccessed.isBefore(oldestTime)) {
        oldestTime = entry.value.lastAccessed;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      _cache.remove(oldestKey);
    }
  }

  int _estimateMemoryUsage() {
    // Rough estimate of memory usage in bytes
    return _cache.entries.fold(0, (total, entry) {
      final keySize = entry.key.length * 2; // UTF-16 encoding
      final valueSize = _estimateValueSize(entry.value.value);
      return total + keySize + valueSize + 64; // 64 bytes overhead per entry
    });
  }

  int _estimateValueSize(dynamic value) {
    if (value is String) return value.length * 2;
    if (value is List) return value.length * 32; // rough estimate
    if (value is Map) return value.length * 64; // rough estimate
    return 32; // default estimate for other types
  }

  final int _hitCount = 0;
  final int _missCount = 0;

  void dispose() {
    _cleanupTimer?.cancel();
    _cache.clear();
  }
}

class _CacheEntry {
  final dynamic value;
  final DateTime expiryTime;
  DateTime lastAccessed;

  _CacheEntry({
    required this.value,
    required this.expiryTime,
    required this.lastAccessed,
  });

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}

class CacheStats {
  final int totalEntries;
  final int activeEntries;
  final int expiredEntries;
  final double hitRate;
  final int memoryUsage;

  CacheStats({
    required this.totalEntries,
    required this.activeEntries,
    required this.expiredEntries,
    required this.hitRate,
    required this.memoryUsage,
  });

  @override
  String toString() {
    return '''
CacheStats:
  Total Entries: $totalEntries
  Active Entries: $activeEntries
  Expired Entries: $expiredEntries
  Hit Rate: ${(hitRate * 100).toStringAsFixed(1)}%
  Memory Usage: ${(memoryUsage / 1024).toStringAsFixed(1)} KB
''';
  }
}
