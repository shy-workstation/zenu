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
    Locale('en'),
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
  /// **'Pause System'**
  String get pauseSystem;

  /// Button to start reminder system
  ///
  /// In en, this message translates to:
  /// **'Start System'**
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
    'that was used.',
  );
}
