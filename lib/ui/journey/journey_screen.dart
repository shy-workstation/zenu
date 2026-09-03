import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../services/care_service.dart';
import '../zenu_theme.dart';

/// A feedback loop, not a log dump: today's care per activity plus a
/// 14-day rhythm bar. History is unbounded in v2, so this can grow into
/// richer views later.
class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final care = context.watch<CareService>();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final daily = care.dailyCounts(days: 14);
    final maxDaily =
        daily.fold(0, (max, v) => v > max ? v : max).clamp(1, 1 << 30);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.v2Journey)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 6, 22, 20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.v2Today,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  for (final activity in care.state.activities) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Icon(
                            ZenuColors.iconForKind(activity.kind),
                            size: 19,
                            color: ZenuColors.forKind(activity.kind),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _label(l10n, activity.kind),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            activity.hasQuantity
                                ? '${care.todayQty(activity.id)} ${activity.unit}'
                                : '${care.todayCount(activity.id)}×',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.v2Last14Days,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 90,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final count in daily)
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2.5),
                              child: Container(
                                height: count == 0
                                    ? 5
                                    : 12 + 76 * (count / maxDaily),
                                decoration: BoxDecoration(
                                  color: count == 0
                                      ? theme.colorScheme.outlineVariant
                                          .withValues(alpha: 0.4)
                                      : ZenuColors.primary.withValues(
                                          alpha:
                                              0.35 + 0.65 * (count / maxDaily)),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.v2CareMoments(daily.fold(0, (a, b) => a + b)),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _label(AppLocalizations l10n, String kind) => switch (kind) {
        'water' => l10n.v2ActivityWater,
        'eyeRest' => l10n.v2ActivityEyeRest,
        'move' => l10n.v2ActivityMove,
        'stretch' => l10n.v2ActivityStretch,
        'strength' => l10n.v2ActivityStrength,
        _ => kind,
      };
}
