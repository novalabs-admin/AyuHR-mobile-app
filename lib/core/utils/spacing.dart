import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Pre-defined spacing constants and gap widgets for consistent layout.
///
/// Usage:
/// ```dart
/// Column(
///   children: [
///     Text('Title'),
///     Gap.v8,               // 8px vertical gap
///     Text('Subtitle'),
///     Gap.v16,              // 16px vertical gap
///     Row(children: [
///       Icon(Icons.star),
///       Gap.h8,             // 8px horizontal gap
///       Text('Rating'),
///     ]),
///   ],
/// )
/// ```
class Gap {
  const Gap._();

  // ──────────────────── Vertical Gaps ────────────────────

  static SizedBox get v2 => SizedBox(height: 2.h);
  static SizedBox get v4 => SizedBox(height: 4.h);
  static SizedBox get v6 => SizedBox(height: 6.h);
  static SizedBox get v8 => SizedBox(height: 8.h);
  static SizedBox get v10 => SizedBox(height: 10.h);
  static SizedBox get v12 => SizedBox(height: 12.h);
  static SizedBox get v16 => SizedBox(height: 16.h);
  static SizedBox get v20 => SizedBox(height: 20.h);
  static SizedBox get v24 => SizedBox(height: 24.h);
  static SizedBox get v32 => SizedBox(height: 32.h);
  static SizedBox get v40 => SizedBox(height: 40.h);
  static SizedBox get v48 => SizedBox(height: 48.h);
  static SizedBox get v64 => SizedBox(height: 64.h);

  // ──────────────────── Horizontal Gaps ────────────────────

  static SizedBox get h2 => SizedBox(width: 2.w);
  static SizedBox get h4 => SizedBox(width: 4.w);
  static SizedBox get h6 => SizedBox(width: 6.w);
  static SizedBox get h8 => SizedBox(width: 8.w);
  static SizedBox get h10 => SizedBox(width: 10.w);
  static SizedBox get h12 => SizedBox(width: 12.w);
  static SizedBox get h16 => SizedBox(width: 16.w);
  static SizedBox get h20 => SizedBox(width: 20.w);
  static SizedBox get h24 => SizedBox(width: 24.w);
  static SizedBox get h32 => SizedBox(width: 32.w);

  /// Custom vertical gap
  static SizedBox vertical(double height) => SizedBox(height: height.h);

  /// Custom horizontal gap
  static SizedBox horizontal(double width) => SizedBox(width: width.w);
}

/// Pre-defined padding values for consistent spacing.
///
/// Usage:
/// ```dart
/// Padding(padding: AppPadding.all16);
/// Container(padding: AppPadding.horizontal16);
/// Padding(padding: AppPadding.fromLTRB(16, 8, 16, 0));
/// ```
class AppPadding {
  const AppPadding._();

  // ──────────────────── All Sides ────────────────────

  static EdgeInsets get all4 => EdgeInsets.all(4.r);
  static EdgeInsets get all8 => EdgeInsets.all(8.r);
  static EdgeInsets get all12 => EdgeInsets.all(12.r);
  static EdgeInsets get all16 => EdgeInsets.all(16.r);
  static EdgeInsets get all20 => EdgeInsets.all(20.r);
  static EdgeInsets get all24 => EdgeInsets.all(24.r);

  // ──────────────────── Horizontal ────────────────────

  static EdgeInsets get horizontal4 => EdgeInsets.symmetric(horizontal: 4.w);
  static EdgeInsets get horizontal8 => EdgeInsets.symmetric(horizontal: 8.w);
  static EdgeInsets get horizontal12 => EdgeInsets.symmetric(horizontal: 12.w);
  static EdgeInsets get horizontal16 => EdgeInsets.symmetric(horizontal: 16.w);
  static EdgeInsets get horizontal20 => EdgeInsets.symmetric(horizontal: 20.w);
  static EdgeInsets get horizontal24 => EdgeInsets.symmetric(horizontal: 24.w);

  // ──────────────────── Vertical ────────────────────

  static EdgeInsets get vertical4 => EdgeInsets.symmetric(vertical: 4.h);
  static EdgeInsets get vertical8 => EdgeInsets.symmetric(vertical: 8.h);
  static EdgeInsets get vertical12 => EdgeInsets.symmetric(vertical: 12.h);
  static EdgeInsets get vertical16 => EdgeInsets.symmetric(vertical: 16.h);
  static EdgeInsets get vertical20 => EdgeInsets.symmetric(vertical: 20.h);
  static EdgeInsets get vertical24 => EdgeInsets.symmetric(vertical: 24.h);

  // ──────────────────── Page Padding ────────────────────

  /// Standard page padding: 16 horizontal, 16 top
  static EdgeInsets get page => EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0);

  /// Standard page padding with bottom: 16 all sides
  static EdgeInsets get pageWithBottom => EdgeInsets.all(16.r);

  // ──────────────────── Custom ────────────────────

  static EdgeInsets fromLTRB(
    double left,
    double top,
    double right,
    double bottom,
  ) =>
      EdgeInsets.fromLTRB(left.w, top.h, right.w, bottom.h);

  static EdgeInsets symmetric({
    double horizontal = 0,
    double vertical = 0,
  }) =>
      EdgeInsets.symmetric(
        horizontal: horizontal.w,
        vertical: vertical.h,
      );
}

/// Pre-defined border radius values.
///
/// Usage:
/// ```dart
/// Container(
///   decoration: BoxDecoration(borderRadius: AppRadius.r8),
/// );
/// ClipRRect(borderRadius: AppRadius.r16, child: Image(...));
/// ```
class AppRadius {
  const AppRadius._();

  static BorderRadius get r4 => BorderRadius.circular(4.r);
  static BorderRadius get r6 => BorderRadius.circular(6.r);
  static BorderRadius get r8 => BorderRadius.circular(8.r);
  static BorderRadius get r10 => BorderRadius.circular(10.r);
  static BorderRadius get r12 => BorderRadius.circular(12.r);
  static BorderRadius get r16 => BorderRadius.circular(16.r);
  static BorderRadius get r20 => BorderRadius.circular(20.r);
  static BorderRadius get r24 => BorderRadius.circular(24.r);
  static BorderRadius get r32 => BorderRadius.circular(32.r);
  static BorderRadius get full => BorderRadius.circular(999.r);

  /// Custom radius
  static BorderRadius circular(double radius) =>
      BorderRadius.circular(radius.r);
}
