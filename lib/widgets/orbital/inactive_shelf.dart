import 'dart:math';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/reminder.dart';

class InactiveShelf extends StatelessWidget {
  final List<Reminder> inactiveReminders;
  final void Function(String) onActivate;

  const InactiveShelf({
    super.key,
    required this.inactiveReminders,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: inactiveReminders.isEmpty ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 250),
      child: inactiveReminders.isEmpty
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)?.inactive ?? 'Inactive',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.4),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 14,
                    runSpacing: 8,
                    children: inactiveReminders
                        .map((r) => _InactiveChip(
                              reminder: r,
                              onTap: () => onActivate(r.id),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
    );
  }
}

class _InactiveChip extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onTap;

  const _InactiveChip({required this.reminder, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: AppLocalizations.of(context)?.tapToEnable(reminder.title) ?? '${reminder.title} — tap to enable',
        child: CustomPaint(
          painter: _DashedCirclePainter(
            color: reminder.color.withValues(alpha: 0.4),
          ),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: Icon(
              reminder.icon,
              size: 24,
              color: reminder.color.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;

  _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;
    const dashCount = 12;
    const dashArc = (2 * pi) / dashCount * 0.6;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = (2 * pi / dashCount) * i;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashArc,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter oldDelegate) =>
      color != oldDelegate.color;
}
