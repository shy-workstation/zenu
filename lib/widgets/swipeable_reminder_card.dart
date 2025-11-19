import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';
import '../services/theme_service.dart';
import '../utils/accessibility_utils.dart';
import '../utils/platform_helper.dart';
import 'pulsing_dot.dart';

/// Cross-platform optimized reminder card with inline notification mode
///
/// Optimizations:
/// - Web: Hover states, keyboard shortcuts, click alternatives, reduced animations
/// - Mobile: Touch-optimized, swipe gestures, haptic feedback
/// - Desktop: Mouse interactions, larger hit targets, keyboard nav
/// - Performance: ValueListenableBuilder, RepaintBoundary, conditional rendering
class SwipeableReminderCard extends StatefulWidget {
  final Reminder reminder;
  final ReminderService reminderService;
  final ThemeService themeService;
  final DateTime currentTime;
  final GlobalKey? cardKey;

  const SwipeableReminderCard({
    super.key,
    required this.reminder,
    required this.reminderService,
    required this.themeService,
    required this.currentTime,
    this.cardKey,
  });

  @override
  State<SwipeableReminderCard> createState() => _SwipeableReminderCardState();
}

class _SwipeableReminderCardState extends State<SwipeableReminderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late double _currentQuantity;
  bool _isInitialized = false;
  bool _isHovered = false; // Web/Desktop hover state

  // Platform detection for cross-platform optimizations
  static final bool _isWeb = PlatformHelper.isWeb;
  static final bool _isMobile = PlatformHelper.isMobile;
  static final bool _isDesktop = PlatformHelper.isDesktop;
  static final bool _usesMousePrimarily = _isWeb || _isDesktop;

  @override
  void initState() {
    super.initState();

    // Animation controller - Web optimization: slower, less aggressive
    _pulseController = AnimationController(
      duration: Duration(milliseconds: _isWeb ? 2000 : 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: _isWeb ? 1.03 : 1.05, // Reduce motion on web for performance
    ).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Initialize quantity
    _initializeQuantity();
  }

  void _initializeQuantity() {
    _currentQuantity = (widget.reminder.exerciseCount > 0
            ? widget.reminder.exerciseCount
            : _getDefaultQuantity())
        .clamp(
      widget.reminder.minQuantity.toDouble(),
      widget.reminder.maxQuantity.toDouble(),
    );
    _isInitialized = true;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  int _getDefaultQuantity() {
    switch (widget.reminder.type) {
      case ReminderType.pullUps:
        return 8;
      case ReminderType.pushUps:
        return 15;
      case ReminderType.squats:
        return 10;
      case ReminderType.jumpingJacks:
        return 15;
      case ReminderType.planks:
        return 30;
      case ReminderType.burpees:
        return 5;
      case ReminderType.water:
        return 300;
      case ReminderType.eyeRest:
        return 30;
      case ReminderType.standUp:
        return 3;
      case ReminderType.stretch:
      case ReminderType.stretching:
        return 5;
      case ReminderType.exercise:
        return 10;
      case ReminderType.custom:
        return ((widget.reminder.minQuantity + widget.reminder.maxQuantity) / 2)
            .round();
    }
  }

  bool _hasQuantity() {
    return widget.reminder.type != ReminderType.custom ||
        widget.reminder.maxQuantity > widget.reminder.minQuantity;
  }

  String _getQuantityUnit() {
    switch (widget.reminder.type) {
      case ReminderType.pullUps:
      case ReminderType.pushUps:
      case ReminderType.squats:
      case ReminderType.jumpingJacks:
      case ReminderType.burpees:
      case ReminderType.exercise:
        return 'reps';
      case ReminderType.planks:
      case ReminderType.eyeRest:
        return 'seconds';
      case ReminderType.water:
        return 'ml';
      case ReminderType.standUp:
      case ReminderType.stretch:
      case ReminderType.stretching:
        return 'minutes';
      case ReminderType.custom:
        return widget.reminder.unit;
    }
  }

  String _getMotivationalMessage() {
    switch (widget.reminder.type) {
      case ReminderType.eyeRest:
        return '👀 Give your eyes a break!\nLook at something 20 feet away.';
      case ReminderType.standUp:
        return '🚶 Time to stand and stretch!\nGet your blood flowing.';
      case ReminderType.pullUps:
        return '💪 Build your upper body strength!\nYou\'ve got this!';
      case ReminderType.pushUps:
        return '💪 Push yourself to be stronger!\nEvery rep counts!';
      case ReminderType.squats:
        return '🏋️ Strengthen those legs!\nSquat your way to health!';
      case ReminderType.jumpingJacks:
        return '⭐ Get your heart pumping!\nJumping jacks boost energy!';
      case ReminderType.planks:
        return '💪 Core power time!\nHold strong, build strength!';
      case ReminderType.burpees:
        return '🔥 Full body burn!\nPush your limits!';
      case ReminderType.water:
        return '💧 Stay hydrated, stay healthy!\nYour body will thank you.';
      case ReminderType.stretch:
      case ReminderType.stretching:
        return '🤸 Keep your muscles flexible!\nPrevent stiffness.';
      case ReminderType.exercise:
        return '💪 Time to exercise!\nKeep your body moving!';
      case ReminderType.custom:
        return '⚡ Time for ${widget.reminder.title}!\n${widget.reminder.description}';
    }
  }

  @override
  Widget build(BuildContext context) {
    // OPTIMIZATION: Only rebuild this card when its notification state changes
    return ValueListenableBuilder<String?>(
      valueListenable: widget.reminderService.activeNotificationId,
      builder: (context, activeId, child) {
        final isNotifying = activeId == widget.reminder.id;

        // Start/stop pulse animation based on notification state
        if (isNotifying && !_pulseController.isAnimating) {
          _pulseController.repeat(reverse: true);
          // Haptic feedback only on mobile (not on web)
          if (!_isWeb) {
            HapticFeedback.mediumImpact();
          }
        } else if (!isNotifying && _pulseController.isAnimating) {
          _pulseController.stop();
          _pulseController.reset();
        }

        return _buildCard(isNotifying);
      },
    );
  }

  Widget _buildCard(bool isNotifying) {
    final timeRemaining = _getTimeRemaining();
    final isRunning = widget.reminder.isEnabled &&
        widget.reminderService.isRunning &&
        timeRemaining != null;

    // OPTIMIZATION: Conditional rendering - different widget trees for each mode
    if (isNotifying) {
      return _buildNotificationMode();
    } else {
      return _buildNormalMode(isRunning, timeRemaining);
    }
  }

  /// NOTIFICATION MODE: Expanded card with actions
  Widget _buildNotificationMode() {
    return RepaintBoundary(
      key: widget.cardKey,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) => Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: widget.themeService.cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.reminder.color.withValues(alpha: 0.6),
                width: 3,
              ),
              gradient: LinearGradient(
                colors: [
                  widget.reminder.color.withValues(alpha: 0.15),
                  widget.reminder.color.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.reminder.color.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: widget.reminder.color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.reminder.color.withValues(alpha: 0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.reminder.icon,
                    size: 56,
                    color: widget.reminder.color,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  widget.reminder.title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: widget.reminder.color,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Motivational message
                Text(
                  _getMotivationalMessage(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: widget.themeService.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Quantity selector
                if (_hasQuantity()) ...[
                  const SizedBox(height: 24),
                  _buildQuantitySelector(),
                ],

                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        label: 'Skip',
                        icon: Icons.close_rounded,
                        isPrimary: false,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.reminderService.skipActiveNotification();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _buildActionButton(
                        label: 'Done!',
                        icon: Icons.check_rounded,
                        isPrimary: true,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          widget.reminderService.completeActiveNotification(
                            _currentQuantity.round(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    final unit = _getQuantityUnit();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.reminder.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.reminder.color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'How much?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: widget.reminder.color,
            ),
          ),
          const SizedBox(height: 20),

          // Current value display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: widget.reminder.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentQuantity.round()} $unit',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: widget.reminder.color,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: widget.reminder.color,
              inactiveTrackColor: widget.reminder.color.withValues(alpha: 0.3),
              thumbColor: widget.reminder.color,
              overlayColor: widget.reminder.color.withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
              trackHeight: 8,
            ),
            child: Slider(
              value: _currentQuantity.clamp(
                widget.reminder.minQuantity.toDouble(),
                widget.reminder.maxQuantity.toDouble(),
              ),
              min: widget.reminder.minQuantity.toDouble(),
              max: widget.reminder.maxQuantity.toDouble(),
              divisions: ((widget.reminder.maxQuantity -
                          widget.reminder.minQuantity) /
                      widget.reminder.stepSize)
                  .round(),
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
                '${widget.reminder.minQuantity} $unit',
                style: TextStyle(
                  fontSize: 13,
                  color: widget.reminder.color.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${widget.reminder.maxQuantity} $unit',
                style: TextStyle(
                  fontSize: 13,
                  color: widget.reminder.color.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isPrimary
          ? widget.reminder.color
          : widget.reminder.color.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(16),
      elevation: isPrimary ? 4 : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : widget.reminder.color,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : widget.reminder.color,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// NORMAL MODE: Compact card with swipe actions
  Widget _buildNormalMode(bool isRunning, Duration? timeRemaining) {
    return AccessibilityUtils.createKeyboardNavigable(
      focusLabel:
          '${widget.reminder.title} reminder card, ${widget.reminder.isEnabled ? "enabled" : "disabled"}',
      onActivate: () =>
          widget.reminderService.toggleReminder(widget.reminder.id),
      onSpace: () => widget.reminderService.toggleReminder(widget.reminder.id),
      onEnter: () => _showTimerChangeDialog(context),
      child: Semantics(
        label:
            '${widget.reminder.title} reminder, ${widget.reminder.isEnabled ? "enabled" : "disabled"}',
        hint: isRunning
            ? 'Next reminder in ${AccessibilityUtils.formatDurationForA11y(timeRemaining)}. Swipe right to complete, left to snooze 10 minutes.'
            : 'Double tap to toggle reminder, press enter to change timer, swipe for actions',
        button: true,
        child: Dismissible(
          key: Key('swipe_${widget.reminder.id}'),
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
            HapticFeedback.mediumImpact();

            if (direction == DismissDirection.startToEnd) {
              widget.reminderService.completeReminder(widget.reminder);
              _showActionFeedback(
                context,
                'Completed ${widget.reminder.title}!',
                Colors.green,
              );
            } else if (direction == DismissDirection.endToStart) {
              _snoozeReminder(10);
              _showActionFeedback(
                context,
                'Snoozed for 10 minutes',
                Colors.orange,
              );
            }
            return false;
          },
          child: _buildReminderCard(context, isRunning, timeRemaining),
        ),
      ),
    );
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
          color: widget.reminder.isEnabled
              ? widget.themeService.cardColor
              : widget.themeService.cardColor.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isRunning
                ? widget.reminder.color.withValues(alpha: 0.6)
                : widget.reminder.isEnabled
                    ? widget.reminder.color.withValues(alpha: 0.2)
                    : widget.themeService.borderColor.withValues(alpha: 0.5),
            width: isRunning ? 2.5 : 2,
          ),
          gradient: isRunning && widget.reminder.isEnabled
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
              color: isRunning
                  ? widget.reminder.color.withValues(alpha: 0.2)
                  : widget.themeService.shadowColor,
              blurRadius: isRunning ? 20 : 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (isRunning && widget.reminder.isEnabled)
              Positioned(
                top: 0,
                right: 0,
                child: PulsingDot(color: widget.reminder.color, size: 10),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isRunning
                            ? widget.reminder.color.withValues(alpha: 0.2)
                            : widget.reminder.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isRunning
                            ? [
                                BoxShadow(
                                  color: widget.reminder.color
                                      .withValues(alpha: 0.3),
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
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.reminderService
                              .toggleReminder(widget.reminder.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: widget.reminder.isEnabled
                                ? widget.reminder.color.withValues(alpha: 0.15)
                                : Colors.grey.withValues(alpha: 0.1),
                            border: Border.all(
                              color: widget.reminder.isEnabled
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
                                color: widget.reminder.isEnabled
                                    ? widget.reminder.color
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.reminder.isEnabled ? 'Ein' : 'Aus',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: widget.reminder.isEnabled
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
                Row(
                  children: [
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
                              color: widget.reminder.color
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: widget.reminder.color
                                    .withValues(alpha: 0.2),
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
                                  color: widget.reminder.color
                                      .withValues(alpha: 0.7),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
                              color:
                                  widget.reminder.color.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PulsingDot(
                                      color: widget.reminder.color, size: 6),
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
                if (isRunning && timeRemaining != null) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _getProgressValue(timeRemaining),
                    backgroundColor:
                        widget.reminder.color.withValues(alpha: 0.1),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(widget.reminder.color),
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
    widget.reminderService
        .snoozeReminder(widget.reminder, Duration(minutes: minutes));
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
                child: Icon(widget.reminder.icon,
                    color: widget.reminder.color, size: 20),
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
                  children: timerOptions.map((minutes) {
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
                            color: isSelected
                                ? widget.reminder.color.withValues(alpha: 0.2)
                                : widget.themeService.isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? widget.reminder.color
                                  : widget.themeService.borderColor,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            _formatDuration(duration),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
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
                    color: widget.themeService.isDarkMode
                        ? Colors.blue.withValues(alpha: 0.1)
                        : Colors.blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 8),
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
}
