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
  String get pauseSystem => 'Erinnerungen pausieren';

  @override
  String get startSystem => 'Erinnerungen starten';

  @override
  String get addReminder => 'Erinnerung hinzufügen';

  @override
  String get waterReminder => 'Wasser-Erinnerung';

  @override
  String get exerciseReminder => 'Übungs-Erinnerung';

  @override
  String get pushUpsReminder => 'Liegestütze-Erinnerung';

  @override
  String get pullUpsReminder => 'Klimmzüge-Erinnerung';

  @override
  String get squatsReminder => 'Kniebeugen-Erinnerung';

  @override
  String get stretchingReminder => 'Dehn-Erinnerung';

  @override
  String get jumpingJacksReminder => 'Hampelmann-Erinnerung';

  @override
  String get planksReminder => 'Plank-Erinnerung';

  @override
  String get burpeesReminder => 'Burpees-Erinnerung';

  @override
  String get eyeRestReminder => 'Augenpause-Erinnerung';

  @override
  String get standUpReminder => 'Aufsteh-Erinnerung';

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
  String get exerciseCount => 'Anzahl der Übungen';

  @override
  String reminderDue(String reminderType) {
    return 'Zeit für $reminderType!';
  }

  @override
  String get statistics => 'Statistiken';

  @override
  String get resetStatistics => 'Statistiken zurücksetzen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get delete => 'Löschen';

  @override
  String get duplicate => 'Duplizieren';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get save => 'Speichern';

  @override
  String get complete => 'Abschließen';

  @override
  String get manageReminders => 'Erinnerungen verwalten';

  @override
  String yourReminders(int count) {
    return 'Ihre Erinnerungen ($count)';
  }

  @override
  String get markComplete => 'Als erledigt markieren';

  @override
  String reminderCompleted(String reminderTitle) {
    return '$reminderTitle erledigt!';
  }

  @override
  String completeReminderTitle(String reminderTitle) {
    return '$reminderTitle abschließen';
  }

  @override
  String reminderSettings(String reminderTitle) {
    return '$reminderTitle Einstellungen';
  }

  @override
  String get intervalMinutes => 'Intervall (Minuten)';

  @override
  String get waterReminderAdded => 'Wasser-Erinnerung hinzugefügt! 💧';

  @override
  String exerciseReminderAdded(String title) {
    return '$title Erinnerung hinzugefügt! 💪';
  }

  @override
  String get eyeRestReminderAdded => 'Augenpause-Erinnerung hinzugefügt! 👁️';

  @override
  String customReminderAdded(String title) {
    return 'Benutzerdefinierte Erinnerung \"$title\" hinzugefügt! ✨';
  }

  @override
  String get chooseExerciseType => 'Übungstyp wählen';

  @override
  String get upperBodyStrengthExercise => 'Oberkörper-Kraftübung';

  @override
  String get backAndArmStrengthening => 'Rücken- und Armstärkung';

  @override
  String get lowerBodyStrengtheningExercise => 'Unterkörper-Kraftübung';

  @override
  String get bodyFlexibilityAndMobility =>
      'Körper-Flexibilität und Beweglichkeit';

  @override
  String get fullBodyCardioExercise => 'Ganzkörper-Cardio-Übung';

  @override
  String get coreStrengtheningExercise => 'Rumpfstärkung';

  @override
  String get fullBodyHighIntensityExercise =>
      'Ganzkörper-Hochintensitäts-Übung';

  @override
  String get icon => 'Symbol:';

  @override
  String get color => 'Farbe:';

  @override
  String get unit => 'Einheit:';

  @override
  String get min => 'Min:';

  @override
  String get max => 'Max:';

  @override
  String get step => 'Schritt:';

  @override
  String get pleaseEnterTitle => 'Bitte geben Sie einen Titel ein';

  @override
  String get statisticsResetSuccess => 'Statistiken erfolgreich zurückgesetzt';

  @override
  String get zenuHealthReminder => 'Zenu - Gesundheitserinnerung';

  @override
  String get zenuHealthReminderApp => 'Zenu Gesundheitserinnerungs-App';

  @override
  String get appRunningSuccessfully => 'App läuft erfolgreich! 🎉';

  @override
  String get compilationErrorsFixed => 'Alle Kompilierungsfehler behoben';

  @override
  String get compilationErrorsFixedDesc =>
      'Die App kompiliert und läuft jetzt ohne Fehler';

  @override
  String get providerIntegrationProgress => 'Provider-Integration in Arbeit';

  @override
  String get fullUIFunctionalityComing =>
      'Vollständige UI-Funktionalität kommt bald';

  @override
  String reminderServiceStatus(String status) {
    return 'Erinnerungsdienst: $status';
  }

  @override
  String get running => 'Läuft';

  @override
  String get stopped => 'Gestoppt';

  @override
  String remindersLoaded(int count) {
    return '$count Erinnerungen geladen';
  }

  @override
  String get testAppFunctionality => 'App-Funktionalität testen';

  @override
  String get manualTestConfirmed =>
      'Manueller Test bestätigt - App funktioniert!';

  @override
  String get stayHydrated => 'Hydriert bleiben';

  @override
  String get drinkWaterRegularly => 'Regelmäßig Wasser trinken';

  @override
  String get restYourEyes => 'Augen ausruhen';

  @override
  String get lookAwayFromScreen => 'Vom Bildschirm wegschauen und blinzeln';

  @override
  String get standAndMove => 'Aufstehen und bewegen';

  @override
  String get getUpFromYourDesk =>
      'Von Ihrem Schreibtisch aufstehen und sich bewegen';

  @override
  String get quickTips => 'Schnelle Tipps';

  @override
  String get startWithSimpleReminders =>
      'Mit 2-3 einfachen Erinnerungen beginnen';

  @override
  String get useDefaultIntervals => 'Standard-Intervalle verwenden';

  @override
  String get enableNotifications => 'Benachrichtigungen aktivieren';

  @override
  String get strengthenThoseLegs => 'Stärke deine Beine!';

  @override
  String get getYourHeartPumping => 'Bring dein Herz in Schwung!';

  @override
  String get corePowerTime => 'Rumpfkraft-Zeit!';

  @override
  String get fullBodyBurn => 'Ganzkörper-Brennen!';

  @override
  String error(String message) {
    return 'Fehler: $message';
  }

  @override
  String get activeReminders => 'Aktive Erinnerungen';

  @override
  String get today => 'Heute';

  @override
  String get allTime => 'Gesamt';

  @override
  String get todaysProgress => 'Heutiger Fortschritt';

  @override
  String get thisWeek => 'Diese Woche';

  @override
  String get resetStatisticsDialog =>
      'Sind Sie sicher, dass Sie alle Statistiken zurücksetzen möchten? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get tapAddReminderToStart =>
      'Tippen Sie auf \"Erinnerung hinzufügen\", um Ihre erste Erinnerung zu erstellen';

  @override
  String get failedToStartApp => 'App konnte nicht gestartet werden';

  @override
  String get notificationTimeToRestEyes =>
      'Zeit für eine Augenpause! Schauen Sie vom Bildschirm weg.';

  @override
  String get notificationTimeToStandUp =>
      'Stehen Sie auf und bewegen Sie sich ein paar Minuten.';

  @override
  String get notificationTimeToDrinkWater =>
      'Vergessen Sie nicht, Wasser zu trinken!';

  @override
  String get notificationTimeToStretch =>
      'Nehmen Sie sich einen Moment zum Dehnen.';

  @override
  String notificationTimeForPullUps(int count) {
    return 'Zeit für $count Klimmzüge!';
  }

  @override
  String notificationTimeForPushUps(int count) {
    return 'Zeit für $count Liegestütze!';
  }

  @override
  String notificationTimeForSquats(int count) {
    return 'Zeit für $count Kniebeugen!';
  }

  @override
  String notificationTimeForJumpingJacks(int count) {
    return 'Zeit für $count Hampelmänner!';
  }

  @override
  String notificationTimeForPlanks(int count) {
    return 'Zeit für einen $count Sekunden Plank!';
  }

  @override
  String notificationTimeForBurpees(int count) {
    return 'Zeit für $count Burpees!';
  }

  @override
  String get healthReminderApp => 'Gesundheitserinnerungs-App';

  @override
  String get healthReminders => 'Gesundheitserinnerungen';

  @override
  String get notificationsForHealthReminders =>
      'Benachrichtigungen für Gesundheitserinnerungen';

  @override
  String get allCompilationErrorsFixed => 'Alle Kompilierungsfehler behoben';

  @override
  String get appCompilesAndRunsWithoutErrors =>
      'Die App kompiliert und läuft ohne Fehler';

  @override
  String get providerIntegrationInProgress => 'Provider-Integration in Arbeit';

  @override
  String get fullUIFunctionalityComingSoon =>
      'Vollständige UI-Funktionalität kommt bald';

  @override
  String get manualTestingConfirmedAppWorking =>
      'Manueller Test bestätigt - App funktioniert!';

  @override
  String get searchExercisesStretches =>
      'Suchen Sie nach Übungen, Dehnungen, Wellness...';

  @override
  String get done => 'Fertig!';

  @override
  String get snooze10m => '10 Min schlummern';

  @override
  String get title => 'Titel';

  @override
  String get description => 'Beschreibung';

  @override
  String get unitHint => 'z.B., Wiederholungen, ml, Minuten';

  @override
  String get settingsAndReminderManagement =>
      'Einstellungen und Erinnerungsverwaltung';

  @override
  String get testReminder => 'Erinnerung testen';

  @override
  String get streak => 'Serie';

  @override
  String get active => 'Aktiv';

  @override
  String get nextIn => 'Nächste in';

  @override
  String reminderListAccessibility(int count) {
    return 'Erinnerungsliste mit $count Erinnerungen';
  }

  @override
  String get settings => 'Einstellungen';

  @override
  String get addHealthReminder => 'Gesundheitserinnerung hinzufügen';

  @override
  String get start => 'STARTEN';

  @override
  String get pause => 'PAUSIEREN';

  @override
  String get enable => 'Aktivieren';

  @override
  String get disable => 'Deaktivieren';

  @override
  String get off => 'Aus';

  @override
  String get on => 'An';

  @override
  String get enabled => 'aktiviert';

  @override
  String get disabled => 'deaktiviert';

  @override
  String reminderEnabled(String reminderTitle) {
    return '$reminderTitle aktiviert';
  }

  @override
  String reminderDisabled(String reminderTitle) {
    return '$reminderTitle deaktiviert';
  }
}
