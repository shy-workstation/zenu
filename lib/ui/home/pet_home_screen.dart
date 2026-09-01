import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/care_activity.dart';
import '../../domain/pet.dart';
import '../../l10n/app_localizations.dart';
import '../../services/care_service.dart';
import '../../services/ticker_service.dart';
import '../pet/pet_view.dart';
import '../zenu_theme.dart';
import 'care_sheet.dart';
import 'need_ring.dart';

/// The pet IS the app: your companion front and center, telling you what
/// it needs. No takeovers — a due need changes the pet's mood and the
/// care button, nothing hijacks the screen.
class PetHomeScreen extends StatelessWidget {
  const PetHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final care = context.watch<CareService>();
    final ticker = context.read<TickerService>();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final petName = _petName(care.state.game.species);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting(l10n),
                        style: const TextStyle(
                            fontSize: 21, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        l10n.v2PetWithYou(petName),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _SparksChip(sparks: care.state.game.sparks),
              ],
            ),
          ),
          if (care.notificationsAllowed == false)
            _NotificationsOffBanner(care: care),
          if (care.migratedFromV1) _MigratedNotice(l10n: l10n),
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: ticker.nowMs,
              builder: (context, _, __) => _PetStage(
                care: care,
                l10n: l10n,
                petName: petName,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.v2GoodMorning;
    if (hour < 18) return l10n.v2GoodAfternoon;
    return l10n.v2GoodEvening;
  }

  static String _petName(PetSpecies? species) => switch (species) {
        PetSpecies.pip => 'Pip',
        PetSpecies.luma => 'Luma',
        _ => 'Miro',
      };
}

class _PetStage extends StatelessWidget {
  final CareService care;
  final AppLocalizations l10n;
  final String petName;

  const _PetStage({
    required this.care,
    required this.l10n,
    required this.petName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = care.mood();
    final focus = care.focusActivity();
    final species = care.state.game.species ?? PetSpecies.miro;

    return Column(
      children: [
        const Spacer(),
        Container(
          constraints: const BoxConstraints(maxWidth: 260),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            _speech(mood),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 6),
        PetView(
          species: species,
          mood: mood,
          worn: care.state.game.worn,
          size: 250,
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final activity in care.enabledActivities)
                Expanded(
                  child: NeedRing(
                    activity: activity,
                    fraction: care.needFraction(activity),
                    overdue: care.isOverdue(activity),
                    label: _activityLabel(activity.kind),
                    onTap: () => _logWithSheet(context, activity),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: _primaryAction(context, focus),
        ),
        const SizedBox(height: 8),
        if (care.running && focus != null)
          TextButton(
            onPressed: () => care.snooze(focus.id),
            child: Text(
              l10n.v2Snooze10,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _primaryAction(BuildContext context, CareActivity? focus) {
    if (!care.running) {
      return FilledButton.icon(
        onPressed: () => care.startSession(),
        icon: const Icon(Icons.play_arrow_rounded),
        label: Text(l10n.v2Start),
      );
    }
    if (focus == null) {
      return FilledButton.icon(
        onPressed: () => care.pauseSession(),
        icon: const Icon(Icons.pause_rounded),
        label: Text(l10n.v2Pause),
      );
    }
    final color = ZenuColors.forKind(focus.kind);
    final due = care.timeUntilDue(focus);
    final label = care.isOverdue(focus)
        ? _careButtonLabel(focus.kind)
        : '${_careButtonLabel(focus.kind)} · ${_format(due)}';
    return FilledButton.icon(
      style: FilledButton.styleFrom(backgroundColor: color),
      onPressed: () => _logWithSheet(context, focus),
      icon: Icon(ZenuColors.iconForKind(focus.kind)),
      label: Text(label, overflow: TextOverflow.ellipsis),
    );
  }

  Future<void> _logWithSheet(BuildContext context, CareActivity activity) async {
    if (!care.running) return;
    if (activity.hasQuantity) {
      final qty = await showCareSheet(context, activity);
      if (qty != null) await care.logCare(activity.id, qty: qty);
    } else {
      await care.logCare(activity.id);
    }
  }

  String _format(Duration? d) {
    if (d == null) return '';
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    if (d.inHours > 0) return '${d.inHours}h ${minutes % 60}m';
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _speech(PetMood mood) => switch (mood) {
        PetMood.content => l10n.v2SpeechContent,
        PetMood.thirsty => l10n.v2SpeechThirsty,
        PetMood.tiredEyes => l10n.v2SpeechTiredEyes,
        PetMood.fidgety => l10n.v2SpeechFidgety,
        PetMood.stretchy => l10n.v2SpeechStretchy,
        PetMood.mighty => l10n.v2SpeechMighty,
        PetMood.resting => l10n.v2SpeechResting(petName),
      };

  String _activityLabel(String kind) => switch (kind) {
        'water' => l10n.v2ActivityWater,
        'eyeRest' => l10n.v2ActivityEyeRest,
        'move' => l10n.v2ActivityMove,
        'stretch' => l10n.v2ActivityStretch,
        'strength' => l10n.v2ActivityStrength,
        _ => kind,
      };

  String _careButtonLabel(String kind) => switch (kind) {
        'water' => l10n.v2CareButtonWater,
        'eyeRest' => l10n.v2CareButtonEyeRest,
        'move' => l10n.v2CareButtonMove,
        'stretch' => l10n.v2CareButtonStretch,
        'strength' => l10n.v2CareButtonStrength,
        _ => kind,
      };
}

class _SparksChip extends StatelessWidget {
  final int sparks;

  const _SparksChip({required this.sparks});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 16, color: ZenuColors.sparks),
          const SizedBox(width: 5),
          Text(
            '$sparks',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _NotificationsOffBanner extends StatelessWidget {
  final CareService care;

  const _NotificationsOffBanner({required this.care});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 12, 22, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_off_outlined,
              color: Theme.of(context).colorScheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.v2NotificationsOffHint,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: () => care.refreshPermissionStatus(request: true),
            child: Text(l10n.v2EnableNotifications),
          ),
        ],
      ),
    );
  }
}

class _MigratedNotice extends StatelessWidget {
  final AppLocalizations l10n;

  const _MigratedNotice({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
      child: Text(
        l10n.v2MigratedNotice,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
