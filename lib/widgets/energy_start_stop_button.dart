import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class EnergyStartStopButton extends StatefulWidget {
  final bool isRunning;
  final VoidCallback onToggle;
  final double size;

  const EnergyStartStopButton({
    super.key,
    required this.isRunning,
    required this.onToggle,
    this.size = 120,
  });

  @override
  State<EnergyStartStopButton> createState() => _EnergyStartStopButtonState();
}

class _EnergyStartStopButtonState extends State<EnergyStartStopButton>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _scaleController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _scaleAnimation;

  Timer? _particleTimer;
  final List<EnergyParticle> _particles = [];
  final List<AmbientDot> _ambientDots = [];

  @override
  void initState() {
    super.initState();

    // Breathing animation for active state
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _breathingAnimation = Tween<double>(begin: 0.15, end: 0.25).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // Scale animation for hover/tap
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));

    // Create ambient dots
    _createAmbientDots();

    // Start effects if already running
    if (widget.isRunning) {
      _startEffects();
    }
  }

  @override
  void didUpdateWidget(EnergyStartStopButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isRunning != oldWidget.isRunning) {
      if (widget.isRunning) {
        _startEffects();
      } else {
        _stopEffects();
      }
    }
  }

  void _createAmbientDots() {
    _ambientDots.clear();
    for (int i = 0; i < 12; i++) {
      final angle = (i * 2 * pi) / 12 + Random().nextDouble() * 0.5;
      final distance = 80 + Random().nextDouble() * 60;
      _ambientDots.add(
        AmbientDot(
          angle: angle,
          distance: distance,
          phase: Random().nextDouble() * 2 * pi,
          speed: 0.8 + Random().nextDouble() * 0.4,
        ),
      );
    }
  }

  void _startEffects() {
    _breathingController.repeat(reverse: true);

    // Create energy particles every 2 seconds
    _particleTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _particles.add(_createEnergyParticle());
        });
      }
    });

    // Create initial particle
    setState(() {
      _particles.add(_createEnergyParticle());
    });
  }

  void _stopEffects() {
    _breathingController.stop();
    _particleTimer?.cancel();
    setState(() {
      _particles.clear();
    });
  }

  EnergyParticle _createEnergyParticle() {
    final angle = Random().nextDouble() * 2 * pi;
    final distance = 120 + Random().nextDouble() * 80;

    return EnergyParticle(
      startAngle: angle,
      startDistance: distance,
      createdTime: DateTime.now(),
    );
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
    widget.onToggle();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breathingAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: widget.size * 2,
            height: widget.size *
                1.2, // Further reduced height to cut more bottom area
            child: ClipRect(
              // Clip to hide bottom effects
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ambient dots
                  ..._ambientDots.map((dot) => _buildAmbientDot(dot)),

                  // Energy particles
                  ..._particles.map(
                    (particle) => _buildEnergyParticle(particle),
                  ),

                  // Main button - positioned higher to account for reduced height
                  Positioned(
                    bottom: widget.size *
                        0.1, // Position button 10px from bottom of reduced container
                    child: GestureDetector(
                      onTapDown: _onTapDown,
                      onTapUp: _onTapUp,
                      onTapCancel: _onTapCancel,
                      child: Container(
                        width: widget.size,
                        height: widget.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                          gradient: RadialGradient(
                            center: Alignment.center,
                            colors: widget.isRunning
                                ? [
                                    const Color(0xFFF9CA24),
                                    const Color(0xFFF0932B),
                                  ]
                                : [
                                    const Color(0xFF1A4073),
                                    const Color(0xFF1A4073),
                                  ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.isRunning
                                  ? const Color(
                                      0xFFF9CA24,
                                    ).withValues(
                                      alpha: _breathingAnimation.value)
                                  : Colors.black.withValues(alpha: 0.2),
                              blurRadius: widget.isRunning ? 20 : 10,
                              spreadRadius: widget.isRunning ? 2 : 0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            widget.isRunning ? 'STOP' : 'START',
                            style: TextStyle(
                              color: Colors.white.withValues(
                                alpha: widget.isRunning ? 0.9 : 0.5,
                              ),
                              fontSize: 16, // Increased from 14 to 16
                              fontWeight: FontWeight
                                  .w500, // Increased from w400 to w500 for better visibility
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmbientDot(AmbientDot dot) {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        final time = _breathingController.value * 2 * pi;
        final animatedDistance =
            dot.distance + sin(time * dot.speed + dot.phase) * 10;
        final x = cos(dot.angle) * animatedDistance;
        final y = sin(dot.angle) * animatedDistance;

        return Positioned(
          left: widget.size + x - 1,
          top: widget.size + y - 1,
          child: Container(
            width: 2,
            height: 2,
            decoration: BoxDecoration(
              color:
                  Colors.white.withValues(alpha: widget.isRunning ? 0.3 : 0.2),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnergyParticle(EnergyParticle particle) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 5),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, progress, child) {
        final elapsed =
            DateTime.now().difference(particle.createdTime).inMilliseconds;
        if (elapsed > 5000) {
          // Remove old particles
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _particles.remove(particle);
              });
            }
          });
          return const SizedBox.shrink();
        }

        final currentDistance = particle.startDistance * (1 - progress);
        final x = cos(particle.startAngle) * currentDistance;
        final y = sin(particle.startAngle) * currentDistance;

        final opacity = progress < 0.1
            ? progress * 6
            : progress > 0.9
                ? (1 - progress) * 10
                : 0.6;

        return Positioned(
          left: widget.size + x - 1.5,
          top: widget.size + y - 1.5,
          child: Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFFF9CA24).withValues(alpha: opacity),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _scaleController.dispose();
    _particleTimer?.cancel();
    super.dispose();
  }
}

class EnergyParticle {
  final double startAngle;
  final double startDistance;
  final DateTime createdTime;

  EnergyParticle({
    required this.startAngle,
    required this.startDistance,
    required this.createdTime,
  });
}

class AmbientDot {
  final double angle;
  final double distance;
  final double phase;
  final double speed;

  AmbientDot({
    required this.angle,
    required this.distance,
    required this.phase,
    required this.speed,
  });
}
