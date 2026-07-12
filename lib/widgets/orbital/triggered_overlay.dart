import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../models/reminder.dart';
import '../../services/reminder_service.dart';

Future<int?> _promptNumber(
  BuildContext context, {
  required String title,
  required int initial,
  required int min,
  int? max,
  String? unit,
  Color? accentColor,
}) {
  final ctrl = TextEditingController(text: initial.toString());
  ctrl.selection = TextSelection(baseOffset: 0, extentOffset: ctrl.text.length);

  int? parse() {
    final v = int.tryParse(ctrl.text.trim());
    if (v == null) return null;
    if (v < min) return null;
    if (max != null && v > max) return null;
    return v;
  }

  return showDialog<int>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: false,
            signed: false,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
          decoration: InputDecoration(
            suffixText: unit,
            border: const OutlineInputBorder(),
            helperText: max != null ? '$min – $max' : '≥ $min',
          ),
          onSubmitted: (_) {
            final v = parse();
            if (v != null) Navigator.of(context).pop(v);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            style: accentColor != null
                ? FilledButton.styleFrom(backgroundColor: accentColor)
                : null,
            onPressed: () {
              final v = parse();
              if (v != null) Navigator.of(context).pop(v);
            },
            child: Text(AppLocalizations.of(context)?.doneButton ?? 'Done'),
          ),
        ],
      );
    },
  ).whenComplete(ctrl.dispose);
}

/// Maps a stored unit key to its localized short form. Falls back to the raw
/// value for custom units.
String localizedUnit(AppLocalizations? l, String unit) {
  switch (unit) {
    case 'reps':
      return l?.unitReps ?? unit;
    case 'sec':
      return l?.unitSec ?? unit;
    case 'min':
      return l?.unitMin ?? unit;
    case 'ml':
      return l?.unitMl ?? unit;
    case 'glasses':
      return l?.unitGlasses ?? unit;
    default:
      return unit;
  }
}

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
            : widget.reminder.stepSize)
        .toDouble();
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
            // Main content — scrollable so the Done button stays reachable on
            // short/landscape viewports and at large text scale.
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 56, 16, 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                              child:
                                  Icon(r.icon, size: 48, color: Colors.white),
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
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () async {
                                final entered = await _promptNumber(
                                  context,
                                  title: r.title,
                                  initial: _qty.round(),
                                  min: r.minQuantity < 1 ? 0 : r.minQuantity,
                                  unit: r.unit,
                                  accentColor: r.color,
                                );
                                if (entered != null) {
                                  setState(() => _qty = entered.toDouble());
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                child: Text(
                                  '${_qty.round()} ${localizedUnit(l, r.unit)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: SliderTheme(
                                data: SliderThemeData(
                                  activeTrackColor: r.color,
                                  inactiveTrackColor:
                                      Colors.white.withValues(alpha: 0.15),
                                  thumbColor: r.color,
                                  overlayColor: r.color.withValues(alpha: 0.2),
                                  trackHeight: 6,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 12,
                                  ),
                                ),
                                child: Slider(
                                  // Clamp so a typed value outside slider bounds still renders.
                                  value: _qty.clamp(
                                    r.minQuantity.toDouble(),
                                    r.maxQuantity.toDouble(),
                                  ),
                                  min: r.minQuantity.toDouble(),
                                  max: r.maxQuantity.toDouble(),
                                  divisions: ((r.maxQuantity - r.minQuantity) /
                                          r.stepSize)
                                      .round(),
                                  onChanged: (v) => setState(() => _qty = v),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${r.minQuantity} ${localizedUnit(l, r.unit)}',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.4),
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '${r.maxQuantity} ${localizedUnit(l, r.unit)}',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.4),
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
                                final diff =
                                    sr.nextReminder?.difference(DateTime.now());
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
                                          color: Colors.white
                                              .withValues(alpha: 0.8),
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
