import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:zenu/widgets/compact_stats_bar.dart';
import 'package:zenu/services/reminder_service.dart';
import 'package:zenu/services/theme_service.dart';
import 'package:zenu/models/reminder.dart';
import 'package:zenu/models/statistics.dart';

// Generate mocks
@GenerateMocks([ReminderService, ThemeService])
import 'compact_stats_bar_test.mocks.dart';

void main() {
  group('CompactStatsBar Widget Tests', () {
    late MockReminderService mockReminderService;
    late MockThemeService mockThemeService;

    setUp(() {
      mockReminderService = MockReminderService();
      mockThemeService = MockThemeService();

      // Setup theme service defaults
      when(mockThemeService.cardColor).thenReturn(Colors.white);
      when(mockThemeService.textPrimary).thenReturn(Colors.black);
      when(mockThemeService.textSecondary).thenReturn(Colors.grey);
      when(
        mockThemeService.shadowColor,
      ).thenReturn(Colors.grey.withValues(alpha: 0.1));
      when(mockThemeService.isDarkMode).thenReturn(false);
    });

    testWidgets('should display stats cards correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      final statistics = Statistics(
        totalCompletions: {'total': 5},
        dailyCompletions: {DateTime.now().toIso8601String().split('T')[0]: 3},
      );

      final reminders = [
        Reminder(
          id: '1',
          type: ReminderType.water,
          title: 'Water',
          description: 'Stay hydrated',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
          isEnabled: true,
        ),
        Reminder(
          id: '2',
          type: ReminderType.custom,
          title: 'Exercise',
          description: 'Stay active',
          icon: Icons.fitness_center,
          color: Colors.green,
          interval: const Duration(hours: 2),
          isEnabled: false,
        ),
      ];

      when(mockReminderService.statistics).thenReturn(statistics);
      when(mockReminderService.reminders).thenReturn(reminders);
      when(mockReminderService.isRunning).thenReturn(true);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactStatsBar(
              reminderService: mockReminderService as ReminderService,
              themeService: mockThemeService as ThemeService,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Streak'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Next in'), findsOneWidget);

      // Check stats values
      expect(find.text('3'), findsOneWidget); // Today's completions
      expect(find.text('1'), findsAtLeastNWidgets(1)); // Active count or streak
    });

    testWidgets('should show correct active reminder count', (
      WidgetTester tester,
    ) async {
      // Arrange
      final reminders = [
        Reminder(
          id: '1',
          type: ReminderType.water,
          title: 'Water',
          description: 'Stay hydrated',
          icon: Icons.water_drop,
          color: Colors.blue,
          interval: const Duration(minutes: 30),
          isEnabled: true,
        ),
        Reminder(
          id: '2',
          type: ReminderType.custom,
          title: 'Exercise',
          description: 'Stay active',
          icon: Icons.fitness_center,
          color: Colors.green,
          interval: const Duration(hours: 2),
          isEnabled: true,
        ),
        Reminder(
          id: '3',
          type: ReminderType.custom,
          title: 'Break',
          description: 'Take a break',
          icon: Icons.coffee,
          color: Colors.orange,
          interval: const Duration(hours: 1),
          isEnabled: false,
        ),
      ];

      when(mockReminderService.reminders).thenReturn(reminders);
      when(mockReminderService.statistics).thenReturn(Statistics());
      when(mockReminderService.isRunning).thenReturn(false);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactStatsBar(
              reminderService: mockReminderService as ReminderService,
              themeService: mockThemeService as ThemeService,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - should show 2 active reminders
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('should show -- when reminders not running', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockReminderService.reminders).thenReturn([]);
      when(mockReminderService.statistics).thenReturn(Statistics());
      when(mockReminderService.isRunning).thenReturn(false);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactStatsBar(
              reminderService: mockReminderService as ReminderService,
              themeService: mockThemeService as ThemeService,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - next reminder time should show --
      expect(find.text('--'), findsOneWidget);
    });

    testWidgets('should be horizontally scrollable', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockReminderService.reminders).thenReturn([]);
      when(mockReminderService.statistics).thenReturn(Statistics());
      when(mockReminderService.isRunning).thenReturn(false);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactStatsBar(
              reminderService: mockReminderService as ReminderService,
              themeService: mockThemeService as ThemeService,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ListView), findsOneWidget);
      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.scrollDirection, equals(Axis.horizontal));
    });

    testWidgets('should have correct container height', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockReminderService.reminders).thenReturn([]);
      when(mockReminderService.statistics).thenReturn(Statistics());
      when(mockReminderService.isRunning).thenReturn(false);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactStatsBar(
              reminderService: mockReminderService as ReminderService,
              themeService: mockThemeService as ThemeService,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxHeight, equals(90));
    });
  });
}
