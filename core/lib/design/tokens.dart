/// Centralized design tokens (Constitution VII, FR-004).
///
/// Pure Dart data: platform packages bind these into their own theming
/// systems (Flutter `ThemeData` extensions; web CSS variables). Client-local
/// overrides of token values are forbidden.
///
/// Colors are hex strings so both platforms can consume them without a
/// Flutter dependency in core.
library;

import 'package:meta/meta.dart';

/// A semantic color with light and dark mode variants.
@immutable
final class DesignColor {
  const DesignColor(this.light, this.dark);

  /// Hex string used for light mode (e.g. `#1565C0`).
  final String light;

  /// Hex string used for dark mode.
  final String dark;
}

abstract final class AppColors {
  static const DesignColor primary = DesignColor('#1565C0', '#90CAF9');
  static const DesignColor onPrimary = DesignColor('#FFFFFF', '#003258');
  static const DesignColor surface = DesignColor('#FFFFFF', '#121212');
  static const DesignColor onSurface = DesignColor('#1C1B1F', '#E6E1E5');
  static const DesignColor background = DesignColor('#FAFAFA', '#0E0E0E');
  static const DesignColor error = DesignColor('#B3261E', '#F2B8B5');
  static const DesignColor success = DesignColor('#2E7D32', '#A5D6A7');
  static const DesignColor warning = DesignColor('#ED6C02', '#FFCC80');
  static const DesignColor muted = DesignColor('#79747E', '#938F99');
}

/// Spacing scale based on a 4pt grid.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  /// Ordered scale, useful for mirroring into CSS variables.
  static const Map<String, double> all = {
    'xs': xs,
    'sm': sm,
    'md': md,
    'lg': lg,
    'xl': xl,
  };
}

/// Corner radius scale.
abstract final class AppRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;

  static const Map<String, double> all = {
    'sm': sm,
    'md': md,
    'lg': lg,
    'xl': xl,
  };
}

/// Typography roles.
enum TextRole {
  display(32, 700),
  headline(24, 600),
  title(18, 600),
  body(14, 400),
  caption(12, 400);

  const TextRole(this.sizeSp, this.weight);

  final double sizeSp;
  final int weight;
}

abstract final class AppTypography {
  static const String fontFamily = 'Roboto';

  static Map<TextRole, double> get sizes => {
    for (final TextRole role in TextRole.values) role: role.sizeSp,
  };
}
