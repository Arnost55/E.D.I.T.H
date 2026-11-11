import 'package:flutter/material.dart';

/// E.D.I.T.H. Design System
/// Near-black backgrounds, cyan/ice-blue accents, white/muted-gray typography
/// Material 3 compatible with custom extensions

/// Core color palette - Static constants only
class EdithColors {
  const EdithColors._(); // Prevent instantiation

  // Public static constants for direct access (e.g., EdithColors.panel)
  static const Color bgPrimary = Color(0xFF080E16);
  static const Color background = Color(0xFF080E16);
  static const Color panel = Color(0xFF121D2A);
  static const Color surface = Color(0xFF1A2838);
  static const Color panelElevated = Color(0xFF1A2838);
  static const Color panelBorder = Color(0xFF1E2D3D);
  static const Color borderColor = Color(0xFF1E2D3D);
  static const Color accent = Color(0xFFD3DCDF); // Ice blue / cyan-white
  static const Color accentStrong = Color(0xFF00E5FF); // Bright cyan
  static const Color accentMuted = Color(0xFF8B9DA8);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textMuted = Color(0xFF78909C);
  static const Color textDisabled = Color(0xFF546E7A);
  static const Color glowColor = Color(0xFF00E5FF);
  static const Color success = Color(0xFF00E676);
  static const Color info = Color(0xFF00B4FF);
  static const Color warning = Color(0xFFFFB300);
  static const Color danger = Color(0xFFFF1744);

  // Status Colors
  static const Color statusLive = Color(0xFF00E676); // Green
  static const Color statusWarning = Color(0xFFFFB300); // Amber
  static const Color statusError = Color(0xFFFF1744); // Red
  static const Color statusSimulation = Color(0xFFD3DCDF); // Accent (ice blue)
  static const Color statusUnavailable = Color(0xFF546E7A); // Muted gray
}

/// Spacing scale - Static constants only
class EdithSpacing {
  const EdithSpacing._(); // Prevent instantiation

  // Public static constants for direct access (e.g., EdithSpacing.md)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Border radius scale - Static constants only
class EdithRadius {
  const EdithRadius._(); // Prevent instantiation

  // Public static constants for direct access (e.g., EdithRadius.md)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double round = 999.0;
}

/// Typography scale - Static constants only
class EdithTypography {
  const EdithTypography._(); // Prevent instantiation

  // Public static constants for direct access (e.g., EdithTypography.bodyMedium)
  static const TextStyle displayLarge = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  );

  static const TextStyle displayMedium = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 45,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle displaySmall = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 36,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle headlineLarge = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const TextStyle headlineMedium = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const TextStyle headlineSmall = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const TextStyle titleLarge = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static const TextStyle titleMedium = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    color: Color(0xFFB0BEC5),
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static const TextStyle bodyLarge = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    color: Color(0xFFB0BEC5),
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    color: Color(0xFF78909C),
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  static const TextStyle labelLarge = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    color: Color(0xFFB0BEC5),
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    color: Color(0xFF78909C),
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // Aliases for easier access
  static const TextStyle bodyStyle = bodyMedium;
  static const TextStyle captionStyle = labelSmall;
  static const TextStyle headlineStyle = headlineMedium;
}

/// Animation durations - Static constants only
class EdithDurations {
  const EdithDurations._(); // Prevent instantiation

  // Public static constants for direct access (e.g., EdithDurations.normal)
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration verySlow = Duration(milliseconds: 500);
}

/// Animation curves - Static constants only
class EdithCurves {
  const EdithCurves._(); // Prevent instantiation

  // Public static constants for direct access (e.g., EdithCurves.standard)
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve decelerate = Curves.easeOutQuart;
  static const Curve accelerate = Curves.easeInQuart;
}

/// Touch target minimums - Static constants only
class EdithTouchTarget {
  const EdithTouchTarget._(); // Prevent instantiation

  // Public static constants for direct access (e.g., EdithTouchTarget.min)
  static const double min = 48.0;
  static const double small = 44.0;
  static const double icon = 48.0;
}

/// Instance interface for EdithColors (for ThemeExtension access)
abstract class EdithColorsInstance {
  Color get bgPrimary;
  Color get background;
  Color get panel;
  Color get surface;
  Color get panelElevated;
  Color get panelBorder;
  Color get borderColor;
  Color get accent;
  Color get accentStrong;
  Color get accentMuted;
  Color get textPrimary;
  Color get textSecondary;
  Color get textMuted;
  Color get textDisabled;
  Color get glowColor;
  Color get success;
  Color get info;
  Color get warning;
  Color get danger;
  Color get statusLive;
  Color get statusWarning;
  Color get statusError;
  Color get statusSimulation;
  Color get statusUnavailable;
}

/// Instance interface for EdithSpacing (for ThemeExtension access)
abstract class EdithSpacingInstance {
  double get xs;
  double get sm;
  double get md;
  double get lg;
  double get xl;
  double get xxl;
}

/// Instance interface for EdithRadius (for ThemeExtension access)
abstract class EdithRadiusInstance {
  double get xs;
  double get sm;
  double get md;
  double get lg;
  double get xl;
  double get round;
}

/// Instance interface for EdithTypography (for ThemeExtension access)
abstract class EdithTypographyInstance {
  TextStyle get displayLarge;
  TextStyle get displayMedium;
  TextStyle get displaySmall;
  TextStyle get headlineLarge;
  TextStyle get headlineMedium;
  TextStyle get headlineSmall;
  TextStyle get titleLarge;
  TextStyle get titleMedium;
  TextStyle get titleSmall;
  TextStyle get bodyLarge;
  TextStyle get bodyMedium;
  TextStyle get bodySmall;
  TextStyle get labelLarge;
  TextStyle get labelMedium;
  TextStyle get labelSmall;
  TextStyle get bodyStyle;
  TextStyle get captionStyle;
  TextStyle get headlineStyle;
}

/// Instance interface for EdithDurations (for ThemeExtension access)
abstract class EdithDurationsInstance {
  Duration get fast;
  Duration get normal;
  Duration get slow;
  Duration get verySlow;
}

/// Instance interface for EdithCurves (for ThemeExtension access)
abstract class EdithCurvesInstance {
  Curve get standard;
  Curve get emphasized;
  Curve get decelerate;
  Curve get accelerate;
}

/// Instance interface for EdithTouchTarget (for ThemeExtension access)
abstract class EdithTouchTargetInstance {
  double get min;
  double get small;
  double get icon;
}

/// Theme extension for easy access in widgets via context.edithTheme
class EdithThemeExtension extends ThemeExtension<EdithThemeExtension> {
  const EdithThemeExtension();

  // Instance getters that return instances with instance accessors for ThemeExtension access
  EdithColorsInstance get colors => const _EdithColorsInstanceImpl();
  EdithSpacingInstance get spacing => const _EdithSpacingInstanceImpl();
  EdithRadiusInstance get radius => const _EdithRadiusInstanceImpl();
  EdithTypographyInstance get typography => const _EdithTypographyInstanceImpl();
  EdithDurationsInstance get durations => const _EdithDurationsInstanceImpl();
  EdithCurvesInstance get curves => const _EdithCurvesInstanceImpl();
  EdithTouchTargetInstance get touchTarget => const _EdithTouchTargetInstanceImpl();

  @override
  EdithThemeExtension copyWith({
    EdithColorsInstance? colors,
    EdithSpacingInstance? spacing,
    EdithRadiusInstance? radius,
    EdithTypographyInstance? typography,
    EdithDurationsInstance? durations,
    EdithCurvesInstance? curves,
    EdithTouchTargetInstance? touchTarget,
  }) {
    return const EdithThemeExtension();
  }

  @override
  EdithThemeExtension lerp(ThemeExtension<EdithThemeExtension>? other, double t) {
    return this; // No interpolation needed for these values
  }
}

/// Instance implementation for EdithColors providing instance accessors
class _EdithColorsInstanceImpl implements EdithColorsInstance {
  const _EdithColorsInstanceImpl();

  // Instance getters that delegate to static constants
  @override
  Color get bgPrimary => EdithColors.bgPrimary;
  @override
  Color get background => EdithColors.background;
  @override
  Color get panel => EdithColors.panel;
  @override
  Color get surface => EdithColors.surface;
  @override
  Color get panelElevated => EdithColors.panelElevated;
  @override
  Color get panelBorder => EdithColors.panelBorder;
  @override
  Color get borderColor => EdithColors.borderColor;
  @override
  Color get accent => EdithColors.accent;
  @override
  Color get accentStrong => EdithColors.accentStrong;
  @override
  Color get accentMuted => EdithColors.accentMuted;
  @override
  Color get textPrimary => EdithColors.textPrimary;
  @override
  Color get textSecondary => EdithColors.textSecondary;
  @override
  Color get textMuted => EdithColors.textMuted;
  @override
  Color get textDisabled => EdithColors.textDisabled;
  @override
  Color get glowColor => EdithColors.glowColor;
  @override
  Color get success => EdithColors.success;
  @override
  Color get info => EdithColors.info;
  @override
  Color get warning => EdithColors.warning;
  @override
  Color get danger => EdithColors.danger;
  @override
  Color get statusLive => EdithColors.statusLive;
  @override
  Color get statusWarning => EdithColors.statusWarning;
  @override
  Color get statusError => EdithColors.statusError;
  @override
  Color get statusSimulation => EdithColors.statusSimulation;
  @override
  Color get statusUnavailable => EdithColors.statusUnavailable;
}

/// Instance implementation for EdithSpacing providing instance accessors
class _EdithSpacingInstanceImpl implements EdithSpacingInstance {
  const _EdithSpacingInstanceImpl();

  @override
  double get xs => EdithSpacing.xs;
  @override
  double get sm => EdithSpacing.sm;
  @override
  double get md => EdithSpacing.md;
  @override
  double get lg => EdithSpacing.lg;
  @override
  double get xl => EdithSpacing.xl;
  @override
  double get xxl => EdithSpacing.xxl;
}

/// Instance implementation for EdithRadius providing instance accessors
class _EdithRadiusInstanceImpl implements EdithRadiusInstance {
  const _EdithRadiusInstanceImpl();

  @override
  double get xs => EdithRadius.xs;
  @override
  double get sm => EdithRadius.sm;
  @override
  double get md => EdithRadius.md;
  @override
  double get lg => EdithRadius.lg;
  @override
  double get xl => EdithRadius.xl;
  @override
  double get round => EdithRadius.round;
}

/// Instance implementation for EdithTypography providing instance accessors
class _EdithTypographyInstanceImpl implements EdithTypographyInstance {
  const _EdithTypographyInstanceImpl();

  @override
  TextStyle get displayLarge => EdithTypography.displayLarge;
  @override
  TextStyle get displayMedium => EdithTypography.displayMedium;
  @override
  TextStyle get displaySmall => EdithTypography.displaySmall;
  @override
  TextStyle get headlineLarge => EdithTypography.headlineLarge;
  @override
  TextStyle get headlineMedium => EdithTypography.headlineMedium;
  @override
  TextStyle get headlineSmall => EdithTypography.headlineSmall;
  @override
  TextStyle get titleLarge => EdithTypography.titleLarge;
  @override
  TextStyle get titleMedium => EdithTypography.titleMedium;
  @override
  TextStyle get titleSmall => EdithTypography.titleSmall;
  @override
  TextStyle get bodyLarge => EdithTypography.bodyLarge;
  @override
  TextStyle get bodyMedium => EdithTypography.bodyMedium;
  @override
  TextStyle get bodySmall => EdithTypography.bodySmall;
  @override
  TextStyle get labelLarge => EdithTypography.labelLarge;
  @override
  TextStyle get labelMedium => EdithTypography.labelMedium;
  @override
  TextStyle get labelSmall => EdithTypography.labelSmall;
  @override
  TextStyle get bodyStyle => EdithTypography.bodyStyle;
  @override
  TextStyle get captionStyle => EdithTypography.captionStyle;
  @override
  TextStyle get headlineStyle => EdithTypography.headlineStyle;
}

/// Instance implementation for EdithDurations providing instance accessors
class _EdithDurationsInstanceImpl implements EdithDurationsInstance {
  const _EdithDurationsInstanceImpl();

  @override
  Duration get fast => EdithDurations.fast;
  @override
  Duration get normal => EdithDurations.normal;
  @override
  Duration get slow => EdithDurations.slow;
  @override
  Duration get verySlow => EdithDurations.verySlow;
}

/// Instance implementation for EdithCurves providing instance accessors
class _EdithCurvesInstanceImpl implements EdithCurvesInstance {
  const _EdithCurvesInstanceImpl();

  @override
  Curve get standard => EdithCurves.standard;
  @override
  Curve get emphasized => EdithCurves.emphasized;
  @override
  Curve get decelerate => EdithCurves.decelerate;
  @override
  Curve get accelerate => EdithCurves.accelerate;
}

/// Instance implementation for EdithTouchTarget providing instance accessors
class _EdithTouchTargetInstanceImpl implements EdithTouchTargetInstance {
  const _EdithTouchTargetInstanceImpl();

  @override
  double get min => EdithTouchTarget.min;
  @override
  double get small => EdithTouchTarget.small;
  @override
  double get icon => EdithTouchTarget.icon;
}

/// Creates the complete Edith ThemeData
ThemeData createEdithThemeData() {
  // Use the public static constants for compile-time constants in ThemeData
  const Color bgPrimary = Color(0xFF080E16);
  const Color background = Color(0xFF080E16);
  const Color panel = Color(0xFF121D2A);
  const Color surface = Color(0xFF1A2838);
  const Color panelElevated = Color(0xFF1A2838);
  const Color panelBorder = Color(0xFF1E2D3D);
  const Color borderColor = Color(0xFF1E2D3D);
  const Color accent = Color(0xFFD3DCDF);
  const Color accentStrong = Color(0xFF00E5FF);
  const Color accentMuted = Color(0xFF8B9DA8);
  const Color textPrimary = Colors.white;
  const Color textSecondary = Color(0xFFB0BEC5);
  const Color textMuted = Color(0xFF78909C);
  const Color textDisabled = Color(0xFF546E7A);
  const Color glowColor = Color(0xFF00E5FF);
  const Color success = Color(0xFF00E676);
  const Color info = Color(0xFF00B4FF);
  const Color warning = Color(0xFFFFB300);
  const Color danger = Color(0xFFFF1744);
  const Color statusLive = Color(0xFF00E676);
  const Color statusWarning = Color(0xFFFFB300);
  const Color statusError = Color(0xFFFF1744);
  const Color statusSimulation = Color(0xFFD3DCDF);
  const Color statusUnavailable = Color(0xFF546E7A);

  const double spacingXs = 4.0;
  const double spacingSm = 8.0;
  const double spacingMd = 16.0;
  const double spacingLg = 24.0;
  const double spacingXl = 32.0;
  const double spacingXxl = 48.0;

  const double radiusXs = 4.0;
  const double radiusSm = 8.0;
  const double radiusMd = 12.0;
  const double radiusLg = 16.0;
  const double radiusXl = 24.0;
  const double radiusRound = 999.0;

  const double touchMin = 48.0;
  const double touchSmall = 44.0;
  const double touchIcon = 48.0;

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
        borderRadius: BorderRadius.circular(radiusLg),
        side: const BorderSide(color: panelBorder, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentStrong,
        foregroundColor: background,
        elevation: 0,
        minimumSize: const Size(double.infinity, touchMin),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLg,
          vertical: spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
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
        minimumSize: const Size(double.infinity, touchMin),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLg,
          vertical: spacingMd,
        ),
        side: const BorderSide(color: accent, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
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
        minimumSize: const Size(touchMin, touchMin),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
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
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: panelBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: panelBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: accentStrong, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: statusError),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingMd,
        vertical: spacingMd,
      ),
      hintStyle: const TextStyle(color: textMuted),
      labelStyle: const TextStyle(color: textSecondary),
    ),
    dividerTheme: const DividerThemeData(
      color: panelBorder,
      thickness: 1,
      space: spacingLg,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: panelElevated,
      selectedColor: accentStrong.withValues(alpha: 0.2),
      disabledColor: panelBorder.withValues(alpha: 0.3),
      labelStyle: const TextStyle(color: textPrimary, fontSize: 12),
      secondaryLabelStyle: const TextStyle(color: accent, fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: spacingSm, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusSm),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: panel,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusXl),
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
        borderRadius: BorderRadius.circular(radiusMd),
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
    extensions: [
      const EdithThemeExtension(),
    ],
  );
}

/// Extension for easy access to EdithThemeExtension
extension EdithThemeExt on BuildContext {
  EdithThemeExtension get edithTheme {
    final extension = Theme.of(this).extension<EdithThemeExtension>();
    return extension ?? const EdithThemeExtension();
  }
}