import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../l10n/app_localizations.dart';

class InAppNotificationService {
  static final InAppNotificationService _instance =
      InAppNotificationService._internal();
  factory InAppNotificationService() => _instance;
  InAppNotificationService._internal();

  // Global key to access the navigator
  GlobalKey<NavigatorState>? navigatorKey;

  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
  }

  Future<void> showReminderDialog(
    Reminder reminder,
    Function(int) onResponse,
  ) async {
    if (navigatorKey?.currentContext == null) return;

    final context = navigatorKey!.currentContext!;

    // Show the reminder dialog
    final result = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext dialogContext) => ReminderDialog(reminder: reminder),
    );

    onResponse(result ?? 0); // 0 means dismissed/skipped
  }
}

class ReminderDialog extends StatefulWidget {
  final Reminder reminder;

  const ReminderDialog({super.key, required this.reminder});

  @override
  State<ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late double _currentQuantity;
  late double _minQuantity;
  late double _maxQuantity;
  late double _quantityStep;

  @override
  void initState() {
    super.initState();

    // Initialize quantity values based on reminder's dynamic properties
    _minQuantity = widget.reminder.minQuantity.toDouble();
    _maxQuantity = widget.reminder.maxQuantity.toDouble();
    _quantityStep = widget.reminder.stepSize.toDouble();

    // Set current quantity with validation to ensure it's within bounds
    double initialQuantity =
        widget.reminder.exerciseCount > 0
            ? widget.reminder.exerciseCount.toDouble()
            : _getDefaultQuantity(widget.reminder.type).toDouble();
    _currentQuantity = initialQuantity.clamp(_minQuantity, _maxQuantity);

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scaleController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.reminder.color.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.reminder.color.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated icon
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder:
                        (context, child) => Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: widget.reminder.color.withValues(
                                alpha: 0.2,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: widget.reminder.color.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.reminder.icon,
                              size: 48,
                              color: widget.reminder.color,
                            ),
                          ),
                        ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    widget.reminder.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: widget.reminder.color,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    _getMotivationalMessage(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  if (_hasQuantity(widget.reminder.type)) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: widget.reminder.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${_currentQuantity.round()} ${_getQuantityUnit(widget.reminder.type)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: widget.reminder.color,
                        ),
                      ),
                    ),
                  ],

                  if (_hasQuantity(widget.reminder.type)) ...[
                    const SizedBox(height: 20),
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
                          onTap:
                              () => Navigator.of(
                                context,
                              ).pop(0), // 0 means skipped
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildActionButton(
                          label: AppLocalizations.of(context)?.done ?? 'Done!',
                          icon: Icons.check_rounded,
                          isPrimary: true,
                          onTap:
                              () => Navigator.of(
                                context,
                              ).pop(_currentQuantity.round()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
        return 1; // 1 plank (duration based)
      case ReminderType.burpees:
        return 5;
      case ReminderType.water:
        return 300; // ml
      case ReminderType.eyeRest:
        return 30; // seconds
      case ReminderType.standUp:
        return 3; // minutes
      case ReminderType.stretch:
        return 5; // minutes
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
        type == ReminderType.stretch;
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
        return 'minutes';
      case ReminderType.custom:
        return widget.reminder.unit; // Use dynamic unit
    }
  }

  Widget _buildQuantitySelector() {
    final unit = _getQuantityUnit(widget.reminder.type);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.reminder.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.reminder.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)?.exerciseCount ?? 'How much?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: widget.reminder.color,
            ),
          ),
          const SizedBox(height: 16),

          // Current value display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: widget.reminder.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentQuantity.round()} $unit',
              style: TextStyle(
                fontSize: 20,
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
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              trackHeight: 6,
              valueIndicatorColor: widget.reminder.color,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Slider(
              value: _currentQuantity.clamp(_minQuantity, _maxQuantity),
              min: _minQuantity,
              max: _maxQuantity,
              divisions:
                  ((_maxQuantity - _minQuantity) / _quantityStep).round(),
              label: '${_currentQuantity.round()} $unit',
              onChanged: (value) {
                setState(() {
                  _currentQuantity = value.clamp(_minQuantity, _maxQuantity);
                });
              },
            ),
          ),

          // Min/Max labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_minQuantity.round()} $unit',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.reminder.color.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_maxQuantity.round()} $unit',
                style: TextStyle(
                  fontSize: 12,
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
      color:
          isPrimary
              ? widget.reminder.color
              : widget.reminder.color.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : widget.reminder.color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : widget.reminder.color,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMotivationalMessage() {
    switch (widget.reminder.type) {
      case ReminderType.eyeRest:
        return '👀 Give your eyes a break!\nLook at something 20 feet away for 20 seconds.';
      case ReminderType.standUp:
        return '🚶‍♂️ Time to stand and stretch!\nGet your blood flowing for a few minutes.';
      case ReminderType.pullUps:
        return '💪 Build your upper body strength!\nYou\'ve got this!';
      case ReminderType.pushUps:
        return '💪 Push yourself to be stronger!\nEvery rep counts!';
      case ReminderType.squats:
        return '🏋️ Strengthen those legs!\nSquat your way to better health!';
      case ReminderType.jumpingJacks:
        return '⭐ Get your heart pumping!\nJumping jacks boost energy!';
      case ReminderType.planks:
        return '💪 Core power time!\nHold strong, build strength!';
      case ReminderType.burpees:
        return '🔥 Full body burn!\nPush your limits with burpees!';
      case ReminderType.water:
        return '💧 Stay hydrated, stay healthy!\nYour body will thank you.';
      case ReminderType.stretch:
        return '🤸‍♂️ Keep your muscles flexible!\nPrevent stiffness and tension.';
      case ReminderType.custom:
        return '⚡ Time for your ${widget.reminder.title.toLowerCase()}!\n${widget.reminder.description}';
    }
  }
}
