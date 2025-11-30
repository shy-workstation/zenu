import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';
import '../services/theme_service.dart';
import '../utils/accessibility_utils.dart';
import '../l10n/app_localizations.dart';
import 'pulsing_dot.dart';
import 'floating_pill.dart';

/// Enum defining the possible states of a reminder card
enum ReminderCardState {
  /// Default state - shows reminder info with countdown
  normal,

  /// Notification state - reminder triggered, shows skip/done buttons
  notification,

  /// Completing state - brief animation when completing
  completing,
}

class SwipeableReminderCard extends StatefulWidget {
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
  State<SwipeableReminderCard> createState() => _SwipeableReminderCardState();
}

class _SwipeableReminderCardState extends State<SwipeableReminderCard>
    with TickerProviderStateMixin {
  ReminderCardState _cardState = ReminderCardState.normal;
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  double _currentQuantity = 0;

  @override
  void initState() {
    super.initState();
    _initializeQuantity();
    _setupAnimations();

    // Check if this reminder is currently triggered
    _checkIfTriggered();
  }

  void _initializeQuantity() {
    _currentQuantity =
        widget.reminder.exerciseCount > 0
            ? widget.reminder.exerciseCount.toDouble()
            : _getDefaultQuantity(widget.reminder.type).toDouble();
    _currentQuantity = _currentQuantity.clamp(
      widget.reminder.minQuantity.toDouble(),
      widget.reminder.maxQuantity.toDouble(),
    );
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
  }

  void _checkIfTriggered() {
    // Check if the reminder was just triggered (nextReminder is null or in the past)
    if (widget.reminder.isEnabled &&
        widget.reminderService.isRunning &&
        widget.reminder.nextReminder != null) {
      final now = widget.currentTime;
      if (now.isAfter(widget.reminder.nextReminder!) ||
          now.isAtSameMomentAs(widget.reminder.nextReminder!)) {
        // Reminder should be in notification state
        _enterNotificationState();
      }
    }
  }

  @override
  void didUpdateWidget(SwipeableReminderCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if reminder just triggered
    if (widget.reminder.isEnabled &&
        widget.reminderService.isRunning &&
        widget.reminder.nextReminder != null &&
        _cardState == ReminderCardState.normal) {
      final now = widget.currentTime;
      if (now.isAfter(widget.reminder.nextReminder!) ||
          now.isAtSameMomentAs(widget.reminder.nextReminder!)) {
        _enterNotificationState();
      }
    }
  }

  void _enterNotificationState() {
    if (_cardState != ReminderCardState.notification) {
      setState(() {
        _cardState = ReminderCardState.notification;
        _initializeQuantity();
      });
      _pulseController.repeat(reverse: true);
      HapticFeedback.mediumImpact();
    }
  }

  void _exitNotificationState({bool completed = false}) {
    _pulseController.stop();
    _pulseController.reset();

    if (completed) {
      setState(() {
        _cardState = ReminderCardState.completing;
      });
      _scaleController.forward().then((_) {
        _scaleController.reverse().then((_) {
          setState(() {
            _cardState = ReminderCardState.normal;
          });
        });
      });
    } else {
      setState(() {
        _cardState = ReminderCardState.normal;
      });
    }
  }

  void _handleSkip() {
    HapticFeedback.lightImpact();
    widget.reminder.resetNextReminder();
    widget.reminderService.saveData();
    widget.reminderService.refresh();
    _exitNotificationState(completed: false);
  }

  void _handleDone() {
    HapticFeedback.mediumImpact();
    widget.reminderService.completeReminder(
      widget.reminder,
      customCount: _currentQuantity.round(),
    );
    _exitNotificationState(completed: true);
  }

  int _getDefaultQuantity(ReminderType type) {
    switch (type) {
      case ReminderType.pullUps:
        return 8;
      case ReminderType.pushUps:
        return 15;
      case ReminderType.squats:
        return 10;
      case ReminderType.jumpingJacks:
        return 15;
      case ReminderType.planks:
        return 1;
      case ReminderType.burpees:
        return 5;
      case ReminderType.water:
        return 300;
      case ReminderType.eyeRest:
        return 30;
      case ReminderType.standUp:
        return 3;
      case ReminderType.stretch:
        return 5;
      case ReminderType.exercise:
        return 10;
      case ReminderType.stretching:
        return 5;
      case ReminderType.custom:
        return ((widget.reminder.minQuantity + widget.reminder.maxQuantity) / 2)
            .round();
    }
  }

  bool _hasQuantity(ReminderType type) {
    return type == ReminderType.pullUps ||
        type == ReminderType.pushUps ||
        type == ReminderType.squats ||
        type == ReminderType.jumpingJacks ||
        type == ReminderType.planks ||
        type == ReminderType.burpees ||
        type == ReminderType.water ||
        type == ReminderType.eyeRest ||
        type == ReminderType.standUp ||
        type == ReminderType.stretch ||
        type == ReminderType.exercise ||
        type == ReminderType.stretching;
  }

  String _getQuantityUnit(ReminderType type) {
    switch (type) {
      case ReminderType.pullUps:
      case ReminderType.pushUps:
      case ReminderType.squats:
      case ReminderType.jumpingJacks:
      case ReminderType.burpees:
        return 'reps';
      case ReminderType.planks:
        return 'seconds';
      case ReminderType.water:
        return 'ml';
      case ReminderType.eyeRest:
        return 'seconds';
      case ReminderType.standUp:
      case ReminderType.stretch:
      case ReminderType.stretching:
        return 'minutes';
      case ReminderType.exercise:
        return 'reps';
      case ReminderType.custom:
        return widget.reminder.unit;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeRemaining = _getTimeRemaining();
    final isRunning =
        widget.reminder.isEnabled &&
        widget.reminderService.isRunning &&
        timeRemaining != null;

    // Determine which content to show based on state
    Widget cardContent;
    switch (_cardState) {
      case ReminderCardState.notification:
        cardContent = AnimatedBuilder(
          animation: _pulseAnimation,
          builder:
              (context, child) => Transform.scale(
                scale: _pulseAnimation.value,
                child: _buildNotificationCard(context),
              ),
        );
        break;
      case ReminderCardState.completing:
        cardContent = ScaleTransition(
          scale: _scaleAnimation,
          child: _buildReminderCard(context, isRunning, timeRemaining),
        );
        break;
      case ReminderCardState.normal:
      default:
        cardContent = _buildReminderCard(context, isRunning, timeRemaining);
    }

    return AccessibilityUtils.createKeyboardNavigable(
      focusLabel:
          '${widget.reminder.title} reminder card, ${widget.reminder.isEnabled ? "enabled" : "disabled"}',
      onActivate: () => widget.reminderService.toggleReminder(widget.reminder.id),
      onSpace: () => widget.reminderService.toggleReminder(widget.reminder.id),
      onEnter: () => _showTimerChangeDialog(context),
      child: Semantics(
        label:
            '${widget.reminder.title} reminder, ${widget.reminder.isEnabled ? "enabled" : "disabled"}',
        hint:
            _cardState == ReminderCardState.notification
                ? 'Reminder triggered! Double tap to complete, or swipe to skip.'
                : isRunning
                ? 'Next reminder in ${AccessibilityUtils.formatDurationForA11y(timeRemaining)}. Swipe right to toggle enable, left to edit settings.'
                : 'Double tap to toggle reminder, press enter to change timer, swipe for actions',
        button: true,
        child:
            _cardState == ReminderCardState.notification
                ? cardContent
                : Dismissible(
                  key: Key('swipe_${widget.reminder.id}'),
                  background: _buildSwipeBackground(
                    alignment: Alignment.centerLeft,
                    color: widget.reminder.isEnabled ? Colors.grey : Colors.green,
                    icon: widget.reminder.isEnabled ? Icons.pause_circle : Icons.play_circle,
                    label: widget.reminder.isEnabled ? 'Disable' : 'Enable',
                  ),
                  secondaryBackground: _buildSwipeBackground(
                    alignment: Alignment.centerRight,
                    color: const Color(0xFF6366F1),
                    icon: Icons.edit,
                    label: 'Edit',
                  ),
                  confirmDismiss: (direction) async {
                    HapticFeedback.mediumImpact();

                    if (direction == DismissDirection.startToEnd) {
                      // Toggle enable/disable
                      widget.reminderService.toggleReminder(widget.reminder.id);
                      _showActionFeedback(
                        context,
                        widget.reminder.isEnabled
                            ? '${widget.reminder.title} disabled'
                            : '${widget.reminder.title} enabled',
                        widget.reminder.isEnabled ? Colors.grey : Colors.green,
                      );
                    } else if (direction == DismissDirection.endToStart) {
                      // Open edit dialog
                      _showEditDialog(context);
                    }
                    return false;
                  },
                  child: cardContent,
                ),
      ),
    );
  }

  /// Builds the notification state card with Skip/Done buttons
  Widget _buildNotificationCard(BuildContext context) {
    final minQuantity = widget.reminder.minQuantity.toDouble();
    final maxQuantity = widget.reminder.maxQuantity.toDouble();
    final stepSize = widget.reminder.stepSize.toDouble();
    final unit = _getQuantityUnit(widget.reminder.type);
    final hasQuantitySelector = _hasQuantity(widget.reminder.type);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.reminder.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.reminder.color, width: 3),
        boxShadow: [
          BoxShadow(
            color: widget.reminder.color.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.reminder.color.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: widget.reminder.color.withValues(alpha: 0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  widget.reminder.icon,
                  color: widget.reminder.color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.reminder.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: widget.themeService.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getMotivationalMessage(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: widget.themeService.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Quantity selector (if applicable)
          if (hasQuantitySelector) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.reminder.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.reminder.color.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  // Current value display
                  Text(
                    '${_currentQuantity.round()} $unit',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: widget.reminder.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: widget.reminder.color,
                      inactiveTrackColor: widget.reminder.color.withValues(
                        alpha: 0.3,
                      ),
                      thumbColor: widget.reminder.color,
                      overlayColor: widget.reminder.color.withValues(alpha: 0.2),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 10,
                      ),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: _currentQuantity.clamp(minQuantity, maxQuantity),
                      min: minQuantity,
                      max: maxQuantity,
                      divisions:
                          ((maxQuantity - minQuantity) / stepSize).round(),
                      onChanged: (value) {
                        setState(() {
                          _currentQuantity = value;
                        });
                      },
                    ),
                  ),
                  // Min/Max labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${minQuantity.round()} $unit',
                        style: TextStyle(
                          fontSize: 11,
                          color: widget.reminder.color.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${maxQuantity.round()} $unit',
                        style: TextStyle(
                          fontSize: 11,
                          color: widget.reminder.color.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Action buttons: Skip and Done
          Row(
            children: [
              // Skip button
              Expanded(
                child: Material(
                  color: widget.themeService.isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _handleSkip,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.close_rounded,
                            color: widget.themeService.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)?.skip ?? 'Skip',
                            style: TextStyle(
                              color: widget.themeService.textSecondary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Done button
              Expanded(
                flex: 2,
                child: Material(
                  color: widget.reminder.color,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _handleDone,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)?.done ?? 'Done!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage() {
    switch (widget.reminder.type) {
      case ReminderType.eyeRest:
        return 'Give your eyes a break!';
      case ReminderType.standUp:
        return 'Time to stand and stretch!';
      case ReminderType.pullUps:
        return 'Build your upper body strength!';
      case ReminderType.pushUps:
        return 'Push yourself to be stronger!';
      case ReminderType.squats:
        return 'Strengthen those legs!';
      case ReminderType.jumpingJacks:
        return 'Get your heart pumping!';
      case ReminderType.planks:
        return 'Core power time!';
      case ReminderType.burpees:
        return 'Full body burn!';
      case ReminderType.water:
        return 'Stay hydrated!';
      case ReminderType.stretch:
        return 'Keep your muscles flexible!';
      case ReminderType.exercise:
        return 'Time to exercise!';
      case ReminderType.stretching:
        return 'Stretching time!';
      case ReminderType.custom:
        return widget.reminder.description;
    }
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
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: widget.reminder.isEnabled ? 1.0 : 0.6,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color:
              widget.reminder.isEnabled
                  ? widget.themeService.cardColor
                  : widget.themeService.cardColor.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isRunning
                    ? widget.reminder.color.withValues(alpha: 0.6)
                    : widget.reminder.isEnabled
                    ? widget.reminder.color.withValues(alpha: 0.2)
                    : widget.themeService.borderColor.withValues(alpha: 0.5),
            width: isRunning ? 2.5 : 2,
          ),
          gradient:
              isRunning && widget.reminder.isEnabled
                  ? LinearGradient(
                    colors: [
                      widget.reminder.color.withValues(alpha: 0.08),
                      widget.reminder.color.withValues(alpha: 0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          boxShadow: [
            BoxShadow(
              color:
                  isRunning
                      ? widget.reminder.color.withValues(alpha: 0.2)
                      : widget.themeService.shadowColor,
              blurRadius: isRunning ? 20 : 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Pulsing indicator for active reminders
            if (isRunning && widget.reminder.isEnabled)
              Positioned(
                top: 0,
                right: 0,
                child: PulsingDot(color: widget.reminder.color, size: 10),
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
                                ? widget.reminder.color.withValues(alpha: 0.2)
                                : widget.reminder.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow:
                            isRunning
                                ? [
                                  BoxShadow(
                                    color: widget.reminder.color.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                                : null,
                      ),
                      child: Icon(
                        widget.reminder.icon,
                        color: widget.reminder.color,
                        size: 24,
                      ),
                    ),
                    const Spacer(),

                    // Enhanced toggle with text and clear states
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.reminderService.toggleReminder(widget.reminder.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color:
                                widget.reminder.isEnabled
                                    ? widget.reminder.color.withValues(alpha: 0.15)
                                    : Colors.grey.withValues(alpha: 0.1),
                            border: Border.all(
                              color:
                                  widget.reminder.isEnabled
                                      ? widget.reminder.color.withValues(alpha: 0.3)
                                      : Colors.grey.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.reminder.isEnabled
                                    ? Icons.check_circle
                                    : Icons.pause_circle_outline,
                                size: 16,
                                color:
                                    widget.reminder.isEnabled
                                        ? widget.reminder.color
                                        : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.reminder.isEnabled
                                    ? (AppLocalizations.of(context)?.active ?? 'On')
                                    : 'Off',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      widget.reminder.isEnabled
                                          ? widget.reminder.color
                                          : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Title and description
                Text(
                  widget.reminder.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: widget.themeService.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.reminder.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.themeService.textSecondary,
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
                          'Reminder interval ${_formatDuration(widget.reminder.interval)}',
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
                              color: widget.reminder.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: widget.reminder.color.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 16,
                                  color: widget.reminder.color,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _formatDuration(widget.reminder.interval),
                                  style: TextStyle(
                                    color: widget.reminder.color,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.edit_rounded,
                                  size: 12,
                                  color: widget.reminder.color.withValues(alpha: 0.7),
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
                                widget.reminder.color.withValues(alpha: 0.15),
                                widget.reminder.color.withValues(alpha: 0.05),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.reminder.color.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PulsingDot(color: widget.reminder.color, size: 6),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Next in',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: widget.reminder.color,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                _formatTimeRemaining(timeRemaining),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: widget.reminder.color,
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
                    backgroundColor: widget.reminder.color.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(widget.reminder.color),
                    minHeight: 4,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Duration? _getTimeRemaining() {
    if (!widget.reminder.isEnabled || widget.reminder.nextReminder == null) {
      return null;
    }

    final now = widget.currentTime;
    final nextTime = widget.reminder.nextReminder!;
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
    final totalDuration = widget.reminder.interval;
    final elapsed = totalDuration - timeRemaining;
    return elapsed.inSeconds / totalDuration.inSeconds;
  }

  void _snoozeReminder(int minutes) {
    // Reset reminder time to snooze duration
    widget.reminder.nextReminder = DateTime.now().add(Duration(minutes: minutes));
    widget.reminderService.saveData();
    widget.reminderService.refresh();
  }

  void _showEditDialog(BuildContext context) {
    // Open the timer change dialog for editing
    _showTimerChangeDialog(context);
  }

  void _showActionFeedback(BuildContext context, String message, Color color) {
    FloatingPill.show(
      context,
      icon: Icons.check_rounded,
      message: message,
      color: color,
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
    final currentMinutes = widget.reminder.interval.inMinutes;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: widget.themeService.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.reminder.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.reminder.icon, color: widget.reminder.color, size: 20),
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
                        color: widget.themeService.textPrimary,
                      ),
                    ),
                    Text(
                      widget.reminder.title,
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.themeService.textSecondary,
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
                    color: widget.themeService.textPrimary,
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
                              widget.reminderService.updateReminderInterval(
                                widget.reminder.id,
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
                                        ? widget.reminder.color.withValues(alpha: 0.2)
                                        : widget.themeService.isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? widget.reminder.color
                                          : widget.themeService.borderColor,
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
                                          ? widget.reminder.color
                                          : widget.themeService.textPrimary,
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
                        widget.themeService.isDarkMode
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
                  color: widget.themeService.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Public method to trigger the notification state externally
  void triggerNotification() {
    _enterNotificationState();
  }
}
