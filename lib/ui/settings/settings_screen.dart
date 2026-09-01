import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../l10n/app_localizations.dart';
import '../../services/care_service.dart';
import '../../services/theme_controller.dart';
import '../zenu_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static bool get _isDesktop =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  @override
  Widget build(BuildContext context) {
    final care = context.watch<CareService>();
    final themeController = context.watch<ThemeController>();
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
        children: [
          Text(
            l10n.v2Settings,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          if (care.notificationsAllowed == false)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: ListTile(
                leading: Icon(
                  Icons.notifications_off_outlined,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                title: Text(l10n.v2NotificationsOff),
                subtitle: Text(l10n.v2NotificationsOffHint),
                trailing: TextButton(
                  onPressed: () => care.refreshPermissionStatus(request: true),
                  child: Text(l10n.v2EnableNotifications),
                ),
              ),
            ),
          _section(l10n.v2Intervals),
          Card(
            child: Column(
              children: [
                for (final activity in care.state.activities)
                  _ActivityRow(care: care, activityId: activity.id),
              ],
            ),
          ),
          _section(l10n.v2Theme),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                      value: ThemeMode.system, label: Text(l10n.v2ThemeSystem)),
                  ButtonSegment(
                      value: ThemeMode.light, label: Text(l10n.v2ThemeLight)),
                  ButtonSegment(
                      value: ThemeMode.dark, label: Text(l10n.v2ThemeDark)),
                ],
                selected: {themeController.mode},
                onSelectionChanged: (selection) =>
                    themeController.setMode(selection.first),
              ),
            ),
          ),
          if (_isDesktop) ...[
            _section(l10n.v2Desktop),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(l10n.v2CloseToTray),
                    value: care.state.closeToTray,
                    onChanged: (value) => care.setCloseToTray(value),
                  ),
                  SwitchListTile(
                    title: Text(l10n.v2AlwaysOnTop),
                    value: care.state.alwaysOnTop,
                    onChanged: (value) async {
                      await care.setAlwaysOnTop(value);
                      try {
                        await windowManager.setAlwaysOnTop(value);
                      } catch (_) {}
                    },
                  ),
                  SwitchListTile(
                    title: Text(l10n.v2LaunchAtStartup),
                    value: care.state.launchAtStartup,
                    onChanged: (value) async {
                      await care.setLaunchAtStartup(value);
                      try {
                        if (value) {
                          await launchAtStartup.enable();
                        } else {
                          await launchAtStartup.disable();
                        }
                      } catch (_) {}
                    },
                  ),
                ],
              ),
            ),
          ],
          _section(l10n.v2DataSection),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.ios_share_outlined),
                  title: Text(l10n.v2ExportData),
                  onTap: () async {
                    final json = care.exportJson();
                    if (json == null) return;
                    await Clipboard.setData(ClipboardData(text: json));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.v2ExportCopied)),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error),
                  title: Text(
                    l10n.v2ClearAllData,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  onTap: () => _confirmClear(context, care, l10n),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
        child: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
      );

  Future<void> _confirmClear(
      BuildContext context, CareService care, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.v2ClearAllConfirmTitle),
        content: Text(l10n.v2ClearAllConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.v2Cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.v2Delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await care.clearAllData();
    }
  }
}

class _ActivityRow extends StatelessWidget {
  final CareService care;
  final String activityId;

  const _ActivityRow({required this.care, required this.activityId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activity =
        care.state.activities.firstWhere((a) => a.id == activityId);
    final label = switch (activity.kind) {
      'water' => l10n.v2ActivityWater,
      'eyeRest' => l10n.v2ActivityEyeRest,
      'move' => l10n.v2ActivityMove,
      'stretch' => l10n.v2ActivityStretch,
      'strength' => l10n.v2ActivityStrength,
      _ => activity.kind,
    };

    return Column(
      children: [
        SwitchListTile(
          secondary: Icon(
            ZenuColors.iconForKind(activity.kind),
            color: ZenuColors.forKind(activity.kind),
          ),
          title: Text(label),
          subtitle: Text(l10n.v2Every(activity.interval.inMinutes)),
          value: activity.enabled,
          onChanged: (value) => care.setActivityEnabled(activity.id, value),
        ),
        if (activity.enabled)
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 16),
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: activity.interval.inMinutes
                        .clamp(5, 240)
                        .toDouble(),
                    min: 5,
                    max: 240,
                    divisions: 47,
                    activeColor: ZenuColors.forKind(activity.kind),
                    onChanged: (value) => care.setActivityInterval(
                      activity.id,
                      Duration(minutes: value.round()),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _typeInterval(context, l10n),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      l10n.v2MinutesShort(activity.interval.inMinutes),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _typeInterval(BuildContext context, AppLocalizations l10n) async {
    final activity =
        care.state.activities.firstWhere((a) => a.id == activityId);
    final controller =
        TextEditingController(text: '${activity.interval.inMinutes}');
    final minutes = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.v2Intervals),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: 'min'),
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
    if (minutes != null && minutes >= 1) {
      await care.setActivityInterval(activity.id, Duration(minutes: minutes));
    }
  }
}
