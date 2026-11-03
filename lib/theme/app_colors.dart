import 'package:flutter/material.dart';

/// Central color system for the app. Keep every color reference in the UI
/// pointed at this class so the palette can be re-themed from one place.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF0E6B4F); // deep emerald
  static const Color primaryLight = Color(0xFF12A874);
  static const Color primaryDark = Color(0xFF084832);
  static const Color secondary = Color(0xFF1C2430); // dark navy / charcoal
  static const Color secondaryLight = Color(0xFF2E3947);

  // Backgrounds
  static const Color background = Color(0xFFF6F8F7); // very light neutral
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF0F3F1);

  // Text
  static const Color textPrimary = Color(0xFF14181C);
  static const Color textSecondary = Color(0xFF6B7680);
  static const Color textMuted = Color(0xFF9AA4AC);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF1DAE64);
  static const Color warning = Color(0xFFE79B26);
  static const Color error = Color(0xFFE0483E);
  static const Color info = Color(0xFF2E7EE0);

  // Misc
  static const Color border = Color(0xFFE4E8E6);
  static const Color divider = Color(0xFFEDF0EF);
  static const Color shadow = Color(0x14000000);

  // Crypto brand accents (used for asset icon backgrounds only)
  static const Color btc = Color(0xFFF7931A);
  static const Color eth = Color(0xFF627EEA);
  static const Color usdt = Color(0xFF26A17B);
  static const Color usdc = Color(0xFF2775CA);
  static const Color sol = Color(0xFF9945FF);
  static const Color bnb = Color(0xFFF3BA2F);
}
