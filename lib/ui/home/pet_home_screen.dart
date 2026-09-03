import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/care_activity.dart';
import '../../domain/pet.dart';
import '../../l10n/app_localizations.dart';
import '../../services/care_service.dart';
import '../../services/ticker_service.dart';
import '../pet/pet_view.dart';
import '../settings/settings_screen.dart';
import '../zenu_theme.dart';
import 'care_sheet.dart';
import 'need_ring.dart';

/// The pet IS the app: your companion front and center, telling you what
/// it needs. No takeovers — a due need changes the pet's mood and the
/// care button, nothing hijacks the screen.
class PetHomeScreen extends StatefulWidget {
  const PetHomeScreen({super.key});

  @override
  State<PetHomeScreen> createState() => _PetHomeScreenState();
}

class _PetHomeScreenState extends State<PetHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<CareService>().migratedFromV1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.v2MigratedNotice)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final care = context.watch<CareService>();
    final ticker = context.read<TickerService>();
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 6, 10, 0),
            child: Row(
              children: [
                const Spacer(),
                IconButton(
                  tooltip: care.running ? l10n.v2Pause : l10n.v2Start,
                  icon: Icon(care.running
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline),
                  onPressed: () =>
                      care.running ? care.pauseSession() : care.startSession(),
                ),
                IconButton(
                  tooltip: l10n.v2Settings,
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const SettingsScreen()),
                  ),
                ),
              ],
            ),
          ),
          if (care.notificationsAllowed == false)
            _NotificationsOffBanner(care: care),
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: ticker.nowMs,
              builder: (context, _, __) =>
                  _PetStage(care: care, l10n: l10n),
            ),
          ),
        ],
      ),
    );
  }
}

class _PetStage extends StatelessWidget {
  final CareService care;
  final AppLocalizations l10n;

  const _PetStage({required this.care, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = care.mood();
    final focus = care.focusActivity();
    final speech = _speech(mood);

    return LayoutBuilder(builder: (context, constraints) {
      // ~280px of chrome (bubble, rings, buttons, gaps) surrounds the pet;
      // shrink the pet instead of overflowing on small windows/phones.
      final petSize =
          (constraints.maxHeight - 280).clamp(120.0, 260.0).toDouble();
      return Column(
        children: [
          const Spacer(),
          // Fixed slot so the pet doesn't jump when the bubble comes and goes.
          SizedBox(
            height: 52,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: speech == null
                  ? const SizedBox.shrink()
                  : Container(
                      key: ValueKey(speech),
                      constraints: const BoxConstraints(maxWidth: 260),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 11),
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
                        speech,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          PetView(profile: care.state.pet, mood: mood, size: petSize),
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
          SizedBox(
            height: 44,
            child: care.running && focus != null && care.isOverdue(focus)
                ? TextButton(
                    onPressed: () => care.snooze(focus.id),
                    child: Text(
                      l10n.v2Snooze10,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 4),
        ],
      );
    });
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
    final label = care.isOverdue(focus)
        ? _careButtonLabel(focus.kind)
        : '${_activityLabel(focus.kind)} · ${_format(care.timeUntilDue(focus))}';
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

  /// null when content: a happy pet doesn't need a caption.
  String? _speech(PetMood mood) => switch (mood) {
        PetMood.content => null as String?,
        PetMood.thirsty => l10n.v2SpeechThirsty,
        PetMood.tiredEyes => l10n.v2SpeechTiredEyes,
        PetMood.fidgety => l10n.v2SpeechFidgety,
        PetMood.stretchy => l10n.v2SpeechStretchy,
        PetMood.mighty => l10n.v2SpeechMighty,
        PetMood.resting => l10n.v2SpeechResting,
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

class _NotificationsOffBanner extends StatelessWidget {
  final CareService care;

  const _NotificationsOffBanner({required this.care});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 4, 22, 0),
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_off_outlined, color: scheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.v2NotificationsOffHint,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: scheme.onErrorContainer,
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
