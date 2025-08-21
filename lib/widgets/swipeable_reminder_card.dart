import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';
import '../services/theme_service.dart';
import '../utils/accessibility_utils.dart';
import 'pulsing_dot.dart';

class SwipeableReminderCard extends StatelessWidget {
  final Reminder reminder;
  final ReminderService reminderService;
  final ThemeService themeService;
  final DateTime currentTime;

  const SwipeableReminderCard({
    super.key,
    required this.reminder,
    required this.reminderService,
    required this.themeService,
    required this.currentTime,
  });

  @override
  Widget build(BuildContext context) {
    final timeRemaining = _getTimeRemaining();
    final isRunning =
        reminder.isEnabled &&
        reminderService.isRunning &&
        timeRemaining != null;

    return AccessibilityUtils.createKeyboardNavigable(
      focusLabel:
          '${reminder.title} reminder card, ${reminder.isEnabled ? "enabled" : "disabled"}',
      onActivate: () => reminderService.toggleReminder(reminder.id),
      onSpace: () => reminderService.toggleReminder(reminder.id),
      onEnter: () => _showTimerChangeDialog(context),
      child: Semantics(
        label:
            '${reminder.title} reminder, ${reminder.isEnabled ? "enabled" : "disabled"}',
        hint:
            isRunning
                ? 'Next reminder in ${AccessibilityUtils.formatDurationForA11y(timeRemaining)}. Swipe right to complete, left to snooze 10 minutes.'
                : 'Double tap to toggle reminder, press enter to change timer, swipe for actions',
        button: true,
        child: Dismissible(
          key: Key('swipe_${reminder.id}'),
          background: _buildSwipeBackground(
            alignment: Alignment.centerLeft,
            color: Colors.green,
            icon: Icons.check_circle,
            label: 'Complete',
          ),
          secondaryBackground: _buildSwipeBackground(
            alignment: Alignment.centerRight,
            color: Colors.orange,
            icon: Icons.snooze,
            label: 'Snooze 10m',
          ),
          confirmDismiss: (direction) async {
            // Provide haptic feedback
            HapticFeedback.mediumImpact();

            if (direction == DismissDirection.startToEnd) {
              // Complete reminder
              reminderService.completeReminder(reminder);
              _showActionFeedback(
                context,
                'Completed ${reminder.title}!',
                Colors.green,
              );
            } else if (direction == DismissDirection.endToStart) {
              // Snooze reminder for 10 minutes
              _snoozeReminder(10);
              _showActionFeedback(
                context,
                'Snoozed for 10 minutes',
                Colors.orange,
              );
            }
            return false; // Don't dismiss the card
          },
          child: _buildReminderCard(context, isRunning, timeRemaining),
        ), // Close Dismissible
      ), // Close Semantics
    ); // Close AccessibilityUtils.createKeyboardNavigable
  }

  Widget _buildSwipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      alignment: alignment,
      padding: EdgeInsets.only(
        left: alignment == Alignment.centerLeft ? 32 : 0,
        right: alignment == Alignment.centerRight ? 32 : 0,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(
    BuildContext context,
    bool isRunning,
    Duration? timeRemaining,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: themeService.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isRunning
                  ? reminder.color.withValues(alpha: 0.6)
                  : reminder.isEnabled
                  ? reminder.color.withValues(alpha: 0.2)
                  : themeService.borderColor,
          width: isRunning ? 2.5 : 2,
        ),
        gradient:
            isRunning && reminder.isEnabled
                ? LinearGradient(
                  colors: [
                    reminder.color.withValues(alpha: 0.08),
                    reminder.color.withValues(alpha: 0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                : null,
        boxShadow: [
          BoxShadow(
            color:
                isRunning
                    ? reminder.color.withValues(alpha: 0.2)
                    : themeService.shadowColor,
            blurRadius: isRunning ? 20 : 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Pulsing indicator for active reminders
          if (isRunning && reminder.isEnabled)
            Positioned(
              top: 0,
              right: 0,
              child: PulsingDot(color: reminder.color, size: 10),
            ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with icon and toggle
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isRunning
                              ? reminder.color.withValues(alpha: 0.2)
                              : reminder.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow:
                          isRunning
                              ? [
                                BoxShadow(
                                  color: reminder.color.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                              : null,
                    ),
                    child: Icon(reminder.icon, color: reminder.color, size: 24),
                  ),
                  const Spacer(),

                  // Enhanced toggle with better touch target
                  Container(
                    padding: const EdgeInsets.all(4), // Increases touch target
                    child: Switch(
                      value: reminder.isEnabled,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        reminderService.toggleReminder(reminder.id);
                      },
                      thumbColor: WidgetStateProperty.resolveWith<Color>((
                        states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return reminder.color;
                        }
                        return Colors.grey;
                      }),
                      trackColor: WidgetStateProperty.resolveWith<Color>((
                        states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return reminder.color.withValues(alpha: 0.5);
                        }
                        return Colors.grey.withValues(alpha: 0.3);
                      }),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Title and description
              Text(
                reminder.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: themeService.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                reminder.description,
                style: TextStyle(
                  fontSize: 14,
                  color: themeService.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 16),

              // Time information with enhanced touch targets
              Row(
                children: [
                  // Interval chip (enhanced touch target)
                  Semantics(
                    label:
                        'Reminder interval ${_formatDuration(reminder.interval)}',
                    hint: 'Double tap to change interval',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _showTimerChangeDialog(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: reminder.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: reminder.color.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 16,
                                color: reminder.color,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatDuration(reminder.interval),
                                style: TextStyle(
                                  color: reminder.color,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.edit_rounded,
                                size: 12,
                                color: reminder.color.withValues(alpha: 0.7),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Time remaining (if running)
                  if (isRunning && timeRemaining != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              reminder.color.withValues(alpha: 0.15),
                              reminder.color.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: reminder.color.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PulsingDot(color: reminder.color, size: 6),
                                const SizedBox(width: 8),
                                Text(
                                  'Next in',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: reminder.color,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              _formatTimeRemaining(timeRemaining),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: reminder.color,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Progress indicator for active reminders
              if (isRunning && timeRemaining != null) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _getProgressValue(timeRemaining),
                  backgroundColor: reminder.color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(reminder.color),
                  minHeight: 4,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Duration? _getTimeRemaining() {
    if (!reminder.isEnabled || reminder.nextReminder == null) {
      return null;
    }

    final now = currentTime;
    final nextTime = reminder.nextReminder!;
    final diff = nextTime.difference(now);

    if (diff.inSeconds <= 0 || diff.inHours > 24) {
      return null;
    }

    return diff;
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  String _formatTimeRemaining(Duration duration) {
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      final seconds = duration.inSeconds % 60;
      if (minutes > 0) {
        return '${hours}h ${minutes}m ${seconds}s';
      } else {
        return '${hours}h ${seconds}s';
      }
    } else if (duration.inMinutes > 0) {
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      return '${minutes}m ${seconds}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  double _getProgressValue(Duration timeRemaining) {
    final totalDuration = reminder.interval;
    final elapsed = totalDuration - timeRemaining;
    return elapsed.inSeconds / totalDuration.inSeconds;
  }

  void _snoozeReminder(int minutes) {
    // Reset reminder time to snooze duration
    reminder.nextReminder = DateTime.now().add(Duration(minutes: minutes));
    reminderService.saveData();
  }

  void _showActionFeedback(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showTimerChangeDialog(BuildContext context) async {
    final List<int> timerOptions = [
      1,
      2,
      5,
      10,
      15,
      20,
      30,
      45,
      60,
      90,
      120,
      180,
      240,
    ];
    final currentMinutes = reminder.interval.inMinutes;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeService.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: reminder.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(reminder.icon, color: reminder.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Change Timer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: themeService.textPrimary,
                      ),
                    ),
                    Text(
                      reminder.title,
                      style: TextStyle(
                        fontSize: 14,
                        color: themeService.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select new interval:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: themeService.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      timerOptions.map((minutes) {
                        final isSelected = minutes == currentMinutes;
                        final duration = Duration(minutes: minutes);

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              reminderService.updateReminderInterval(
                                reminder.id,
                                duration,
                              );
                              Navigator.of(context).pop();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? reminder.color.withValues(alpha: 0.2)
                                        : themeService.isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? reminder.color
                                          : themeService.borderColor,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Text(
                                _formatDuration(duration),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                  color:
                                      isSelected
                                          ? reminder.color
                                          : themeService.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        themeService.isDarkMode
                            ? Colors.blue.withValues(alpha: 0.1)
                            : Colors.blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Timer will reset and start with the new interval',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: themeService.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
