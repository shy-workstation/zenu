import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../generated/l10n/app_localizations.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';

class QuickAddDialogs {
  static Future<void> showWaterReminderDialog(
    BuildContext context,
    ReminderService reminderService,
  ) async {
    final localizations = AppLocalizations.of(context);

    final reminder = Reminder(
      id: const Uuid().v4(),
      type: ReminderType.water,
      title: '💧 ${localizations?.waterReminder ?? 'Water Reminder'}',
      description: 'Stay hydrated throughout the day',
      interval: const Duration(minutes: 30),
      icon: Icons.water_drop,
      color: const Color(0xFF06B6D4),
      isEnabled: true,
      minQuantity: 1,
      maxQuantity: 10,
      stepSize: 1,
      unit: 'glasses',
    );

    reminderService.addReminder(reminder);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Water reminder added! 💧'),
          backgroundColor: reminder.color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  static Future<void> showExerciseReminderDialog(
    BuildContext context,
    ReminderService reminderService,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ExerciseTypeDialog(),
    );

    if (result != null && context.mounted) {
      final reminder = Reminder(
        id: const Uuid().v4(),
        type: result['type'],
        title: result['title'],
        description: result['description'],
        interval: const Duration(minutes: 10),
        icon: result['icon'],
        color: result['color'],
        isEnabled: true,
        exerciseCount: result['defaultCount'],
        minQuantity: 1,
        maxQuantity: 50,
        stepSize: 1,
        unit: 'reps',
      );

      reminderService.addReminder(reminder);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result['title']} reminder added! 💪'),
          backgroundColor: reminder.color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  static Future<void> showEyeRestReminderDialog(
    BuildContext context,
    ReminderService reminderService,
  ) async {
    final localizations = AppLocalizations.of(context);

    final reminder = Reminder(
      id: const Uuid().v4(),
      type: ReminderType.eyeRest,
      title: '👁️ ${localizations?.eyeRestReminder ?? 'Eye Rest Reminder'}',
      description: 'Look away from screen - 20/20/20 rule',
      interval: const Duration(minutes: 20),
      icon: Icons.remove_red_eye,
      color: const Color(0xFF3B82F6),
      isEnabled: true,
      minQuantity: 20,
      maxQuantity: 60,
      stepSize: 10,
      unit: 'seconds',
    );

    reminderService.addReminder(reminder);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eye rest reminder added! 👁️'),
          backgroundColor: reminder.color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  static Future<void> showCustomReminderDialog(
    BuildContext context,
    ReminderService reminderService,
  ) async {
    final result = await showDialog<Reminder>(
      context: context,
      builder: (context) => _CustomReminderDialog(),
    );

    if (result != null && context.mounted) {
      reminderService.addReminder(result);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Custom reminder "${result.title}" added! ✨'),
          backgroundColor: result.color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}

class _ExerciseTypeDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final exerciseTypes = [
      {
        'type': ReminderType.pushUps,
        'title': '🏋️ Push-ups',
        'description': 'Upper body strength exercise',
        'icon': Icons.fitness_center,
        'color': const Color(0xFFEF4444),
        'defaultCount': 5,
      },
      {
        'type': ReminderType.pullUps,
        'title': '🏃 Pull-ups',
        'description': 'Back and arm strengthening',
        'icon': Icons.sports_gymnastics,
        'color': const Color(0xFFF97316),
        'defaultCount': 3,
      },
      {
        'type': ReminderType.stretch,
        'title': '🤸 Stretching',
        'description': 'Body flexibility and mobility',
        'icon': Icons.self_improvement,
        'color': const Color(0xFF8B5CF6),
        'defaultCount': 1,
      },
    ];

    return AlertDialog(
      title: const Text('Choose Exercise Type'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: exerciseTypes.length,
          itemBuilder: (context, index) {
            final exercise = exerciseTypes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: (exercise['color'] as Color).withValues(
                    alpha: 0.2,
                  ),
                  child: Icon(
                    exercise['icon'] as IconData,
                    color: exercise['color'] as Color,
                  ),
                ),
                title: Text(
                  exercise['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(exercise['description'] as String),
                onTap: () => Navigator.of(context).pop(exercise),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _CustomReminderDialog extends StatefulWidget {
  @override
  State<_CustomReminderDialog> createState() => _CustomReminderDialogState();
}

class _CustomReminderDialogState extends State<_CustomReminderDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _intervalMinutes = 30;
  IconData _selectedIcon = Icons.notifications;
  Color _selectedColor = const Color(0xFF6366F1);

  final List<IconData> _iconOptions = [
    Icons.notifications,
    Icons.local_cafe,
    Icons.directions_walk,
    Icons.laptop,
    Icons.phone,
    Icons.book,
    Icons.music_note,
    Icons.spa,
    Icons.psychology,
    Icons.schedule,
  ];

  final List<Color> _colorOptions = [
    const Color(0xFF6366F1),
    const Color(0xFF10B981),
    const Color(0xFFF59E0B),
    const Color(0xFFEF4444),
    const Color(0xFF8B5CF6),
    const Color(0xFF06B6D4),
    const Color(0xFFF97316),
    const Color(0xFFEC4899),
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(localizations?.customReminder ?? 'Custom Reminder'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title field
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Reminder Title',
                border: OutlineInputBorder(),
              ),
              maxLength: 50,
            ),

            const SizedBox(height: 16),

            // Description field
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
              maxLines: 2,
            ),

            const SizedBox(height: 16),

            // Interval slider
            Text(
              'Interval: $_intervalMinutes minutes',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Slider(
              value: _intervalMinutes.toDouble(),
              min: 1,
              max: 240,
              divisions: 239,
              onChanged:
                  (value) => setState(() => _intervalMinutes = value.round()),
            ),

            const SizedBox(height: 16),

            // Icon selection
            const Text('Icon:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  _iconOptions.map((icon) {
                    final isSelected = icon == _selectedIcon;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? _selectedColor.withValues(alpha: 0.2)
                                  : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isSelected ? _selectedColor : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected ? _selectedColor : Colors.grey[600],
                          size: 24,
                        ),
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 16),

            // Color selection
            const Text('Color:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  _colorOptions.map((color) {
                    final isSelected = color == _selectedColor;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isSelected ? Colors.black : Colors.grey[300]!,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child:
                            isSelected
                                ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                                : null,
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              _titleController.text.trim().isEmpty
                  ? null
                  : () {
                    final reminder = Reminder(
                      id: const Uuid().v4(),
                      type: ReminderType.custom,
                      title: _titleController.text.trim(),
                      description:
                          _descriptionController.text.trim().isEmpty
                              ? 'Custom reminder'
                              : _descriptionController.text.trim(),
                      interval: Duration(minutes: _intervalMinutes),
                      icon: _selectedIcon,
                      color: _selectedColor,
                      isEnabled: true,
                    );
                    Navigator.of(context).pop(reminder);
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedColor,
            foregroundColor: Colors.white,
          ),
          child: Text(localizations?.addReminder ?? 'Add Reminder'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
