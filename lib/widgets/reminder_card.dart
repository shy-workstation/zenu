import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final ReminderService reminderService;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.reminderService,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: reminder.color.withValues(alpha: 0.2),
                  child: Icon(reminder.icon, color: reminder.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reminder.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: reminder.isEnabled,
                  onChanged: (value) {
                    reminderService.toggleReminder(reminder.id);
                  },
                  activeThumbColor: reminder.color,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(
                  'Interval: ${_formatDuration(reminder.interval)}',
                  Icons.schedule,
                ),
                const SizedBox(width: 8),
                if (reminder.exerciseCount > 0)
                  _buildInfoChip(
                    'Count: ${reminder.exerciseCount}',
                    Icons.fitness_center,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (reminder.isEnabled &&
                reminder.nextReminder != null &&
                reminderService.isRunning) ...[
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Next in: ${_formatTimeRemaining(reminder.timeUntilNext)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _getProgressValue(reminder),
                backgroundColor: reminder.color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(reminder.color),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        () => _showCompleteDialog(
                          context,
                          reminder,
                          reminderService,
                        ),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Mark Complete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: reminder.color,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed:
                      () => _showSettingsDialog(
                        context,
                        reminder,
                        reminderService,
                      ),
                  icon: const Icon(Icons.settings),
                  tooltip: 'Settings',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: reminder.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: reminder.color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: reminder.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  String _formatTimeRemaining(Duration? duration) {
    if (duration == null || duration.isNegative) return '0:00';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  double _getProgressValue(Reminder reminder) {
    if (reminder.nextReminder == null) return 0;

    final totalDuration = reminder.interval;
    final remaining = reminder.timeUntilNext ?? Duration.zero;
    final elapsed = totalDuration - remaining;

    return elapsed.inSeconds / totalDuration.inSeconds;
  }

  void _showCompleteDialog(
    BuildContext context,
    Reminder reminder,
    ReminderService reminderService,
  ) {
    if (reminder.exerciseCount > 0) {
      showDialog(
        context: context,
        builder:
            (context) => _ExerciseCompleteDialog(
              reminder: reminder,
              reminderService: reminderService,
            ),
      );
    } else {
      reminderService.completeReminder(reminder);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${reminder.title} completed!'),
          backgroundColor: reminder.color,
        ),
      );
    }
  }

  void _showSettingsDialog(
    BuildContext context,
    Reminder reminder,
    ReminderService reminderService,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => _ReminderSettingsDialog(
            reminder: reminder,
            reminderService: reminderService,
          ),
    );
  }
}

class _ExerciseCompleteDialog extends StatefulWidget {
  final Reminder reminder;
  final ReminderService reminderService;

  const _ExerciseCompleteDialog({
    required this.reminder,
    required this.reminderService,
  });

  @override
  State<_ExerciseCompleteDialog> createState() =>
      _ExerciseCompleteDialogState();
}

class _ExerciseCompleteDialogState extends State<_ExerciseCompleteDialog> {
  late int _completedCount;

  @override
  void initState() {
    super.initState();
    _completedCount = widget.reminder.exerciseCount;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Complete ${widget.reminder.title}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'How many ${widget.reminder.title.toLowerCase()} did you complete?',
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed:
                    _completedCount > 0
                        ? () => setState(() => _completedCount--)
                        : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_completedCount',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _completedCount++),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.reminderService.completeReminder(
              widget.reminder,
              customCount: _completedCount,
            );
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Completed $_completedCount ${widget.reminder.title.toLowerCase()}!',
                ),
                backgroundColor: widget.reminder.color,
              ),
            );
          },
          child: const Text('Complete'),
        ),
      ],
    );
  }
}

class _ReminderSettingsDialog extends StatefulWidget {
  final Reminder reminder;
  final ReminderService reminderService;

  const _ReminderSettingsDialog({
    required this.reminder,
    required this.reminderService,
  });

  @override
  State<_ReminderSettingsDialog> createState() =>
      _ReminderSettingsDialogState();
}

class _ReminderSettingsDialogState extends State<_ReminderSettingsDialog> {
  late int _intervalMinutes;
  late int _exerciseCount;

  @override
  void initState() {
    super.initState();
    _intervalMinutes = widget.reminder.interval.inMinutes;
    _exerciseCount = widget.reminder.exerciseCount;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.reminder.title} Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Interval (minutes)'),
          Slider(
            value: _intervalMinutes.toDouble(),
            min: 1,
            max: 120,
            divisions: 119,
            label: '$_intervalMinutes min',
            onChanged:
                (value) => setState(() => _intervalMinutes = value.round()),
          ),
          if (widget.reminder.exerciseCount > 0) ...[
            const SizedBox(height: 16),
            Text('Exercise Count'),
            Slider(
              value: _exerciseCount.toDouble(),
              min: 1,
              max: 50,
              divisions: 49,
              label: '$_exerciseCount',
              onChanged:
                  (value) => setState(() => _exerciseCount = value.round()),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.reminderService.updateReminderInterval(
              widget.reminder.id,
              Duration(minutes: _intervalMinutes),
            );
            if (widget.reminder.exerciseCount > 0) {
              widget.reminderService.updateExerciseCount(
                widget.reminder.id,
                _exerciseCount,
              );
            }
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
