import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../utils/state_management.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../l10n/app_localizations.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';
import '../services/theme_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/compact_stats_bar.dart';
import '../widgets/swipeable_reminder_card.dart';
import '../widgets/quick_add_dialogs.dart';
import 'statistics_screen.dart';
import 'reminder_management_screen.dart';

class HomeScreen extends StatefulWidget {
  final ReminderService? reminderService;
  final ThemeService? themeService;

  const HomeScreen({super.key, this.reminderService, this.themeService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  Timer? _clockTimer;
  DateTime _currentTime = DateTime.now();
  String? _lastAnnouncedReminder;
  final FocusNode _mainFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _startClockTimer();

    // Announce when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // AccessibilityUtils.announceFocusChange(
      //   context,
      //   'Health reminders home screen loaded',
      // );
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _mainFocusNode.dispose();
    super.dispose();
  }

  void _startClockTimer() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });

        // Announce upcoming reminders for accessibility
        _checkForUpcomingReminders();
      }
    });
  }

  void _checkForUpcomingReminders() {
    final reminderService = widget.reminderService;
    if (reminderService == null || !reminderService.isRunning) return;

    for (final reminder in reminderService.reminders) {
      if (reminder.isEnabled && reminder.nextReminder != null) {
        final timeUntil = reminder.nextReminder!.difference(_currentTime);

        // Announce 1 minute before reminder
        if (timeUntil.inSeconds == 60 &&
            _lastAnnouncedReminder != reminder.id) {
          // AccessibilityUtils.announce('${reminder.title} reminder in 1 minute');
          _lastAnnouncedReminder = reminder.id;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Consumer<ReminderService>(
          builder: (context, service, child) {
            return Scaffold(
              backgroundColor: themeService.backgroundColor,
              appBar: AppBar(
                title: Text(
                  AppLocalizations.of(context)?.appTitle ?? 'Zenu',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: themeService.textPrimary,
                  ),
                ),
                backgroundColor: themeService.cardColor,
                foregroundColor: themeService.textPrimary,
                elevation: 0,
                shadowColor: themeService.shadowColor,
                surfaceTintColor: Colors.transparent,
                toolbarHeight: 80,
                actions: [
                  // Management button with improved touch target
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Semantics(
                      label: 'Settings and reminder management',
                      hint: 'Double tap to open settings',
                      child: Material(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => Provider<ReminderService>(
                                      value: service,
                                      child: Provider<ThemeService>(
                                        value: themeService,
                                        child: const ReminderManagementScreen(),
                                      ),
                                    ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(
                              16,
                            ), // Increased from 12 to 16
                            child: const Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Theme toggle button with improved accessibility
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Semantics(
                      label:
                          themeService.isDarkMode
                              ? 'Switch to light mode'
                              : 'Switch to dark mode',
                      hint: 'Double tap to toggle theme',
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => themeService.toggleTheme(),
                          child: Container(
                            padding: const EdgeInsets.all(
                              16,
                            ), // Increased from 12 to 16
                            child: Icon(
                              themeService.isDarkMode
                                  ? Icons.light_mode
                                  : Icons.dark_mode,
                              color: themeService.textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: Material(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => Provider<ReminderService>(
                                    value: service,
                                    child: StatisticsScreen(
                                      reminderService: service,
                                    ),
                                  ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.analytics_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Analytics',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              body: Stack(
                children: [
                  // Main content
                  service.reminders.isEmpty
                      ? EmptyState(
                        onAddReminder:
                            () => _showQuickAddMenu(context, service),
                        primaryColor: const Color(0xFF6366F1),
                      )
                      : CustomScrollView(
                        slivers: [
                          // Top spacing
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 20),
                          ),
                          
                          // Reminders Grid with container box (stats moved to bottom)
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            sliver: SliverToBoxAdapter(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: themeService.isDarkMode 
                                      ? Colors.black.withValues(alpha: 0.2)
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: themeService.isDarkMode
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Responsive Grid Layout
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      // Strict 12-column responsive grid system
                                      int columns = 1;
                                      double maxWidth = constraints.maxWidth;

                                      // Desktop: 3 columns (1280px+)
                                      if (maxWidth >= 1200) {
                                        columns = 3;
                                      }
                                      // Tablet: 2 columns (768px - 1199px)
                                      else if (maxWidth >= 768) {
                                        columns = 2;
                                      }
                                      // Mobile: 1 column (< 768px)
                                      else {
                                        columns = 1;
                                      }

                                      const double spacing = 16.0;
                                      final double itemWidth =
                                          (maxWidth - (columns - 1) * spacing) /
                                          columns;

                                      // Create rows with equal-height cards
                                      final List<Widget> rows = [];
                                      final List<Reminder> reminders =
                                          service.reminders;

                                      for (
                                        int i = 0;
                                        i < reminders.length;
                                        i += columns
                                      ) {
                                        final rowItems = <Widget>[];

                                        for (int j = 0; j < columns; j++) {
                                          if (i + j < reminders.length) {
                                            rowItems.add(
                                              SizedBox(
                                                width: itemWidth,
                                                child: SwipeableReminderCard(
                                                  reminder: reminders[i + j],
                                                  reminderService: service,
                                                  themeService: themeService,
                                                  currentTime: _currentTime,
                                                ),
                                              ),
                                            );
                                          } else {
                                            // Empty placeholder for consistent grid
                                            rowItems.add(
                                              SizedBox(width: itemWidth),
                                            );
                                          }
                                        }

                                        rows.add(
                                          Padding(
                                            padding: EdgeInsets.only(
                                              bottom:
                                                  i + columns < reminders.length
                                                      ? 16
                                                      : 0,
                                            ),
                                            child: Row(
                                              children:
                                                  rowItems
                                                      .expand(
                                                        (widget) => [
                                                          widget,
                                                          if (widget !=
                                                              rowItems.last)
                                                            const SizedBox(
                                                              width: spacing,
                                                            ),
                                                        ],
                                                      )
                                                      .toList(),
                                            ),
                                          ),
                                        );
                                      }

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: rows,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            ),
                          ),
                          
                          // Bottom padding for gradient area
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 160),
                          ),
                        ],
                      ),

                  // Bottom gradient blur with start/stop button
                  if (service.reminders.isNotEmpty)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              themeService.backgroundColor.withValues(alpha: 0.0),
                              themeService.backgroundColor.withValues(alpha: 0.0),
                              themeService.backgroundColor.withValues(alpha: 0.7),
                              themeService.backgroundColor.withValues(alpha: 0.95),
                            ],
                            stops: const [0.0, 0.4, 0.7, 1.0],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Start/Stop Button
                            AnimatedScale(
                              duration: const Duration(milliseconds: 150),
                              scale: 1.0,
                              child: _buildSimpleStartStopButton(service),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
              floatingActionButton: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Stats button on the left
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: FloatingActionButton(
                        heroTag: "stats",
                        backgroundColor: const Color(0xFF8B5CF6),
                        onPressed: () {
                          _showStatsBottomSheet(context, service, themeService);
                        },
                        child: const Icon(Icons.bar_chart_rounded, color: Colors.white),
                      ),
                    ),
                    // Add reminder button on the right
                    SpeedDial(
                icon: Icons.add,
                activeIcon: Icons.close,
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                activeForegroundColor: Colors.white,
                activeBackgroundColor: Colors.grey[600],
                buttonSize: const Size(64, 64),
                iconTheme: const IconThemeData(size: 28),
                label:
                    service.reminders.isEmpty
                        ? Text(
                          AppLocalizations.of(context)?.addReminder ??
                              'Add Reminder',
                        )
                        : null,
                tooltip: 'Add health reminder',
                overlayColor: Colors.black,
                overlayOpacity: 0.4,
                children: [
                  SpeedDialChild(
                    child: const Icon(Icons.water_drop, color: Colors.white),
                    backgroundColor: const Color(0xFF06B6D4),
                    label:
                        AppLocalizations.of(context)?.waterReminder ??
                        'Water Reminder',
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                    onTap:
                        () => QuickAddDialogs.showWaterReminderDialog(
                          context,
                          service,
                        ),
                  ),
                  SpeedDialChild(
                    child: const Icon(
                      Icons.fitness_center,
                      color: Colors.white,
                    ),
                    backgroundColor: const Color(0xFFEF4444),
                    label:
                        AppLocalizations.of(context)?.exerciseReminder ??
                        'Exercise Reminder',
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                    onTap:
                        () => QuickAddDialogs.showExerciseReminderDialog(
                          context,
                          service,
                        ),
                  ),
                  SpeedDialChild(
                    child: const Icon(
                      Icons.remove_red_eye,
                      color: Colors.white,
                    ),
                    backgroundColor: const Color(0xFF3B82F6),
                    label:
                        AppLocalizations.of(context)?.eyeRestReminder ??
                        'Eye Rest Reminder',
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                    onTap:
                        () => QuickAddDialogs.showEyeRestReminderDialog(
                          context,
                          service,
                        ),
                  ),
                  SpeedDialChild(
                    child: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                    ),
                    backgroundColor: const Color(0xFF8B5CF6),
                    label:
                        AppLocalizations.of(context)?.customReminder ??
                        'Custom Reminder',
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                    onTap:
                        () => QuickAddDialogs.showCustomReminderDialog(
                          context,
                          service,
                        ),
                  ),
                  if (service.isRunning && service.reminders.isNotEmpty)
                    SpeedDialChild(
                      child: const Icon(Icons.science, color: Colors.white),
                      backgroundColor: Colors.orange,
                      label: 'Test Reminder',
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      onTap: () => _testNotification(service),
                    ),
                ],
              ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showStatsBottomSheet(BuildContext context, ReminderService service, ThemeService themeService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 200,
        decoration: BoxDecoration(
          color: themeService.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: themeService.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CompactStatsBar(
                reminderService: service,
                themeService: themeService,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _testNotification(ReminderService service) {
    // Test with the first enabled reminder
    final enabledReminders =
        service.reminders.where((r) => r.isEnabled).toList();
    if (enabledReminders.isNotEmpty) {
      service.triggerTestReminder(enabledReminders.first);
    }
  }

  void _showQuickAddMenu(BuildContext context, ReminderService service) {
    // This method is used by the empty state
    // The actual quick add is handled by the SpeedDial FAB
    // Could show a bottom sheet with reminder templates
  }

  Widget _buildSimpleStartStopButton(ReminderService service) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(20),
      shadowColor:
          service.isRunning
              ? const Color(0xFFEF4444).withValues(alpha: 0.2)
              : const Color(0xFF10B981).withValues(alpha: 0.2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                service.isRunning
                    ? [
                      const Color(0xFFEF4444), // Red gradient for stop
                      const Color(0xFFDC2626),
                    ]
                    : [
                      const Color(0xFF10B981), // Green gradient for start
                      const Color(0xFF059669),
                    ],
          ),
          boxShadow: [
            BoxShadow(
              color:
                  service.isRunning
                      ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                      : const Color(0xFF10B981).withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: 1.0,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTapDown: (_) {}, // Handled by AnimatedScale
            onTapCancel: () {}, // Handled by AnimatedScale
            onTap: () {
              // Haptic feedback for better user experience
              HapticFeedback.mediumImpact();
              if (service.isRunning) {
                service.stopReminders();
              } else {
                service.startReminders();
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    service.isRunning
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    service.isRunning
                        ? AppLocalizations.of(context)?.pauseSystem ?? 'PAUSE'
                        : AppLocalizations.of(context)?.startSystem ?? 'START',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
