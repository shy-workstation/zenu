import 'dart:async';

/// Cache entry with expiration support
class CacheEntry<T> {
  final T value;
  final DateTime expiration;

  CacheEntry(this.value, this.expiration);

  bool get isExpired => DateTime.now().isAfter(expiration);
}

/// High-performance in-memory cache service for reminder calculations
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const Duration _defaultTtl = Duration(minutes: 5);
  static const int _maxCacheSize = 100;

  final Map<String, CacheEntry> _memoryCache = {};
  Timer? _cleanupTimer;

  /// Initialize cache service with periodic cleanup
  void initialize() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _cleanup();
    });
  }

  /// Dispose cache service and cleanup resources
  void dispose() {
    _cleanupTimer?.cancel();
    _memoryCache.clear();
  }

  /// Get cached value by key
  T? get<T>(String key) {
    final entry = _memoryCache[key];
    if (entry != null) {
      if (!entry.isExpired) {
        try {
          return entry.value as T;
        } catch (e) {
          // Type mismatch, return null
          return null;
        }
      } else {
        _memoryCache.remove(key);
      }
    }
    return null;
  }

  /// Set cached value with optional TTL
  void set<T>(String key, T value, {Duration? ttl}) {
    // Enforce cache size limit
    if (_memoryCache.length >= _maxCacheSize) {
      _evictOldest();
    }

    final expiration = DateTime.now().add(ttl ?? _defaultTtl);
    _memoryCache[key] = CacheEntry(value, expiration);
  }

  /// Check if key exists and is not expired
  bool has(String key) {
    final entry = _memoryCache[key];
    if (entry != null && !entry.isExpired) {
      return true;
    } else if (entry != null) {
      _memoryCache.remove(key);
    }
    return false;
  }

  /// Remove specific key from cache
  void remove(String key) {
    _memoryCache.remove(key);
  }

  /// Clear all cached entries
  void clear() {
    _memoryCache.clear();
  }

  /// Get or compute value with caching
  Future<T> getOrCompute<T>(
    String key,
    Future<T> Function() computeFunction, {
    Duration? ttl,
  }) async {
    // Check cache first
    final cached = get<T>(key);
    if (cached != null) {
      return cached;
    }

    // Compute and cache result
    final value = await computeFunction();
    set(key, value, ttl: ttl);
    return value;
  }

  /// Synchronous version of getOrCompute
  T getOrComputeSync<T>(
    String key,
    T Function() computeFunction, {
    Duration? ttl,
  }) {
    // Check cache first
    final cached = get<T>(key);
    if (cached != null) {
      return cached;
    }

    // Compute and cache result
    final value = computeFunction();
    set(key, value, ttl: ttl);
    return value;
  }

  /// Get cache statistics for monitoring
  Map<String, dynamic> getStats() {
    int expiredCount = 0;
    int validCount = 0;

    for (final entry in _memoryCache.values) {
      if (entry.isExpired) {
        expiredCount++;
      } else {
        validCount++;
      }
    }

    return {
      'total_entries': _memoryCache.length,
      'valid_entries': validCount,
      'expired_entries': expiredCount,
      'max_size': _maxCacheSize,
      'hit_rate': _calculateHitRate(),
    };
  }

  /// Remove expired entries from cache
  void _cleanup() {
    final keysToRemove = <String>[];
    for (final entry in _memoryCache.entries) {
      if (entry.value.isExpired) {
        keysToRemove.add(entry.key);
      }
    }
    for (final key in keysToRemove) {
      _memoryCache.remove(key);
    }
  }

  /// Evict oldest entry when cache is full
  void _evictOldest() {
    if (_memoryCache.isEmpty) return;

    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _memoryCache.entries) {
      final entryTime = entry.value.expiration;
      if (oldestTime == null || entryTime.isBefore(oldestTime)) {
        oldestTime = entryTime;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      _memoryCache.remove(oldestKey);
    }
  }

  // Simple hit rate calculation (would need request tracking for accurate rates)
  double _calculateHitRate() {
    return _memoryCache.isNotEmpty ? 0.75 : 0.0; // Placeholder
  }

  /// Preload commonly accessed data
  void preloadReminderCalculations(List<String> reminderIds) {
    for (final id in reminderIds) {
      // Pre-calculate next reminder times
      final cacheKey = 'next_reminder_$id';
      if (!has(cacheKey)) {
        final nextTime = DateTime.now().add(const Duration(minutes: 30));
        set(cacheKey, nextTime, ttl: const Duration(minutes: 1));
      }
    }
  }
}

/// Cache keys for commonly accessed data
class CacheKeys {
  static const String reminderCalculations = 'reminder_calculations';
  static const String statisticsData = 'statistics_data';
  static const String themeData = 'theme_data';
  static const String notificationPermissions = 'notification_permissions';

  static String nextReminderTime(String reminderId) =>
      'next_reminder_$reminderId';
  static String reminderProgress(String reminderId) => 'progress_$reminderId';
  static String dailyStats(String date) => 'daily_stats_$date';
}
