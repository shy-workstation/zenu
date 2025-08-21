import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../generated/l10n/app_localizations.dart';

class EmptyState extends StatelessWidget {
  final VoidCallback onAddReminder;
  final Color primaryColor;

  const EmptyState({
    super.key,
    required this.onAddReminder,
    this.primaryColor = const Color(0xFF6366F1),
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated icon with gentle pulse
              TweenAnimationBuilder<double>(
                duration: const Duration(seconds: 2),
                tween: Tween(begin: 0.8, end: 1.0),
                curve: Curves.easeInOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor.withValues(alpha: 0.1),
                            primaryColor.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_none_outlined,
                        size: 120,
                        color: primaryColor.withValues(alpha: 0.6),
                      ),
                    ),
                  );
                },
                onEnd: () {
                  // Restart animation for continuous pulse (only in non-test environment)
                  if (!kIsWeb && !kDebugMode) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (context.mounted) {
                        (context as Element).markNeedsBuild();
                      }
                    });
                  }
                },
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
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // CTA Button with accessibility
              Semantics(
                label: localizations?.getStarted ?? 'Get Started',
                hint: 'Double tap to add your first health reminder',
                child: ElevatedButton.icon(
                  onPressed: onAddReminder,
                  icon: const Icon(Icons.add_circle_outline, size: 24),
                  label: Text(
                    localizations?.getStarted ?? 'Get Started',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: primaryColor.withValues(alpha: 0.3),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Quick start tips
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.blue, size: 24),
                    const SizedBox(height: 8),
                    Text(
                      'Quick Tips',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Start with 2-3 simple reminders\n• Use default intervals initially\n• Enable notifications for best results',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.withValues(alpha: 0.8),
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
