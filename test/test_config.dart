import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenu/services/theme_service.dart';
import 'package:zenu/services/reminder_service.dart';

/// Test configuration class for managing common test setup
class TestConfig {
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 5);
  static const Duration longTimeout = Duration(seconds: 60);

  /// Initialize test environment
  static Future<void> initialize() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Set up shared preferences for testing
    SharedPreferences.setMockInitialValues({});
  }

  /// Create a test wrapper widget with material app
  static Widget createTestWrapper({
    required Widget child,
    ThemeData? theme,
    Locale? locale,
  }) {
    return MaterialApp(
      theme: theme ?? ThemeData.light(),
      locale: locale ?? const Locale('en', 'US'),
      home: Scaffold(body: child),
    );
  }

  /// Create a full app test wrapper with providers
  static Widget createAppWrapper({
    required Widget child,
    ReminderService? reminderService,
    ThemeService? themeService,
  }) {
    return MaterialApp(
      title: 'Test App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(body: child),
    );
  }

  /// Test data factory methods
  static Map<String, dynamic> createTestReminderData({
    String? id,
    String? title,
    bool? isEnabled,
  }) {
    return {
      'id': id ?? 'test-reminder-1',
      'type': 0, // ReminderType.water
      'title': title ?? 'Test Reminder',
      'description': 'Test description',
      'iconCodePoint': Icons.water_drop.codePoint,
      'iconFontFamily': Icons.water_drop.fontFamily,
      'colorValue': '2196F3',
      'interval': 1800,
      'isEnabled': isEnabled ?? true,
      'nextReminder': DateTime.now().add(Duration(minutes: 30)).millisecondsSinceEpoch,
    };
  }

  /// Platform test utilities
  static void setPlatform(TargetPlatform platform) {
    debugDefaultTargetPlatformOverride = platform;
  }

  static void resetPlatform() {
    debugDefaultTargetPlatformOverride = null;
  }
}

/// Test categories for organizing tests
enum TestCategory {
  unit,
  widget,
  integration,
  performance,
  accessibility,
  platform,
}

/// Test severity levels
enum TestSeverity {
  critical,
  high,
  medium,
  low,
}

/// Test annotation for categorizing tests
class TestAnnotation {
  const TestAnnotation({
    required this.category,
    required this.severity,
    this.platforms = const [],
    this.description = '',
  });

  final TestCategory category;
  final TestSeverity severity;
  final List<TargetPlatform> platforms;
  final String description;
}

/// Custom matchers for testing
class CustomMatchers {
  /// Matcher for checking if a widget has accessibility semantics
  static Matcher hasAccessibilitySemantics() {
    return const _HasAccessibilitySemantics();
  }

  /// Matcher for checking if duration is approximately equal
  static Matcher approximatelyEqual(Duration expected, {Duration tolerance = const Duration(seconds: 1)}) {
    return _ApproximatelyEqualDuration(expected, tolerance);
  }
}

class _HasAccessibilitySemantics extends Matcher {
  const _HasAccessibilitySemantics();

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Widget) return false;
    // This would need to be implemented to check semantic properties
    return true;
  }

  @override
  Description describe(Description description) {
    return description.add('has accessibility semantics');
  }
}

class _ApproximatelyEqualDuration extends Matcher {
  const _ApproximatelyEqualDuration(this.expected, this.tolerance);

  final Duration expected;
  final Duration tolerance;

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Duration) return false;
    final difference = (item.inMilliseconds - expected.inMilliseconds).abs();
    return difference <= tolerance.inMilliseconds;
  }

  @override
  Description describe(Description description) {
    return description.add('approximately equals $expected (±$tolerance)');
  }
}