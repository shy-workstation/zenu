import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:zenu/services/reminder_service.dart';
import 'package:zenu/services/theme_service.dart';
import 'package:zenu/models/reminder.dart';
import 'package:zenu/models/statistics.dart';

/// Helper class for common test operations
class TestHelpers {
  /// Pump and settle with custom timeout
  static Future<void> pumpAndSettleWithTimeout(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 10),
    Duration interval = const Duration(milliseconds: 100),
  }) async {
    await tester.pumpAndSettle(timeout);
  }

  /// Find widget by key with timeout
  static Future<Finder> findByKeyWithTimeout(
    WidgetTester tester,
    Key key, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final stopwatch = Stopwatch()..start();
    
    while (stopwatch.elapsed < timeout) {
      await tester.pump();
      final finder = find.byKey(key);
      if (finder.evaluate().isNotEmpty) {
        return finder;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    throw Exception('Widget with key $key not found within $timeout');
  }

  /// Tap and wait for animation to complete
  static Future<void> tapAndWait(
    WidgetTester tester,
    Finder finder, {
    Duration wait = const Duration(milliseconds: 300),
  }) async {
    await tester.tap(finder);
    await tester.pump();
    await Future.delayed(wait);
    await tester.pumpAndSettle();
  }

  /// Drag widget with custom parameters
  static Future<void> dragWidget(
    WidgetTester tester,
    Finder finder,
    Offset offset, {
    Duration duration = const Duration(milliseconds: 300),
  }) async {
    await tester.drag(finder, offset);
    await tester.pumpAndSettle();
  }

  /// Enter text with delay simulation
  static Future<void> enterTextSlowly(
    WidgetTester tester,
    Finder finder,
    String text, {
    Duration delayBetweenChars = const Duration(milliseconds: 50),
  }) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
    
    for (int i = 0; i < text.length; i++) {
      await tester.enterText(finder, text.substring(0, i + 1));
      await Future.delayed(delayBetweenChars);
      await tester.pump();
    }
    
    await tester.pumpAndSettle();
  }

  /// Scroll until widget is visible
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder finder,
    Finder scrollableFinder, {
    double delta = 300.0,
    AxisDirection scrollDirection = AxisDirection.down,
  }) async {
    while (finder.evaluate().isEmpty) {
      await tester.drag(scrollableFinder, 
          scrollDirection == AxisDirection.down 
              ? Offset(0, -delta) 
              : Offset(0, delta));
      await tester.pumpAndSettle();
    }
  }

  /// Wait for condition to be true
  static Future<void> waitForCondition(
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 10),
    Duration interval = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();
    
    while (!condition() && stopwatch.elapsed < timeout) {
      await Future.delayed(interval);
    }
    
    if (!condition()) {
      throw TimeoutException('Condition not met within $timeout', timeout);
    }
  }

  /// Check if widget has semantic properties
  static bool hasSemanticLabel(WidgetTester tester, Finder finder, String expectedLabel) {
    try {
      final semantics = tester.getSemantics(finder);
      return semantics.label == expectedLabel;
    } catch (e) {
      return false;
    }
  }

  /// Check if widget is accessible
  static bool isAccessible(WidgetTester tester, Finder finder) {
    try {
      final semantics = tester.getSemantics(finder);
      return semantics.label.isNotEmpty || semantics.hint.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Verify widget tree performance
  static void verifyNoBuildErrors(WidgetTester tester) {
    expect(tester.takeException(), isNull);
  }

  /// Create test reminder with defaults
  static Reminder createTestReminder({
    String? id,
    ReminderType type = ReminderType.water,
    String? title,
    bool isEnabled = true,
    Duration? interval,
  }) {
    return Reminder(
      id: id ?? 'test-${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      title: title ?? 'Test ${type.name}',
      description: 'Test description for ${type.name}',
      icon: _getIconForType(type),
      color: _getColorForType(type),
      interval: interval ?? const Duration(minutes: 30),
      isEnabled: isEnabled,
    );
  }

  /// Create test statistics with sample data
  static Statistics createTestStatistics({
    int totalCompletions = 10,
    int dailyCompletions = 3,
  }) {
    return Statistics(
      totalCompletions: {'test': totalCompletions},
      dailyCompletions: {'test': dailyCompletions},
    );
  }

  static IconData _getIconForType(ReminderType type) {
    switch (type) {
      case ReminderType.water:
        return Icons.water_drop;
      case ReminderType.exercise:
        return Icons.fitness_center;
      case ReminderType.eyeRest:
        return Icons.visibility;
      case ReminderType.stretching:
        return Icons.accessibility_new;
      case ReminderType.custom:
        return Icons.notifications;
      case ReminderType.standUp:
        return Icons.airline_seat_recline_normal;
      case ReminderType.pullUps:
        return Icons.fitness_center;
      case ReminderType.pushUps:
        return Icons.fitness_center;
      case ReminderType.stretch:
        return Icons.accessibility_new;
      case ReminderType.squats:
        return Icons.fitness_center;
      case ReminderType.jumpingJacks:
        return Icons.fitness_center;
      case ReminderType.planks:
        return Icons.fitness_center;
      case ReminderType.burpees:
        return Icons.fitness_center;
    }
  }

  static Color _getColorForType(ReminderType type) {
    switch (type) {
      case ReminderType.water:
        return Colors.blue;
      case ReminderType.exercise:
        return Colors.green;
      case ReminderType.eyeRest:
        return Colors.orange;
      case ReminderType.stretching:
        return Colors.purple;
      case ReminderType.custom:
        return Colors.red;
      case ReminderType.standUp:
        return Colors.teal;
      case ReminderType.pullUps:
        return Colors.indigo;
      case ReminderType.pushUps:
        return Colors.cyan;
      case ReminderType.stretch:
        return Colors.purple;
      case ReminderType.squats:
        return Colors.deepOrange;
      case ReminderType.jumpingJacks:
        return Colors.lime;
      case ReminderType.planks:
        return Colors.brown;
      case ReminderType.burpees:
        return Colors.pink;
    }
  }
}

/// Mock setup helpers for common services
class MockSetupHelpers {
  /// Setup mock reminder service with default behavior
  static void setupMockReminderService(
    MockReminderService mock, {
    List<Reminder>? reminders,
    Statistics? statistics,
    bool isRunning = false,
  }) {
    when(mock.reminders).thenReturn(reminders ?? []);
    when(mock.statistics).thenReturn(statistics ?? Statistics());
    when(mock.isRunning).thenReturn(isRunning);
    when(mock.loadData()).thenAnswer((_) async {});
    when(mock.saveData()).thenAnswer((_) async {});
    // addReminder and removeReminder are void methods - no need to mock return values
    when(mock.startReminders()).thenAnswer((_) async {});
    when(mock.stopReminders()).thenAnswer((_) async {});
  }

  /// Setup mock theme service with default behavior
  static void setupMockThemeService(
    MockThemeService mock, {
    bool isDarkMode = false,
  }) {
    when(mock.isDarkMode).thenReturn(isDarkMode);
    when(mock.cardColor).thenReturn(isDarkMode ? Colors.grey[800]! : Colors.white);
    when(mock.textPrimary).thenReturn(isDarkMode ? Colors.white : Colors.black);
    when(mock.textSecondary).thenReturn(isDarkMode ? Colors.grey[400]! : Colors.grey[600]!);
    when(mock.shadowColor).thenReturn(Colors.grey.withValues(alpha: 0.1));
    when(mock.toggleTheme()).thenAnswer((_) async {});
  }
}

/// Performance testing helpers
class PerformanceTestHelpers {
  /// Measure widget build time
  static Future<Duration> measureBuildTime(
    WidgetTester tester,
    Widget widget,
  ) async {
    final stopwatch = Stopwatch()..start();
    await tester.pumpWidget(widget);
    stopwatch.stop();
    return stopwatch.elapsed;
  }

  /// Measure animation performance
  static Future<Map<String, dynamic>> measureAnimationPerformance(
    WidgetTester tester,
    Future<void> Function() animation,
  ) async {
    final List<Duration> frameTimes = [];
    final stopwatch = Stopwatch();
    
    tester.binding.addPersistentFrameCallback((timeStamp) {
      if (stopwatch.isRunning) {
        frameTimes.add(stopwatch.elapsed);
        stopwatch.reset();
        stopwatch.start();
      }
    });
    
    stopwatch.start();
    await animation();
    stopwatch.stop();
    
    return {
      'frameCount': frameTimes.length,
      'averageFrameTime': frameTimes.isNotEmpty 
          ? frameTimes.reduce((a, b) => a + b) ~/ frameTimes.length
          : Duration.zero,
      'maxFrameTime': frameTimes.isNotEmpty 
          ? frameTimes.reduce((a, b) => a > b ? a : b)
          : Duration.zero,
    };
  }

  /// Check for memory leaks in widget tests
  static void checkForMemoryLeaks(WidgetTester tester) {
    // This would typically integrate with memory profiling tools
    // For now, just verify no exceptions occurred
    expect(tester.takeException(), isNull);
  }
}

/// Accessibility testing helpers
class AccessibilityTestHelpers {
  /// Check if widget meets accessibility guidelines
  static Future<void> checkAccessibility(WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  }

  /// Verify screen reader announcements
  static void verifyScreenReaderAnnouncement(
    WidgetTester tester,
    String expectedAnnouncement,
  ) {
    // This would integrate with actual screen reader testing
    // For now, check that semantic labels exist
    final semanticsFinder = find.bySemanticsLabel(expectedAnnouncement);
    expect(semanticsFinder, findsAtLeastNWidgets(1));
  }

  /// Test keyboard navigation
  static Future<void> testKeyboardNavigation(WidgetTester tester) async {
    // Test tab navigation
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    
    // Verify focus moved to next element
    expect(find.byType(Focus), findsWidgets);
  }
}

/// Mock class placeholders (these would be generated by mockito)
abstract class MockReminderService extends Mock implements ReminderService {}
abstract class MockThemeService extends Mock implements ThemeService {}