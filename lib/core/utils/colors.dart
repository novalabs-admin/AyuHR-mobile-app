import 'package:flutter/material.dart';

class AppColor {
  const AppColor._();

  // ──────────────────── Red & White Theme Palette ────────────────────
  static const primary = Color(0xFF339B47);
  static const primaryDark = Color(0xFF005215);
  static const primaryLight = Color(0xFF00AE0C);

  // Vibrant Accents
  static const accentRed = Color(0xFFFF5252);
  static const accentWhite = Color(0xFFFFFFFF);

  // Decorative & utility
  static const pinkBubble = Color(0xFFFBDDD9);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF1A1A1A);
  static const grey = Color(0xFF757575);
  static const greyLight = Color(0xFFF5F5F5);

  static const redGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryDark],
  );
}
