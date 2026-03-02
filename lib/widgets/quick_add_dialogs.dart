import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';
import 'floating_pill.dart';

class _HoverScale extends StatefulWidget {
  final Widget child;
  const _HoverScale({required this.child});
  @override
  State<_HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<_HoverScale> {
  bool _hovering = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class QuickAddDialogs {

  /// Shows a template picker with all available reminder types grouped by category.
  static Future<void> showTemplatePicker(
    BuildContext context,
    ReminderService reminderService,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => _TemplatePickerDialog(
        existingTypes: reminderService.reminders
            .map((r) => r.type)
            .toSet(),
      ),
    );

    if (result == null || !context.mounted) return;

    final reminder = Reminder(
      id: const Uuid().v4(),
      type: result['type'] as ReminderType,
      title: result['title'] as String,
      description: result['description'] as String,
      interval: result['interval'] as Duration,
      icon: result['icon'] as IconData,
      color: result['color'] as Color,
      isEnabled: true,
      exerciseCount: (result['defaultCount'] as int?) ?? 0,
      minQuantity: (result['minQuantity'] as int?) ?? 1,
      maxQuantity: (result['maxQuantity'] as int?) ?? 100,
      stepSize: (result['stepSize'] as int?) ?? 1,
      unit: (result['unit'] as String?) ?? 'reps',
    );

    reminderService.addReminder(reminder);

    if (context.mounted) {
      FloatingPill.success(context, '${reminder.title} added',
          color: reminder.color);
    }
  }
}

class _TemplatePickerDialog extends StatelessWidget {
  final Set<ReminderType> existingTypes;

  const _TemplatePickerDialog({required this.existingTypes});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final categories = _buildCategories(l);

    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(l?.addReminder ?? 'Add Reminder'),
          ),
          _HoverScale(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.of(context).pop(),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: categories.entries.expand((category) {
            return [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4, left: 4),
                child: Text(
                  category.key,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              ...category.value.map((t) {
                final alreadyAdded = existingTypes.contains(t['type']);
                return Card(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          (t['color'] as Color).withValues(alpha: 0.2),
                      child: Icon(
                        t['icon'] as IconData,
                        color: t['color'] as Color,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      t['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      t['description'] as String,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: alreadyAdded
                        ? Icon(Icons.check_circle,
                            color: theme.colorScheme.primary, size: 18)
                        : null,
                    onTap: () => Navigator.of(context).pop(t),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }),
            ];
          }).toList(),
        ),
      ),
      actions: [
        _HoverScale(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l?.cancel ?? 'Cancel'),
          ),
        ),
      ],
    );
  }

  Map<String, List<Map<String, dynamic>>> _buildCategories(
      AppLocalizations? l) {
    return {
      (l?.categoryHealth ?? 'Health').toUpperCase(): [
        {
          'type': ReminderType.water,
          'title': '\u{1F4A7} ${l?.stayHydrated ?? 'Stay Hydrated'}',
          'description':
              l?.drinkWaterRegularly ?? 'Drink water regularly',
          'icon': Icons.water_drop,
          'color': const Color(0xFF06B6D4),
          'interval': const Duration(minutes: 30),
          'minQuantity': 0,
          'maxQuantity': 1000,
          'stepSize': 25,
          'unit': 'ml',
        },
        {
          'type': ReminderType.eyeRest,
          'title': '\u{1F441}\u{FE0F} ${l?.restYourEyes ?? 'Rest Your Eyes'}',
          'description':
              l?.lookAwayFromScreen ?? 'Look away from screen and blink',
          'icon': Icons.remove_red_eye,
          'color': const Color(0xFF3B82F6),
          'interval': const Duration(minutes: 20),
          'minQuantity': 5,
          'maxQuantity': 60,
          'stepSize': 5,
          'unit': 'sec',
        },
        {
          'type': ReminderType.standUp,
          'title': '\u{1F9CD} ${l?.standAndMove ?? 'Stand and Move'}',
          'description':
              l?.getUpFromYourDesk ?? 'Get up from your desk and move around',
          'icon': Icons.directions_walk,
          'color': const Color(0xFF14B8A6),
          'interval': const Duration(minutes: 45),
          'minQuantity': 1,
          'maxQuantity': 10,
          'stepSize': 1,
          'unit': 'min',
        },
      ],
      (l?.categoryExercise ?? 'Exercise').toUpperCase(): [
        {
          'type': ReminderType.pushUps,
          'title': '\u{1F3CB}\u{FE0F} ${l?.pushUps ?? 'Push-ups'}',
          'description':
              l?.upperBodyStrengthExercise ?? 'Upper body strength exercise',
          'icon': Icons.fitness_center,
          'color': const Color(0xFFEF4444),
          'interval': const Duration(minutes: 10),
          'defaultCount': 5,
          'maxQuantity': 50,
          'unit': 'reps',
        },
        {
          'type': ReminderType.pullUps,
          'title': '\u{1F3C3} ${l?.pullUps ?? 'Pull-ups'}',
          'description':
              l?.backAndArmStrengthening ?? 'Back and arm strengthening',
          'icon': Icons.sports_gymnastics,
          'color': const Color(0xFFF97316),
          'interval': const Duration(minutes: 10),
          'defaultCount': 3,
          'maxQuantity': 30,
          'unit': 'reps',
        },
        {
          'type': ReminderType.squats,
          'title': '\u{1F938} ${l?.squats ?? 'Squats'}',
          'description': l?.lowerBodyStrengtheningExercise ??
              'Lower body strengthening exercise',
          'icon': Icons.accessibility_new,
          'color': const Color(0xFF10B981),
          'interval': const Duration(minutes: 10),
          'defaultCount': 10,
          'maxQuantity': 50,
          'unit': 'reps',
        },
        {
          'type': ReminderType.jumpingJacks,
          'title': '\u{2B50} ${l?.jumpingJacks ?? 'Jumping Jacks'}',
          'description':
              l?.fullBodyCardioExercise ?? 'Full body cardio exercise',
          'icon': Icons.directions_run,
          'color': const Color(0xFF06B6D4),
          'interval': const Duration(minutes: 10),
          'defaultCount': 15,
          'maxQuantity': 50,
          'unit': 'reps',
        },
        {
          'type': ReminderType.burpees,
          'title': '\u{1F525} ${l?.burpees ?? 'Burpees'}',
          'description': l?.fullBodyHighIntensityExercise ??
              'Full body high intensity exercise',
          'icon': Icons.bolt,
          'color': const Color(0xFFDC2626),
          'interval': const Duration(minutes: 10),
          'defaultCount': 5,
          'maxQuantity': 30,
          'unit': 'reps',
        },
      ],
      (l?.categoryMindBody ?? 'Mind & Body').toUpperCase(): [
        {
          'type': ReminderType.stretch,
          'title': '\u{1F9D8} ${l?.stretching ?? 'Stretching'}',
          'description':
              l?.bodyFlexibilityAndMobility ?? 'Body flexibility and mobility',
          'icon': Icons.self_improvement,
          'color': const Color(0xFF8B5CF6),
          'interval': const Duration(minutes: 15),
          'defaultCount': 30,
          'maxQuantity': 120,
          'unit': 'sec',
        },
        {
          'type': ReminderType.planks,
          'title': '\u{1F4AA} ${l?.planks ?? 'Planks'}',
          'description': l?.coreStrengtheningExercise ??
              'Core strengthening exercise',
          'icon': Icons.horizontal_rule,
          'color': const Color(0xFFEC4899),
          'interval': const Duration(minutes: 15),
          'defaultCount': 30,
          'maxQuantity': 120,
          'unit': 'sec',
        },
        {
          'type': ReminderType.deepBreathing,
          'title': '\u{1F32C}\u{FE0F} ${l?.deepBreathing ?? 'Deep Breathing'}',
          'description': l?.deepBreathingDescription ??
              'Calm your mind with breathing exercises',
          'icon': Icons.air,
          'color': const Color(0xFF6366F1),
          'interval': const Duration(minutes: 30),
          'defaultCount': 60,
          'maxQuantity': 300,
          'unit': 'sec',
        },
        {
          'type': ReminderType.meditation,
          'title': '\u{1F9D8} ${l?.meditationTitle ?? 'Meditation'}',
          'description': l?.meditationDescription ??
              'Clear your mind and find focus',
          'icon': Icons.spa,
          'color': const Color(0xFF7C3AED),
          'interval': const Duration(minutes: 60),
          'defaultCount': 120,
          'maxQuantity': 600,
          'unit': 'sec',
        },
      ],
    };
  }
}
