import 'package:flutter/material.dart';
import '../services/reminder_service.dart';
import '../services/theme_service.dart';

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
    return Container(
      height: 90, // Increased from 80 to 90 for better spacing
      margin: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 20,
      ), // Increased vertical margin
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _CompactStatCard(
            icon: Icons.timer,
            value: _getNextReminderTime(),
            label: 'Nächste in',
            color: const Color(0xFF8B5CF6),
            themeService: themeService,
            isTime: true,
          ),
          const SizedBox(width: 12),
          _CompactStatCard(
            icon: Icons.today,
            value: _getTodayCompletions().toString(),
            label: 'Heute',
            color: const Color(0xFF10B981),
            themeService: themeService,
          ),
          const SizedBox(width: 12),
          _CompactStatCard(
            icon: Icons.notifications_active,
            value: _getActiveCount().toString(),
            label: 'Aktiv',
            color: const Color(0xFF3B82F6),
            themeService: themeService,
          ),
          const SizedBox(width: 12),
          _CompactStatCard(
            icon: Icons.local_fire_department,
            value: _getStreak().toString(),
            label: 'Serie',
            color: const Color(0xFFF97316),
            themeService: themeService,
          ),
        ],
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
    if (!reminderService.isRunning) return 'Pausiert';

    final enabledReminders =
        reminderService.reminders
            .where((r) => r.isEnabled && r.nextReminder != null)
            .toList();

    if (enabledReminders.isEmpty) return 'Keine';

    final nextReminder = enabledReminders.reduce((a, b) {
      final aDiff = a.nextReminder!.difference(DateTime.now());
      final bDiff = b.nextReminder!.difference(DateTime.now());
      return aDiff.inSeconds < bDiff.inSeconds ? a : b;
    });

    final timeRemaining = nextReminder.nextReminder!.difference(DateTime.now());

    if (timeRemaining.inMinutes > 0) {
      return '${timeRemaining.inMinutes}m';
    } else {
      return '${timeRemaining.inSeconds}s';
    }
  }
}

class _CompactStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final ThemeService themeService;
  final bool isTime;

  const _CompactStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.themeService,
    this.isTime = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 10,
      ), // More precise padding
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
            padding: const EdgeInsets.all(4), // Further reduced
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16), // Smaller icon
          ),
          const SizedBox(height: 3), // Reduced spacing
          Text(
            value,
            style: TextStyle(
              fontSize: isTime ? 13 : 16, // Reduced sizes to prevent overflow
              fontWeight: FontWeight.w800,
              color: themeService.textPrimary,
              fontFamily: isTime ? 'monospace' : null,
            ),
          ),
          const SizedBox(height: 1), // Reduced spacing
          Text(
            label,
            style: TextStyle(
              fontSize: 11, // Reduced from 12 to 11
              fontWeight: FontWeight.w500,
              color: themeService.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
