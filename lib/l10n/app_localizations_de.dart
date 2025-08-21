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
}
