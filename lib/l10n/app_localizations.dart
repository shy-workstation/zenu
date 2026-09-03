import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// Main app title
  ///
  /// In en, this message translates to:
  /// **'Zenu'**
  String get appTitle;

  /// Dashboard title
  ///
  /// In en, this message translates to:
  /// **'Health Dashboard'**
  String get healthDashboard;

  /// Status when system is running
  ///
  /// In en, this message translates to:
  /// **'System Active - Monitoring your health'**
  String get systemActive;

  /// Status when system is paused
  ///
  /// In en, this message translates to:
  /// **'System Paused - Click to resume'**
  String get systemPaused;

  /// Button to pause reminder system
  ///
  /// In en, this message translates to:
  /// **'Pause Reminders'**
  String get pauseSystem;

  /// Button to start reminder system
  ///
  /// In en, this message translates to:
  /// **'Start Reminders'**
  String get startSystem;

  /// Add reminder button
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminder;

  /// Water reminder type
  ///
  /// In en, this message translates to:
  /// **'Water Reminder'**
  String get waterReminder;

  /// Exercise reminder type
  ///
  /// In en, this message translates to:
  /// **'Exercise Reminder'**
  String get exerciseReminder;

  /// Push-ups reminder type
  ///
  /// In en, this message translates to:
  /// **'Push-ups Reminder'**
  String get pushUpsReminder;

  /// Pull-ups reminder type
  ///
  /// In en, this message translates to:
  /// **'Pull-ups Reminder'**
  String get pullUpsReminder;

  /// Squats reminder type
  ///
  /// In en, this message translates to:
  /// **'Squats Reminder'**
  String get squatsReminder;

  /// Stretching reminder type
  ///
  /// In en, this message translates to:
  /// **'Stretching Reminder'**
  String get stretchingReminder;

  /// Jumping jacks reminder type
  ///
  /// In en, this message translates to:
  /// **'Jumping Jacks Reminder'**
  String get jumpingJacksReminder;

  /// Planks reminder type
  ///
  /// In en, this message translates to:
  /// **'Planks Reminder'**
  String get planksReminder;

  /// Burpees reminder type
  ///
  /// In en, this message translates to:
  /// **'Burpees Reminder'**
  String get burpeesReminder;

  /// Eye rest reminder type
  ///
  /// In en, this message translates to:
  /// **'Eye Rest Reminder'**
  String get eyeRestReminder;

  /// Stand up reminder type
  ///
  /// In en, this message translates to:
  /// **'Stand Up Reminder'**
  String get standUpReminder;

  /// Custom reminder type
  ///
  /// In en, this message translates to:
  /// **'Custom Reminder'**
  String get customReminder;

  /// Complete exercise button
  ///
  /// In en, this message translates to:
  /// **'Complete Exercise'**
  String get completeExercise;

  /// Snooze button
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get snooze;

  /// Skip button text
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No reminders yet'**
  String get noRemindersYet;

  /// Empty state description
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to create your first healthy habit'**
  String get tapToCreateFirst;

  /// Empty state CTA button
  ///
  /// In en, this message translates to:
  /// **'Add First Reminder'**
  String get addFirstReminder;

  /// Empty state main title
  ///
  /// In en, this message translates to:
  /// **'No reminders yet'**
  String get noRemindersTitle;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to create your first healthy habit'**
  String get noRemindersSubtitle;

  /// Get started button text
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Exercise count label
  ///
  /// In en, this message translates to:
  /// **'Exercise Count'**
  String get exerciseCount;

  /// No description provided for @reminderDue.
  ///
  /// In en, this message translates to:
  /// **'Time for {reminderType}!'**
  String reminderDue(String reminderType);

  /// Statistics screen title
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Reset statistics button
  ///
  /// In en, this message translates to:
  /// **'Reset Statistics'**
  String get resetStatistics;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Reset button
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Complete button text
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// Manage reminders screen title
  ///
  /// In en, this message translates to:
  /// **'Manage Reminders'**
  String get manageReminders;

  /// Your reminders count
  ///
  /// In en, this message translates to:
  /// **'Your Reminders ({count})'**
  String yourReminders(int count);

  /// Button to mark reminder as complete
  ///
  /// In en, this message translates to:
  /// **'Mark Complete'**
  String get markComplete;

  /// Reminder completed message
  ///
  /// In en, this message translates to:
  /// **'{reminderTitle} completed!'**
  String reminderCompleted(String reminderTitle);

  /// Complete reminder dialog title
  ///
  /// In en, this message translates to:
  /// **'Complete {reminderTitle}'**
  String completeReminderTitle(String reminderTitle);

  /// Reminder settings dialog title
  ///
  /// In en, this message translates to:
  /// **'{reminderTitle} Settings'**
  String reminderSettings(String reminderTitle);

  /// Interval in minutes label
  ///
  /// In en, this message translates to:
  /// **'Interval (minutes)'**
  String get intervalMinutes;

  /// Water reminder added message
  ///
  /// In en, this message translates to:
  /// **'Water reminder added! 💧'**
  String get waterReminderAdded;

  /// Exercise reminder added message
  ///
  /// In en, this message translates to:
  /// **'{title} reminder added! 💪'**
  String exerciseReminderAdded(String title);

  /// Eye rest reminder added message
  ///
  /// In en, this message translates to:
  /// **'Eye rest reminder added! 👁️'**
  String get eyeRestReminderAdded;

  /// Custom reminder added message
  ///
  /// In en, this message translates to:
  /// **'Custom reminder \"{title}\" added! ✨'**
  String customReminderAdded(String title);

  /// Choose exercise type dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose Exercise Type'**
  String get chooseExerciseType;

  /// Upper body exercise description
  ///
  /// In en, this message translates to:
  /// **'Upper body strength exercise'**
  String get upperBodyStrengthExercise;

  /// Pull-ups exercise description
  ///
  /// In en, this message translates to:
  /// **'Back and arm strengthening'**
  String get backAndArmStrengthening;

  /// Squats exercise description
  ///
  /// In en, this message translates to:
  /// **'Lower body strengthening exercise'**
  String get lowerBodyStrengtheningExercise;

  /// Stretching exercise description
  ///
  /// In en, this message translates to:
  /// **'Body flexibility and mobility'**
  String get bodyFlexibilityAndMobility;

  /// Jumping jacks exercise description
  ///
  /// In en, this message translates to:
  /// **'Full body cardio exercise'**
  String get fullBodyCardioExercise;

  /// Planks exercise description
  ///
  /// In en, this message translates to:
  /// **'Core strengthening exercise'**
  String get coreStrengtheningExercise;

  /// Burpees exercise description
  ///
  /// In en, this message translates to:
  /// **'Full body high intensity exercise'**
  String get fullBodyHighIntensityExercise;

  /// Icon selection label
  ///
  /// In en, this message translates to:
  /// **'Icon:'**
  String get icon;

  /// Color selection label
  ///
  /// In en, this message translates to:
  /// **'Color:'**
  String get color;

  /// Unit selection label
  ///
  /// In en, this message translates to:
  /// **'Unit:'**
  String get unit;

  /// Minimum value label
  ///
  /// In en, this message translates to:
  /// **'Min:'**
  String get min;

  /// Maximum value label
  ///
  /// In en, this message translates to:
  /// **'Max:'**
  String get max;

  /// Step value label
  ///
  /// In en, this message translates to:
  /// **'Step:'**
  String get step;

  /// Validation message for empty title
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get pleaseEnterTitle;

  /// Statistics reset success message
  ///
  /// In en, this message translates to:
  /// **'Statistics reset successfully'**
  String get statisticsResetSuccess;

  /// App title in simple home screen
  ///
  /// In en, this message translates to:
  /// **'Zenu - Health Reminder'**
  String get zenuHealthReminder;

  /// Full app name
  ///
  /// In en, this message translates to:
  /// **'Zenu Health Reminder App'**
  String get zenuHealthReminderApp;

  /// App running success message
  ///
  /// In en, this message translates to:
  /// **'App is running successfully! 🎉'**
  String get appRunningSuccessfully;

  /// Compilation errors fixed message
  ///
  /// In en, this message translates to:
  /// **'All compilation errors fixed'**
  String get compilationErrorsFixed;

  /// Compilation errors fixed description
  ///
  /// In en, this message translates to:
  /// **'The app now compiles and runs without errors'**
  String get compilationErrorsFixedDesc;

  /// Provider integration status
  ///
  /// In en, this message translates to:
  /// **'Provider integration in progress'**
  String get providerIntegrationProgress;

  /// UI functionality coming soon message
  ///
  /// In en, this message translates to:
  /// **'Full UI functionality coming soon'**
  String get fullUIFunctionalityComing;

  /// Reminder service status
  ///
  /// In en, this message translates to:
  /// **'Reminder Service: {status}'**
  String reminderServiceStatus(String status);

  /// Running status
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// Stopped status
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get stopped;

  /// Reminders loaded count
  ///
  /// In en, this message translates to:
  /// **'{count} reminders loaded'**
  String remindersLoaded(int count);

  /// Button to test app functionality
  ///
  /// In en, this message translates to:
  /// **'Test App Functionality'**
  String get testAppFunctionality;

  /// Manual test confirmation message
  ///
  /// In en, this message translates to:
  /// **'Manual testing confirmed - App is working!'**
  String get manualTestConfirmed;

  /// Stay hydrated title
  ///
  /// In en, this message translates to:
  /// **'Stay Hydrated'**
  String get stayHydrated;

  /// Drink water description
  ///
  /// In en, this message translates to:
  /// **'Drink water regularly'**
  String get drinkWaterRegularly;

  /// Rest your eyes title
  ///
  /// In en, this message translates to:
  /// **'Rest Your Eyes'**
  String get restYourEyes;

  /// Eye rest description
  ///
  /// In en, this message translates to:
  /// **'Look away from screen and blink'**
  String get lookAwayFromScreen;

  /// Stand up title
  ///
  /// In en, this message translates to:
  /// **'Stand and Move'**
  String get standAndMove;

  /// Stand up description
  ///
  /// In en, this message translates to:
  /// **'Get up from your desk and move around'**
  String get getUpFromYourDesk;

  /// Quick tips section title
  ///
  /// In en, this message translates to:
  /// **'Quick Tips'**
  String get quickTips;

  /// Quick tip 1
  ///
  /// In en, this message translates to:
  /// **'Start with 2-3 simple reminders'**
  String get startWithSimpleReminders;

  /// Quick tip 2
  ///
  /// In en, this message translates to:
  /// **'Use default intervals'**
  String get useDefaultIntervals;

  /// Quick tip 3
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotifications;

  /// Squats motivational message
  ///
  /// In en, this message translates to:
  /// **'Strengthen those legs!'**
  String get strengthenThoseLegs;

  /// Jumping jacks motivational message
  ///
  /// In en, this message translates to:
  /// **'Get your heart pumping!'**
  String get getYourHeartPumping;

  /// Planks motivational message
  ///
  /// In en, this message translates to:
  /// **'Core power time!'**
  String get corePowerTime;

  /// Burpees motivational message
  ///
  /// In en, this message translates to:
  /// **'Full body burn!'**
  String get fullBodyBurn;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String error(String message);

  /// Active reminders count label on statistics screen
  ///
  /// In en, this message translates to:
  /// **'Active Reminders'**
  String get activeReminders;

  /// Today stats label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// All time completions label on statistics screen
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// Today's progress section title on statistics screen
  ///
  /// In en, this message translates to:
  /// **'Today\'s Progress'**
  String get todaysProgress;

  /// This week section title on statistics screen
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// Reset statistics confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all statistics? This action cannot be undone.'**
  String get resetStatisticsDialog;

  /// Empty state message on reminder management screen
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add Reminder\" to create your first reminder'**
  String get tapAddReminderToStart;

  /// Error message when app fails to start
  ///
  /// In en, this message translates to:
  /// **'Failed to start app'**
  String get failedToStartApp;

  /// Notification message for eye rest reminder
  ///
  /// In en, this message translates to:
  /// **'Time to rest your eyes! Look away from your screen.'**
  String get notificationTimeToRestEyes;

  /// Notification message for stand up reminder
  ///
  /// In en, this message translates to:
  /// **'Stand up and move around for a few minutes.'**
  String get notificationTimeToStandUp;

  /// Notification message for water reminder
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to drink water!'**
  String get notificationTimeToDrinkWater;

  /// Notification message for stretch reminder
  ///
  /// In en, this message translates to:
  /// **'Take a moment to stretch your body.'**
  String get notificationTimeToStretch;

  /// Notification message for pull-ups reminder
  ///
  /// In en, this message translates to:
  /// **'Time for {count} pull-ups!'**
  String notificationTimeForPullUps(int count);

  /// Notification message for push-ups reminder
  ///
  /// In en, this message translates to:
  /// **'Time for {count} push-ups!'**
  String notificationTimeForPushUps(int count);

  /// Notification message for squats reminder
  ///
  /// In en, this message translates to:
  /// **'Time for {count} squats!'**
  String notificationTimeForSquats(int count);

  /// Notification message for jumping jacks reminder
  ///
  /// In en, this message translates to:
  /// **'Time for {count} jumping jacks!'**
  String notificationTimeForJumpingJacks(int count);

  /// Notification message for planks reminder
  ///
  /// In en, this message translates to:
  /// **'Time for a {count} second plank!'**
  String notificationTimeForPlanks(int count);

  /// Notification message for burpees reminder
  ///
  /// In en, this message translates to:
  /// **'Time for {count} burpees!'**
  String notificationTimeForBurpees(int count);

  /// App name in Windows notifications
  ///
  /// In en, this message translates to:
  /// **'Health Reminder App'**
  String get healthReminderApp;

  /// Notification channel name
  ///
  /// In en, this message translates to:
  /// **'Health Reminders'**
  String get healthReminders;

  /// Notification channel description
  ///
  /// In en, this message translates to:
  /// **'Notifications for health reminders'**
  String get notificationsForHealthReminders;

  /// Development message - compilation errors fixed
  ///
  /// In en, this message translates to:
  /// **'All compilation errors fixed'**
  String get allCompilationErrorsFixed;

  /// Development message - app status
  ///
  /// In en, this message translates to:
  /// **'The app compiles and runs without errors'**
  String get appCompilesAndRunsWithoutErrors;

  /// Development message - integration progress
  ///
  /// In en, this message translates to:
  /// **'Provider integration in progress'**
  String get providerIntegrationInProgress;

  /// Development message - upcoming functionality
  ///
  /// In en, this message translates to:
  /// **'Full UI functionality coming soon'**
  String get fullUIFunctionalityComingSoon;

  /// Development message - testing confirmation
  ///
  /// In en, this message translates to:
  /// **'Manual testing confirmed - App is working!'**
  String get manualTestingConfirmedAppWorking;

  /// Search hint text
  ///
  /// In en, this message translates to:
  /// **'Search exercises, stretches, wellness...'**
  String get searchExercisesStretches;

  /// Done button text
  ///
  /// In en, this message translates to:
  /// **'Done!'**
  String get done;

  /// Snooze 10 minutes button text
  ///
  /// In en, this message translates to:
  /// **'Snooze 10m'**
  String get snooze10m;

  /// Title field label
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Unit field hint text
  ///
  /// In en, this message translates to:
  /// **'e.g., reps, ml, minutes'**
  String get unitHint;

  /// Tooltip for settings button
  ///
  /// In en, this message translates to:
  /// **'Settings and reminder management'**
  String get settingsAndReminderManagement;

  /// Test reminder button tooltip
  ///
  /// In en, this message translates to:
  /// **'Test Reminder'**
  String get testReminder;

  /// Streak stats label
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// Active reminders stats label
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Next reminder time stats label
  ///
  /// In en, this message translates to:
  /// **'Next in'**
  String get nextIn;

  /// Accessibility label for reminder list
  ///
  /// In en, this message translates to:
  /// **'Reminder list with {count} reminders'**
  String reminderListAccessibility(int count);

  /// Settings button tooltip
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Add reminder button tooltip
  ///
  /// In en, this message translates to:
  /// **'Add health reminder'**
  String get addHealthReminder;

  /// Start button text
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get start;

  /// Pause button text
  ///
  /// In en, this message translates to:
  /// **'PAUSE'**
  String get pause;

  /// Enable action label
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// Disable action label
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// Off status label
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// On status label
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// Enabled status text (lowercase)
  ///
  /// In en, this message translates to:
  /// **'enabled'**
  String get enabled;

  /// Disabled status text (lowercase)
  ///
  /// In en, this message translates to:
  /// **'disabled'**
  String get disabled;

  /// Message shown when reminder is enabled
  ///
  /// In en, this message translates to:
  /// **'{reminderTitle} enabled'**
  String reminderEnabled(String reminderTitle);

  /// Message shown when reminder is disabled
  ///
  /// In en, this message translates to:
  /// **'{reminderTitle} disabled'**
  String reminderDisabled(String reminderTitle);

  /// Health category header in template picker
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// Exercise category header in template picker
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get categoryExercise;

  /// Mind & Body category header in template picker
  ///
  /// In en, this message translates to:
  /// **'Mind & Body'**
  String get categoryMindBody;

  /// Push-ups exercise name
  ///
  /// In en, this message translates to:
  /// **'Push-ups'**
  String get pushUps;

  /// Pull-ups exercise name
  ///
  /// In en, this message translates to:
  /// **'Pull-ups'**
  String get pullUps;

  /// Squats exercise name
  ///
  /// In en, this message translates to:
  /// **'Squats'**
  String get squats;

  /// Stretching exercise name
  ///
  /// In en, this message translates to:
  /// **'Stretching'**
  String get stretching;

  /// Jumping jacks exercise name
  ///
  /// In en, this message translates to:
  /// **'Jumping Jacks'**
  String get jumpingJacks;

  /// Planks exercise name
  ///
  /// In en, this message translates to:
  /// **'Planks'**
  String get planks;

  /// Burpees exercise name
  ///
  /// In en, this message translates to:
  /// **'Burpees'**
  String get burpees;

  /// Deep breathing activity name
  ///
  /// In en, this message translates to:
  /// **'Deep Breathing'**
  String get deepBreathing;

  /// Meditation activity name
  ///
  /// In en, this message translates to:
  /// **'Meditation'**
  String get meditationTitle;

  /// Deep breathing description
  ///
  /// In en, this message translates to:
  /// **'Calm your mind with breathing exercises'**
  String get deepBreathingDescription;

  /// Meditation description
  ///
  /// In en, this message translates to:
  /// **'Clear your mind and find focus'**
  String get meditationDescription;

  /// Notification message for deep breathing reminder
  ///
  /// In en, this message translates to:
  /// **'Take a deep breath and relax.'**
  String get notificationTimeForDeepBreathing;

  /// Notification message for meditation reminder
  ///
  /// In en, this message translates to:
  /// **'Take a moment to clear your mind.'**
  String get notificationTimeForMeditation;

  /// Label for reminders still running in triggered overlay
  ///
  /// In en, this message translates to:
  /// **'Still running'**
  String get stillRunning;

  /// Interval label in edit drawer
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get interval;

  /// Enabled switch label in edit drawer
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabledLabel;

  /// Inactive section label
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// Tooltip for inactive reminder
  ///
  /// In en, this message translates to:
  /// **'{title} — tap to enable'**
  String tapToEnable(String title);

  /// Done button label without exclamation
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneButton;

  /// Accessibility hint for toggle button
  ///
  /// In en, this message translates to:
  /// **'Double tap to toggle'**
  String get doubleTapToToggle;

  /// Accessibility hint for theme cycle button
  ///
  /// In en, this message translates to:
  /// **'Double tap to cycle theme'**
  String get doubleTapToCycleTheme;

  /// Accessibility hint for add reminder button
  ///
  /// In en, this message translates to:
  /// **'Double tap to add your first health reminder'**
  String get doubleTapToAddReminder;

  /// System theme accessibility label
  ///
  /// In en, this message translates to:
  /// **'Theme: System'**
  String get themeSystem;

  /// Light theme accessibility label
  ///
  /// In en, this message translates to:
  /// **'Theme: Light'**
  String get themeLight;

  /// Dark theme accessibility label
  ///
  /// In en, this message translates to:
  /// **'Theme: Dark'**
  String get themeDark;

  /// Due label for overdue reminders
  ///
  /// In en, this message translates to:
  /// **'due'**
  String get due;

  /// Last 30 days section title
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get last30Days;

  /// Number of times completed
  ///
  /// In en, this message translates to:
  /// **'{count} times'**
  String times(int count);

  /// Daily average label
  ///
  /// In en, this message translates to:
  /// **'Daily avg'**
  String get dailyAverage;

  /// Empty state for statistics
  ///
  /// In en, this message translates to:
  /// **'No completions yet'**
  String get noCompletionsYet;

  /// Total label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Feedback message after clearing all timers
  ///
  /// In en, this message translates to:
  /// **'Timers reset'**
  String get timersReset;

  /// Confirmation shown after adding a reminder
  ///
  /// In en, this message translates to:
  /// **'{title} added'**
  String reminderAddedNamed(String title);

  /// Warning when trying to activate a 16th reminder
  ///
  /// In en, this message translates to:
  /// **'Maximum of 15 active reminders reached'**
  String get maxActiveReminders;

  /// Unit: repetitions
  ///
  /// In en, this message translates to:
  /// **'reps'**
  String get unitReps;

  /// Unit: seconds
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get unitSec;

  /// Unit: minutes
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get unitMin;

  /// Unit: millilitres
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get unitMl;

  /// Unit: glasses
  ///
  /// In en, this message translates to:
  /// **'glasses'**
  String get unitGlasses;

  /// Accessibility label for the start button
  ///
  /// In en, this message translates to:
  /// **'Start reminders'**
  String get startReminders;

  /// Accessibility label for the pause button
  ///
  /// In en, this message translates to:
  /// **'Pause reminders'**
  String get pauseReminders;

  /// Accessibility label for the add-reminder badge
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get addReminderTooltip;

  /// Accessibility label for the reset-timers badge
  ///
  /// In en, this message translates to:
  /// **'Reset timers'**
  String get resetTimersTooltip;

  /// Accessibility label for the statistics button
  ///
  /// In en, this message translates to:
  /// **'Open statistics'**
  String get openStatistics;

  /// Accessibility label for a reminder bubble
  ///
  /// In en, this message translates to:
  /// **'Edit {title}'**
  String editReminderNamed(String title);

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Care reminders'**
  String get v2NotifChannelName;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Your pet asks for water, eye breaks, and movement'**
  String get v2NotifChannelDescription;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get v2ActionDone;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Snooze 10 min'**
  String get v2ActionSnooze;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Your pet is thirsty'**
  String get v2NotifTitleWater;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Your pet\'s eyes are tired'**
  String get v2NotifTitleEyeRest;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Your pet is fidgety'**
  String get v2NotifTitleMove;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Your pet wants to stretch'**
  String get v2NotifTitleStretch;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Your pet is feeling mighty'**
  String get v2NotifTitleStrength;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Time for a sip of water.'**
  String get v2NotifBodyWater;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Look 20 feet away for 20 seconds — together.'**
  String get v2NotifBodyEyeRest;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Stand up and move for a minute.'**
  String get v2NotifBodyMove;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'A little stretch goes a long way.'**
  String get v2NotifBodyStretch;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'A few reps together?'**
  String get v2NotifBodyStrength;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get v2ActivityWater;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Eyes'**
  String get v2ActivityEyeRest;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get v2ActivityMove;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Stretch'**
  String get v2ActivityStretch;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get v2ActivityStrength;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'All good.'**
  String get v2SpeechContent;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'A sip of water?'**
  String get v2SpeechThirsty;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Rest your eyes with me.'**
  String get v2SpeechTiredEyes;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Let\'s move!'**
  String get v2SpeechFidgety;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Stretch time!'**
  String get v2SpeechStretchy;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'A few reps?'**
  String get v2SpeechMighty;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Resting. Tap Start when ready.'**
  String get v2SpeechResting;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Choose your companion'**
  String get v2ChooseCompanionTitle;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'It feels what your body needs. Caring for it is caring for you.'**
  String get v2ChooseCompanionSubtitle;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Start together with {name}'**
  String v2StartTogether(String name);

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Calm and patient.'**
  String get v2BlurbMiro;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Bouncy and cheerful.'**
  String get v2BlurbPip;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Dreamy and watchful.'**
  String get v2BlurbLuma;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Drank water'**
  String get v2CareButtonWater;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Rested my eyes'**
  String get v2CareButtonEyeRest;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Moved'**
  String get v2CareButtonMove;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Stretched'**
  String get v2CareButtonStretch;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Log reps'**
  String get v2CareButtonStrength;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Later (10 min)'**
  String get v2Snooze10;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get v2Start;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get v2Pause;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Cozy Scarf'**
  String get v2CosmeticCozyScarf;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Round Glasses'**
  String get v2CosmeticRoundGlasses;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Leaf Crown'**
  String get v2CosmeticLeafCrown;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Night Cap'**
  String get v2CosmeticNightCap;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Tiny Mug'**
  String get v2CosmeticTinyMug;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Star Charm'**
  String get v2CosmeticStarCharm;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Journey'**
  String get v2Journey;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get v2Today;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Last 14 days'**
  String get v2Last14Days;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 care moment} other{{count} care moments}}'**
  String v2CareMoments(int count);

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get v2Settings;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get v2Intervals;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String v2MinutesShort(int minutes);

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get v2Theme;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get v2ThemeSystem;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get v2ThemeLight;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get v2ThemeDark;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Desktop'**
  String get v2Desktop;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Close to tray'**
  String get v2CloseToTray;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Always on top'**
  String get v2AlwaysOnTop;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Launch at startup'**
  String get v2LaunchAtStartup;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Notifications are off'**
  String get v2NotificationsOff;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Allow notifications so your pet can remind you.'**
  String get v2NotificationsOffHint;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get v2EnableNotifications;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get v2DataSection;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Export data (copy JSON)'**
  String get v2ExportData;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get v2ExportCopied;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Clear all data'**
  String get v2ClearAllData;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Delete everything?'**
  String get v2ClearAllConfirmTitle;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Reminders, history, and your pet will be gone. This can\'t be undone.'**
  String get v2ClearAllConfirmBody;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get v2Cancel;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get v2Delete;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'How much?'**
  String get v2HowMuch;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get v2Log;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Show Zenu'**
  String get v2TrayShow;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Pause reminders'**
  String get v2TrayPause;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Resume reminders'**
  String get v2TrayResume;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get v2TrayQuit;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Welcome back. Your reminders and history came along.'**
  String get v2MigratedNotice;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get v2Style;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get v2Colour;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get v2Pattern;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get v2None;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Head'**
  String get v2SlotHead;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Face'**
  String get v2SlotFace;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get v2SlotNeck;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Charm'**
  String get v2SlotCharm;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Mint'**
  String get v2ColorMint;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Sky'**
  String get v2ColorSky;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Lilac'**
  String get v2ColorLilac;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Peach'**
  String get v2ColorPeach;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get v2ColorRose;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Lemon'**
  String get v2ColorLemon;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Aqua'**
  String get v2ColorAqua;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Slate'**
  String get v2ColorSlate;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Plain'**
  String get v2PatternPlain;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Spots'**
  String get v2PatternSpots;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Freckles'**
  String get v2PatternFreckles;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Stripes'**
  String get v2PatternStripes;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Heart'**
  String get v2PatternHeart;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Bow Tie'**
  String get v2CosmeticBowTie;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Bandana'**
  String get v2CosmeticBandana;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Bell Collar'**
  String get v2CosmeticBellCollar;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Sunglasses'**
  String get v2CosmeticSunglasses;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Monocle'**
  String get v2CosmeticMonocle;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Eye Patch'**
  String get v2CosmeticEyePatch;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Beanie'**
  String get v2CosmeticBeanie;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Top Hat'**
  String get v2CosmeticTopHat;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Hair Bow'**
  String get v2CosmeticHairBow;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Halo'**
  String get v2CosmeticHalo;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Flower Clip'**
  String get v2CosmeticFlowerClip;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Heart Charm'**
  String get v2CosmeticHeartCharm;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Balloon'**
  String get v2CosmeticBalloon;

  /// Zenu v2 pet UI
  ///
  /// In en, this message translates to:
  /// **'Butterfly'**
  String get v2CosmeticButterfly;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
