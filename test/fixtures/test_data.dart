import 'package:flutter/material.dart';
import 'package:zenu/models/reminder.dart';
import 'package:zenu/models/statistics.dart';

/// Test data fixtures for reminders
class TestReminders {
  static Reminder water = Reminder(
    id: 'test-water-1',
    type: ReminderType.water,
    title: 'Stay Hydrated',
    description: 'Drink water regularly',
    icon: Icons.water_drop,
    color: Colors.blue,
    interval: const Duration(minutes: 30),
    isEnabled: true,
  );

  static Reminder exercise = Reminder(
    id: 'test-exercise-1',
    type: ReminderType.exercise,
    title: 'Exercise Break',
    description: 'Do some light exercise',
    icon: Icons.fitness_center,
    color: Colors.green,
    interval: const Duration(hours: 2),
    isEnabled: true,
  );

  static Reminder eyeRest = Reminder(
    id: 'test-eyerest-1',
    type: ReminderType.eyeRest,
    title: 'Eye Rest',
    description: 'Look away from screen',
    icon: Icons.visibility,
    color: Colors.orange,
    interval: const Duration(minutes: 20),
    isEnabled: true,
  );

  static Reminder stretching = Reminder(
    id: 'test-stretching-1',
    type: ReminderType.stretching,
    title: 'Stretch',
    description: 'Stretch your muscles',
    icon: Icons.accessibility_new,
    color: Colors.purple,
    interval: const Duration(hours: 1),
    isEnabled: false,
  );

  static Reminder custom = Reminder(
    id: 'test-custom-1',
    type: ReminderType.custom,
    title: 'Custom Reminder',
    description: 'Custom description',
    icon: Icons.notifications,
    color: Colors.red,
    interval: const Duration(minutes: 45),
    isEnabled: true,
  );

  static List<Reminder> all = [water, exercise, eyeRest, stretching, custom];
  static List<Reminder> enabled = [water, exercise, eyeRest, custom];
  static List<Reminder> disabled = [stretching];
}

/// Test data fixtures for statistics
class TestStatistics {
  static Statistics empty = Statistics();

  static Statistics withData = Statistics(
    totalCompletions: {
      'test-water-1': 25,
      'test-exercise-1': 5,
      'test-eyerest-1': 15,
      'test-custom-1': 3,
    },
    dailyCompletions: {
      'test-water-1': 8,
      'test-exercise-1': 2,
      'test-eyerest-1': 6,
      'test-custom-1': 1,
    },
    weeklyCompletions: {
      'test-water-1': 50,
      'test-exercise-1': 10,
      'test-eyerest-1': 35,
      'test-custom-1': 7,
    },
    monthlyCompletions: {
      'test-water-1': 200,
      'test-exercise-1': 40,
      'test-eyerest-1': 150,
      'test-custom-1': 25,
    },
  );

  static Statistics highVolume = Statistics(
    totalCompletions: {
      'test-water-1': 500,
      'test-exercise-1': 100,
      'test-eyerest-1': 300,
      'test-custom-1': 75,
    },
    dailyCompletions: {
      'test-water-1': 16,
      'test-exercise-1': 4,
      'test-eyerest-1': 12,
      'test-custom-1': 3,
    },
  );
}

/// Test data for platform-specific scenarios
class TestPlatformData {
  static Map<String, dynamic> androidNotificationData = {
    'id': 1,
    'title': 'Test Notification',
    'body': 'Test notification body',
    'channelId': 'zenu_reminders',
    'importance': 'high',
    'priority': 'high',
    'autoCancel': true,
  };

  static Map<String, dynamic> iOSNotificationData = {
    'id': 1,
    'title': 'Test Notification',
    'body': 'Test notification body',
    'badge': 1,
    'sound': 'default',
    'categoryId': 'reminder',
  };

  static Map<String, dynamic> windowsToastData = {
    'id': 1,
    'title': 'Test Notification',
    'body': 'Test notification body',
    'group': 'zenu',
    'tag': 'reminder',
    'duration': 'short',
  };

  static List<Map<String, dynamic>> systemTrayMenuItems = [
    {'label': 'Show App', 'action': 'show'},
    {'label': 'Start Reminders', 'action': 'start'},
    {'label': 'Stop Reminders', 'action': 'stop'},
    {'separator': true},
    {'label': 'Quit', 'action': 'quit'},
  ];
}

/// Test scenarios for different user journeys
class TestScenarios {
  static const firstTimeUser = {
    'hasReminders': false,
    'hasCompletedOnboarding': false,
    'preferredTheme': 'system',
    'notificationsEnabled': true,
  };

  static const returningUser = {
    'hasReminders': true,
    'reminderCount': 3,
    'hasCompletedOnboarding': true,
    'totalCompletions': 150,
    'preferredTheme': 'light',
    'notificationsEnabled': true,
  };

  static const powerUser = {
    'hasReminders': true,
    'reminderCount': 8,
    'hasCompletedOnboarding': true,
    'totalCompletions': 1000,
    'customReminders': 4,
    'preferredTheme': 'dark',
    'notificationsEnabled': true,
    'systemTrayEnabled': true,
  };

  static const restrictedUser = {
    'hasReminders': true,
    'reminderCount': 2,
    'notificationsEnabled': false,
    'systemTrayEnabled': false,
    'limitedPermissions': true,
  };
}

/// Test environment configurations
class TestEnvironments {
  static const development = {
    'debug': true,
    'logging': 'verbose',
    'mockData': true,
    'analytics': false,
  };

  static const testing = {
    'debug': true,
    'logging': 'info',
    'mockData': true,
    'analytics': false,
    'animations': false,
  };

  static const production = {
    'debug': false,
    'logging': 'error',
    'mockData': false,
    'analytics': true,
    'animations': true,
  };
}

/// Mock response data for API-like operations
class MockResponses {
  static const Map<String, dynamic> successResponse = {
    'status': 'success',
    'message': 'Operation completed successfully',
    'data': {},
  };

  static const Map<String, dynamic> errorResponse = {
    'status': 'error',
    'message': 'Operation failed',
    'error': {
      'code': 'TEST_ERROR',
      'details': 'This is a test error',
    },
  };

  static const Map<String, dynamic> networkErrorResponse = {
    'status': 'error',
    'message': 'Network error',
    'error': {
      'code': 'NETWORK_ERROR',
      'details': 'Failed to connect to server',
    },
  };

  static const Map<String, dynamic> validationErrorResponse = {
    'status': 'error',
    'message': 'Validation error',
    'error': {
      'code': 'VALIDATION_ERROR',
      'details': 'Invalid input data',
      'fields': ['title', 'interval'],
    },
  };
}