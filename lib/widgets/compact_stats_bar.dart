import 'package:flutter/material.dart';
import '../services/reminder_service.dart';
import '../services/theme_service.dart';
import '../utils/duration_formatter.dart';

class CompactStatsBar extends StatelessWidget {
  final ReminderService reminderService;
  final ThemeService themeService;

  const CompactStatsBar({
    super.key,
    required this.reminderService,
    required this.themeService,
  });

  @override
  Widget build(BuildContext context) {
    final nextTime = _getNextReminderTime();
    final todayCount = _getTodayCompletions();
    final activeCount = _getActiveCount();
    final streak = _getStreak();

    return Semantics(
      label: 'Statistics summary: Next reminder $nextTime, $todayCount completed today, $activeCount active reminders, $streak day streak',
      container: true,
      child: Container(
        height: 90,
        margin: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _CompactStatCard(
              icon: Icons.timer,
              value: nextTime,
              label: 'Next in',
              semanticLabel: 'Next reminder in $nextTime',
              color: const Color(0xFF8B5CF6),
              themeService: themeService,
              isTime: true,
            ),
            const SizedBox(width: 12),
            _CompactStatCard(
              icon: Icons.today,
              value: todayCount.toString(),
              label: 'Today',
              semanticLabel: '$todayCount reminders completed today',
              color: const Color(0xFF10B981),
              themeService: themeService,
            ),
            const SizedBox(width: 12),
            _CompactStatCard(
              icon: Icons.notifications_active,
              value: activeCount.toString(),
              label: 'Active',
              semanticLabel: '$activeCount active reminders',
              color: const Color(0xFF3B82F6),
              themeService: themeService,
            ),
            const SizedBox(width: 12),
            _CompactStatCard(
              icon: Icons.local_fire_department,
              value: streak.toString(),
              label: 'Streak',
              semanticLabel: '$streak day streak',
              color: const Color(0xFFF97316),
              themeService: themeService,
            ),
          ],
        ),
      ),
    );
  }

  int _getTodayCompletions() {
    int total = 0;
    for (var entry in reminderService.statistics.dailyCompletions.values) {
      total += entry;
    }
    return total;
  }

  int _getStreak() {
    // Simplified streak calculation - could be enhanced
    final today = _getTodayCompletions();
    return today > 0 ? 1 : 0;
  }

  int _getActiveCount() {
    return reminderService.reminders.where((r) => r.isEnabled).length;
  }

  String _getNextReminderTime() {
    if (!reminderService.isRunning) return 'Paused';

    final enabledReminders =
        reminderService.reminders
            .where((r) => r.isEnabled && r.nextReminder != null)
            .toList();

    if (enabledReminders.isEmpty) return 'None';

    final nextReminder = enabledReminders.reduce((a, b) {
      final aDiff = a.nextReminder!.difference(DateTime.now());
      final bDiff = b.nextReminder!.difference(DateTime.now());
      return aDiff.inSeconds < bDiff.inSeconds ? a : b;
    });

    final timeRemaining = nextReminder.nextReminder!.difference(DateTime.now());

    return DurationFormatter.formatDurationCompact(timeRemaining);
  }
}

class _CompactStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String semanticLabel;
  final Color color;
  final ThemeService themeService;
  final bool isTime;

  const _CompactStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.semanticLabel,
    required this.color,
    required this.themeService,
    this.isTime = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: themeService.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: themeService.shadowColor,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: isTime ? 13 : 16,
                fontWeight: FontWeight.w800,
                color: themeService.textPrimary,
                fontFamily: isTime ? 'monospace' : null,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: themeService.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
