import 'package:flutter/material.dart';

import '../../domain/care_activity.dart';
import '../../l10n/app_localizations.dart';
import '../zenu_theme.dart';

/// Bottom sheet for logging a care moment with a quantity: slider for the
/// normal range, tap the number to type any value.
Future<int?> showCareSheet(BuildContext context, CareActivity activity) {
  return showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => _CareSheet(activity: activity),
  );
}

class _CareSheet extends StatefulWidget {
  final CareActivity activity;

  const _CareSheet({required this.activity});

  @override
  State<_CareSheet> createState() => _CareSheetState();
}

class _CareSheetState extends State<_CareSheet> {
  late int qty = widget.activity.goalQty;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activity = widget.activity;
    final color = ZenuColors.forKind(activity.kind);
    final divisions =
        ((activity.maxQty - activity.minQty) / activity.stepQty).round();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(ZenuColors.iconForKind(activity.kind), color: color),
                const SizedBox(width: 10),
                Text(
                  l10n.v2HowMuch,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _typeExactValue,
                child: Text(
                  '$qty ${activity.unit}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ),
            Slider(
              value: qty
                  .clamp(activity.minQty, activity.maxQty)
                  .toDouble(),
              min: activity.minQty.toDouble(),
              max: activity.maxQty.toDouble(),
              divisions: divisions > 0 ? divisions : null,
              activeColor: color,
              onChanged: (value) => setState(() => qty = value.round()),
            ),
            const SizedBox(height: 8),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: color),
              onPressed: () => Navigator.of(context).pop(qty),
              child: Text(l10n.v2Log),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _typeExactValue() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: '$qty');
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.v2HowMuch),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(suffixText: widget.activity.unit),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.v2Cancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(int.tryParse(controller.text)),
            child: Text(l10n.v2Log),
          ),
        ],
      ),
    );
    if (result != null && result > 0) {
      setState(() => qty = result);
    }
  }
}
