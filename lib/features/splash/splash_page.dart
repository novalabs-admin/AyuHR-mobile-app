import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  // ── Logo entrance ──
  late AnimationController _logoController;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;

  // ── Tagline entrance ──
  late AnimationController _taglineController;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _taglineSlide;

  // ── Heartbeat line ──
  late AnimationController _heartbeatController;

  // ── Bottom badge ──
  late AnimationController _badgeController;
  late Animation<double> _badgeOpacity;

  @override
  void initState() {
    super.initState();
    // Dismiss the native splash immediately — our animated splash takes over.
    FlutterNativeSplash.remove();

    // Logo: scale from 0.6 → 1.0, fade in
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    // Tagline: slide up + fade in, starts after logo
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOutCubic),
    );

    // Heartbeat: continuous loop
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    // Bottom badge: fade in last
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _badgeOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.easeIn),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    // Small initial pause
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 650));
    _taglineController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _badgeController.forward();

    // Stay on splash for a total comfortable viewing time, then navigate
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      context.go('/');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _taglineController.dispose();
    _heartbeatController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFFAFDFA),
              Color(0xFFF2F8F2),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ── Decorative blurred circle top-right ──
            Positioned(
              top: -80.r,
              right: -80.r,
              child: Container(
                width: 280.r,
                height: 280.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00AE0C).withValues(alpha: 0.06),
                ),
              ),
            ),

            // ── Decorative blurred circle bottom-left ──
            Positioned(
              bottom: -60.r,
              left: -60.r,
              child: Container(
                width: 220.r,
                height: 220.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00AE0C).withValues(alpha: 0.05),
                ),
              ),
            ),

            // ── Decorative small circle mid-left ──
            Positioned(
              top: 180.h,
              left: -30.r,
              child: Container(
                width: 100.r,
                height: 100.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00AE0C).withValues(alpha: 0.03),
                ),
              ),
            ),

            // ── Main center content ──
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Animated Logo ──
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28.r),
                        border: Border.all(
                          color: const Color(0xFF00AE0C).withValues(alpha: 0.12),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: const Color(0xFF00AE0C).withValues(alpha: 0.05),
                            blurRadius: 40,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/ayu_hr.png',
                        width: 200.w,
                      ),
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // ── Animated Heartbeat Line ──
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: child,
                      );
                    },
                    child: AnimatedBuilder(
                      animation: _heartbeatController,
                      builder: (context, _) {
                        return CustomPaint(
                          size: Size(200.w, 36.h),
                          painter: _HeartbeatPainter(
                            progress: _heartbeatController.value,
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 28.h),

                  // ── Tagline ──
                  SlideTransition(
                    position: _taglineSlide,
                    child: FadeTransition(
                      opacity: _taglineOpacity,
                      child: Column(
                        children: [
                          Text(
                            'Valuable care for valuable life',
                            style: TextStyle(
                              color: const Color(0xFF005215), // brand primaryDark
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            width: 48.w,
                            height: 3.h,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF00AE0C), // primaryLight
                                  Color(0xFF005215), // primaryDark
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom badge ──
            Positioned(
              bottom: 40.h,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _badgeOpacity,
                child: Column(
                  children: [
                    // Loading dots
                    _PulsingDots(),
                    SizedBox(height: 20.h),
                    Text(
                      'ERP Sales Management',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF005215).withValues(alpha: 0.6),
                        fontSize: 11.sp,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '© ${DateTime.now().year} Ayu Lanka Medical Pvt Ltd.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.35),
                        fontSize: 10.sp,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Heartbeat line painter – draws an ECG-style trace that scrolls from
// right to left to give a live "pulse" effect.
// ─────────────────────────────────────────────────────────────────────────────
class _HeartbeatPainter extends CustomPainter {
  final double progress;
  _HeartbeatPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final gradient = const LinearGradient(
      colors: [
        Color(0x0008F10C),
        Color(0xFF08F10C),
        Color(0xFF00AE0C),
        Color(0x0008F10C),
      ],
      stops: [0.0, 0.3, 0.7, 1.0],
    );

    paint.shader = gradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    final path = Path();
    final w = size.width;
    final h = size.height;
    final midY = h / 2;

    // Offset the entire waveform based on progress (scrolling effect)
    final offset = progress * w;

    // Draw the ECG waveform repeated twice for smooth looping
    for (int repeat = -1; repeat <= 1; repeat++) {
      final x0 = repeat * w - offset;
      _drawEcgSegment(path, x0, midY, w, h);
    }

    canvas.drawPath(path, paint);
  }

  void _drawEcgSegment(Path path, double x0, double midY, double w, double h) {
    // Flat → small bump → spike up → spike down → small bounce → flat
    final pts = [
      Offset(x0 + 0.00 * w, midY),
      Offset(x0 + 0.18 * w, midY),
      Offset(x0 + 0.22 * w, midY - h * 0.15),
      Offset(x0 + 0.26 * w, midY),
      Offset(x0 + 0.32 * w, midY),
      Offset(x0 + 0.38 * w, midY - h * 0.42), // Q wave
      Offset(x0 + 0.42 * w, midY - h * 0.42),
      Offset(x0 + 0.44 * w, midY - h * 0.9),  // R peak
      Offset(x0 + 0.46 * w, midY + h * 0.35), // S valley
      Offset(x0 + 0.50 * w, midY),
      Offset(x0 + 0.58 * w, midY + h * 0.20), // T wave
      Offset(x0 + 0.66 * w, midY),
      Offset(x0 + 1.00 * w, midY),
    ];

    for (int i = 0; i < pts.length; i++) {
      if (i == 0) {
        path.moveTo(pts[i].dx, pts[i].dy);
      } else {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
    }
  }

  @override
  bool shouldRepaint(_HeartbeatPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Three animated loading dots
// ─────────────────────────────────────────────────────────────────────────────
class _PulsingDots extends StatefulWidget {
  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3.0;
            final phase = (_ctrl.value - delay) % 1.0;
            final scale = 0.6 + 0.4 * math.sin(math.pi * phase.clamp(0, 1));
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 7.r,
                  height: 7.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00AE0C).withValues(alpha: 0.7),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
