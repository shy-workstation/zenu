import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A subtle, minimal floating pill notification that appears briefly
/// Much less intrusive than traditional snackbars
class FloatingPill {
  static OverlayEntry? _currentEntry;

  /// Shows a floating pill notification
  ///
  /// [context] - Build context
  /// [icon] - Icon to display (e.g., Icons.check)
  /// [message] - Short message (keep under 20 chars for best results)
  /// [color] - Background color of the pill
  /// [duration] - How long to show (default 1.5 seconds)
  /// [position] - Where to show: 'top', 'center', or 'bottom' (default 'top')
  /// [haptic] - Whether to trigger haptic feedback (default true)
  static void show(
    BuildContext context, {
    required IconData icon,
    required String message,
    Color? color,
    Duration duration = const Duration(milliseconds: 1500),
    String position = 'top',
    bool haptic = true,
  }) {
    // Dismiss any existing pill
    _currentEntry?.remove();
    _currentEntry = null;

    // Haptic feedback
    if (haptic) {
      HapticFeedback.lightImpact();
    }

    final overlay = Overlay.of(context);
    final pillColor = color ?? Theme.of(context).primaryColor;

    _currentEntry = OverlayEntry(
      builder: (context) => _FloatingPillWidget(
        icon: icon,
        message: message,
        color: pillColor,
        duration: duration,
        position: position,
        onDismiss: () {
          _currentEntry?.remove();
          _currentEntry = null;
        },
      ),
    );

    overlay.insert(_currentEntry!);
  }

  /// Convenience method for success feedback
  static void success(BuildContext context, String message, {Color? color}) {
    show(
      context,
      icon: Icons.check_rounded,
      message: message,
      color: color ?? const Color(0xFF10B981),
    );
  }

  /// Convenience method for info feedback
  static void info(BuildContext context, String message, {Color? color}) {
    show(
      context,
      icon: Icons.info_outline_rounded,
      message: message,
      color: color ?? const Color(0xFF3B82F6),
    );
  }

  /// Convenience method for warning feedback
  static void warning(BuildContext context, String message) {
    show(
      context,
      icon: Icons.warning_amber_rounded,
      message: message,
      color: const Color(0xFFF59E0B),
    );
  }

  /// Dismiss current pill if showing
  static void dismiss() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _FloatingPillWidget extends StatefulWidget {
  final IconData icon;
  final String message;
  final Color color;
  final Duration duration;
  final String position;
  final VoidCallback onDismiss;

  const _FloatingPillWidget({
    required this.icon,
    required this.message,
    required this.color,
    required this.duration,
    required this.position,
    required this.onDismiss,
  });

  @override
  State<_FloatingPillWidget> createState() => _FloatingPillWidgetState();
}

class _FloatingPillWidgetState extends State<_FloatingPillWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Start animation
    _controller.forward();

    // Auto dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;

    double topPosition;
    switch (widget.position) {
      case 'center':
        topPosition = screenSize.height / 2 - 20;
        break;
      case 'bottom':
        topPosition = screenSize.height - 150;
        break;
      case 'top':
      default:
        topPosition = topPadding + 60;
    }

    return Positioned(
      top: topPosition,
      left: 0,
      right: 0,
      child: Center(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
