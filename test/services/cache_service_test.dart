import 'package:flutter_test/flutter_test.dart';
import 'package:zenu/services/cache_service.dart';

void main() {
  group('CacheService Tests', () {
    late CacheService cacheService;

    setUp(() {
      cacheService = CacheService();
      cacheService.initialize();
    });

    tearDown(() {
      cacheService.clear();
      cacheService.dispose();
    });

    group('Basic Operations', () {
      test('should store and retrieve values', () {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';

        // Act
        cacheService.set(key, value);
        final retrieved = cacheService.get<String>(key);

        // Assert
        expect(retrieved, equals(value));
      });

      test('should return null for non-existent keys', () {
        // Act
        final result = cacheService.get<String>('non_existent');

        // Assert
        expect(result, isNull);
      });

      test('should check key existence correctly', () {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';

        // Act & Assert
        expect(cacheService.has(key), isFalse);

        cacheService.set(key, value);
        expect(cacheService.has(key), isTrue);
      });

      test('should remove specific keys', () {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';
        cacheService.set(key, value);

        // Act
        cacheService.remove(key);

        // Assert
        expect(cacheService.has(key), isFalse);
        expect(cacheService.get<String>(key), isNull);
      });

      test('should clear all entries', () {
        // Arrange
        cacheService.set('key1', 'value1');
        cacheService.set('key2', 'value2');

        // Act
        cacheService.clear();

        // Assert
        expect(cacheService.has('key1'), isFalse);
        expect(cacheService.has('key2'), isFalse);
      });
    });

    group('TTL and Expiration', () {
      test('should respect custom TTL', () async {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';
        const shortTtl = Duration(milliseconds: 10);

        // Act
        cacheService.set(key, value, ttl: shortTtl);
        expect(cacheService.has(key), isTrue);

        // Wait for expiration
        await Future.delayed(const Duration(milliseconds: 20));

        // Assert
        expect(cacheService.has(key), isFalse);
        expect(cacheService.get<String>(key), isNull);
      });

      test('should not expire before TTL', () {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';
        const longTtl = Duration(minutes: 10);

        // Act
        cacheService.set(key, value, ttl: longTtl);

        // Assert
        expect(cacheService.has(key), isTrue);
        expect(cacheService.get<String>(key), equals(value));
      });
    });

    group('Compute Functions', () {
      test('should compute and cache result', () async {
        // Arrange
        const key = 'compute_key';
        const expectedValue = 'computed_value';
        int computeCallCount = 0;

        Future<String> computeFunction() async {
          computeCallCount++;
          return expectedValue;
        }

        // Act
        final result1 = await cacheService.getOrCompute(key, computeFunction);
        final result2 = await cacheService.getOrCompute(key, computeFunction);

        // Assert
        expect(result1, equals(expectedValue));
        expect(result2, equals(expectedValue));
        expect(computeCallCount, equals(1)); // Should only compute once
      });

      test('should compute synchronously and cache result', () {
        // Arrange
        const key = 'sync_compute_key';
        const expectedValue = 42;
        int computeCallCount = 0;

        int computeFunction() {
          computeCallCount++;
          return expectedValue;
        }

        // Act
        final result1 = cacheService.getOrComputeSync(key, computeFunction);
        final result2 = cacheService.getOrComputeSync(key, computeFunction);

        // Assert
        expect(result1, equals(expectedValue));
        expect(result2, equals(expectedValue));
        expect(computeCallCount, equals(1)); // Should only compute once
      });
    });

    group('Statistics and Monitoring', () {
      test('should provide cache statistics', () {
        // Arrange
        cacheService.set('key1', 'value1');
        cacheService.set('key2', 'value2');

        // Act
        final stats = cacheService.getStats();

        // Assert
        expect(stats['total_entries'], equals(2));
        expect(stats['valid_entries'], equals(2));
        expect(stats['expired_entries'], equals(0));
        expect(stats['max_size'], equals(100));
        expect(stats.containsKey('hit_rate'), isTrue);
      });
    });

    group('Type Safety', () {
      test('should handle different data types correctly', () {
        // Arrange & Act
        cacheService.set('string_key', 'string_value');
        cacheService.set('int_key', 42);
        cacheService.set('bool_key', true);
        cacheService.set('list_key', [1, 2, 3]);
        cacheService.set('map_key', {'a': 1, 'b': 2});

        // Assert
        expect(cacheService.get<String>('string_key'), equals('string_value'));
        expect(cacheService.get<int>('int_key'), equals(42));
        expect(cacheService.get<bool>('bool_key'), isTrue);
        expect(cacheService.get<List<int>>('list_key'), equals([1, 2, 3]));
        expect(
          cacheService.get<Map<String, int>>('map_key'),
          equals({'a': 1, 'b': 2}),
        );
      });

      test('should return null for wrong type casting', () {
        // Arrange
        cacheService.set('string_key', 'string_value');

        // Act & Assert
        expect(cacheService.get<int>('string_key'), isNull);
      });
    });
  });
}
