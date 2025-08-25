import 'package:flutter_test/flutter_test.dart';
import 'package:zenu/models/statistics.dart';

void main() {
  group('Statistics Domain Model Tests', () {
    group('Creation and Initialization', () {
      test('should create empty statistics by default', () {
        // Act
        final stats = Statistics();

        // Assert
        expect(stats.totalCompletions, isEmpty);
        expect(stats.dailyCompletions, isEmpty);
        expect(stats.weeklyCompletions, isEmpty);
        expect(stats.monthlyCompletions, isEmpty);
      });

      test('should create statistics with provided data', () {
        // Arrange
        final totalCompletions = {'water': 10, 'exercise': 5};
        final dailyCompletions = {'water': 3, 'exercise': 1};

        // Act
        final stats = Statistics(
          totalCompletions: totalCompletions,
          dailyCompletions: dailyCompletions,
        );

        // Assert
        expect(stats.totalCompletions, equals(totalCompletions));
        expect(stats.dailyCompletions, equals(dailyCompletions));
        expect(stats.weeklyCompletions, isEmpty);
        expect(stats.monthlyCompletions, isEmpty);
      });
    });

    group('Completion Tracking', () {
      test('should increment total completions', () {
        // Arrange
        final stats = Statistics();

        // Act
        stats.incrementCompletion('water');
        stats.incrementCompletion('water');
        stats.incrementCompletion('exercise');

        // Assert
        expect(stats.totalCompletions['water'], equals(2));
        expect(stats.totalCompletions['exercise'], equals(1));
      });

      test('should increment daily completions', () {
        // Arrange
        final stats = Statistics();

        // Act
        stats.incrementDailyCompletion('water');
        stats.incrementDailyCompletion('water');

        // Assert
        expect(stats.dailyCompletions['water'], equals(2));
      });

      test('should increment weekly completions', () {
        // Arrange
        final stats = Statistics();

        // Act
        stats.incrementWeeklyCompletion('water');
        stats.incrementWeeklyCompletion('exercise');
        stats.incrementWeeklyCompletion('water');

        // Assert
        expect(stats.weeklyCompletions['water'], equals(2));
        expect(stats.weeklyCompletions['exercise'], equals(1));
      });

      test('should increment monthly completions', () {
        // Arrange
        final stats = Statistics();

        // Act
        stats.incrementMonthlyCompletion('water');

        // Assert
        expect(stats.monthlyCompletions['water'], equals(1));
      });

      test('should handle custom completion counts', () {
        // Arrange
        final stats = Statistics();

        // Act
        stats.addCompletion('water', DateTime.now());
        stats.addCompletion('water', DateTime.now());

        // Assert
        expect(stats.totalCompletions['water'], equals(8));
      });
    });

    group('Statistics Calculation', () {
      test('should calculate total completions across all reminders', () {
        // Arrange
        final stats = Statistics(
          totalCompletions: {
            'water': 20,
            'exercise': 10,
            'eyerest': 15,
          },
        );

        // Act
        final total = stats.getTotalCompletions();

        // Assert
        expect(total, equals(45));
      });

      test('should calculate daily total completions', () {
        // Arrange
        final stats = Statistics(
          dailyCompletions: {
            'water': 8,
            'exercise': 2,
            'eyerest': 6,
          },
        );

        // Act
        final dailyTotal = stats.getDailyTotal(DateTime.now());

        // Assert
        expect(dailyTotal, equals(16));
      });

      test('should get completion count for specific reminder', () {
        // Arrange
        final stats = Statistics(
          totalCompletions: {'water': 25, 'exercise': 10},
        );

        // Act & Assert
        expect(stats.getCompletionCount('water'), equals(25));
        expect(stats.getCompletionCount('exercise'), equals(10));
        expect(stats.getCompletionCount('nonexistent'), equals(0));
      });

      test('should get daily completion count for specific reminder', () {
        // Arrange
        final stats = Statistics(
          dailyCompletions: {'water': 8, 'exercise': 3},
        );

        // Act & Assert
        expect(stats.getDailyCompletionCount('water'), equals(8));
        expect(stats.getDailyCompletionCount('exercise'), equals(3));
        expect(stats.getDailyCompletionCount('nonexistent'), equals(0));
      });

      test('should calculate completion rate', () {
        // Arrange
        final stats = Statistics(
          totalCompletions: {'water': 75},
        );

        // Act
        final rate = stats.getCompletionRate('water');

        // Assert
        expect(rate, equals(0.75));
      });

      test('should handle zero expected total in completion rate', () {
        // Arrange
        final stats = Statistics(
          totalCompletions: {'water': 10},
        );

        // Act
        final rate = stats.getCompletionRate('water');

        // Assert
        expect(rate, equals(0.0));
      });
    });

    group('Streak Calculation', () {
      test('should calculate current streak', () {
        // Arrange
        final stats = Statistics();
        
        // Simulate a 5-day streak
        final today = DateTime.now();
        for (int i = 0; i < 5; i++) {
          final date = today.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          stats.dailyCompletions[dateKey] = 1;
        }

        // Act
        final streak = stats.getCurrentStreak();

        // Assert
        expect(streak, equals(5));
      });

      test('should return zero streak when no recent completions', () {
        // Arrange
        final stats = Statistics();

        // Act
        final streak = stats.getCurrentStreak();

        // Assert
        expect(streak, equals(0));
      });

      test('should calculate longest streak', () {
        // Arrange
        final stats = Statistics();
        
        // Simulate completions with a gap
        final baseDate = DateTime(2024, 1, 1);
        
        // 3-day streak
        for (int i = 0; i < 3; i++) {
          final date = baseDate.add(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          stats.dailyCompletions[dateKey] = 1;
        }
        
        // Gap of 2 days
        
        // 5-day streak (should be the longest)
        for (int i = 5; i < 10; i++) {
          final date = baseDate.add(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          stats.dailyCompletions[dateKey] = 1;
        }

        // Act
        final longestStreak = stats.getLongestStreak();

        // Assert
        expect(longestStreak, equals(5));
      });
    });

    group('Data Persistence', () {
      test('should serialize to JSON correctly', () {
        // Arrange
        final stats = Statistics(
          totalCompletions: {'water': 25, 'exercise': 10},
          dailyCompletions: {'water': 8, 'exercise': 3},
          weeklyCompletions: {'water': 50, 'exercise': 20},
          monthlyCompletions: {'water': 200, 'exercise': 80},
        );

        // Act
        final json = stats.toJson();

        // Assert
        expect(json['totalCompletions'], equals({'water': 25, 'exercise': 10}));
        expect(json['dailyCompletions'], equals({'water': 8, 'exercise': 3}));
        expect(json['weeklyCompletions'], equals({'water': 50, 'exercise': 20}));
        expect(json['monthlyCompletions'], equals({'water': 200, 'exercise': 80}));
      });

      test('should deserialize from JSON correctly', () {
        // Arrange
        final json = {
          'totalCompletions': {'water': 25, 'exercise': 10},
          'dailyCompletions': {'water': 8, 'exercise': 3},
          'weeklyCompletions': {'water': 50, 'exercise': 20},
          'monthlyCompletions': {'water': 200, 'exercise': 80},
        };

        // Act
        final stats = Statistics.fromJson(json);

        // Assert
        expect(stats.totalCompletions, equals({'water': 25, 'exercise': 10}));
        expect(stats.dailyCompletions, equals({'water': 8, 'exercise': 3}));
        expect(stats.weeklyCompletions, equals({'water': 50, 'exercise': 20}));
        expect(stats.monthlyCompletions, equals({'water': 200, 'exercise': 80}));
      });

      test('should handle null values in JSON deserialization', () {
        // Arrange
        final json = {
          'totalCompletions': {'water': 25},
          // Missing other fields
        };

        // Act
        final stats = Statistics.fromJson(json);

        // Assert
        expect(stats.totalCompletions, equals({'water': 25}));
        expect(stats.dailyCompletions, isEmpty);
        expect(stats.weeklyCompletions, isEmpty);
        expect(stats.monthlyCompletions, isEmpty);
      });
    });

    group('Data Reset and Cleanup', () {
      test('should reset daily completions', () {
        // Arrange
        final stats = Statistics(
          totalCompletions: {'water': 25, 'exercise': 10},
          dailyCompletions: {'water': 8, 'exercise': 3},
        );

        // Act
        stats.resetDailyCompletions();

        // Assert
        expect(stats.dailyCompletions, isEmpty);
        expect(stats.totalCompletions, equals({'water': 25, 'exercise': 10})); // Should remain
      });

      test('should reset weekly completions', () {
        // Arrange
        final stats = Statistics(
          weeklyCompletions: {'water': 50, 'exercise': 20},
          totalCompletions: {'water': 200, 'exercise': 80},
        );

        // Act
        stats.resetWeeklyCompletions();

        // Assert
        expect(stats.weeklyCompletions, isEmpty);
        expect(stats.totalCompletions, isNotEmpty); // Should remain
      });

      test('should reset monthly completions', () {
        // Arrange
        final stats = Statistics(
          monthlyCompletions: {'water': 200, 'exercise': 80},
        );

        // Act
        stats.resetMonthlyCompletions();

        // Assert
        expect(stats.monthlyCompletions, isEmpty);
      });

      test('should reset all statistics', () {
        // Arrange
        final stats = Statistics(
          totalCompletions: {'water': 25},
          dailyCompletions: {'water': 8},
          weeklyCompletions: {'water': 50},
          monthlyCompletions: {'water': 200},
        );

        // Act
        stats.resetAll();

        // Assert
        expect(stats.totalCompletions, isEmpty);
        expect(stats.dailyCompletions, isEmpty);
        expect(stats.weeklyCompletions, isEmpty);
        expect(stats.monthlyCompletions, isEmpty);
      });
    });

    group('Edge Cases', () {
      test('should handle large numbers', () {
        // Arrange
        final stats = Statistics();

        // Act
        stats.addCompletion('water', DateTime.fromMillisecondsSinceEpoch(1000000));

        // Assert
        expect(stats.totalCompletions['water'], equals(1000000));
      });

      test('should handle negative completion counts gracefully', () {
        // Arrange
        final stats = Statistics();

        // Act & Assert - should not allow negative values
        expect(() => stats.addCompletion('water', DateTime.fromMillisecondsSinceEpoch(-5)), throwsArgumentError);
      });

      test('should handle empty reminder ID', () {
        // Arrange
        final stats = Statistics();

        // Act
        stats.incrementCompletion('');

        // Assert
        expect(stats.totalCompletions[''], equals(1));
      });

      test('should handle special characters in reminder ID', () {
        // Arrange
        final stats = Statistics();
        final specialId = 'reminder-with-special-chars_!@#\$%^&*()';

        // Act
        stats.incrementCompletion(specialId);

        // Assert
        expect(stats.totalCompletions[specialId], equals(1));
      });
    });
  });
}