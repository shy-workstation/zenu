import 'dart:math';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';
import '../services/theme_service.dart';
import '../utils/state_management.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return Consumer<ReminderService>(
          builder: (context, service, _) {
            final l = AppLocalizations.of(context);
            final reminders = service.reminders;

            return Scaffold(
              backgroundColor: themeService.backgroundColor,
              appBar: AppBar(
                title: Text(l?.statistics ?? 'Statistics'),
                backgroundColor: themeService.cardColor,
                foregroundColor: themeService.textPrimary,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
              ),
              body: reminders.isEmpty
                  ? Center(
                      child: Text(
                        l?.noCompletionsYet ?? 'No completions yet',
                        style: TextStyle(
                          color:
                              themeService.textPrimary.withValues(alpha: 0.5),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _SectionHeader(
                          title: l?.today ?? 'Today',
                          color: themeService.textPrimary,
                        ),
                        const SizedBox(height: 8),
                        _TodaySection(
                          reminders: reminders,
                          themeService: themeService,
                          l: l,
                        ),
                        const SizedBox(height: 24),
                        _SectionHeader(
                          title: l?.last30Days ?? 'Last 30 Days',
                          color: themeService.textPrimary,
                        ),
                        const SizedBox(height: 8),
                        _Last30DaysSection(
                          reminders: reminders,
                          themeService: themeService,
                          l: l,
                        ),
                      ],
                    ),
            );
          },
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }
}

class _TodaySection extends StatelessWidget {
  final List<Reminder> reminders;
  final ThemeService themeService;
  final AppLocalizations? l;

  const _TodaySection({
    required this.reminders,
    required this.themeService,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    final withCompletions = reminders.where((r) => r.todayCount > 0).toList();

    if (withCompletions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: themeService.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            l?.noCompletionsYet ?? 'No completions yet',
            style: TextStyle(
              color: themeService.textPrimary.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Column(
      children: withCompletions.map((r) {
        final stripped = r.title.replaceAll(
          RegExp(r'^[\p{So}\p{Sk}\p{Cf}\p{M}\s]+', unicode: true),
          '',
        );
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: themeService.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: r.color.withValues(alpha: 0.2),
                child: Icon(r.icon, color: r.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stripped,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: themeService.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l?.times(r.todayCount) ?? '${r.todayCount} times',
                      style: TextStyle(
                        fontSize: 12,
                        color: themeService.textPrimary.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${r.todayTotal} ${r.unit}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: r.color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Last30DaysSection extends StatelessWidget {
  final List<Reminder> reminders;
  final ThemeService themeService;
  final AppLocalizations? l;

  const _Last30DaysSection({
    required this.reminders,
    required this.themeService,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    final withHistory =
        reminders.where((r) => r.completionLog.isNotEmpty).toList();

    if (withHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: themeService.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            l?.noCompletionsYet ?? 'No completions yet',
            style: TextStyle(
              color: themeService.textPrimary.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Column(
      children: withHistory.map((r) {
        final stripped = r.title.replaceAll(
          RegExp(r'^[\p{So}\p{Sk}\p{Cf}\p{M}\s]+', unicode: true),
          '',
        );
        final dailyTotals = r.dailyTotals;
        final totalQty =
            r.completionLog.fold<int>(0, (s, e) => s + (e['qty'] as int));
        final totalCount = r.completionLog.length;
        final daysWithData = dailyTotals.length;
        final dailyAvg =
            daysWithData > 0 ? (totalQty / daysWithData).round() : 0;
        final maxDaily = dailyTotals.values.fold<int>(0, max);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: themeService.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: r.color.withValues(alpha: 0.2),
                    child: Icon(r.icon, color: r.color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      stripped,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: themeService.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Stats row
              Row(
                children: [
                  Expanded(
                    child: _StatChip(
                      label: l?.total ?? 'Total',
                      value: '$totalQty ${r.unit}',
                      themeService: themeService,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatChip(
                      label: l?.times(totalCount) ?? '$totalCount times',
                      value: '',
                      themeService: themeService,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatChip(
                      label: l?.dailyAverage ?? 'Daily avg',
                      value: '$dailyAvg ${r.unit}',
                      themeService: themeService,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Simple bar chart for last 30 days
              if (maxDaily > 0)
                _DailyBars(
                  dailyTotals: dailyTotals,
                  maxDaily: maxDaily,
                  color: r.color,
                  themeService: themeService,
                  unit: r.unit,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final ThemeService themeService;

  const _StatChip({
    required this.label,
    required this.value,
    required this.themeService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (value.isNotEmpty)
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: themeService.textPrimary,
            ),
          ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: themeService.textPrimary.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _DailyBars extends StatelessWidget {
  final Map<String, int> dailyTotals;
  final int maxDaily;
  final Color color;
  final ThemeService themeService;
  final String unit;

  const _DailyBars({
    required this.dailyTotals,
    required this.maxDaily,
    required this.color,
    required this.themeService,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    // Build days newest-first, only days that have data
    final now = DateTime.now();
    final days = <String>[];
    for (int i = 0; i < 30; i++) {
      final d = now.subtract(Duration(days: i));
      final key = d.toIso8601String().substring(0, 10);
      if (dailyTotals.containsKey(key)) {
        days.add(key);
      }
    }

    return Column(
      children: days.map((date) {
        final val = dailyTotals[date]!;
        final fraction = val / maxDaily;
        // Format date as "Mar 2" or "02.03"
        final parts = date.split('-');
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        final label = '$day.${month.toString().padLeft(2, '0')}';

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: themeService.textPrimary.withValues(alpha: 0.6),
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Container(
                          height: 14,
                          decoration: BoxDecoration(
                            color: themeService.textPrimary
                                .withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        Container(
                          height: 14,
                          width: max(4, fraction * constraints.maxWidth),
                          decoration: BoxDecoration(
                            color:
                                color.withValues(alpha: 0.3 + 0.7 * fraction),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 48,
                child: Text(
                  '$val $unit',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: themeService.textPrimary.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
