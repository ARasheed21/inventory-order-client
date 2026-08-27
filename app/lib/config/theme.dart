import 'package:flutter/material.dart';

import 'package:core/core.dart';

/// Binds core design tokens into Flutter [ThemeData] (FR-004).
///
/// This is the ONLY place raw token values are converted to Flutter types.
/// Screens consume the resulting theme — never `Color(0x...)` literals.
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: _color(AppColors.primary, brightness),
          brightness: brightness,
        ).copyWith(
          primary: _color(AppColors.primary, brightness),
          onPrimary: _color(AppColors.onPrimary, brightness),
          surface: _color(AppColors.surface, brightness),
          onSurface: _color(AppColors.onSurface, brightness),
          error: _color(AppColors.error, brightness),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _color(AppColors.background, brightness),
      extensions: <ThemeExtension<dynamic>>[
        AppSpacingExtension.fromTokens(),
        AppRadiusExtension.fromTokens(),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: _color(AppColors.surface, brightness),
        foregroundColor: _color(AppColors.onSurface, brightness),
      ),
      textTheme: _textTheme(brightness),
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    final Color onSurface = _color(AppColors.onSurface, brightness);
    return TextTheme(
      displaySmall: TextStyle(
        fontSize: AppTypography.sizes[TextRole.display]!,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: AppTypography.sizes[TextRole.headline]!,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: AppTypography.sizes[TextRole.title]!,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: AppTypography.sizes[TextRole.body]!,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: AppTypography.sizes[TextRole.caption]!,
        fontWeight: FontWeight.w400,
        color: _color(AppColors.muted, brightness),
      ),
    );
  }

  /// Parses a core hex token into a [Color] for the given brightness.
  static Color _color(DesignColor token, Brightness brightness) {
    final String hex = brightness == Brightness.light
        ? token.light
        : token.dark;
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }
}

/// Theme extension exposing the spacing scale to screens.
class AppSpacingExtension extends ThemeExtension<AppSpacingExtension> {
  const AppSpacingExtension({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  factory AppSpacingExtension.fromTokens() => const AppSpacingExtension(
    xs: AppSpacing.xs,
    sm: AppSpacing.sm,
    md: AppSpacing.md,
    lg: AppSpacing.lg,
    xl: AppSpacing.xl,
  );

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;

  @override
  AppSpacingExtension copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
  }) => AppSpacingExtension(
    xs: xs ?? this.xs,
    sm: sm ?? this.sm,
    md: md ?? this.md,
    lg: lg ?? this.lg,
    xl: xl ?? this.xl,
  );

  @override
  AppSpacingExtension lerp(AppSpacingExtension other, double t) =>
      t < 0.5 ? this : other;
}

/// Theme extension exposing the radius scale to screens.
class AppRadiusExtension extends ThemeExtension<AppRadiusExtension> {
  const AppRadiusExtension({
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  factory AppRadiusExtension.fromTokens() => const AppRadiusExtension(
    sm: AppRadius.sm,
    md: AppRadius.md,
    lg: AppRadius.lg,
    xl: AppRadius.xl,
  );

  final double sm;
  final double md;
  final double lg;
  final double xl;

  @override
  AppRadiusExtension copyWith({
    double? sm,
    double? md,
    double? lg,
    double? xl,
  }) => AppRadiusExtension(
    sm: sm ?? this.sm,
    md: md ?? this.md,
    lg: lg ?? this.lg,
    xl: xl ?? this.xl,
  );

  @override
  AppRadiusExtension lerp(AppRadiusExtension other, double t) =>
      t < 0.5 ? this : other;
}
