// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Zenu';

  @override
  String get healthDashboard => 'Gesundheits-Dashboard';

  @override
  String get systemActive => 'System aktiv - Überwacht Ihre Gesundheit';

  @override
  String get systemPaused => 'System pausiert - Klicken zum Fortsetzen';

  @override
  String get pauseSystem => 'System pausieren';

  @override
  String get startSystem => 'System starten';

  @override
  String get addReminder => 'Erinnerung hinzufügen';

  @override
  String get waterReminder => 'Wasser-Erinnerung';

  @override
  String get exerciseReminder => 'Übungs-Erinnerung';

  @override
  String get eyeRestReminder => 'Augenpause-Erinnerung';

  @override
  String get customReminder => 'Benutzerdefinierte Erinnerung';

  @override
  String get completeExercise => 'Übung abschließen';

  @override
  String get snooze => 'Schlummern';

  @override
  String get skip => 'Überspringen';

  @override
  String get noRemindersYet => 'Noch keine Erinnerungen';

  @override
  String get tapToCreateFirst =>
      'Tippen Sie auf + um Ihre erste gesunde Gewohnheit zu erstellen';

  @override
  String get addFirstReminder => 'Erste Erinnerung hinzufügen';

  @override
  String get noRemindersTitle => 'Noch keine Erinnerungen';

  @override
  String get noRemindersSubtitle =>
      'Tippen Sie auf + um Ihre erste gesunde Gewohnheit zu erstellen';

  @override
  String get getStarted => 'Erste Schritte';

  @override
  String exerciseCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Übungen',
      one: '1 Übung',
      zero: 'Keine Übungen',
    );
    return '$_temp0';
  }

  @override
  String reminderDue(String reminderType) {
    return 'Zeit für $reminderType!';
  }

  @override
  String get statistics => 'Statistics';

  @override
  String get resetStatistics => 'Reset Statistics';

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get save => 'Save';

  @override
  String get complete => 'Complete';

  @override
  String get manageReminders => 'Manage Reminders';

  @override
  String yourReminders(int count) {
    return 'Your Reminders ($count)';
  }

  @override
  String get markComplete => 'Mark Complete';

  @override
  String reminderCompleted(String reminderTitle) {
    return '$reminderTitle completed!';
  }

  @override
  String completeReminderTitle(String reminderTitle) {
    return 'Complete $reminderTitle';
  }

  @override
  String reminderSettings(String reminderTitle) {
    return '$reminderTitle Settings';
  }

  @override
  String get intervalMinutes => 'Interval (minutes)';

  @override
  String get waterReminderAdded => 'Water reminder added! 💧';

  @override
  String exerciseReminderAdded(String title) {
    return '$title reminder added! 💪';
  }

  @override
  String get eyeRestReminderAdded => 'Eye rest reminder added! 👁️';

  @override
  String customReminderAdded(String title) {
    return 'Custom reminder \"$title\" added! ✨';
  }

  @override
  String get chooseExerciseType => 'Choose Exercise Type';

  @override
  String get icon => 'Icon:';

  @override
  String get color => 'Color:';

  @override
  String get unit => 'Unit:';

  @override
  String get min => 'Min:';

  @override
  String get max => 'Max:';

  @override
  String get step => 'Step:';

  @override
  String get pleaseEnterTitle => 'Please enter a title';

  @override
  String get statisticsResetSuccess => 'Statistics reset successfully';

  @override
  String get zenuHealthReminder => 'Zenu - Health Reminder';

  @override
  String get zenuHealthReminderApp => 'Zenu Health Reminder App';

  @override
  String get appRunningSuccessfully => 'App is running successfully! 🎉';

  @override
  String get compilationErrorsFixed => 'All compilation errors fixed';

  @override
  String get compilationErrorsFixedDesc =>
      'The app now compiles and runs without errors';

  @override
  String get providerIntegrationProgress => 'Provider integration in progress';

  @override
  String get fullUIFunctionalityComing => 'Full UI functionality coming soon';

  @override
  String reminderServiceStatus(String status) {
    return 'Reminder Service: $status';
  }

  @override
  String get running => 'Running';

  @override
  String get stopped => 'Stopped';

  @override
  String remindersLoaded(int count) {
    return '$count reminders loaded';
  }

  @override
  String get testAppFunctionality => 'Test App Functionality';

  @override
  String get manualTestConfirmed =>
      'Manual testing confirmed - App is working!';

  @override
  String error(String message) {
    return 'Error: $message';
  }
}
