import 'package:app_core/src/theme/app_tokens.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light(Color accentColor) {
    return _buildTheme(accentColor: accentColor, brightness: Brightness.light);
  }

  static ThemeData dark(Color accentColor) {
    return _buildTheme(accentColor: accentColor, brightness: Brightness.dark);
  }

  static ThemeData _buildTheme({
    required Color accentColor,
    required Brightness brightness,
  }) {
    final bool isLight = brightness == Brightness.light;
    final Color surface = isLight ? AppColors.card : AppColors.cardDark;
    final Color background =
        isLight ? AppColors.background : AppColors.backgroundDark;
    final Color elevatedSurface = Color.alphaBlend(
      accentColor.withValues(alpha: isLight ? 0.04 : 0.08),
      surface,
    );
    final Color textPrimary =
        isLight ? AppColors.textPrimary : AppColors.textPrimaryDark;
    final Color textSecondary =
        isLight ? AppColors.textSecondary : AppColors.textSecondaryDark;
    final Color divider = isLight ? AppColors.divider : AppColors.dividerDark;

    final ThemeData baseTheme =
        isLight
            ? FlexThemeData.light(
              colors: FlexSchemeColor.from(
                primary: accentColor,
                secondary: _blend(accentColor, Colors.white, 0.38),
                tertiary: _blend(accentColor, Colors.white, 0.56),
              ),
              surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
              blendLevel: 10,
              appBarStyle: FlexAppBarStyle.scaffoldBackground,
              appBarElevation: 0,
              useMaterial3: true,
            )
            : FlexThemeData.dark(
              colors: FlexSchemeColor.from(
                primary: accentColor,
                secondary: _blend(accentColor, Colors.black, 0.24),
                tertiary: _blend(accentColor, Colors.black, 0.36),
              ),
              surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
              blendLevel: 16,
              appBarStyle: FlexAppBarStyle.scaffoldBackground,
              appBarElevation: 0,
              useMaterial3: true,
            );

    final ColorScheme colorScheme = baseTheme.colorScheme.copyWith(
      primary: accentColor,
      onPrimary: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      outline: divider,
      outlineVariant: divider,
      surfaceTint: accentColor,
      primaryContainer: Color.alphaBlend(
        accentColor.withValues(alpha: isLight ? 0.18 : 0.28),
        surface,
      ),
      secondaryContainer: Color.alphaBlend(
        accentColor.withValues(alpha: isLight ? 0.10 : 0.16),
        surface,
      ),
    );

    final TextTheme textTheme = baseTheme.textTheme.copyWith(
      headlineLarge: baseTheme.textTheme.headlineLarge?.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.9,
      ),
      headlineMedium: baseTheme.textTheme.headlineMedium?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.6,
      ),
      titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.3,
      ),
      titleMedium: baseTheme.textTheme.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(
        fontSize: 15,
        height: 1.5,
        color: textPrimary,
      ),
      bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.5,
        color: textSecondary,
      ),
      bodySmall: baseTheme.textTheme.bodySmall?.copyWith(
        fontSize: 12,
        height: 1.45,
        color: textSecondary,
      ),
      labelLarge: baseTheme.textTheme.labelLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );

    return baseTheme.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      dividerColor: divider,
      textTheme: textTheme,
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: background,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: elevatedSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          side: BorderSide(color: divider),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
          textStyle: textTheme.labelLarge,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.hovered)) {
              return Colors.white.withValues(alpha: 0.06);
            }
            return null;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          foregroundColor: textPrimary,
          side: BorderSide(color: divider),
          backgroundColor: Color.alphaBlend(
            accentColor.withValues(alpha: isLight ? 0.03 : 0.08),
            surface,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
          textStyle: textTheme.labelLarge,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.pressed)) {
              return accentColor.withValues(alpha: 0.08);
            }
            if (states.contains(WidgetState.hovered)) {
              return accentColor.withValues(alpha: 0.04);
            }
            return null;
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
        ),
      ),
      chipTheme: baseTheme.chipTheme.copyWith(
        backgroundColor: surface,
        selectedColor: accentColor,
        secondarySelectedColor: accentColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: divider),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: textPrimary),
        secondaryLabelStyle: textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),
      progressIndicatorTheme: baseTheme.progressIndicatorTheme.copyWith(
        color: accentColor,
        linearTrackColor: Color.alphaBlend(
          accentColor.withValues(alpha: isLight ? 0.10 : 0.20),
          surface,
        ),
        linearMinHeight: 10,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color.alphaBlend(
          accentColor.withValues(alpha: isLight ? 0.03 : 0.06),
          surface,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
        labelStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: accentColor, width: 1.4),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.large),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: elevatedSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          side: BorderSide(color: divider),
        ),
      ),
    );
  }

  static Color _blend(Color color, Color target, double amount) {
    return Color.lerp(color, target, amount)!;
  }
}
