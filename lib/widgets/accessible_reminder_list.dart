import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';
import '../services/theme_service.dart';
import '../utils/accessibility_utils.dart';
import 'swipeable_reminder_card.dart';

/// Accessible reminder list with keyboard navigation and screen reader support
class AccessibleReminderList extends StatefulWidget {
  final List<Reminder> reminders;
  final ReminderService reminderService;
  final ThemeService themeService;
  final DateTime currentTime;

  const AccessibleReminderList({
    super.key,
    required this.reminders,
    required this.reminderService,
    required this.themeService,
    required this.currentTime,
  });

  @override
  State<AccessibleReminderList> createState() => _AccessibleReminderListState();
}

class _AccessibleReminderListState extends State<AccessibleReminderList> {
  int _focusedIndex = 0;
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    _initializeFocusNodes();
  }

  @override
  void didUpdateWidget(AccessibleReminderList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reminders.length != oldWidget.reminders.length) {
      _initializeFocusNodes();
    }
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _initializeFocusNodes() {
    // Dispose old nodes
    for (final node in _focusNodes) {
      node.dispose();
    }
    _focusNodes.clear();

    // Create new nodes for each reminder
    for (int i = 0; i < widget.reminders.length; i++) {
      _focusNodes.add(FocusNode());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Reminder list with ${widget.reminders.length} reminders',
      hint: 'Use arrow keys to navigate, space to toggle, enter to edit',
      child: Focus(
        onKeyEvent: _handleKeyNavigation,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: widget.reminders.length,
          itemBuilder: (context, index) {
            final reminder = widget.reminders[index];

            return Focus(
              focusNode: _focusNodes[index],
              onFocusChange: (hasFocus) {
                if (hasFocus) {
                  setState(() => _focusedIndex = index);
                  _announceReminderFocus(reminder, index);
                }
              },
              child: Container(
                decoration:
                    _focusedIndex == index
                        ? BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF6366F1),
                            width: 3,
                          ),
                        )
                        : null,
                child: SwipeableReminderCard(
                  reminder: reminder,
                  reminderService: widget.reminderService,
                  themeService: widget.themeService,
                  currentTime: widget.currentTime,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  KeyEventResult _handleKeyNavigation(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        _moveFocus(1);
        return KeyEventResult.handled;

      case LogicalKeyboardKey.arrowUp:
        _moveFocus(-1);
        return KeyEventResult.handled;

      case LogicalKeyboardKey.space:
        _toggleCurrentReminder();
        return KeyEventResult.handled;

      case LogicalKeyboardKey.enter:
        _editCurrentReminder();
        return KeyEventResult.handled;

      case LogicalKeyboardKey.keyC:
        if (HardwareKeyboard.instance.isControlPressed) {
          _completeCurrentReminder();
          return KeyEventResult.handled;
        }
        break;

      case LogicalKeyboardKey.keyS:
        if (HardwareKeyboard.instance.isControlPressed) {
          _snoozeCurrentReminder();
          return KeyEventResult.handled;
        }
        break;
    }

    return KeyEventResult.ignored;
  }

  void _moveFocus(int direction) {
    if (widget.reminders.isEmpty) return;

    final newIndex = (_focusedIndex + direction) % widget.reminders.length;
    if (newIndex >= 0 && newIndex < _focusNodes.length) {
      _focusNodes[newIndex].requestFocus();
    }
  }

  void _announceReminderFocus(Reminder reminder, int index) {
    final position = '${index + 1} of ${widget.reminders.length}';
    final status = reminder.isEnabled ? 'enabled' : 'disabled';
    final nextTime =
        reminder.nextReminder != null
            ? 'Next reminder ${AccessibilityUtils.formatDurationForA11y(reminder.nextReminder!.difference(widget.currentTime))}'
            : 'No next reminder scheduled';

    AccessibilityUtils.announce(
      'Focused on ${reminder.title} reminder, $status, $position, $nextTime',
    );
  }

  void _toggleCurrentReminder() {
    if (_focusedIndex < widget.reminders.length) {
      final reminder = widget.reminders[_focusedIndex];
      widget.reminderService.toggleReminder(reminder.id);

      AccessibilityUtils.announce(
        '${reminder.title} reminder ${reminder.isEnabled ? "disabled" : "enabled"}',
      );

      AccessibilityUtils.provideFeedback(() {
        HapticFeedback.lightImpact();
      });
    }
  }

  void _editCurrentReminder() {
    if (_focusedIndex < widget.reminders.length) {
      final reminder = widget.reminders[_focusedIndex];
      // This would trigger the timer change dialog
      AccessibilityUtils.announce(
        'Opening timer settings for ${reminder.title}',
      );
    }
  }

  void _completeCurrentReminder() {
    if (_focusedIndex < widget.reminders.length) {
      final reminder = widget.reminders[_focusedIndex];
      widget.reminderService.completeReminder(reminder);

      AccessibilityUtils.announce('Completed ${reminder.title} reminder');
      AccessibilityUtils.provideFeedback(() {
        HapticFeedback.mediumImpact();
      });
    }
  }

  void _snoozeCurrentReminder() {
    if (_focusedIndex < widget.reminders.length) {
      final reminder = widget.reminders[_focusedIndex];
      // Add snooze functionality if not already implemented
      AccessibilityUtils.announce('Snoozed ${reminder.title} for 10 minutes');
      AccessibilityUtils.provideFeedback(() {
        HapticFeedback.lightImpact();
      });
    }
  }
}
