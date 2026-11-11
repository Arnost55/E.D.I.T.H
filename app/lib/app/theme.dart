import 'package:flutter/material.dart';

/// E.D.I.T.H. App Theme
/// Near-black backgrounds, cyan/ice-blue accents, white/muted-gray typography
class EdithTheme {
  EdithTheme._();

  // Core Colors
  static const Color background = Color(0xFF080E16);
  static const Color panel = Color(0xFF121D2A);
  static const Color panelElevated = Color(0xFF1A2838);
  static const Color panelBorder = Color(0xFF1E2D3D);
  static const Color accent = Color(0xFFD3DCDF); // Ice blue / cyan-white
  static const Color accentStrong = Color(0xFF00E5FF); // Bright cyan
  static const Color accentMuted = Color(0xFF8B9DA8);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textMuted = Color(0xFF78909C);
  static const Color textDisabled = Color(0xFF546E7A);

  // Status Colors
  static const Color statusLive = Color(0xFF00E676); // Green
  static const Color statusWarning = Color(0xFFFFB300); // Amber
  static const Color statusError = Color(0xFFFF1744); // Red
  static const Color statusSimulation = Color(0xFFD3DCDF); // Accent (ice blue)
  static const Color statusUnavailable = Color(0xFF546E7A); // Muted gray

  // Touch Target
  static const double minTouchTarget = 48.0;
  static const double minTouchTargetSmall = 44.0;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;

  // Border Radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;

  // Animation
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 350);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accentStrong,
        onPrimary: background,
        secondary: accent,
        onSecondary: background,
        tertiary: accentMuted,
        onTertiary: background,
        surface: panel,
        onSurface: textPrimary,
        surfaceContainerHighest: panelElevated,
        outline: panelBorder,
        outlineVariant: panelBorder,
        error: statusError,
        onError: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: panel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
          side: const BorderSide(color: panelBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentStrong,
          foregroundColor: background,
          elevation: 0,
          minimumSize: const Size(double.infinity, minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLG,
            vertical: spacingMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          minimumSize: const Size(double.infinity, minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLG,
            vertical: spacingMD,
          ),
          side: const BorderSide(color: accent, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          minimumSize: const Size(minTouchTarget, minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMD,
            vertical: spacingSM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: panelElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: panelBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: panelBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: accentStrong, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: statusError),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMD,
          vertical: spacingMD,
        ),
        hintStyle: const TextStyle(color: textMuted),
        labelStyle: const TextStyle(color: textSecondary),
      ),
      dividerTheme: const DividerThemeData(
        color: panelBorder,
        thickness: 1,
        space: spacingLG,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: panelElevated,
        selectedColor: accentStrong.withValues(alpha: 0.2),
        disabledColor: panelBorder.withValues(alpha: 0.3),
        labelStyle: const TextStyle(color: textPrimary, fontSize: 12),
        secondaryLabelStyle: const TextStyle(color: accent, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: spacingSM, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSM),
          side: const BorderSide(color: panelBorder),
        ),
        side: const BorderSide(color: panelBorder),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: panel,
        indicatorColor: accent.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: accentStrong,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(
            color: textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: accentStrong, size: 24);
          }
          return const IconThemeData(color: textMuted, size: 24);
        }),
        height: 72,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: panel,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXL)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: panel,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXL),
          side: const BorderSide(color: panelBorder),
        ),
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: panelElevated,
        contentTextStyle: const TextStyle(color: textPrimary),
        actionTextColor: accentStrong,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontSize: 45,
          fontWeight: FontWeight.w400,
        ),
        displaySmall: TextStyle(
          color: textPrimary,
          fontSize: 36,
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        headlineSmall: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          color: textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
        labelLarge: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          color: textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}