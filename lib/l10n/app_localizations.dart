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

  /// Eye rest reminder type
  ///
  /// In en, this message translates to:
  /// **'Eye Rest Reminder'**
  String get eyeRestReminder;

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

  /// Skip button
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

  /// No description provided for @exerciseCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No exercises} =1{1 exercise} other{{count} exercises}}'**
  String exerciseCount(num count);

  /// No description provided for @reminderDue.
  ///
  /// In en, this message translates to:
  /// **'Time for {reminderType}!'**
  String reminderDue(String reminderType);
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
