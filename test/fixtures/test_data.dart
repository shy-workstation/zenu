import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenu/models/reminder.dart';

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
    minQuantity: 0,
    maxQuantity: 1000,
    stepSize: 25,
    unit: 'ml',
  );

  static Reminder eyeRest = Reminder(
    id: 'test-eyerest-1',
    type: ReminderType.eyeRest,
    title: 'Eye Rest',
    description: 'Look away from screen',
    icon: Icons.remove_red_eye,
    color: Colors.orange,
    interval: const Duration(minutes: 20),
    isEnabled: true,
  );

  static Reminder stretch = Reminder(
    id: 'test-stretch-1',
    type: ReminderType.stretch,
    title: 'Stretch',
    description: 'Stretch your muscles',
    icon: Icons.self_improvement,
    color: Colors.purple,
    interval: const Duration(minutes: 15),
    isEnabled: false,
  );

  static Reminder pushUps = Reminder(
    id: 'test-pushups-1',
    type: ReminderType.pushUps,
    title: 'Push-ups',
    description: 'Upper body strength',
    icon: Icons.fitness_center,
    color: Colors.red,
    interval: const Duration(minutes: 10),
    isEnabled: true,
    exerciseCount: 5,
    maxQuantity: 50,
    unit: 'reps',
  );

  static List<Reminder> all = [water, eyeRest, stretch, pushUps];
  static List<Reminder> enabled = [water, eyeRest, pushUps];
  static List<Reminder> disabled = [stretch];
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
}

/// Mock platform channel for testing platform-specific functionality
class MockPlatformChannel {
  static const MethodChannel _channel = MethodChannel('test/platform');

  static void setMockMethodCallHandler(
      Future<dynamic> Function(MethodCall call)? handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, handler);
  }

  static Future<T?> invokeMethod<T>(String method, [dynamic arguments]) {
    return _channel.invokeMethod<T>(method, arguments);
  }

  static void reset() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  }
}
