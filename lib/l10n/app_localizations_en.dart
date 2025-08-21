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
    return 'Exercise Count';
  }

  @override
  String reminderDue(String reminderType) {
    return 'Time for $reminderType!';
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
