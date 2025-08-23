import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../utils/state_management.dart';
import '../services/reminder_service.dart';
import '../services/reminder_template_service.dart';
import '../l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class ReminderManagementScreen extends StatelessWidget {
  const ReminderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.manageReminders,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<ReminderService>(
        builder: (context, reminderService, child) {
          return Column(
            children: [
              // Header with add button
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!.yourReminders(reminderService.reminders.length),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddReminderDialog(context),
                      icon: const Icon(Icons.add),
                      label: Text(AppLocalizations.of(context)!.addReminder),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Reminders list
              Expanded(
                child:
                    reminderService.reminders.isEmpty
                        ? _buildEmptyState(context)
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: reminderService.reminders.length,
                          itemBuilder: (context, index) {
                            final reminder = reminderService.reminders[index];
                            return _buildReminderCard(
                              context,
                              reminder,
                              reminderService,
                            );
                          },
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 80, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noRemindersTitle,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.tapAddReminderToStart,
            style: const TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(
    BuildContext context,
    Reminder reminder,
    ReminderService service,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: reminder.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: reminder.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(reminder.icon, color: reminder.color, size: 24),
        ),
        title: Text(
          reminder.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              reminder.description,
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(
                  _formatInterval(reminder.interval),
                  Icons.schedule,
                  reminder.color,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  '${reminder.minQuantity}-${reminder.maxQuantity} ${reminder.unit}',
                  Icons.straighten,
                  reminder.color,
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Enable/Disable toggle
            Switch(
              value: reminder.isEnabled,
              onChanged: (value) {
                service.toggleReminder(reminder.id);
              },
              thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return reminder.color;
                }
                return Colors.grey;
              }),
              trackColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return reminder.color.withValues(alpha: 0.5);
                }
                return Colors.grey.withValues(alpha: 0.3);
              }),
            ),
            const SizedBox(width: 8),
            // More options menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white54),
              color: const Color(0xFF2A2A3E),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditReminderDialog(context, reminder, service);
                    break;
                  case 'duplicate':
                    _duplicateReminder(reminder, service);
                    break;
                  case 'delete':
                    _showDeleteConfirmation(context, reminder, service);
                    break;
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.white70),
                          SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context)?.edit ?? 'Edit',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Row(
                        children: [
                          Icon(Icons.copy, color: Colors.white70),
                          SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context)?.duplicate ?? 'Duplicate',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context)?.delete ?? 'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatInterval(Duration interval) {
    if (interval.inHours > 0) {
      return '${interval.inHours}h';
    } else {
      return '${interval.inMinutes}m';
    }
  }

  void _showAddReminderDialog(BuildContext context) {
    final reminderService = Provider.of<ReminderService>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder:
          (context) => ReminderEditDialog(reminderService: reminderService),
    );
  }

  void _showEditReminderDialog(
    BuildContext context,
    Reminder reminder,
    ReminderService service,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => ReminderEditDialog(
            existingReminder: reminder,
            reminderService: service,
          ),
    );
  }

  void _duplicateReminder(Reminder reminder, ReminderService service) {
    final newReminder = Reminder(
      id: const Uuid().v4(),
      type: reminder.type,
      title: '${reminder.title} (Copy)',
      description: reminder.description,
      interval: reminder.interval,
      icon: reminder.icon,
      color: reminder.color,
      minQuantity: reminder.minQuantity,
      maxQuantity: reminder.maxQuantity,
      stepSize: reminder.stepSize,
      unit: reminder.unit,
    );
    service.addReminder(newReminder);
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Reminder reminder,
    ReminderService service,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2A2A3E),
            title: const Text(
              'Delete Reminder',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Are you sure you want to delete "${reminder.title}"?',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  service.removeReminder(reminder.id);
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}

class ReminderEditDialog extends StatefulWidget {
  final Reminder? existingReminder;
  final ReminderService reminderService;

  const ReminderEditDialog({
    super.key,
    this.existingReminder,
    required this.reminderService,
  });

  @override
  State<ReminderEditDialog> createState() => _ReminderEditDialogState();
}

class _ReminderEditDialogState extends State<ReminderEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late IconData _selectedIcon;
  late Color _selectedColor;
  late int _intervalMinutes;
  late int _minQuantity;
  late int _maxQuantity;
  late int _stepSize;
  late String _unit;
  ReminderType _selectedType = ReminderType.custom;

  @override
  void initState() {
    super.initState();
    final reminder = widget.existingReminder;

    _titleController = TextEditingController(text: reminder?.title ?? '');
    _descriptionController = TextEditingController(
      text: reminder?.description ?? '',
    );
    _selectedIcon = reminder?.icon ?? Icons.fitness_center;
    _selectedColor = reminder?.color ?? Colors.blue;
    _intervalMinutes = reminder?.interval.inMinutes ?? 60;
    _minQuantity = reminder?.minQuantity ?? 1;
    _maxQuantity = reminder?.maxQuantity ?? 100;
    _stepSize = reminder?.stepSize ?? 1;
    _unit = reminder?.unit ?? 'reps';
    _selectedType = reminder?.type ?? ReminderType.custom;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF2A2A3E),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              widget.existingReminder != null
                  ? 'Edit Reminder'
                  : 'Add New Reminder',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Template selection (only for new reminders)
                    if (widget.existingReminder == null) ...[
                      const Text(
                        'Choose Template',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTemplateSelector(),
                      const SizedBox(height: 24),
                    ],

                    // Title
                    _buildTextField(
                      controller: _titleController,
                      label: 'Title',
                      hint: 'Enter reminder title',
                    ),
                    const SizedBox(height: 16),

                    // Description
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Enter reminder description',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Icon and Color selection
                    Row(
                      children: [
                        Expanded(child: _buildIconSelector()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildColorSelector()),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Interval
                    _buildIntervalSelector(),
                    const SizedBox(height: 16),

                    // Quantity settings
                    _buildQuantitySettings(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveReminder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      widget.existingReminder != null ? 'Update' : 'Add',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateSelector() {
    final templates = ReminderTemplateService.getBuiltInTemplates();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Custom option
        _buildTemplateChip(
          'Custom',
          Icons.add,
          Colors.grey,
          ReminderType.custom,
          null,
        ),
        // Built-in templates
        _buildTemplateChip(
          'Eye Rest',
          Icons.visibility_outlined,
          Colors.cyan,
          ReminderType.eyeRest,
          templates.firstWhere((t) => t.name == 'Eye Rest'),
        ),
        _buildTemplateChip(
          'Stand Up',
          Icons.accessibility_new,
          Colors.orange,
          ReminderType.standUp,
          templates.firstWhere((t) => t.name == 'Stand Up'),
        ),
        _buildTemplateChip(
          'Pull Ups',
          Icons.fitness_center,
          Colors.red,
          ReminderType.pullUps,
          templates.firstWhere((t) => t.name == 'Pull Ups'),
        ),
        _buildTemplateChip(
          'Push Ups',
          Icons.sports_gymnastics,
          Colors.green,
          ReminderType.pushUps,
          templates.firstWhere((t) => t.name == 'Push Ups'),
        ),
        _buildTemplateChip(
          'Drink Water',
          Icons.local_drink,
          Colors.blue,
          ReminderType.water,
          templates.firstWhere((t) => t.name == 'Drink Water'),
        ),
        _buildTemplateChip(
          'Stretch',
          Icons.self_improvement,
          Colors.purple,
          ReminderType.stretch,
          templates.firstWhere((t) => t.name == 'Stretch'),
        ),
      ],
    );
  }

  Widget _buildTemplateChip(
    String name,
    IconData icon,
    Color color,
    ReminderType type,
    ReminderTemplate? template,
  ) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          if (type != ReminderType.custom && template != null) {
            _titleController.text = template.name;
            _descriptionController.text = template.description;
            _selectedIcon = template.icon;
            _selectedColor = template.color;
            _intervalMinutes = template.defaultInterval.inMinutes;

            // Validate and ensure consistent quantity values
            _minQuantity = template.minQuantity.clamp(1, 100).toInt();
            _maxQuantity =
                template.maxQuantity.clamp(_minQuantity, 100).toInt();
            _stepSize =
                template.stepSize.clamp(1, _maxQuantity - _minQuantity).toInt();
            _unit = template.unit;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _selectedColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Icon',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showIconPicker,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(_selectedIcon, color: _selectedColor, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Choose Icon',
                  style: TextStyle(color: Colors.white70),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: Colors.white54),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showColorPicker,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Choose Color',
                  style: TextStyle(color: Colors.white70),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: Colors.white54),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntervalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reminder Interval',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Slider(
                  value: _intervalMinutes.toDouble(),
                  min: 1,
                  max: 240, // 4 hours
                  divisions: 239,
                  label: _formatIntervalLabel(_intervalMinutes),
                  activeColor: _selectedColor,
                  onChanged: (value) {
                    setState(() {
                      _intervalMinutes = value.round();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatIntervalLabel(_intervalMinutes),
                style: TextStyle(
                  color: _selectedColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quantity Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Unit
              Row(
                children: [
                  const Text('Unit:', style: TextStyle(color: Colors.white70)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'e.g., reps, ml, minutes',
                        hintStyle: const TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) => _unit = value,
                      controller: TextEditingController(text: _unit),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white24),

              // Min Quantity
              Row(
                children: [
                  const Text('Min:', style: TextStyle(color: Colors.white70)),
                  Expanded(
                    child: Slider(
                      value: _minQuantity.clamp(1, _maxQuantity - 1).toDouble(),
                      min: 1,
                      max: (_maxQuantity - 1).clamp(2, 999).toDouble(),
                      divisions: ((_maxQuantity - 2).clamp(1, 998)).toInt(),
                      label: _minQuantity.toString(),
                      activeColor: _selectedColor,
                      onChanged: (value) {
                        setState(() {
                          _minQuantity = value.round().clamp(
                            1,
                            _maxQuantity - 1,
                          );
                        });
                      },
                    ),
                  ),
                  Text(
                    _minQuantity.toString(),
                    style: TextStyle(
                      color: _selectedColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              // Max Quantity
              Row(
                children: [
                  const Text('Max:', style: TextStyle(color: Colors.white70)),
                  Expanded(
                    child: Slider(
                      value:
                          _maxQuantity.clamp(_minQuantity + 1, 1000).toDouble(),
                      min: (_minQuantity + 1).clamp(2, 999).toDouble(),
                      max: 1000,
                      divisions: (999 - _minQuantity).clamp(1, 998),
                      label: _maxQuantity.toString(),
                      activeColor: _selectedColor,
                      onChanged: (value) {
                        setState(() {
                          _maxQuantity = value.round().clamp(
                            _minQuantity + 1,
                            1000,
                          );
                        });
                      },
                    ),
                  ),
                  Text(
                    _maxQuantity.toString(),
                    style: TextStyle(
                      color: _selectedColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              // Step Size
              Row(
                children: [
                  const Text('Step:', style: TextStyle(color: Colors.white70)),
                  Expanded(
                    child: Slider(
                      value: _stepSize.toDouble(),
                      min: 1,
                      max: 25,
                      divisions: 24,
                      label: _stepSize.toString(),
                      activeColor: _selectedColor,
                      onChanged: (value) {
                        setState(() {
                          _stepSize = value.round();
                        });
                      },
                    ),
                  ),
                  Text(
                    _stepSize.toString(),
                    style: TextStyle(
                      color: _selectedColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatIntervalLabel(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return remainingMinutes == 0
          ? '${hours}h'
          : '${hours}h ${remainingMinutes}m';
    } else {
      return '${minutes}m';
    }
  }

  void _showIconPicker() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2A2A3E),
            title: const Text(
              'Choose Icon',
              style: TextStyle(color: Colors.white),
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  childAspectRatio: 1,
                ),
                itemCount: ReminderTemplateService.getAvailableIcons().length,
                itemBuilder: (context, index) {
                  final icon =
                      ReminderTemplateService.getAvailableIcons()[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color:
                            _selectedIcon == icon
                                ? _selectedColor.withValues(alpha: 0.3)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              _selectedIcon == icon
                                  ? _selectedColor
                                  : Colors.white24,
                        ),
                      ),
                      child: Icon(icon, color: _selectedColor),
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
          ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2A2A3E),
            title: const Text(
              'Choose Color',
              style: TextStyle(color: Colors.white),
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 200,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  childAspectRatio: 1,
                ),
                itemCount: ReminderTemplateService.getAvailableColors().length,
                itemBuilder: (context, index) {
                  final color =
                      ReminderTemplateService.getAvailableColors()[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              _selectedColor == color
                                  ? Colors.white
                                  : Colors.transparent,
                          width: 3,
                        ),
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
          ),
    );
  }

  void _saveReminder() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.pleaseEnterTitle ??
                'Please enter a title',
          ),
        ),
      );
      return;
    }

    final reminderService = widget.reminderService;

    final reminder = Reminder(
      id: widget.existingReminder?.id ?? const Uuid().v4(),
      type: _selectedType,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      interval: Duration(minutes: _intervalMinutes),
      icon: _selectedIcon,
      color: _selectedColor,
      minQuantity: _minQuantity,
      maxQuantity: _maxQuantity,
      stepSize: _stepSize,
      unit: _unit.trim(),
      isEnabled: widget.existingReminder?.isEnabled ?? true,
      exerciseCount: widget.existingReminder?.exerciseCount ?? 0,
      totalCompleted: widget.existingReminder?.totalCompleted ?? 0,
    );

    if (widget.existingReminder != null) {
      reminderService.updateReminder(reminder);
    } else {
      reminderService.addReminder(reminder);
    }

    Navigator.of(context).pop();
  }
}
