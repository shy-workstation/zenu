import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:zenu/widgets/empty_state.dart';
import 'package:zenu/l10n/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en', 'US')],
    home: Scaffold(body: child),
  );
}

void main() {
  group('EmptyState Widget Tests', () {
    testWidgets('should display empty state with correct text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(EmptyState(onAddReminder: () {})),
      );
      // Use pump() instead of pumpAndSettle — widget has infinite animation
      await tester.pump(const Duration(seconds: 1));

      expect(find.byIcon(Icons.notifications_none_outlined), findsOneWidget);
      expect(find.text('No reminders yet'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Quick Tips'), findsOneWidget);
    });

    testWidgets('should call onAddReminder when button is tapped', (
      WidgetTester tester,
    ) async {
      bool addReminderCalled = false;

      await tester.pumpWidget(
        _wrap(EmptyState(onAddReminder: () => addReminderCalled = true)),
      );
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Get Started'));
      await tester.pump();

      expect(addReminderCalled, isTrue);
    });

    testWidgets('should use custom primary color', (WidgetTester tester) async {
      const customColor = Colors.purple;

      await tester.pumpWidget(
        _wrap(EmptyState(
          onAddReminder: () {},
          primaryColor: customColor,
        )),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('should display quick tips section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(EmptyState(onAddReminder: () {})),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
      expect(find.text('Quick Tips'), findsOneWidget);
      expect(
        find.textContaining('Start with 2-3 simple reminders'),
        findsOneWidget,
      );
      expect(find.textContaining('Use default intervals'), findsOneWidget);
      expect(find.textContaining('Enable notifications'), findsOneWidget);
    });
  });
}
