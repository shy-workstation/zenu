import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/state_management.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../l10n/app_localizations.dart';
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

  // Animation controllers for the interactive button
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _energyController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _energyAnimation;

  @override
  void initState() {
    super.initState();
    _startClockTimer();

    // Initialize animation controllers
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3), // Slower, smoother pulse
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000), // Smoother glow
      vsync: this,
    );
    _energyController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05, // Reduced intensity for subtlety
    ).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _energyAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _energyController, curve: Curves.easeOutCirc),
    );

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
    _pulseController.dispose();
    _glowController.dispose();
    _energyController.dispose();
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
              body:
                  service.reminders.isEmpty
                      ? EmptyState(
                        onAddReminder:
                            () => _showQuickAddMenu(context, service),
                        primaryColor: const Color(0xFF6366F1),
                      )
                      : CustomScrollView(
                        slivers: [
                          // Morph Blob Control
                          SliverToBoxAdapter(
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                              child: Center(
                                child: _buildMorphBlobButton(service),
                              ),
                            ),
                          ),

                          // Compact Stats Bar
                          SliverToBoxAdapter(
                            child: CompactStatsBar(
                              reminderService: service,
                              themeService: themeService,
                            ),
                          ),

                          // Reminders Grid with enhanced cards
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            sliver: SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Section Header
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF10B981,
                                          ).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.notifications_active_rounded,
                                          color: Color(0xFF10B981),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Active Reminders',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: themeService.textPrimary,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                            Text(
                                              '${service.reminders.length} reminder${service.reminders.length == 1 ? '' : 's'} configured',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    themeService.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  // Responsive Grid Layout
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      // Calculate number of columns based on available width
                                      int columns = 1;
                                      if (constraints.maxWidth > 800) {
                                        columns = 3;
                                      } else if (constraints.maxWidth > 600) {
                                        columns = 2;
                                      }

                                      return Wrap(
                                        spacing: 12,
                                        runSpacing: 16,
                                        children:
                                            service.reminders.map((reminder) {
                                              return SizedBox(
                                                width:
                                                    (constraints.maxWidth -
                                                        (columns - 1) * 12) /
                                                    columns,
                                                child: SwipeableReminderCard(
                                                  reminder: reminder,
                                                  reminderService: service,
                                                  themeService: themeService,
                                                  currentTime: _currentTime,
                                                ),
                                              );
                                            }).toList(),
                                      );
                                    },
                                  ),
                                  // Add bottom padding to prevent overflow
                                  const SizedBox(height: 100),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              floatingActionButton: SpeedDial(
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
            );
          },
        );
      },
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

  Widget _buildMorphBlobButton(ReminderService service) {
    // Control animations based on service state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (service.isRunning) {
        _pulseController.repeat(reverse: true);
        _glowController.repeat(reverse: true);
        _energyController.repeat();
      } else {
        _pulseController.stop();
        _glowController.stop();
        _energyController.stop();
        _pulseController.reset();
        _glowController.reset();
        _energyController.reset();
      }
    });

    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseAnimation,
          _glowAnimation,
          _energyAnimation,
        ]),
        builder: (context, child) {
          return GestureDetector(
            onTap: () {
              // Toggle the service
              if (service.isRunning) {
                service.stopReminders();
              } else {
                service.startReminders();
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Energy glow effect from bottom
                if (service.isRunning)
                  AnimatedBuilder(
                    animation: _energyAnimation,
                    builder: (context, child) {
                      return Positioned(
                        bottom: 0,
                        child: Container(
                          width: 120 + (30 * _energyAnimation.value),
                          height: 60 + (20 * _energyAnimation.value),
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFFFE140).withValues(
                                  alpha: 0.4 * (1 - _energyAnimation.value),
                                ),
                                const Color(0xFFFA709A).withValues(
                                  alpha: 0.2 * (1 - _energyAnimation.value),
                                ),
                                Colors.transparent,
                              ],
                              stops: [0.0, 0.3, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(60),
                          ),
                        ),
                      );
                    },
                  ),
                // Main morph blob button
                Transform.scale(
                  scale:
                      service.isRunning
                          ? (0.98 + 0.02 * _pulseAnimation.value)
                          : 1.0,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors:
                            service.isRunning
                                ? [
                                  Color.lerp(
                                    const Color(0xFFFA709A),
                                    const Color(0xFFFEE140),
                                    _glowAnimation.value * 0.3,
                                  )!,
                                  Color.lerp(
                                    const Color(0xFFFEE140),
                                    const Color(0xFFFA709A),
                                    _glowAnimation.value * 0.3,
                                  )!,
                                ]
                                : [
                                  const Color(0xFF00F2FE),
                                  const Color(0xFF4FACFE),
                                ],
                      ),
                      borderRadius:
                          service.isRunning
                              ? BorderRadius.only(
                                topLeft: Radius.circular(
                                  45 + 5 * _pulseAnimation.value,
                                ),
                                topRight: Radius.circular(
                                  30 + 10 * _pulseAnimation.value,
                                ),
                                bottomLeft: Radius.circular(
                                  20 + 15 * _pulseAnimation.value,
                                ),
                                bottomRight: Radius.circular(
                                  55 + 3 * _pulseAnimation.value,
                                ),
                              )
                              : BorderRadius.circular(
                                60,
                              ), // Perfect circle when stopped
                      boxShadow: [
                        BoxShadow(
                          color:
                              service.isRunning
                                  ? const Color(0xFFFA709A).withValues(
                                    alpha: 0.2 + 0.15 * _glowAnimation.value,
                                  )
                                  : const Color(
                                    0xFF4FACFE,
                                  ).withValues(alpha: 0.25),
                          blurRadius:
                              service.isRunning
                                  ? 12 + 8 * _glowAnimation.value
                                  : 12,
                          spreadRadius:
                              service.isRunning
                                  ? 0.5 + 0.8 * _glowAnimation.value
                                  : 0.5,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(
                          milliseconds: 600,
                        ), // Even smoother transition
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation.drive(
                              Tween(
                                begin: 0.7,
                                end: 1.0,
                              ).chain(CurveTween(curve: Curves.easeOutBack)),
                            ),
                            child: child,
                          );
                        },
                        child:
                            service.isRunning
                                ? _buildPauseIcon()
                                : _buildPlayIcon(),
                      ),
                    ),
                  ), // Close Container
                ), // Close Transform.scale
              ], // Close Stack children
            ), // Close Stack
          );
        },
      ),
    );
  }

  Widget _buildPlayIcon() {
    return CustomPaint(
      key: const ValueKey('play'),
      size: const Size(30, 30), // Reduced from 50x50 to 30x30
      painter: _PlayIconPainter(),
    );
  }

  Widget _buildPauseIcon() {
    return SizedBox(
      key: const ValueKey('pause'),
      width: 30, // Reduced from 50 to 30
      height: 30, // Reduced from 50 to 30
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8, // Reduced from 12 to 8
            height: 24, // Reduced from 40 to 24
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6), // Reduced from 8 to 6
          Container(
            width: 8, // Reduced from 12 to 8
            height: 24, // Reduced from 40 to 24
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for the play triangle
class _PlayIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final path =
        Path()
          ..moveTo(size.width * 0.25, size.height * 0.2)
          ..lineTo(size.width * 0.75, size.height * 0.5)
          ..lineTo(size.width * 0.25, size.height * 0.8)
          ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
