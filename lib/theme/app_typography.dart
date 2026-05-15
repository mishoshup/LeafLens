import 'package:flutter/material.dart';

/// LEAFLENS Design System — Typography
/// Font families: Inter (primary UI), Poppins (headings),
/// Roboto (body), Lexend (graph labels), SF Pro (status bar)
class AppTypography {
  AppTypography._();

  // ── Font Families ──────────────────────────────────────────
  static const String inter = 'Inter';
  static const String poppins = 'Poppins';
  static const String roboto = 'Roboto';
  static const String lexend = 'Lexend';

  // ── Display / Large Headings ──────────────────────────────

  /// Screen titles (Login, Sign Up) — Poppins SemiBold 38px
  static const TextStyle displayLarge = TextStyle(
    fontFamily: poppins,
    fontWeight: FontWeight.w600,
    fontSize: 38,
    letterSpacing: -0.5,
  );

  /// Section headings — Poppins SemiBold 30px
  static const TextStyle displayMedium = TextStyle(
    fontFamily: poppins,
    fontWeight: FontWeight.w600,
    fontSize: 30,
    letterSpacing: -0.3,
  );

  /// CTA buttons (Get Started, Login, Sign Up) — Poppins SemiBold 24px
  static const TextStyle displaySmall = TextStyle(
    fontFamily: poppins,
    fontWeight: FontWeight.w600,
    fontSize: 24,
  );

  // ── Sensor Values ─────────────────────────────────────────

  /// Large sensor readings (26, 64%, 90%) — Inter Bold 36px
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: inter,
    fontWeight: FontWeight.w700,
    fontSize: 36,
  );

  /// Gauge values — Inter ExtraBold 28px
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: inter,
    fontWeight: FontWeight.w800,
    fontSize: 28,
  );

  // ── Card Titles ───────────────────────────────────────────

  /// Card title (Temperature, Humidity, etc.) — Inter Bold 20px
  static const TextStyle titleLarge = TextStyle(
    fontFamily: inter,
    fontWeight: FontWeight.w700,
    fontSize: 20,
  );

  /// Menu item labels — Inter Bold 16px
  static const TextStyle titleMedium = TextStyle(
    fontFamily: inter,
    fontWeight: FontWeight.w700,
    fontSize: 16,
  );

  // ── Status Text ───────────────────────────────────────────

  /// Status labels (Perfect Environment, Saturated) — Inter Bold 16px
  static const TextStyle labelLarge = TextStyle(
    fontFamily: inter,
    fontWeight: FontWeight.w700,
    fontSize: 16,
  );

  /// Status descriptions (Temperature is normal) — Inter SemiBold Italic 16px
  static const TextStyle labelMedium = TextStyle(
    fontFamily: inter,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
    fontSize: 16,
  );

  // ── Body Text ─────────────────────────────────────────────

  /// Input labels, body text — Roboto Medium 16px
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: roboto,
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );

  /// Input field content — Roboto Regular 32px
  static const TextStyle bodyExtraLarge = TextStyle(
    fontFamily: roboto,
    fontWeight: FontWeight.w400,
    fontSize: 32,
  );

  /// Small labels, metadata — Roboto Regular 14px
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: roboto,
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );

  /// Tiny text — Roboto Regular 12px
  static const TextStyle bodySmall = TextStyle(
    fontFamily: roboto,
    fontWeight: FontWeight.w400,
    fontSize: 12,
  );

  // ── Graph Labels ──────────────────────────────────────────

  /// Y-axis values — Lexend Light 20px
  static const TextStyle graphLabelLarge = TextStyle(
    fontFamily: lexend,
    fontWeight: FontWeight.w300,
    fontSize: 20,
  );

  /// Graph titles — Lexend Bold 20px
  static const TextStyle graphTitle = TextStyle(
    fontFamily: lexend,
    fontWeight: FontWeight.w700,
    fontSize: 20,
  );

  // ── Footer / Secondary Links ─────────────────────────────

  /// Footer text — Lexend Light 20px
  static const TextStyle footerLight = TextStyle(
    fontFamily: lexend,
    fontWeight: FontWeight.w300,
    fontSize: 20,
  );

  /// Footer link — Lexend Bold 20px
  static const TextStyle footerBold = TextStyle(
    fontFamily: lexend,
    fontWeight: FontWeight.w700,
    fontSize: 20,
  );
}
