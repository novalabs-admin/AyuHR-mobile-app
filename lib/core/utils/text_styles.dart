import 'package:erp_hr/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


/// Pre-defined text styles for consistent typography across the app.
///
/// Usage:
/// ```dart
/// Text('Hello', style: AppTextStyle.h1);
/// Text('Hello', style: AppTextStyle.bodyMedium.bold);
/// Text('Hello', style: AppTextStyle.caption.color(Colors.grey));
/// ```
class AppTextStyle {
  const AppTextStyle._();

// Headings
  /// 32sp - Page titles, hero text
  static TextStyle get h1 => TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        height: 1.25,
      );

  /// 28sp - Section headers
  static TextStyle get h2 => TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
        height: 1.29,
      );

  /// 24sp - Card titles, dialog headers
  static TextStyle get h3 => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        height: 1.33,
      );

  /// 20sp - Sub-section headers
  static TextStyle get h4 => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  /// 18sp - List group headers
  static TextStyle get h5 => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        height: 1.44,
      );

  /// 16sp - Small headers
  static TextStyle get h6 => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  // Body Text

  /// 16sp - Primary body text
  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  /// 14sp - Default body text
  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 1.43,
      );

  /// 12sp - Secondary text, descriptions
  static TextStyle get bodySmall => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 1.33,
      );

  //  Labels & Buttons

  /// 16sp semibold - Button text
  static TextStyle get button => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  /// 14sp medium - Form labels, tab labels
  static TextStyle get label => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        height: 1.43,
      );

  /// 12sp medium - Small labels, chips, badges
  static TextStyle get labelSmall => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        height: 1.33,
      );

  // Utility

  /// 10sp - Timestamps, fine print
  static TextStyle get caption => TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  /// 12sp - Overline text, category labels
  static TextStyle get overline => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        height: 1.33,
      );
}

/// Extension to make text styles chainable.
///
/// ```dart
/// AppTextStyle.bodyMedium.bold.color(AppColor.primary)
/// AppTextStyle.h3.italic.withValues(alpha: 0.7)
/// ```
extension TextStyleX on TextStyle {
  // Weight
  TextStyle get thin => copyWith(fontWeight: FontWeight.w100);
  TextStyle get extraLight => copyWith(fontWeight: FontWeight.w200);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);
  TextStyle get extraBold => copyWith(fontWeight: FontWeight.w800);

  //  Style
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);
  TextStyle get underline => copyWith(decoration: TextDecoration.underline);
  TextStyle get lineThrough => copyWith(decoration: TextDecoration.lineThrough);

  // Color
  TextStyle withColor(Color c) => copyWith(color: c);
  TextStyle get primary => copyWith(color: AppColor.primary);
  TextStyle get white => copyWith(color: AppColor.white);
  TextStyle setOpacity(double opacity) {
    final c = color;
    if (c == null) return this;
    // ignore: deprecated_member_use
    return copyWith(color: c.withValues(alpha: opacity));
  }

  // Spacing
  TextStyle letterSpace(double spacing) => copyWith(letterSpacing: spacing);
  TextStyle wordSpace(double spacing) => copyWith(wordSpacing: spacing);
  TextStyle lineHeight(double height) => copyWith(height: height);

  // Size
  TextStyle size(double size) => copyWith(fontSize: size.sp);
}
