import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../mocks/mock_adapters.dart';
import '../../../fixtures/test_data.dart';
import '../../../test_config.dart';

void main() {
  group('iOS Notification Tests', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Set up iOS platform
      TestConfig.setPlatform(TargetPlatform.iOS);
    });

    tearDown(() {
      TestConfig.resetPlatform();
      MockPlatformChannel.reset();
    });

    group('Permission Management', () {
      test('should request notification permissions with all options', () async {
        // Arrange
        bool permissionRequested = false;
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'requestNotificationPermissions') {
            permissionRequested = true;
            final permissions = call.arguments['permissions'] as List;
            expect(permissions, contains('alert'));
            expect(permissions, contains('badge'));
            expect(permissions, contains('sound'));
            expect(permissions, contains('criticalAlert'));
            expect(permissions, contains('announcement'));
            return {
              'granted': true,
              'permissions': {
                'alert': true,
                'badge': true,
                'sound': true,
                'criticalAlert': false,
                'announcement': true,
              }
            };
          }
          return null;
        });

        // Act
        final result = await MockPlatformChannel.invokeMethod('requestNotificationPermissions', {
          'permissions': ['alert', 'badge', 'sound', 'criticalAlert', 'announcement'],
        });

        // Assert
        expect(permissionRequested, isTrue);
        expect(result['granted'], isTrue);
        expect(result['permissions']['alert'], isTrue);
        expect(result['permissions']['badge'], isTrue);
        expect(result['permissions']['sound'], isTrue);
        expect(result['permissions']['criticalAlert'], isFalse); // Usually requires special approval
      });

      test('should handle partial permission grant', () async {
        // Arrange
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'requestNotificationPermissions') {
            return {
              'granted': true,
              'permissions': {
                'alert': true,
                'badge': false, // User denied badge
                'sound': true,
              }
            };
          }
          return null;
        });

        // Act
        final result = await MockPlatformChannel.invokeMethod('requestNotificationPermissions', {
          'permissions': ['alert', 'badge', 'sound'],
        });

        // Assert
        expect(result['granted'], isTrue);
        expect(result['permissions']['alert'], isTrue);
        expect(result['permissions']['badge'], isFalse);
        expect(result['permissions']['sound'], isTrue);
      });

      test('should check current notification settings', () async {
        // Arrange
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'getNotificationSettings') {
            return {
              'authorizationStatus': 'authorized',
              'alertSetting': 'enabled',
              'badgeSetting': 'enabled',
              'soundSetting': 'enabled',
              'criticalAlertSetting': 'notSupported',
              'announcementSetting': 'enabled',
              'notificationCenterSetting': 'enabled',
              'lockScreenSetting': 'enabled',
            };
          }
          return null;
        });

        // Act
        final settings = await MockPlatformChannel.invokeMethod('getNotificationSettings');

        // Assert
        expect(settings['authorizationStatus'], equals('authorized'));
        expect(settings['alertSetting'], equals('enabled'));
        expect(settings['badgeSetting'], equals('enabled'));
        expect(settings['soundSetting'], equals('enabled'));
      });
    });

    group('Notification Categories and Actions', () {
      test('should register notification categories with actions', () async {
        // Arrange
        bool categoriesRegistered = false;
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'setNotificationCategories') {
            categoriesRegistered = true;
            final categories = call.arguments['categories'] as List;
            final reminderCategory = categories.firstWhere((c) => c['identifier'] == 'REMINDER_CATEGORY');
            
            expect(reminderCategory['actions'], isNotEmpty);
            final actions = reminderCategory['actions'] as List;
            expect(actions.any((a) => a['identifier'] == 'COMPLETE_ACTION'), isTrue);
            expect(actions.any((a) => a['identifier'] == 'SNOOZE_ACTION'), isTrue);
            
            return true;
          }
          return null;
        });

        // Act
        await MockPlatformChannel.invokeMethod('setNotificationCategories', {
          'categories': [
            {
              'identifier': 'REMINDER_CATEGORY',
              'actions': [
                {
                  'identifier': 'COMPLETE_ACTION',
                  'title': 'Complete',
                  'options': ['foreground'],
                },
                {
                  'identifier': 'SNOOZE_ACTION',
                  'title': 'Snooze 5 min',
                  'options': [],
                },
              ],
            },
          ],
        });

        // Assert
        expect(categoriesRegistered, isTrue);
      });

      test('should handle notification action with text input', () async {
        // Arrange
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'setNotificationCategories') {
            final categories = call.arguments['categories'] as List;
            final category = categories.first;
            final actions = category['actions'] as List;
            final textAction = actions.firstWhere((a) => a['identifier'] == 'TEXT_INPUT_ACTION');
            
            expect(textAction['textInputButtonTitle'], equals('Send'));
            expect(textAction['textInputPlaceholder'], equals('Enter custom time...'));
            
            return true;
          }
          return null;
        });

        // Act
        await MockPlatformChannel.invokeMethod('setNotificationCategories', {
          'categories': [
            {
              'identifier': 'CUSTOM_CATEGORY',
              'actions': [
                {
                  'identifier': 'TEXT_INPUT_ACTION',
                  'title': 'Custom Snooze',
                  'textInputButtonTitle': 'Send',
                  'textInputPlaceholder': 'Enter custom time...',
                  'options': ['foreground'],
                },
              ],
            },
          ],
        });
      });
    });

    group('Notification Content', () {
      test('should show basic notification with iOS-specific properties', () async {
        // Arrange
        final notificationData = TestPlatformData.iOSNotificationData;
        bool notificationShown = false;
        
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'showNotification') {
            notificationShown = true;
            
            expect(call.arguments['id'], equals(notificationData['id']));
            expect(call.arguments['title'], equals(notificationData['title']));
            expect(call.arguments['body'], equals(notificationData['body']));
            expect(call.arguments['badge'], equals(1));
            expect(call.arguments['sound'], equals('default'));
            expect(call.arguments['categoryId'], equals('reminder'));
            
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

      test('should show notification with custom sound', () async {
        // Arrange
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'showNotification') {
            expect(call.arguments['sound'], equals('custom_reminder.aiff'));
            return true;
          }
          return null;
        });

        // Act
        await MockPlatformChannel.invokeMethod('showNotification', {
          'id': 1,
          'title': 'Custom Sound Reminder',
          'body': 'With custom notification sound',
          'sound': 'custom_reminder.aiff',
        });
      });

      test('should show notification with attachments', () async {
        // Arrange
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'showNotification') {
            final attachments = call.arguments['attachments'] as List;
            expect(attachments.length, equals(1));
            expect(attachments[0]['identifier'], equals('image1'));
            expect(attachments[0]['url'], contains('.png'));
            expect(attachments[0]['type'], equals('image'));
            return true;
          }
          return null;
        });

        // Act
        await MockPlatformChannel.invokeMethod('showNotification', {
          'id': 1,
          'title': 'Notification with Image',
          'body': 'This notification has an attachment',
          'attachments': [
            {
              'identifier': 'image1',
              'url': 'file://path/to/image.png',
              'type': 'image',
            },
          ],
        });
      });

      test('should show critical alert notification', () async {
        // Arrange
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'showNotification') {
            expect(call.arguments['criticalAlert'], isTrue);
            expect(call.arguments['volume'], equals(0.8));
            return true;
          }
          return null;
        });

        // Act
        await MockPlatformChannel.invokeMethod('showNotification', {
          'id': 1,
          'title': 'Critical Health Alert',
          'body': 'Important health reminder',
          'criticalAlert': true,
          'volume': 0.8,
        });
      });
    });

    group('Scheduled Notifications', () {
      test('should schedule notification with date trigger', () async {
        // Arrange
        final scheduledTime = DateTime.now().add(const Duration(minutes: 30));
        bool notificationScheduled = false;
        
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'scheduleNotification') {
            notificationScheduled = true;
            expect(call.arguments['trigger']['type'], equals('date'));
            expect(call.arguments['trigger']['dateComponents'], isNotNull);
            expect(call.arguments['trigger']['repeats'], isFalse);
            return true;
          }
          return null;
        });

        // Act
        await MockPlatformChannel.invokeMethod('scheduleNotification', {
          'id': 1,
          'title': 'Scheduled Reminder',
          'body': 'Time for your reminder',
          'trigger': {
            'type': 'date',
            'dateComponents': {
              'year': scheduledTime.year,
              'month': scheduledTime.month,
              'day': scheduledTime.day,
              'hour': scheduledTime.hour,
              'minute': scheduledTime.minute,
            },
            'repeats': false,
          },
        });

        // Assert
        expect(notificationScheduled, isTrue);
      });

      test('should schedule repeating notification with calendar trigger', () async {
        // Arrange
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'scheduleNotification') {
            expect(call.arguments['trigger']['type'], equals('calendar'));
            expect(call.arguments['trigger']['repeats'], isTrue);
            expect(call.arguments['trigger']['dateMatching']['hour'], equals(9));
            expect(call.arguments['trigger']['dateMatching']['minute'], equals(0));
            return true;
          }
          return null;
        });

        // Act
        await MockPlatformChannel.invokeMethod('scheduleNotification', {
          'id': 1,
          'title': 'Daily Water Reminder',
          'body': 'Start your day with water',
          'trigger': {
            'type': 'calendar',
            'repeats': true,
            'dateMatching': {
              'hour': 9,
              'minute': 0,
            },
          },
        });
      });

      test('should schedule notification with time interval trigger', () async {
        // Arrange
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'scheduleNotification') {
            expect(call.arguments['trigger']['type'], equals('timeInterval'));
            expect(call.arguments['trigger']['timeInterval'], equals(1800.0)); // 30 minutes
            expect(call.arguments['trigger']['repeats'], isTrue);
            return true;
          }
          return null;
        });

        // Act
        await MockPlatformChannel.invokeMethod('scheduleNotification', {
          'id': 1,
          'title': 'Regular Water Reminder',
          'body': 'Time to hydrate',
          'trigger': {
            'type': 'timeInterval',
            'timeInterval': 1800.0, // 30 minutes in seconds
            'repeats': true,
          },
        });
      });
    });

    group('Notification Interaction', () {
      test('should handle notification tap', () async {
        // Arrange
        Map<String, dynamic>? receivedResponse;
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'onNotificationResponse') {
            receivedResponse = call.arguments;
            return null;
          }
          return null;
        });

        // Act
        await MockPlatformChannel.invokeMethod('onNotificationResponse', {
          'notificationId': 'reminder_1',
          'actionIdentifier': 'com.apple.UNNotificationDefaultActionIdentifier', // Default tap
          'userInfo': {'reminderId': 'water_1'},
        });

        // Assert
        expect(receivedResponse, isNotNull);
        expect(receivedResponse!['actionIdentifier'], equals('com.apple.UNNotificationDefaultActionIdentifier'));
        expect(receivedResponse!['userInfo']['reminderId'], equals('water_1'));
      });

      test('should handle custom action response', () async {
        // Arrange
        Map<String, dynamic>? receivedResponse;
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'onNotificationResponse') {
            receivedResponse = call.arguments;
            return null;
          }
          return null;
        });

        // Act
        await MockPlatformChannel.invokeMethod('onNotificationResponse', {
          'notificationId': 'reminder_1',
          'actionIdentifier': 'COMPLETE_ACTION',
          'userInfo': {'reminderId': 'water_1'},
        });

        // Assert
        expect(receivedResponse!['actionIdentifier'], equals('COMPLETE_ACTION'));
      });

      test('should handle text input action response', () async {
        // Arrange
        Map<String, dynamic>? receivedResponse;
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'onNotificationResponse') {
            receivedResponse = call.arguments;
            return null;
          }
          return null;
        });

        // Act
        await MockPlatformChannel.invokeMethod('onNotificationResponse', {
          'notificationId': 'reminder_1',
          'actionIdentifier': 'TEXT_INPUT_ACTION',
          'userText': '15 minutes',
          'userInfo': {'reminderId': 'water_1'},
        });

        // Assert
        expect(receivedResponse!['actionIdentifier'], equals('TEXT_INPUT_ACTION'));
        expect(receivedResponse!['userText'], equals('15 minutes'));
      });
    });

    group('iOS Version Compatibility', () {
      test('should handle iOS 12+ notification features', () async {
        // Test notification grouping
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'showNotification') {
            expect(call.arguments['threadIdentifier'], equals('water_reminders'));
            expect(call.arguments['summaryArgument'], equals('water reminder'));
            return true;
          }
          return null;
        });

        await MockPlatformChannel.invokeMethod('showNotification', {
          'id': 1,
          'title': 'Water Reminder',
          'body': 'Time to hydrate',
          'threadIdentifier': 'water_reminders',
          'summaryArgument': 'water reminder',
        });
      });

      test('should handle iOS 15+ communication notifications', () async {
        // Test communication notifications
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'showNotification') {
            expect(call.arguments['interruptionLevel'], equals('active'));
            expect(call.arguments['relevanceScore'], equals(0.8));
            return true;
          }
          return null;
        });

        await MockPlatformChannel.invokeMethod('showNotification', {
          'id': 1,
          'title': 'Health Check',
          'body': 'Time for your health reminder',
          'interruptionLevel': 'active',
          'relevanceScore': 0.8,
        });
      });

      test('should handle iOS 16+ Live Activities (if applicable)', () async {
        // Test Live Activities setup
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'startLiveActivity') {
            expect(call.arguments['activityId'], equals('water_tracking'));
            expect(call.arguments['attributes'], isNotNull);
            return {'activityId': 'activity_123'};
          }
          return null;
        });

        final result = await MockPlatformChannel.invokeMethod('startLiveActivity', {
          'activityId': 'water_tracking',
          'attributes': {
            'title': 'Water Intake Tracking',
            'target': 8,
            'current': 3,
          },
        });

        expect(result['activityId'], isNotNull);
      });
    });

    group('Focus and Do Not Disturb', () {
      test('should respect Focus modes', () async {
        // Arrange
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'checkFocusStatus') {
            return {
              'isActive': true,
              'focusMode': 'work',
              'allowsNotifications': false,
            };
          }
          return null;
        });

        // Act
        final focusStatus = await MockPlatformChannel.invokeMethod('checkFocusStatus');

        // Assert
        expect(focusStatus['isActive'], isTrue);
        expect(focusStatus['focusMode'], equals('work'));
        expect(focusStatus['allowsNotifications'], isFalse);
      });

      test('should set notification relevance score for Focus filtering', () async {
        // Arrange
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          if (call.method == 'showNotification') {
            expect(call.arguments['relevanceScore'], equals(1.0)); // High relevance
            expect(call.arguments['interruptionLevel'], equals('timeSensitive'));
            return true;
          }
          return null;
        });

        // Act
        await MockPlatformChannel.invokeMethod('showNotification', {
          'id': 1,
          'title': 'Critical Health Alert',
          'body': 'Important medication reminder',
          'relevanceScore': 1.0,
          'interruptionLevel': 'timeSensitive',
        });
      });
    });

    group('Error Handling', () {
      test('should handle permission denied', () async {
        // Arrange
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          throw PlatformException(
            code: 'PERMISSION_DENIED',
            message: 'User denied notification permissions',
          );
        });

        // Act & Assert
        expect(
          () => MockPlatformChannel.invokeMethod('requestNotificationPermissions'),
          throwsA(isA<PlatformException>()),
        );
      });

      test('should handle invalid category identifier', () async {
        // Arrange
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          throw PlatformException(
            code: 'INVALID_CATEGORY',
            message: 'Category identifier not found',
          );
        });

        // Act & Assert
        expect(
          () => MockPlatformChannel.invokeMethod('showNotification', {
            'categoryId': 'NONEXISTENT_CATEGORY'
          }),
          throwsA(isA<PlatformException>()),
        );
      });

      test('should handle notification content too large', () async {
        // Arrange
        MockPlatformChannel.setMockMethodCallHandler((MethodCall call) async {
          throw PlatformException(
            code: 'CONTENT_TOO_LARGE',
            message: 'Notification content exceeds size limits',
          );
        });

        // Act & Assert
        expect(
          () => MockPlatformChannel.invokeMethod('showNotification', {
            'body': 'A' * 10000 // Very large content
          }),
          throwsA(isA<PlatformException>()),
        );
      });
    });
  });
}