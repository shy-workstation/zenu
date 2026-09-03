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

  @override
  String get categoryHealth => 'Gesundheit';

  @override
  String get categoryExercise => 'Übungen';

  @override
  String get categoryMindBody => 'Geist & Körper';

  @override
  String get pushUps => 'Liegestütze';

  @override
  String get pullUps => 'Klimmzüge';

  @override
  String get squats => 'Kniebeugen';

  @override
  String get stretching => 'Dehnen';

  @override
  String get jumpingJacks => 'Hampelmänner';

  @override
  String get planks => 'Planks';

  @override
  String get burpees => 'Burpees';

  @override
  String get deepBreathing => 'Tiefes Atmen';

  @override
  String get meditationTitle => 'Meditation';

  @override
  String get deepBreathingDescription =>
      'Beruhige deinen Geist mit Atemübungen';

  @override
  String get meditationDescription => 'Geist klären und Fokus finden';

  @override
  String get notificationTimeForDeepBreathing =>
      'Atme tief durch und entspanne dich.';

  @override
  String get notificationTimeForMeditation =>
      'Nimm dir einen Moment, um deinen Geist zu klären.';

  @override
  String get stillRunning => 'Läuft noch';

  @override
  String get interval => 'Intervall';

  @override
  String get enabledLabel => 'Aktiviert';

  @override
  String get inactive => 'Inaktiv';

  @override
  String tapToEnable(String title) {
    return '$title — tippen zum Aktivieren';
  }

  @override
  String get doneButton => 'Fertig';

  @override
  String get doubleTapToToggle => 'Doppeltippen zum Umschalten';

  @override
  String get doubleTapToCycleTheme => 'Doppeltippen zum Themenwechsel';

  @override
  String get doubleTapToAddReminder =>
      'Doppeltippen, um erste Erinnerung hinzuzufügen';

  @override
  String get themeSystem => 'Design: System';

  @override
  String get themeLight => 'Design: Hell';

  @override
  String get themeDark => 'Design: Dunkel';

  @override
  String get due => 'fällig';

  @override
  String get last30Days => 'Letzte 30 Tage';

  @override
  String times(int count) {
    return '$count Mal';
  }

  @override
  String get dailyAverage => 'Tagesschnitt';

  @override
  String get noCompletionsYet => 'Noch keine Abschlüsse';

  @override
  String get total => 'Gesamt';

  @override
  String get timersReset => 'Timer zurückgesetzt';

  @override
  String reminderAddedNamed(String title) {
    return '$title hinzugefügt';
  }

  @override
  String get maxActiveReminders => 'Maximal 15 aktive Erinnerungen erreicht';

  @override
  String get unitReps => 'Wdh.';

  @override
  String get unitSec => 'Sek.';

  @override
  String get unitMin => 'Min.';

  @override
  String get unitMl => 'ml';

  @override
  String get unitGlasses => 'Gläser';

  @override
  String get startReminders => 'Erinnerungen starten';

  @override
  String get pauseReminders => 'Erinnerungen pausieren';

  @override
  String get addReminderTooltip => 'Erinnerung hinzufügen';

  @override
  String get resetTimersTooltip => 'Timer zurücksetzen';

  @override
  String get openStatistics => 'Statistiken öffnen';

  @override
  String editReminderNamed(String title) {
    return '$title bearbeiten';
  }

  @override
  String get v2NotifChannelName => 'Pflege-Erinnerungen';

  @override
  String get v2NotifChannelDescription =>
      'Dein Begleiter bittet um Wasser, Augenpausen und Bewegung';

  @override
  String get v2ActionDone => 'Erledigt';

  @override
  String get v2ActionSnooze => '10 Min. später';

  @override
  String get v2NotifTitleWater => 'Dein Begleiter hat Durst';

  @override
  String get v2NotifTitleEyeRest => 'Die Augen deines Begleiters sind müde';

  @override
  String get v2NotifTitleMove => 'Dein Begleiter ist zappelig';

  @override
  String get v2NotifTitleStretch => 'Dein Begleiter möchte sich strecken';

  @override
  String get v2NotifTitleStrength => 'Dein Begleiter fühlt sich stark';

  @override
  String get v2NotifBodyWater => 'Zeit für einen Schluck Wasser.';

  @override
  String get v2NotifBodyEyeRest =>
      'Schau 20 Sekunden in die Ferne – gemeinsam.';

  @override
  String get v2NotifBodyMove => 'Steh auf und beweg dich eine Minute.';

  @override
  String get v2NotifBodyStretch => 'Eine kleine Dehnung wirkt Wunder.';

  @override
  String get v2NotifBodyStrength => 'Ein paar Wiederholungen zusammen?';

  @override
  String get v2ActivityWater => 'Wasser';

  @override
  String get v2ActivityEyeRest => 'Augen';

  @override
  String get v2ActivityMove => 'Bewegung';

  @override
  String get v2ActivityStretch => 'Dehnen';

  @override
  String get v2ActivityStrength => 'Kraft';

  @override
  String get v2SpeechContent => 'Alles gut.';

  @override
  String get v2SpeechThirsty => 'Ein Schluck Wasser?';

  @override
  String get v2SpeechTiredEyes => 'Augen ausruhen, mit mir.';

  @override
  String get v2SpeechFidgety => 'Los, bewegen!';

  @override
  String get v2SpeechStretchy => 'Zeit zum Dehnen!';

  @override
  String get v2SpeechMighty => 'Ein paar Wiederholungen?';

  @override
  String get v2SpeechResting => 'Ruht sich aus. Tippe auf Start.';

  @override
  String get v2ChooseCompanionTitle => 'Wähle deinen Begleiter';

  @override
  String get v2ChooseCompanionSubtitle =>
      'Er fühlt, was dein Körper braucht. Für ihn sorgen heißt für dich sorgen.';

  @override
  String v2StartTogether(String name) {
    return 'Gemeinsam mit $name starten';
  }

  @override
  String get v2BlurbMiro => 'Ruhig und geduldig.';

  @override
  String get v2BlurbPip => 'Munter und fröhlich.';

  @override
  String get v2BlurbLuma => 'Verträumt und wachsam.';

  @override
  String get v2CareButtonWater => 'Getrunken';

  @override
  String get v2CareButtonEyeRest => 'Augen ausgeruht';

  @override
  String get v2CareButtonMove => 'Bewegt';

  @override
  String get v2CareButtonStretch => 'Gedehnt';

  @override
  String get v2CareButtonStrength => 'Wiederholungen eintragen';

  @override
  String get v2Snooze10 => 'Später (10 Min.)';

  @override
  String get v2Start => 'Start';

  @override
  String get v2Pause => 'Pause';

  @override
  String get v2CosmeticCozyScarf => 'Kuscheliger Schal';

  @override
  String get v2CosmeticRoundGlasses => 'Runde Brille';

  @override
  String get v2CosmeticLeafCrown => 'Blätterkrone';

  @override
  String get v2CosmeticNightCap => 'Schlafmütze';

  @override
  String get v2CosmeticTinyMug => 'Kleine Tasse';

  @override
  String get v2CosmeticStarCharm => 'Sternanhänger';

  @override
  String get v2Journey => 'Verlauf';

  @override
  String get v2Today => 'Heute';

  @override
  String get v2Last14Days => 'Letzte 14 Tage';

  @override
  String v2CareMoments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Pflegemomente',
      one: '1 Pflegemoment',
    );
    return '$_temp0';
  }

  @override
  String get v2Settings => 'Einstellungen';

  @override
  String get v2Intervals => 'Erinnerungen';

  @override
  String v2MinutesShort(int minutes) {
    return '$minutes Min.';
  }

  @override
  String get v2Theme => 'Design';

  @override
  String get v2ThemeSystem => 'System';

  @override
  String get v2ThemeLight => 'Hell';

  @override
  String get v2ThemeDark => 'Dunkel';

  @override
  String get v2Desktop => 'Desktop';

  @override
  String get v2CloseToTray => 'Beim Schließen in den Infobereich';

  @override
  String get v2AlwaysOnTop => 'Immer im Vordergrund';

  @override
  String get v2LaunchAtStartup => 'Beim Systemstart starten';

  @override
  String get v2NotificationsOff => 'Benachrichtigungen sind aus';

  @override
  String get v2NotificationsOffHint =>
      'Erlaube Benachrichtigungen, damit dein Begleiter dich erinnern kann.';

  @override
  String get v2EnableNotifications => 'Erlauben';

  @override
  String get v2DataSection => 'Deine Daten';

  @override
  String get v2ExportData => 'Daten exportieren (JSON kopieren)';

  @override
  String get v2ExportCopied => 'In die Zwischenablage kopiert';

  @override
  String get v2ClearAllData => 'Alle Daten löschen';

  @override
  String get v2ClearAllConfirmTitle => 'Alles löschen?';

  @override
  String get v2ClearAllConfirmBody =>
      'Erinnerungen, Verlauf und dein Begleiter werden gelöscht. Das lässt sich nicht rückgängig machen.';

  @override
  String get v2Cancel => 'Abbrechen';

  @override
  String get v2Delete => 'Löschen';

  @override
  String get v2HowMuch => 'Wie viel?';

  @override
  String get v2Log => 'Eintragen';

  @override
  String get v2TrayShow => 'Zenu anzeigen';

  @override
  String get v2TrayPause => 'Erinnerungen pausieren';

  @override
  String get v2TrayResume => 'Erinnerungen fortsetzen';

  @override
  String get v2TrayQuit => 'Beenden';

  @override
  String get v2MigratedNotice =>
      'Willkommen zurück. Deine Erinnerungen und dein Verlauf sind mitgekommen.';

  @override
  String get v2Style => 'Aussehen';

  @override
  String get v2Colour => 'Farbe';

  @override
  String get v2Pattern => 'Muster';

  @override
  String get v2None => 'Nichts';

  @override
  String get v2SlotHead => 'Kopf';

  @override
  String get v2SlotFace => 'Gesicht';

  @override
  String get v2SlotNeck => 'Hals';

  @override
  String get v2SlotCharm => 'Anhänger';

  @override
  String get v2ColorMint => 'Mint';

  @override
  String get v2ColorSky => 'Himmel';

  @override
  String get v2ColorLilac => 'Flieder';

  @override
  String get v2ColorPeach => 'Pfirsich';

  @override
  String get v2ColorRose => 'Rosé';

  @override
  String get v2ColorLemon => 'Zitrone';

  @override
  String get v2ColorAqua => 'Aqua';

  @override
  String get v2ColorSlate => 'Schiefer';

  @override
  String get v2PatternPlain => 'Einfarbig';

  @override
  String get v2PatternSpots => 'Punkte';

  @override
  String get v2PatternFreckles => 'Sommersprossen';

  @override
  String get v2PatternStripes => 'Streifen';

  @override
  String get v2PatternHeart => 'Herz';

  @override
  String get v2CosmeticBowTie => 'Fliege';

  @override
  String get v2CosmeticBandana => 'Halstuch';

  @override
  String get v2CosmeticBellCollar => 'Glöckchenhalsband';

  @override
  String get v2CosmeticSunglasses => 'Sonnenbrille';

  @override
  String get v2CosmeticMonocle => 'Monokel';

  @override
  String get v2CosmeticEyePatch => 'Augenklappe';

  @override
  String get v2CosmeticBeanie => 'Mütze';

  @override
  String get v2CosmeticTopHat => 'Zylinder';

  @override
  String get v2CosmeticHairBow => 'Haarschleife';

  @override
  String get v2CosmeticHalo => 'Heiligenschein';

  @override
  String get v2CosmeticFlowerClip => 'Blumenspange';

  @override
  String get v2CosmeticHeartCharm => 'Herzanhänger';

  @override
  String get v2CosmeticBalloon => 'Luftballon';

  @override
  String get v2CosmeticButterfly => 'Schmetterling';
}
