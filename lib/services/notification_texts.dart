import '../l10n/app_localizations.dart';

/// Snapshot of localized notification copy, captured from the widget tree
/// and handed to the scheduler (scheduled notifications bake their text in
/// at schedule time).
class NotificationTexts {
  final String channelName;
  final String channelDescription;
  final String actionDone;
  final String actionSnooze;
  final Map<String, String> titleByKind;
  final Map<String, String> bodyByKind;

  const NotificationTexts({
    required this.channelName,
    required this.channelDescription,
    required this.actionDone,
    required this.actionSnooze,
    required this.titleByKind,
    required this.bodyByKind,
  });

  factory NotificationTexts.fallback() => const NotificationTexts(
        channelName: 'Care reminders',
        channelDescription: 'Your pet asks for water, eye breaks, and movement',
        actionDone: 'Done',
        actionSnooze: 'Snooze 10 min',
        titleByKind: {
          'water': 'Your pet is thirsty',
          'eyeRest': 'Your pet\'s eyes are tired',
          'move': 'Your pet is fidgety',
          'stretch': 'Your pet wants to stretch',
          'strength': 'Your pet is feeling mighty',
        },
        bodyByKind: {
          'water': 'Time for a sip of water.',
          'eyeRest': 'Look 20 feet away for 20 seconds — together.',
          'move': 'Stand up and move for a minute.',
          'stretch': 'A little stretch goes a long way.',
          'strength': 'A few reps together?',
        },
      );

  factory NotificationTexts.of(AppLocalizations l10n) => NotificationTexts(
        channelName: l10n.v2NotifChannelName,
        channelDescription: l10n.v2NotifChannelDescription,
        actionDone: l10n.v2ActionDone,
        actionSnooze: l10n.v2ActionSnooze,
        titleByKind: {
          'water': l10n.v2NotifTitleWater,
          'eyeRest': l10n.v2NotifTitleEyeRest,
          'move': l10n.v2NotifTitleMove,
          'stretch': l10n.v2NotifTitleStretch,
          'strength': l10n.v2NotifTitleStrength,
        },
        bodyByKind: {
          'water': l10n.v2NotifBodyWater,
          'eyeRest': l10n.v2NotifBodyEyeRest,
          'move': l10n.v2NotifBodyMove,
          'stretch': l10n.v2NotifBodyStretch,
          'strength': l10n.v2NotifBodyStrength,
        },
      );

  String titleFor(String kind) => titleByKind[kind] ?? 'Zenu';
  String bodyFor(String kind) => bodyByKind[kind] ?? '';
}
