import 'package:erp_hr/core/utils/colors.dart';
import 'package:erp_hr/core/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


/// Reusable top-positioned snack bar with multiple variants.
///
/// Usage:
/// ```dart
/// AppSnackBar.show(context, message: 'Saved successfully');
/// AppSnackBar.success(context, message: 'Lead created!');
/// AppSnackBar.error(context, message: 'Something went wrong');
/// AppSnackBar.warning(context, message: 'Please select a plan first');
/// AppSnackBar.info(context, message: 'Tip: swipe to delete');
/// ```
class AppSnackBar {
  const AppSnackBar._();

  static OverlayEntry? _currentEntry;

  // ──────────────────── Variants ────────────────────

  /// Default snack bar using the app primary colour.
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _display(
      context,
      message: message,
      backgroundColor: AppColor.primary,
      icon: Icons.info_outline,
      duration: duration,
    );
  }

  /// Green success snack bar.
  static void success(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _display(
      context,
      message: message,
      backgroundColor: const Color(0xFF388E3C),
      icon: Icons.check_circle_outline,
      duration: duration,
    );
  }

  /// Red error snack bar.
  static void error(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    _display(
      context,
      message: message,
      backgroundColor: const Color(0xFFD32F2F),
      icon: Icons.error_outline,
      duration: duration,
    );
  }

  /// Amber warning snack bar.
  static void warning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _display(
      context,
      message: message,
      backgroundColor: const Color(0xFFF57C00),
      icon: Icons.warning_amber_outlined,
      duration: duration,
    );
  }

  /// Blue info snack bar.
  static void info(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _display(
      context,
      message: message,
      backgroundColor: const Color(0xFF1976D2),
      icon: Icons.info_outline,
      duration: duration,
    );
  }

  // ──────────────────── Internal ────────────────────

  static void _display(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    required Duration duration,
  }) {
    // Remove any existing snack bar first
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.of(context, rootOverlay: true);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _TopSnackBarWidget(
        message: message,
        backgroundColor: backgroundColor,
        icon: icon,
        duration: duration,
        onDismissed: () {
          entry.remove();
          if (_currentEntry == entry) _currentEntry = null;
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }
}

class _TopSnackBarWidget extends StatefulWidget {
  const _TopSnackBarWidget({
    required this.message,
    required this.backgroundColor,
    required this.icon,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final Color backgroundColor;
  final IconData icon;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_TopSnackBarWidget> createState() => _TopSnackBarWidgetState();
}

class _TopSnackBarWidgetState extends State<_TopSnackBarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 250),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // Auto-dismiss after duration
    Future.delayed(widget.duration, _dismiss);
  }

  void _dismiss() {
    if (mounted) {
      _controller.reverse().then((_) {
        if (mounted) widget.onDismissed();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! < 0) {
                _dismiss();
              }
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.only(
                  top: topPadding + 8.h,
                  bottom: 12.h,
                  left: 16.w,
                  right: 16.w,
                ),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.r),
                    bottomRight: Radius.circular(16.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.backgroundColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      Icon(widget.icon, color: AppColor.white, size: 22.r),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          widget.message,
                          style:
                              AppTextStyle.bodyMedium.withColor(AppColor.white),
                        ),
                      ),
                      GestureDetector(
                        onTap: _dismiss,
                        child: Icon(
                          Icons.close,
                          color: AppColor.white.withValues(alpha: 0.8),
                          size: 20.r,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
