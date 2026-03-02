import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class EmptyState extends StatefulWidget {
  final VoidCallback onAddReminder;
  final Color primaryColor;

  const EmptyState({
    super.key,
    required this.onAddReminder,
    this.primaryColor = const Color(0xFF6366F1),
  });

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated icon with gentle pulse using safe AnimationController
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.primaryColor.withValues(alpha: 0.1),
                        widget.primaryColor.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_none_outlined,
                    size: 120,
                    color: widget.primaryColor.withValues(alpha: 0.6),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                localizations?.noRemindersTitle ?? 'No reminders yet',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                localizations?.noRemindersSubtitle ??
                    'Tap the + button to create your first healthy habit',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // CTA Button with accessibility
              Semantics(
                label: localizations?.getStarted ?? 'Get Started',
                hint: localizations?.doubleTapToAddReminder ?? 'Double tap to add your first health reminder',
                child: ElevatedButton.icon(
                  onPressed: widget.onAddReminder,
                  icon: const Icon(Icons.add_circle_outline, size: 24),
                  label: Text(
                    localizations?.getStarted ?? 'Get Started',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: widget.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Quick start tips
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.primaryColor.withValues(alpha: isDark ? 0.1 : 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.primaryColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.lightbulb_outline, color: widget.primaryColor, size: 24),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)?.quickTips ?? 'Quick Tips',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: widget.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• ${AppLocalizations.of(context)?.startWithSimpleReminders ?? 'Start with 2-3 simple reminders'}\n• ${AppLocalizations.of(context)?.useDefaultIntervals ?? 'Use default intervals initially'}\n• ${AppLocalizations.of(context)?.enableNotifications ?? 'Enable notifications for best results'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: widget.primaryColor.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
