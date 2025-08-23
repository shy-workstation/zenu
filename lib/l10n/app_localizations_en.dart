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
  String get pushUpsReminder => 'Push-ups Reminder';

  @override
  String get pullUpsReminder => 'Pull-ups Reminder';

  @override
  String get squatsReminder => 'Squats Reminder';

  @override
  String get stretchingReminder => 'Stretching Reminder';

  @override
  String get jumpingJacksReminder => 'Jumping Jacks Reminder';

  @override
  String get planksReminder => 'Planks Reminder';

  @override
  String get burpeesReminder => 'Burpees Reminder';

  @override
  String get eyeRestReminder => 'Eye Rest Reminder';

  @override
  String get standUpReminder => 'Stand Up Reminder';

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
  String get exerciseCount => 'Exercise Count';

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
  String get duplicate => 'Duplicate';

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
  String get upperBodyStrengthExercise => 'Upper body strength exercise';

  @override
  String get backAndArmStrengthening => 'Back and arm strengthening';

  @override
  String get lowerBodyStrengtheningExercise =>
      'Lower body strengthening exercise';

  @override
  String get bodyFlexibilityAndMobility => 'Body flexibility and mobility';

  @override
  String get fullBodyCardioExercise => 'Full body cardio exercise';

  @override
  String get coreStrengtheningExercise => 'Core strengthening exercise';

  @override
  String get fullBodyHighIntensityExercise =>
      'Full body high intensity exercise';

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
  String get stayHydrated => 'Stay Hydrated';

  @override
  String get drinkWaterRegularly => 'Drink water regularly';

  @override
  String get restYourEyes => 'Rest Your Eyes';

  @override
  String get lookAwayFromScreen => 'Look away from screen and blink';

  @override
  String get standAndMove => 'Stand and Move';

  @override
  String get getUpFromYourDesk => 'Get up from your desk and move around';

  @override
  String get quickTips => 'Quick Tips';

  @override
  String get startWithSimpleReminders => 'Start with 2-3 simple reminders';

  @override
  String get useDefaultIntervals => 'Use default intervals';

  @override
  String get enableNotifications => 'Enable notifications';

  @override
  String get strengthenThoseLegs => 'Strengthen those legs!';

  @override
  String get getYourHeartPumping => 'Get your heart pumping!';

  @override
  String get corePowerTime => 'Core power time!';

  @override
  String get fullBodyBurn => 'Full body burn!';

  @override
  String error(String message) {
    return 'Error: $message';
  }

  @override
  String get activeReminders => 'Active Reminders';

  @override
  String get today => 'Today';

  @override
  String get allTime => 'All Time';

  @override
  String get todaysProgress => 'Today\'s Progress';

  @override
  String get thisWeek => 'This Week';

  @override
  String get resetStatisticsDialog =>
      'Are you sure you want to reset all statistics? This action cannot be undone.';

  @override
  String get tapAddReminderToStart =>
      'Tap \"Add Reminder\" to create your first reminder';

  @override
  String get failedToStartApp => 'Failed to start app';

  @override
  String get notificationTimeToRestEyes =>
      'Time to rest your eyes! Look away from your screen.';

  @override
  String get notificationTimeToStandUp =>
      'Stand up and move around for a few minutes.';

  @override
  String get notificationTimeToDrinkWater => 'Don\'t forget to drink water!';

  @override
  String get notificationTimeToStretch => 'Take a moment to stretch your body.';

  @override
  String notificationTimeForPullUps(int count) {
    return 'Time for $count pull-ups!';
  }

  @override
  String notificationTimeForPushUps(int count) {
    return 'Time for $count push-ups!';
  }

  @override
  String notificationTimeForSquats(int count) {
    return 'Time for $count squats!';
  }

  @override
  String notificationTimeForJumpingJacks(int count) {
    return 'Time for $count jumping jacks!';
  }

  @override
  String notificationTimeForPlanks(int count) {
    return 'Time for a $count second plank!';
  }

  @override
  String notificationTimeForBurpees(int count) {
    return 'Time for $count burpees!';
  }

  @override
  String get healthReminderApp => 'Health Reminder App';

  @override
  String get healthReminders => 'Health Reminders';

  @override
  String get notificationsForHealthReminders =>
      'Notifications for health reminders';

  @override
  String get allCompilationErrorsFixed => 'All compilation errors fixed';

  @override
  String get appCompilesAndRunsWithoutErrors =>
      'The app compiles and runs without errors';

  @override
  String get providerIntegrationInProgress =>
      'Provider integration in progress';

  @override
  String get fullUIFunctionalityComingSoon =>
      'Full UI functionality coming soon';

  @override
  String get manualTestingConfirmedAppWorking =>
      'Manual testing confirmed - App is working!';

  @override
  String get searchExercisesStretches =>
      'Search exercises, stretches, wellness...';

  @override
  String get done => 'Done!';

  @override
  String get snooze10m => 'Snooze 10m';

  @override
  String get title => 'Title';

  @override
  String get description => 'Description';

  @override
  String get unitHint => 'e.g., reps, ml, minutes';

  @override
  String get settingsAndReminderManagement =>
      'Settings and reminder management';

  @override
  String get testReminder => 'Test Reminder';

  @override
  String get streak => 'Streak';

  @override
  String get active => 'Active';

  @override
  String get nextIn => 'Next in';

  @override
  String reminderListAccessibility(int count) {
    return 'Reminder list with $count reminders';
  }

  @override
  String get settings => 'Settings';

  @override
  String get addHealthReminder => 'Add health reminder';

  @override
  String get start => 'START';

  @override
  String get pause => 'PAUSE';
}
