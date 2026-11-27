import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/tokens/app_radii.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_typography.dart';

/// The two app themes, built from the tokens.
///
/// Widgets read the tokens with `context.colors` and `context.textStyles`.
/// The Material slots are mapped too (flat, no tint, no shadow), so a stock
/// Material widget still renders in the pushIt greys.
abstract final class AppTheme {
  /// Light (Fog), the default.
  static ThemeData light() => _build(AppColors.light, Brightness.light);

  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors colors, Brightness brightness) {
    const styles = AppTypography.standard;
    const none = AppColors.transparent;
    const sheetTop = BorderRadius.vertical(
      top: Radius.circular(AppRadii.sheet),
    );
    const allSheet = BorderRadius.all(Radius.circular(AppRadii.sheet));
    const allCard = BorderRadius.all(Radius.circular(AppRadii.card));

    final scheme = ColorScheme(
      brightness: brightness,
      primary: colors.accent,
      onPrimary: colors.onAccent,
      primaryContainer: colors.block,
      onPrimaryContainer: colors.text,
      secondary: colors.accent,
      onSecondary: colors.onAccent,
      secondaryContainer: colors.block,
      onSecondaryContainer: colors.text,
      tertiary: colors.accent,
      onTertiary: colors.onAccent,
      tertiaryContainer: colors.block,
      onTertiaryContainer: colors.text,
      // Greys only: errors are shown with an icon and a word.
      error: colors.text,
      onError: colors.surface,
      errorContainer: colors.block,
      onErrorContainer: colors.text,
      surface: colors.surface,
      onSurface: colors.text,
      surfaceDim: colors.surface,
      surfaceBright: colors.surface,
      surfaceContainerLowest: colors.surface,
      surfaceContainerLow: colors.surface,
      surfaceContainer: colors.surface,
      surfaceContainerHigh: colors.surface,
      surfaceContainerHighest: colors.surface,
      onSurfaceVariant: colors.sub,
      outline: colors.line,
      outlineVariant: colors.line,
      shadow: none,
      scrim: colors.scrim,
      inverseSurface: colors.accent,
      onInverseSurface: colors.onAccent,
      inversePrimary: colors.onAccent,
      surfaceTint: none,
    );

    final textTheme = TextTheme(
      displayLarge: styles.time,
      displayMedium: styles.time,
      displaySmall: styles.h1,
      headlineLarge: styles.h1,
      headlineMedium: styles.h1,
      headlineSmall: styles.title,
      titleLarge: styles.title,
      titleMedium: styles.bodyStrong,
      titleSmall: styles.bodyStrong,
      bodyLarge: styles.body,
      bodyMedium: styles.body,
      bodySmall: styles.small,
      labelLarge: styles.button,
      labelMedium: styles.small,
      labelSmall: styles.tiny,
    ).apply(bodyColor: colors.text, displayColor: colors.text);

    return ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.bg,
      canvasColor: colors.bg,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      extensions: [colors, styles],
      iconTheme: IconThemeData(color: colors.text, size: AppSizes.icon),
      dividerTheme: DividerThemeData(color: colors.line, thickness: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.bg,
        foregroundColor: colors.text,
        surfaceTintColor: none,
        shadowColor: none,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        toolbarHeight: AppSizes.topBarHeight,
        titleTextStyle: styles.bodyStrong.copyWith(color: colors.text),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        surfaceTintColor: none,
        shadowColor: none,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: allCard),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: none,
        shadowColor: none,
        elevation: 0,
        barrierColor: colors.scrim,
        shape: const RoundedRectangleBorder(borderRadius: allSheet),
        titleTextStyle: styles.title.copyWith(color: colors.text),
        contentTextStyle: styles.body.copyWith(color: colors.sub),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        modalBackgroundColor: colors.surface,
        surfaceTintColor: none,
        shadowColor: none,
        elevation: 0,
        modalElevation: 0,
        modalBarrierColor: colors.scrim,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(borderRadius: sheetTop),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.accent,
        contentTextStyle: styles.body.copyWith(color: colors.onAccent),
        actionTextColor: colors.onAccent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.accent,
        linearTrackColor: colors.line,
        circularTrackColor: colors.line,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.text,
        selectionColor: colors.block,
        selectionHandleColor: colors.text,
      ),
    );
  }
}

/// The pushIt tokens of the surrounding theme.
extension AppThemeContext on BuildContext {
  /// The colour tokens. Outside an `AppTheme`, the tokens of the theme
  /// brightness.
  AppColors get colors {
    final theme = Theme.of(this);
    return theme.extension<AppColors>() ??
        (theme.brightness == Brightness.dark
            ? AppColors.dark
            : AppColors.light);
  }

  /// The text styles, without colour.
  AppTypography get textStyles =>
      Theme.of(this).extension<AppTypography>() ?? AppTypography.standard;
}
