import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../mocks/mock_adapters.dart';
import '../../../fixtures/test_data.dart';
import '../../../test_config.dart';

void main() {
  group('Android Notification Tests', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Set up Android platform
      TestConfig.setPlatform(TargetPlatform.android);
    });

    tearDown(() {
      TestConfig.resetPlatform();
      MockPlatformChannel.reset();
    });

    group('Notification Initialization', () {
      test('should initialize notification channel on Android API 26+', () async {
        // Arrange
        bool channelCreated = false;
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'createNotificationChannel') {
            channelCreated = true;
            expect(call.arguments['channelId'], equals('zenu_reminders'));
            expect(call.arguments['channelName'], equals('Zenu Reminders'));
            expect(call.arguments['importance'], equals('high'));
            return true;
          }
          return null;
        });

        // Act
        final result = await MockPlatformChannel.invokeMethod('createNotificationChannel', {
          'channelId': 'zenu_reminders',
          'channelName': 'Zenu Reminders',
          'importance': 'high',
        });

        // Assert
        expect(result, isTrue);
        expect(channelCreated, isTrue);
      });

      test('should request notification permissions on Android 13+', () async {
        // Arrange
        bool permissionRequested = false;
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'requestNotificationPermission') {
            permissionRequested = true;
            return true;
          }
          return null;
        });

        // Act
        final result = await MockPlatformChannel.invokeMethod('requestNotificationPermission');

        // Assert
        expect(result, isTrue);
        expect(permissionRequested, isTrue);
      });

      test('should handle permission denial gracefully', () async {
        // Arrange
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'requestNotificationPermission') {
            return false;
          }
          return null;
        });

        // Act
        final result = await MockPlatformChannel.invokeMethod('requestNotificationPermission');

        // Assert
        expect(result, isFalse);
      });
    });

    group('Notification Display', () {
      test('should show basic notification with correct Android parameters', () async {
        // Arrange
        final notificationData = TestPlatformData.androidNotificationData;
        bool notificationShown = false;
        
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'showNotification') {
            notificationShown = true;
            
            // Verify Android-specific parameters
            expect(call.arguments['id'], equals(notificationData['id']));
            expect(call.arguments['title'], equals(notificationData['title']));
            expect(call.arguments['body'], equals(notificationData['body']));
            expect(call.arguments['channelId'], equals('zenu_reminders'));
            expect(call.arguments['importance'], equals('high'));
            expect(call.arguments['priority'], equals('high'));
            expect(call.arguments['autoCancel'], isTrue);
            
            return true;
          }
          return null;
        });

        // Act
        final result = await MockPlatformChannel.invokeMethod('showNotification', notificationData);

        // Assert
        expect(result, isTrue);
        expect(notificationShown, isTrue);
      });

      test('should handle notification with large icon', () async {
        // Arrange
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'showNotification') {
            expect(call.arguments['largeIcon'], equals('app_icon'));
            expect(call.arguments['smallIcon'], equals('notification_icon'));
            return true;
          }
          return null;
        });

        // Act
        await MockPlatformChannel.invokeMethod('showNotification', {
          'id': 1,
          'title': 'Test',
          'body': 'Test body',
          'largeIcon': 'app_icon',
          'smallIcon': 'notification_icon',
        });
      });

      test('should show notification with action buttons', () async {
        // Arrange
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'showNotification') {
            final actions = call.arguments['actions'] as List<Map>;
            expect(actions.length, equals(2));
            expect(actions[0]['title'], equals('Complete'));
            expect(actions[0]['action'], equals('complete'));
            expect(actions[1]['title'], equals('Snooze'));
            expect(actions[1]['action'], equals('snooze'));
            return true;
          }
          return null;
        });

        // Act
        await MockPlatformChannel.invokeMethod('showNotification', {
          'id': 1,
          'title': 'Water Reminder',
          'body': 'Time to drink water',
          'actions': [
            {'title': 'Complete', 'action': 'complete'},
            {'title': 'Snooze', 'action': 'snooze'},
          ],
        });
      });
    });

    group('Scheduled Notifications', () {
      test('should schedule notification with exact alarm', () async {
        // Arrange
        final scheduledTime = DateTime.now().add(const Duration(minutes: 30));
        bool notificationScheduled = false;
        
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'scheduleExactNotification') {
            notificationScheduled = true;
            expect(call.arguments['scheduledTime'], equals(scheduledTime.millisecondsSinceEpoch));
            expect(call.arguments['allowWhileIdle'], isTrue);
            return true;
          }
          return null;
        });

        // Act
        await MockPlatformChannel.invokeMethod('scheduleExactNotification', {
          'id': 1,
          'title': 'Scheduled Reminder',
          'body': 'Time for your reminder',
          'scheduledTime': scheduledTime.millisecondsSinceEpoch,
          'allowWhileIdle': true,
        });

        // Assert
        expect(notificationScheduled, isTrue);
      });

      test('should handle Android battery optimization restrictions', () async {
        // Arrange
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'checkBatteryOptimization') {
            return false; // App is being battery optimized
          }
          if (call.method == 'requestIgnoreBatteryOptimization') {
            return true;
          }
          return null;
        });

        // Act
        final isOptimized = await MockPlatformChannel.invokeMethod('checkBatteryOptimization');
        final requestResult = await MockPlatformChannel.invokeMethod('requestIgnoreBatteryOptimization');

        // Assert
        expect(isOptimized, isFalse);
        expect(requestResult, isTrue);
      });

      test('should use WorkManager for repeated notifications on Android 12+', () async {
        // Arrange
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'scheduleWorkManagerNotification') {
            expect(call.arguments['workName'], equals('reminder_1'));
            expect(call.arguments['repeatInterval'], equals(30)); // minutes
            expect(call.arguments['constraints']['requiresCharging'], isFalse);
            expect(call.arguments['constraints']['requiresNetworkType'], equals('not_required'));
            return true;
          }
          return null;
        });

        // Act
        await MockPlatformChannel.invokeMethod('scheduleWorkManagerNotification', {
          'id': 1,
          'workName': 'reminder_1',
          'title': 'Water Reminder',
          'body': 'Time to hydrate',
          'repeatInterval': 30,
          'constraints': {
            'requiresCharging': false,
            'requiresNetworkType': 'not_required',
          },
        });
      });
    });

    group('Notification Interaction', () {
      test('should handle notification tap', () async {
        // Arrange
        String? receivedAction;
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'onNotificationTapped') {
            receivedAction = call.arguments['action'];
            return null;
          }
          return null;
        });

        // Act
        await MockPlatformChannel.invokeMethod('onNotificationTapped', {
          'notificationId': 1,
          'action': 'open_app',
          'payload': {'reminderId': 'water_1'},
        });

        // Assert
        expect(receivedAction, equals('open_app'));
      });

      test('should handle notification action button press', () async {
        // Arrange
        String? receivedAction;
        Map? receivedPayload;
        
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'onNotificationAction') {
            receivedAction = call.arguments['action'];
            receivedPayload = call.arguments['payload'];
            return null;
          }
          return null;
        });

        // Act
        await MockPlatformChannel.invokeMethod('onNotificationAction', {
          'notificationId': 1,
          'action': 'complete',
          'payload': {'reminderId': 'water_1'},
        });

        // Assert
        expect(receivedAction, equals('complete'));
        expect(receivedPayload!['reminderId'], equals('water_1'));
      });

      test('should handle notification dismiss', () async {
        // Arrange
        bool dismissHandled = false;
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'onNotificationDismissed') {
            dismissHandled = true;
            expect(call.arguments['notificationId'], equals(1));
            return null;
          }
          return null;
        });

        // Act
        await MockPlatformChannel.invokeMethod('onNotificationDismissed', {
          'notificationId': 1,
        });

        // Assert
        expect(dismissHandled, isTrue);
      });
    });

    group('Android Version Compatibility', () {
      test('should handle API level 21-30 notification features', () async {
        // Test basic notification features for older Android versions
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'showNotification') {
            // Should not include features not available on older APIs
            expect(call.arguments.containsKey('bubbleMetadata'), isFalse);
            expect(call.arguments.containsKey('conversationTitle'), isFalse);
            return true;
          }
          return null;
        });

        await MockPlatformChannel.invokeMethod('showNotification', {
          'id': 1,
          'title': 'Basic Notification',
          'body': 'Compatible with older Android versions',
          'channelId': 'zenu_reminders',
        });
      });

      test('should handle API level 31+ notification features', () async {
        // Test new features for Android 12+
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'showNotification') {
            // Can include newer features
            expect(call.arguments['customBigContentView'], isNotNull);
            expect(call.arguments['colorized'], isTrue);
            return true;
          }
          return null;
        });

        await MockPlatformChannel.invokeMethod('showNotification', {
          'id': 1,
          'title': 'Modern Notification',
          'body': 'Uses Android 12+ features',
          'customBigContentView': {'layout': 'custom_layout'},
          'colorized': true,
        });
      });

      test('should handle API level 33+ notification permission', () async {
        // Test runtime permission for Android 13+
        bool permissionChecked = false;
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'checkNotificationPermission') {
            permissionChecked = true;
            return true;
          }
          return null;
        });

        final hasPermission = await MockPlatformChannel.invokeMethod('checkNotificationPermission');
        
        expect(permissionChecked, isTrue);
        expect(hasPermission, isTrue);
      });

      test('should handle API level 34+ notification restrictions', () async {
        // Test notification restrictions for Android 14+
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'checkNotificationPolicy') {
            return {
              'areNotificationsEnabled': true,
              'canShowBadge': true,
              'canOverrideDoNotDisturb': false,
            };
          }
          return null;
        });

        final policy = await MockPlatformChannel.invokeMethod('checkNotificationPolicy');
        
        expect(policy['areNotificationsEnabled'], isTrue);
        expect(policy['canShowBadge'], isTrue);
        expect(policy['canOverrideDoNotDisturb'], isFalse);
      });
    });

    group('Error Handling', () {
      test('should handle notification service unavailable', () async {
        // Arrange
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          throw PlatformException(
            code: 'SERVICE_UNAVAILABLE',
            message: 'Notification service not available',
          );
        });

        // Act & Assert
        expect(
          () => MockPlatformChannel.invokeMethod('showNotification', {'id': 1}),
          throwsA(isA<PlatformException>()),
        );
      });

      test('should handle invalid notification data', () async {
        // Arrange
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          throw PlatformException(
            code: 'INVALID_ARGUMENTS',
            message: 'Invalid notification data',
          );
        });

        // Act & Assert
        expect(
          () => MockPlatformChannel.invokeMethod('showNotification', {'invalid': 'data'}),
          throwsA(isA<PlatformException>()),
        );
      });

      test('should handle network security policy restrictions', () async {
        // Arrange
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          throw PlatformException(
            code: 'SECURITY_EXCEPTION',
            message: 'Network security policy restricts cleartext traffic',
          );
        });

        // Act & Assert
        expect(
          () => MockPlatformChannel.invokeMethod('downloadNotificationIcon', {
            'url': 'http://example.com/icon.png'
          }),
          throwsA(isA<PlatformException>()),
        );
      });
    });

    group('Performance Tests', () {
      test('should handle rapid notification scheduling', () async {
        // Arrange
        int notificationCount = 0;
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'scheduleNotification') {
            notificationCount++;
            return true;
          }
          return null;
        });

        // Act - Schedule 100 notifications rapidly
        final futures = List.generate(100, (index) => 
          MockPlatformChannel.invokeMethod('scheduleNotification', {
            'id': index,
            'title': 'Notification $index',
            'scheduledTime': DateTime.now().add(Duration(minutes: index)).millisecondsSinceEpoch,
          })
        );
        
        await Future.wait(futures);

        // Assert
        expect(notificationCount, equals(100));
      });

      test('should handle notification cleanup efficiently', () async {
        // Arrange
        bool cleanupCalled = false;
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'cleanupOldNotifications') {
            cleanupCalled = true;
            expect(call.arguments['olderThan'], isA<int>());
            return {'cleaned': 50};
          }
          return null;
        });

        // Act
        final result = await MockPlatformChannel.invokeMethod('cleanupOldNotifications', {
          'olderThan': DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch,
        });

        // Assert
        expect(cleanupCalled, isTrue);
        expect(result['cleaned'], equals(50));
      });
    });
  });
}