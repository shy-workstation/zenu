// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Zenu';

  @override
  String get healthDashboard => 'Health Dashboard';

  @override
  String get systemActive => 'System Active - Monitoring your health';

  @override
  String get systemPaused => 'System Paused - Click to resume';

  @override
  String get pauseSystem => 'Pause System';

  @override
  String get startSystem => 'Start System';

  @override
  String get addReminder => 'Add Reminder';

  @override
  String get waterReminder => 'Water Reminder';

  @override
  String get exerciseReminder => 'Exercise Reminder';

  @override
  String get eyeRestReminder => 'Eye Rest Reminder';

  @override
  String get customReminder => 'Custom Reminder';

  @override
  String get completeExercise => 'Complete Exercise';

  @override
  String get snooze => 'Snooze';

  @override
  String get skip => 'Skip';

  @override
  String get noRemindersYet => 'No reminders yet';

  @override
  String get tapToCreateFirst =>
      'Tap the + button to create your first healthy habit';

  @override
  String get addFirstReminder => 'Add First Reminder';

  @override
  String get noRemindersTitle => 'No reminders yet';

  @override
  String get noRemindersSubtitle =>
      'Tap the + button to create your first healthy habit';

  @override
  String get getStarted => 'Get Started';

  @override
  String exerciseCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '1 exercise',
      zero: 'No exercises',
    );
    return '$_temp0';
  }

  @override
  String reminderDue(String reminderType) {
    return 'Time for $reminderType!';
  }
}
