import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../l10n/app_localizations.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';
import '../services/theme_service.dart';
import '../utils/global_timer_service.dart';
import '../utils/state_management.dart';
import '../widgets/empty_state.dart';
import '../widgets/orbital/orbital_field.dart';
import '../widgets/orbital/inactive_shelf.dart';
import '../widgets/orbital/edit_drawer.dart';
import '../widgets/orbital/triggered_overlay.dart';
import '../widgets/floating_pill.dart';
import '../widgets/quick_add_dialogs.dart';
import 'statistics_screen.dart';

class OrbitalHomeScreen extends StatefulWidget {
  final ReminderService? reminderService;
  final ThemeService? themeService;

  const OrbitalHomeScreen({
    super.key,
    this.reminderService,
    this.themeService,
  });

  @override
  State<OrbitalHomeScreen> createState() => _OrbitalHomeScreenState();
}

class _OrbitalHomeScreenState extends State<OrbitalHomeScreen> {
  String? _clockTimerSubscriptionId;
  DateTime _currentTime = DateTime.now();
  String? _triggeredId;

  @override
  void initState() {
    super.initState();
    _startClockTimer();
  }

  @override
  void dispose() {
    if (_clockTimerSubscriptionId != null) {
      GlobalTimerService.instance.unsubscribe(_clockTimerSubscriptionId!);
      _clockTimerSubscriptionId = null;
    }
    super.dispose();
  }

  void _startClockTimer() {
    _clockTimerSubscriptionId = GlobalTimerService.instance.subscribe(
      const Duration(seconds: 1),
      () {
        if (mounted) {
          setState(() {
            _currentTime = DateTime.now();
          });
          _checkTriggered();
        }
      },
      id: 'orbital_home_clock',
    );
  }

  void _checkTriggered() {
    final service = widget.reminderService ??
        Provider.of<ReminderService>(context, listen: false);

    // Auto-dismiss if current triggered reminder is no longer past due
    if (_triggeredId != null) {
      final r = service.reminders
          .cast<Reminder?>()
          .firstWhere((r) => r?.id == _triggeredId, orElse: () => null);
      if (r == null ||
          !r.isEnabled ||
          r.nextReminder == null ||
          !_currentTime.isAfter(r.nextReminder!)) {
        setState(() => _triggeredId = null);
        // Fall through to check for new triggers
      } else {
        return; // Still triggered, keep showing
      }
    }

    if (!service.isRunning) return;

    for (final r in service.reminders) {
      if (r.isEnabled &&
          r.nextReminder != null &&
          _currentTime.isAfter(r.nextReminder!)) {
        setState(() => _triggeredId = r.id);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Consumer<ReminderService>(
          builder: (context, service, child) {
            final activeReminders =
                service.reminders.where((r) => r.isEnabled).toList();
            final inactiveReminders =
                service.reminders.where((r) => !r.isEnabled).toList();
            final triggeredReminder = _triggeredId != null
                ? service.reminders
                    .cast<Reminder?>()
                    .firstWhere((r) => r?.id == _triggeredId, orElse: () => null)
                : null;

            if (_triggeredId != null && triggeredReminder == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _triggeredId = null);
              });
            }

            return Scaffold(
              backgroundColor: themeService.backgroundColor,
              appBar: AppBar(
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icon/app_icon_zenu_300.svg',
                      height: 32,
                      width: 32,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AppLocalizations.of(context)?.appTitle ?? 'Zenu',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: themeService.textPrimary,
                      ),
                    ),
                  ],
                ),
                backgroundColor: themeService.cardColor,
                foregroundColor: themeService.textPrimary,
                elevation: 0,
                shadowColor: themeService.shadowColor,
                surfaceTintColor: Colors.transparent,
                toolbarHeight: 64,
                actions: [
                  // Statistics button
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StatisticsScreen(),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.bar_chart,
                            color: themeService.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Theme cycle button
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: Semantics(
                      label: _themeLabel(themeService),
                      hint: AppLocalizations.of(context)?.doubleTapToCycleTheme ?? 'Double tap to cycle theme',
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => themeService.cycleTheme(),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              _themeIcon(themeService),
                              color: themeService.textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              body: service.reminders.isEmpty
                  ? EmptyState(
                      onAddReminder: () =>
                          QuickAddDialogs.showTemplatePicker(
                        context,
                        service,
                      ),
                      primaryColor: const Color(0xFF6366F1),
                    )
                  : Stack(
                      children: [
                        // Main orbital layout
                        Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: OrbitalField(
                                  activeReminders: activeReminders,
                                  isRunning: service.isRunning,
                                  currentTime: _currentTime,
                                  onToggleRunning: () {
                                    if (service.isRunning) {
                                      service.stopReminders();
                                    } else {
                                      service.startReminders();
                                    }
                                  },
                                  onTapBubble: (r) => _onTapBubble(r, service),
                                  onLongPressBubble: (r) =>
                                      _showEditDialog(r, service),
                                  onAddReminder: () => _onAddReminder(service),
                                  onClearTimers: () {
                                    service.clearTimers();
                                    FloatingPill.info(
                                      context,
                                      AppLocalizations.of(context)
                                              ?.timersReset ??
                                          'Timers reset',
                                    );
                                  },
                                ),
                              ),
                            ),
                            // Inactive shelf
                            InactiveShelf(
                              inactiveReminders: inactiveReminders,
                              onActivate: (id) => service.toggleReminder(id),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                        // Triggered overlay
                        if (triggeredReminder != null)
                          Positioned.fill(
                            child: TriggeredOverlay(
                              reminder: triggeredReminder,
                              service: service,
                              stillRunning: activeReminders
                                  .where((r) =>
                                      r.id != triggeredReminder.id &&
                                      r.isEnabled &&
                                      r.nextReminder != null &&
                                      !_currentTime.isAfter(r.nextReminder!))
                                  .toList(),
                              onDismiss: () =>
                                  setState(() => _triggeredId = null),
                            ),
                          ),
                      ],
                    ),
            );
          },
        );
      },
    );
  }

  void _onTapBubble(Reminder r, ReminderService service) {
    if (service.isRunning &&
        r.isEnabled &&
        r.nextReminder != null &&
        _currentTime.isAfter(r.nextReminder!)) {
      // Show triggered overlay for due reminders
      setState(() => _triggeredId = r.id);
    } else {
      // Always open edit modal
      _showEditDialog(r, service);
    }
  }

  void _showEditDialog(Reminder r, ReminderService service) {
    EditReminderDialog.show(context, r, service);
  }

  void _onAddReminder(ReminderService service) {
    final countBefore = service.reminders.length;
    QuickAddDialogs.showTemplatePicker(context, service).then((_) {
      if (service.reminders.length > countBefore) {
        _showEditDialog(service.reminders.last, service);
      }
    });
  }

  IconData _themeIcon(ThemeService themeService) {
    switch (themeService.themeMode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  String _themeLabel(ThemeService themeService) {
    final l = AppLocalizations.of(context);
    switch (themeService.themeMode) {
      case ThemeMode.system:
        return l?.themeSystem ?? 'Theme: System';
      case ThemeMode.light:
        return l?.themeLight ?? 'Theme: Light';
      case ThemeMode.dark:
        return l?.themeDark ?? 'Theme: Dark';
    }
  }
}
