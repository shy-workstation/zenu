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
  String get pauseSystem => 'Pause Reminders';

  @override
  String get startSystem => 'Start Reminders';

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

  @override
  String get enable => 'Enable';

  @override
  String get disable => 'Disable';

  @override
  String get off => 'Off';

  @override
  String get on => 'On';

  @override
  String get enabled => 'enabled';

  @override
  String get disabled => 'disabled';

  @override
  String reminderEnabled(String reminderTitle) {
    return '$reminderTitle enabled';
  }

  @override
  String reminderDisabled(String reminderTitle) {
    return '$reminderTitle disabled';
  }

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryExercise => 'Exercise';

  @override
  String get categoryMindBody => 'Mind & Body';

  @override
  String get pushUps => 'Push-ups';

  @override
  String get pullUps => 'Pull-ups';

  @override
  String get squats => 'Squats';

  @override
  String get stretching => 'Stretching';

  @override
  String get jumpingJacks => 'Jumping Jacks';

  @override
  String get planks => 'Planks';

  @override
  String get burpees => 'Burpees';

  @override
  String get deepBreathing => 'Deep Breathing';

  @override
  String get meditationTitle => 'Meditation';

  @override
  String get deepBreathingDescription =>
      'Calm your mind with breathing exercises';

  @override
  String get meditationDescription => 'Clear your mind and find focus';

  @override
  String get notificationTimeForDeepBreathing =>
      'Take a deep breath and relax.';

  @override
  String get notificationTimeForMeditation =>
      'Take a moment to clear your mind.';

  @override
  String get stillRunning => 'Still running';

  @override
  String get interval => 'Interval';

  @override
  String get enabledLabel => 'Enabled';

  @override
  String get inactive => 'Inactive';

  @override
  String tapToEnable(String title) {
    return '$title — tap to enable';
  }

  @override
  String get doneButton => 'Done';

  @override
  String get doubleTapToToggle => 'Double tap to toggle';

  @override
  String get doubleTapToCycleTheme => 'Double tap to cycle theme';

  @override
  String get doubleTapToAddReminder =>
      'Double tap to add your first health reminder';

  @override
  String get themeSystem => 'Theme: System';

  @override
  String get themeLight => 'Theme: Light';

  @override
  String get themeDark => 'Theme: Dark';

  @override
  String get due => 'due';

  @override
  String get last30Days => 'Last 30 Days';

  @override
  String times(int count) {
    return '$count times';
  }

  @override
  String get dailyAverage => 'Daily avg';

  @override
  String get noCompletionsYet => 'No completions yet';

  @override
  String get total => 'Total';

  @override
  String get timersReset => 'Timers reset';

  @override
  String reminderAddedNamed(String title) {
    return '$title added';
  }

  @override
  String get maxActiveReminders => 'Maximum of 15 active reminders reached';

  @override
  String get unitReps => 'reps';

  @override
  String get unitSec => 'sec';

  @override
  String get unitMin => 'min';

  @override
  String get unitMl => 'ml';

  @override
  String get unitGlasses => 'glasses';

  @override
  String get startReminders => 'Start reminders';

  @override
  String get pauseReminders => 'Pause reminders';

  @override
  String get addReminderTooltip => 'Add reminder';

  @override
  String get resetTimersTooltip => 'Reset timers';

  @override
  String get openStatistics => 'Open statistics';

  @override
  String editReminderNamed(String title) {
    return 'Edit $title';
  }

  @override
  String get v2NotifChannelName => 'Care reminders';

  @override
  String get v2NotifChannelDescription =>
      'Your pet asks for water, eye breaks, and movement';

  @override
  String get v2ActionDone => 'Done';

  @override
  String get v2ActionSnooze => 'Snooze 10 min';

  @override
  String get v2NotifTitleWater => 'Your pet is thirsty';

  @override
  String get v2NotifTitleEyeRest => 'Your pet\'s eyes are tired';

  @override
  String get v2NotifTitleMove => 'Your pet is fidgety';

  @override
  String get v2NotifTitleStretch => 'Your pet wants to stretch';

  @override
  String get v2NotifTitleStrength => 'Your pet is feeling mighty';

  @override
  String get v2NotifBodyWater => 'Time for a sip of water.';

  @override
  String get v2NotifBodyEyeRest =>
      'Look 20 feet away for 20 seconds — together.';

  @override
  String get v2NotifBodyMove => 'Stand up and move for a minute.';

  @override
  String get v2NotifBodyStretch => 'A little stretch goes a long way.';

  @override
  String get v2NotifBodyStrength => 'A few reps together?';

  @override
  String get v2ActivityWater => 'Water';

  @override
  String get v2ActivityEyeRest => 'Eyes';

  @override
  String get v2ActivityMove => 'Move';

  @override
  String get v2ActivityStretch => 'Stretch';

  @override
  String get v2ActivityStrength => 'Strength';

  @override
  String get v2SpeechContent => 'All good. I\'m happy when you\'re well.';

  @override
  String get v2SpeechThirsty => 'I could use a sip of water…';

  @override
  String get v2SpeechTiredEyes => 'My eyes are getting heavy…';

  @override
  String get v2SpeechFidgety => 'I need to wiggle. Walk with me?';

  @override
  String get v2SpeechStretchy => 'Stretch time! Arms up — do it with me!';

  @override
  String get v2SpeechMighty => 'Game face on. A few reps together!';

  @override
  String v2SpeechResting(String petName) {
    return '$petName is resting. Tap Start when you\'re ready.';
  }

  @override
  String get v2GoodMorning => 'Good morning';

  @override
  String get v2GoodAfternoon => 'Good afternoon';

  @override
  String get v2GoodEvening => 'Good evening';

  @override
  String v2PetWithYou(String petName) {
    return '$petName is with you today';
  }

  @override
  String get v2ChooseCompanionTitle => 'Choose your companion';

  @override
  String get v2ChooseCompanionSubtitle =>
      'Your pet feels what your body needs — thirsty when you should drink, tired-eyed when you need a screen break. Caring for it is caring for you.';

  @override
  String v2StartTogether(String name) {
    return 'Start together with $name';
  }

  @override
  String get v2PetNeverSuffers =>
      'Your pet never gets sick, sad, or lost. It just needs what you need.';

  @override
  String get v2BlurbMiro =>
      'A calm sprout-spirit. Gentle, patient, hums when watered.';

  @override
  String get v2BlurbPip =>
      'A bouncy cloud-pup. Cheers loudest when you stand and move.';

  @override
  String get v2BlurbLuma =>
      'A dreamy star-cat. Guards your eyes and your evenings.';

  @override
  String get v2CareButtonWater => 'Give water · I just drank';

  @override
  String get v2CareButtonEyeRest => 'Rest eyes · Just did';

  @override
  String get v2CareButtonMove => 'We moved!';

  @override
  String get v2CareButtonStretch => 'We stretched!';

  @override
  String get v2CareButtonStrength => 'Log workout';

  @override
  String get v2Snooze10 => 'Snooze 10 min';

  @override
  String get v2Start => 'Start';

  @override
  String get v2Pause => 'Pause';

  @override
  String get v2Wardrobe => 'Wardrobe';

  @override
  String get v2Owned => 'Owned';

  @override
  String get v2Wearing => 'Wearing';

  @override
  String get v2WardrobeHint =>
      'Sparks come from care moments — a drink logged, a stretch done. Nothing to buy, nothing to lose.';

  @override
  String get v2CosmeticCozyScarf => 'Cozy Scarf';

  @override
  String get v2CosmeticRoundGlasses => 'Round Glasses';

  @override
  String get v2CosmeticLeafCrown => 'Leaf Crown';

  @override
  String get v2CosmeticNightCap => 'Night Cap';

  @override
  String get v2CosmeticTinyMug => 'Tiny Mug';

  @override
  String get v2CosmeticStarCharm => 'Star Charm';

  @override
  String get v2Journey => 'Journey';

  @override
  String get v2Today => 'Today';

  @override
  String get v2Last14Days => 'Last 14 days';

  @override
  String v2CareMoments(int count) {
    return '$count care moments';
  }

  @override
  String get v2Settings => 'Settings';

  @override
  String get v2Intervals => 'Reminders';

  @override
  String v2Every(int minutes) {
    return 'Every $minutes min';
  }

  @override
  String v2MinutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get v2Theme => 'Theme';

  @override
  String get v2ThemeSystem => 'System';

  @override
  String get v2ThemeLight => 'Light';

  @override
  String get v2ThemeDark => 'Dark';

  @override
  String get v2Desktop => 'Desktop';

  @override
  String get v2CloseToTray => 'Close to tray';

  @override
  String get v2AlwaysOnTop => 'Always on top';

  @override
  String get v2LaunchAtStartup => 'Launch at startup';

  @override
  String get v2NotificationsOff => 'Notifications are off';

  @override
  String get v2NotificationsOffHint =>
      'Zenu can\'t remind you until notifications are allowed.';

  @override
  String get v2EnableNotifications => 'Allow';

  @override
  String get v2DataSection => 'Your data';

  @override
  String get v2ExportData => 'Export data (copy JSON)';

  @override
  String get v2ExportCopied => 'Copied to clipboard';

  @override
  String get v2ClearAllData => 'Clear all data';

  @override
  String get v2ClearAllConfirmTitle => 'Delete everything?';

  @override
  String get v2ClearAllConfirmBody =>
      'Your reminders, history, sparks, and pet will be gone. This can\'t be undone.';

  @override
  String get v2Cancel => 'Cancel';

  @override
  String get v2Delete => 'Delete';

  @override
  String get v2HowMuch => 'How much?';

  @override
  String get v2Log => 'Log';

  @override
  String get v2TabPet => 'Pet';

  @override
  String get v2TabWardrobe => 'Wardrobe';

  @override
  String get v2TabJourney => 'Journey';

  @override
  String get v2TabSettings => 'Settings';

  @override
  String get v2TrayShow => 'Show Zenu';

  @override
  String get v2TrayPause => 'Pause reminders';

  @override
  String get v2TrayResume => 'Resume reminders';

  @override
  String get v2TrayQuit => 'Quit';

  @override
  String get v2MigratedNotice =>
      'Welcome back — your old reminders and history came along.';
}
