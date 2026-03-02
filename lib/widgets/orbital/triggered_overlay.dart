import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class TriggeredOverlay extends StatefulWidget {
  final Reminder reminder;
  final ReminderService service;
  final List<Reminder> stillRunning;
  final VoidCallback onDismiss;

  const TriggeredOverlay({
    super.key,
    required this.reminder,
    required this.service,
    required this.stillRunning,
    required this.onDismiss,
  });

  @override
  State<TriggeredOverlay> createState() => _TriggeredOverlayState();
}

class _TriggeredOverlayState extends State<TriggeredOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late double _qty;

  @override
  void initState() {
    super.initState();
    _qty = (widget.reminder.exerciseCount > 0
        ? widget.reminder.exerciseCount
        : widget.reminder.stepSize).toDouble();
    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _done() {
    HapticFeedback.mediumImpact();
    widget.onDismiss();
    widget.service.completeReminder(widget.reminder, customCount: _qty.round());
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reminder;
    final l = AppLocalizations.of(context);

    return Material(
      color: Colors.black.withValues(alpha: 0.88),
      child: SafeArea(
        child: Stack(
          children: [
            // Close button top-right
            Positioned(
              top: 8,
              right: 8,
              child: _HoverScale(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: widget.onDismiss,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 22,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
            // Main content
            Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            // Pulsing icon
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (context, child) => Transform.scale(
                scale: _pulseAnim.value,
                child: child,
              ),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: r.color,
                  boxShadow: [
                    BoxShadow(
                      color: r.color.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(r.icon, size: 48, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              r.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              r.description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Quantity slider
            if (r.maxQuantity > 1) ...[
              Text(
                '${_qty.round()} ${r.unit}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: r.color,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
                    thumbColor: r.color,
                    overlayColor: r.color.withValues(alpha: 0.2),
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                    ),
                  ),
                  child: Slider(
                    value: _qty,
                    min: r.minQuantity.toDouble(),
                    max: r.maxQuantity.toDouble(),
                    divisions: ((r.maxQuantity - r.minQuantity) / r.stepSize).round(),
                    onChanged: (v) => setState(() => _qty = v),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${r.minQuantity} ${r.unit}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${r.maxQuantity} ${r.unit}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
            // Done button
            _HoverScale(
              child: FilledButton.icon(
                onPressed: _done,
                icon: const Icon(Icons.check, size: 20),
                label: Text(l?.doneButton ?? 'Done'),
                style: FilledButton.styleFrom(
                  backgroundColor: r.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Still running list
            if (widget.stillRunning.isNotEmpty) ...[
              Text(
                l?.stillRunning ?? 'Still running',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: widget.stillRunning.map((sr) {
                  final diff = sr.nextReminder?.difference(DateTime.now());
                  final label = diff != null && !diff.isNegative
                      ? '${diff.inMinutes}m'
                      : (l?.due ?? 'due');
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(sr.icon, size: 14, color: sr.color),
                        const SizedBox(width: 4),
                        Text(
                          label,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
            const Spacer(flex: 3),
          ],
        ),
          ],
        ),
      ),
    );
  }
}

