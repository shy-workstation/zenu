import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/reminder.dart';
import '../../services/reminder_service.dart';

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

class EditReminderDialog {
  static Future<void> show(
    BuildContext context,
    Reminder reminder,
    ReminderService service,
  ) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => _EditDialog(reminder: reminder, service: service),
    );
  }
}

class _EditDialog extends StatefulWidget {
  final Reminder reminder;
  final ReminderService service;

  const _EditDialog({required this.reminder, required this.service});

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  late TextEditingController _titleCtrl;
  late double _intervalMin;
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.reminder.title);
    _intervalMin = widget.reminder.interval.inMinutes.clamp(1, 60).toDouble();
    _enabled = widget.reminder.isEnabled;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final r = widget.reminder;
    final updated = Reminder(
      id: r.id,
      type: r.type,
      title: _titleCtrl.text.trim().isEmpty ? r.title : _titleCtrl.text.trim(),
      description: r.description,
      interval: Duration(minutes: _intervalMin.round()),
      icon: r.icon,
      color: r.color,
      isEnabled: _enabled,
      nextReminder: r.nextReminder,
      exerciseCount: r.exerciseCount,
      totalCompleted: r.totalCompleted,
      completionLog: r.completionLog,
      minQuantity: r.minQuantity,
      maxQuantity: r.maxQuantity,
      stepSize: r.stepSize,
      unit: r.unit,
    );
    widget.service.updateReminder(updated);
    Navigator.of(context).pop();
  }

  void _delete() {
    widget.service.removeReminder(widget.reminder.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final r = widget.reminder;
    final theme = Theme.of(context);

    return AlertDialog(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: r.color.withValues(alpha: 0.2),
            child: Icon(r.icon, color: r.color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              r.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
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
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title input
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: l?.title ?? 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
              maxLength: 25,
            ),
            const SizedBox(height: 8),
            // Interval
            Row(
              children: [
                Text(
                  l?.interval ?? 'Interval',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const Spacer(),
                Text(
                  '${_intervalMin.round()} min',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: r.color,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: r.color,
                inactiveTrackColor: r.color.withValues(alpha: 0.15),
                thumbColor: r.color,
                overlayColor: r.color.withValues(alpha: 0.15),
              ),
              child: Slider(
                value: _intervalMin,
                min: 1,
                max: 60,
                divisions: 59,
                onChanged: (v) => setState(() => _intervalMin = v),
              ),
            ),
            // Enable toggle
            SwitchListTile(
              title: Text(l?.enabledLabel ?? 'Enabled'),
              value: _enabled,
              onChanged: (v) => setState(() => _enabled = v),
              contentPadding: EdgeInsets.zero,
              activeTrackColor: r.color.withValues(alpha: 0.5),
              activeThumbColor: r.color,
            ),
          ],
        ),
      ),
      actions: [
        _HoverScale(
          child: TextButton.icon(
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text(l?.delete ?? 'Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ),
        _HoverScale(
          child: FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(backgroundColor: r.color),
            child: Text(l?.doneButton ?? 'Done'),
          ),
        ),
      ],
    );
  }
}
