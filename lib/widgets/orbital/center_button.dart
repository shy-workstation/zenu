import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';

class CenterButton extends StatefulWidget {
  final bool isRunning;
  final int activeCount;
  final VoidCallback onToggle;
  final VoidCallback? onAdd;
  final VoidCallback? onClear;
  final double size;

  const CenterButton({
    super.key,
    required this.isRunning,
    required this.activeCount,
    required this.onToggle,
    this.onAdd,
    this.onClear,
    this.size = 90,
  });

  @override
  State<CenterButton> createState() => _CenterButtonState();
}

class _CenterButtonState extends State<CenterButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut),
    );
    _pulseCtrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    if (widget.isRunning) {
      _pulseCtrl.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant CenterButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !oldWidget.isRunning) {
      _pulseCtrl.repeat(reverse: true);
    } else if (!widget.isRunning && oldWidget.isRunning) {
      _pulseCtrl
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final toggleLabel = widget.isRunning
        ? (l?.pauseReminders ?? 'Pause reminders')
        : (l?.startReminders ?? 'Start reminders');
    final button = GestureDetector(
      onTapDown: (_) => _scaleCtrl.forward(),
      onTapUp: (_) {
        _scaleCtrl.reverse();
        HapticFeedback.mediumImpact();
        widget.onToggle();
      },
      onTapCancel: () => _scaleCtrl.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnim, _pulseAnim]),
        builder: (context, child) {
          final pulseT = (_pulseAnim.value - 1.0) / 0.04; // 0→1
          return Transform.scale(
            scale: _scaleAnim.value * _pulseAnim.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFF9CA24), Color(0xFFF0932B)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF9CA24).withValues(alpha: 0.4),
                    blurRadius: 24 + 6 * pulseT,
                    spreadRadius: 4 + 3 * pulseT,
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: Icon(
          widget.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 36,
        ),
      ),
    );

    final wrappedButton = Semantics(
      button: true,
      label: toggleLabel,
      child: Tooltip(message: toggleLabel, child: button),
    );

    final hasAdd = widget.onAdd != null;
    final hasClear = widget.onClear != null;

    if (!hasAdd && !hasClear) return wrappedButton;

    return SizedBox(
      width: widget.size + 18,
      height: widget.size + 18,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main button centered
          Positioned(
            left: 9,
            top: 9,
            child: wrappedButton,
          ),
          // "+" badge at top-right
          if (hasAdd)
            Positioned(
              right: 0,
              top: 0,
              child: Semantics(
                button: true,
                label: l?.addReminderTooltip ?? 'Add reminder',
                child: Tooltip(
                  message: l?.addReminderTooltip ?? 'Add reminder',
                  child: GestureDetector(
                    onTap: widget.onAdd,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Clear badge at bottom-left
          if (hasClear)
            Positioned(
              left: 0,
              bottom: 0,
              child: Semantics(
                button: true,
                label: l?.resetTimersTooltip ?? 'Reset timers',
                child: Tooltip(
                  message: l?.resetTimersTooltip ?? 'Reset timers',
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      widget.onClear!();
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context)
                            .colorScheme
                            .error
                            .withValues(alpha: 0.9),
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .error
                                .withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
