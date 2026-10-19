import 'package:erp_hr/core/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable button with multiple variants and built-in loading state.
///
/// Usage:
/// ```dart
/// AppButton(label: 'Login', onPressed: () => login());
/// AppButton.secondary(label: 'Cancel', onPressed: () => cancel());
/// AppButton.outlined(label: 'Details', onPressed: () => details());
/// AppButton(label: 'Saving...', onPressed: null, isLoading: true);
///
/// // Web-style gradient pill button (e.g. the LOG IN button):
/// AppButton(
///   label: 'LOG IN',
///   onPressed: () => login(),
///   gradientColors: [AppColor.primary, AppColor.primaryLight],
///   borderRadius: 30,
///   height: 52,
/// );
/// ```
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.fontSize,
    this.gradientColors,
    this.letterSpacing,
    this.uppercase = false,
    this.useGradient = true, // primary buttons are gradient by default
  }) : _variant = _ButtonVariant.primary;

  const AppButton.secondary({
    required this.label,
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.fontSize,
    this.gradientColors,
    this.letterSpacing,
    this.uppercase = false,
    this.useGradient = false, // secondary stays flat unless opted in
  }) : _variant = _ButtonVariant.secondary;

  const AppButton.outlined({
    required this.label,
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.fontSize,
    this.letterSpacing,
    this.uppercase = false,
  })  : _variant = _ButtonVariant.outlined,
        gradientColors = null,
        useGradient = false;

  const AppButton.text({
    required this.label,
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.fontSize,
    this.letterSpacing,
    this.uppercase = false,
  })  : _variant = _ButtonVariant.text,
        gradientColors = null,
        useGradient = false;

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? borderRadius;
  final double? fontSize;

  /// When provided (primary/secondary variants only), the button is filled
  /// with a left-to-right gradient instead of a flat [backgroundColor] —
  /// this is what gives the "LOG IN" web-style pill look.
  /// e.g. `[AppColor.primary, AppColor.primary.withValues(alpha: 0.7)]`.
  final List<Color>? gradientColors;

  /// Letter spacing for the label, e.g. `1.5` to match the web button text.
  final double? letterSpacing;

  /// Uppercases the label, e.g. 'Log in' → 'LOG IN'.
  final bool uppercase;

  /// Whether to render with a gradient fill (like the LOG IN button) instead
  /// of a flat [backgroundColor]. Defaults to `true` for the primary
  /// constructor so every existing `AppButton(...)` call site picks up the
  /// new look automatically. Set to `false` to keep a flat color.
  final bool useGradient;

  final _ButtonVariant _variant;

  bool get _hasGradient => useGradient && _variant != _ButtonVariant.outlined &&
      _variant != _ButtonVariant.text;

  List<Color> _resolveGradientColors(ColorScheme cs) {
    if (gradientColors != null && gradientColors!.length >= 2) {
      return gradientColors!;
    }
    // Default gradient derived from the button's own color, so every
    // AppButton looks like the login button without passing colors in.
    final base = backgroundColor ??
        (_variant == _ButtonVariant.secondary
            ? cs.secondaryContainer
            : cs.primary);
    return [base, base.withValues(alpha: 0.75)];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final btnHeight = height ?? 48.h;
    final btnRadius = borderRadius ?? 12.r;
    final btnFontSize = fontSize ?? 16.sp;

    final textStyle = AppTextStyle.button.size(btnFontSize).copyWith(
      letterSpacing: letterSpacing,
    );

    final style = switch (_variant) {
      _ButtonVariant.primary => ElevatedButton.styleFrom(
        backgroundColor:
        _hasGradient ? Colors.transparent : (backgroundColor ?? cs.primary),
        foregroundColor: foregroundColor ?? cs.onPrimary,
        minimumSize: Size(width ?? double.infinity, btnHeight),
        elevation: _hasGradient ? 0 : null,
        shadowColor: _hasGradient ? Colors.transparent : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(btnRadius),
        ),
        textStyle: textStyle,
      ),
      _ButtonVariant.secondary => ElevatedButton.styleFrom(
        backgroundColor: _hasGradient
            ? Colors.transparent
            : (backgroundColor ?? cs.secondaryContainer),
        foregroundColor: foregroundColor ?? cs.onSecondaryContainer,
        minimumSize: Size(width ?? double.infinity, btnHeight),
        elevation: _hasGradient ? 0 : null,
        shadowColor: _hasGradient ? Colors.transparent : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(btnRadius),
        ),
        textStyle: textStyle,
      ),
      _ButtonVariant.outlined => OutlinedButton.styleFrom(
        foregroundColor: foregroundColor ?? cs.primary,
        minimumSize: Size(width ?? double.infinity, btnHeight),
        side: BorderSide(color: cs.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(btnRadius),
        ),
        textStyle: textStyle,
      ),
      _ButtonVariant.text => TextButton.styleFrom(
        foregroundColor: foregroundColor ?? cs.primary,
        minimumSize: Size(width ?? 0, btnHeight),
        textStyle: textStyle,
      ),
    };

    final labelText = uppercase ? label.toUpperCase() : label;

    final child = isLoading
        ? SizedBox(
      width: 20.r,
      height: 20.r,
      child: CircularProgressIndicator(
        strokeWidth: 2.r,
        color: _variant == _ButtonVariant.primary
            ? cs.onPrimary
            : cs.primary,
      ),
    )
        : icon != null
        ? Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20.r),
        SizedBox(width: 8.w),
        Text(labelText,style: TextStyle(color: Colors.white),),
      ],
    )
        : Text(labelText,);

    Widget button;

    if (_variant == _ButtonVariant.outlined) {
      button = OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: child,
      );
    } else if (_variant == _ButtonVariant.text) {
      button = TextButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: child,
      );
    } else {
      button = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: child,
      );
    }

    // Wrap in a gradient-filled container for the web-style pill look.
    // The button itself stays transparent (via the style above) so the
    // gradient shows through, while all press/ripple/disabled behavior
    // stays native to ElevatedButton.
    if (_hasGradient) {
      final colors = _resolveGradientColors(cs);
      return Container(
        width: width ?? double.infinity,
        height: btnHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(btnRadius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: onPressed == null && !isLoading
                ? colors.map((c) => c.withValues(alpha: 0.5)).toList()
                : colors,
          ),
        ),
        child: button,
      );
    }

    return button;
  }
}

enum _ButtonVariant { primary, secondary, outlined, text }