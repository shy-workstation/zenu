import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';
import '../utils/state_management.dart';
import '../l10n/app_localizations.dart';
import '../widgets/floating_pill.dart';

class StatisticsScreen extends StatelessWidget {
  final ReminderService reminderService;

  const StatisticsScreen({super.key, required this.reminderService});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.statistics),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: AppLocalizations.of(context)!.resetStatistics,
            onPressed: () => _showResetStatsDialog(context, reminderService),
          ),
        ],
      ),
      body: Consumer<ReminderService>(
        builder: (context, service, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCards(context, service),
                const SizedBox(height: 24),
                _buildDailyStats(context, service),
                const SizedBox(height: 24),
                _buildWeeklyStats(context, service),
                const SizedBox(height: 24),
                _buildAllTimeStats(context, service),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context, ReminderService service) {
    final stats = service.statistics;
    final activeReminders = service.reminders.where((r) => r.isEnabled).length;
    final totalCompletions = stats.totalCompletions.values.fold(
      0,
      (sum, count) => sum + count,
    );
    final todayCompletions = stats.dailyCompletions.values.fold(
      0,
      (sum, count) => sum + count,
    );

    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            context,
            AppLocalizations.of(context)!.activeReminders,
            '$activeReminders',
            Icons.notifications_active,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOverviewCard(
            context,
            AppLocalizations.of(context)!.today,
            '$todayCompletions',
            Icons.today,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOverviewCard(
            context,
            AppLocalizations.of(context)!.allTime,
            '$totalCompletions',
            Icons.emoji_events,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Semantics(
      label: '$value $title',
      excludeSemantics: true,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyStats(BuildContext context, ReminderService service) {
    return _buildStatsSection(
      context,
      AppLocalizations.of(context)!.todaysProgress,
      service.reminders,
      service.statistics.dailyCompletions,
      Colors.green,
    );
  }

  Widget _buildWeeklyStats(BuildContext context, ReminderService service) {
    return _buildStatsSection(
      context,
      AppLocalizations.of(context)!.thisWeek,
      service.reminders,
      service.statistics.weeklyCompletions,
      Colors.blue,
    );
  }

  Widget _buildAllTimeStats(BuildContext context, ReminderService service) {
    return _buildStatsSection(
      context,
      AppLocalizations.of(context)!.allTime,
      service.reminders,
      service.statistics.totalCompletions,
      Colors.purple,
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    String title,
    List<Reminder> reminders,
    Map<String, int> completions,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...reminders.map((reminder) {
              final count = completions[reminder.id] ?? 0;
              return _buildStatItem(context, reminder, count, color);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, Reminder reminder, int count, Color color) {
    final theme = Theme.of(context);
    return Semantics(
      label: '${reminder.title}: $count completions',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: reminder.color.withValues(alpha: 0.2),
              child: Icon(reminder.icon, color: reminder.color, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                reminder.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showResetStatsDialog(
    BuildContext context,
    ReminderService service,
  ) async {
    final theme = Theme.of(context);
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text(
            AppLocalizations.of(dialogContext)!.resetStatistics,
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: Text(
            AppLocalizations.of(dialogContext)!.resetStatisticsDialog,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(AppLocalizations.of(dialogContext)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                // Reset statistics
                service.statistics.reset();
                service.saveData();
                Navigator.of(dialogContext).pop();
                FloatingPill.success(context, 'Stats reset');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(dialogContext)!.reset),
            ),
          ],
        );
      },
    );
  }
}
