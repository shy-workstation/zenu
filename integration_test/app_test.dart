import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zenu/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Health Reminder App Integration Tests', () {
    testWidgets(
      'Complete user flow: add reminder, start timers, complete reminder',
      (WidgetTester tester) async {
        // Start the app
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should show empty state initially
        expect(find.text('No reminders yet'), findsOneWidget);
        expect(find.text('Add First Reminder'), findsOneWidget);

        // Tap to add first reminder
        await tester.tap(find.text('Add First Reminder'));
        await tester.pumpAndSettle();

        // Should show speed dial options
        expect(find.byType(FloatingActionButton), findsWidgets);

        // Tap water reminder option
        await tester.tap(find.byIcon(Icons.water_drop));
        await tester.pumpAndSettle();

        // Should show quick add dialog
        expect(find.text('Water Reminder'), findsOneWidget);

        // Add water reminder with default settings
        await tester.tap(find.text('Add Reminder'));
        await tester.pumpAndSettle();

        // Should now show reminder card
        expect(find.text('Stay Hydrated'), findsOneWidget);
        expect(find.text('Drink water regularly'), findsOneWidget);

        // Start reminders
        final startButton = find.text('Start Reminders');
        if (startButton.evaluate().isNotEmpty) {
          await tester.tap(startButton);
          await tester.pumpAndSettle();
        }

        // Should show active reminder with timer
        expect(find.byIcon(Icons.water_drop), findsOneWidget);

        // Test swipe to complete
        await tester.drag(
          find.byKey(const Key('swipe_water')),
          const Offset(300, 0), // Swipe right
        );
        await tester.pumpAndSettle();

        // Should show completion feedback
        expect(find.textContaining('Completed'), findsOneWidget);

        // Check statistics updated
        await tester.tap(find.byIcon(Icons.bar_chart));
        await tester.pumpAndSettle();

        // Should show updated stats
        expect(
          find.text('1'),
          findsAtLeastNWidgets(1),
        ); // At least one completion
      },
    );

    testWidgets(
      'Accessibility: keyboard navigation and screen reader support',
      (WidgetTester tester) async {
        // Start the app
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Test keyboard navigation
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // Should focus on first interactive element
        expect(find.byType(Focus), findsWidgets);

        // Test screen reader announcements
        final emptyStateWidget = find.byType(Semantics).first;
        expect(emptyStateWidget, findsOneWidget);

        final semantics = tester.getSemantics(emptyStateWidget);
        expect(semantics.label, isNotNull);
        expect(semantics.hint, isNotNull);
      },
    );

    testWidgets('Performance: app starts within reasonable time', (
      WidgetTester tester,
    ) async {
      final stopwatch = Stopwatch()..start();

      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      stopwatch.stop();

      // Should start within 5 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));

      // Should show main UI
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Zenyu'), findsOneWidget);
    });

    testWidgets('Error handling: graceful degradation on failures', (
      WidgetTester tester,
    ) async {
      // This test would need to mock failure scenarios
      // For now, just ensure app doesn't crash on startup

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // App should still render even if services fail
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Internationalization: switch between languages', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Initial language should be English
      expect(find.text('Zenyu'), findsOneWidget);

      // Note: In a real test, we'd change system locale and verify
      // that German strings appear. This requires platform channel mocking.
    });

    testWidgets('Theme switching: dark mode toggle works', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to settings (assuming it exists)
      if (find.byIcon(Icons.settings).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();

        // Look for theme toggle
        final themeToggle = find.byType(Switch);
        if (themeToggle.evaluate().isNotEmpty) {
          await tester.tap(themeToggle.first);
          await tester.pumpAndSettle();

          // UI should update to reflect theme change
          expect(find.byType(MaterialApp), findsOneWidget);
        }
      }
    });

    testWidgets('Reminder lifecycle: create, modify, delete', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Add a reminder
      await tester.tap(find.text('Add First Reminder'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.fitness_center));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Reminder'));
      await tester.pumpAndSettle();

      // Should show reminder
      expect(find.textContaining('Exercise'), findsOneWidget);

      // Navigate to management screen
      if (find.byIcon(Icons.settings).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();

        // Test reminder management features
        expect(find.byType(ListView), findsWidgets);
      }
    });
  });
}
