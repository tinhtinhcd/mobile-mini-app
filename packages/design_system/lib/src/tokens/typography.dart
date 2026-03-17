import 'package:flutter/material.dart';

class AppTypography {
  static const double timerDisplay = 52;
  static const double screenTitle = 30;
  static const double pageTitle = 22;
  static const double sectionTitle = 18;
  static const double body = 14;
  static const double caption = 12;
  static const double button = 14;

  static TextTheme build({
    required TextTheme base,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: timerDisplay,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        letterSpacing: -1.2,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: screenTitle,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        letterSpacing: -0.8,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: pageTitle,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.4,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: sectionTitle,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.2,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: body + 1,
        height: 1.4,
        color: textPrimary,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: body,
        height: 1.4,
        color: textSecondary,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: caption,
        height: 1.35,
        color: textSecondary,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: button,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
