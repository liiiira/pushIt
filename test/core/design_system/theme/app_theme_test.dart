import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/tokens/app_typography.dart';

void main() {
  for (final (name, theme, colors, brightness) in [
    ('light', AppTheme.light(), AppColors.light, Brightness.light),
    ('dark', AppTheme.dark(), AppColors.dark, Brightness.dark),
  ]) {
    group('AppTheme.$name', () {
      test('carries the tokens as extensions', () {
        expect(theme.brightness, brightness);
        expect(theme.extension<AppColors>(), colors);
        expect(theme.extension<AppTypography>(), AppTypography.standard);
      });

      test('paints screens with bg and accents with accent', () {
        final scheme = theme.colorScheme;

        expect(theme.scaffoldBackgroundColor, colors.bg);
        expect(theme.canvasColor, colors.bg);
        expect(scheme.brightness, brightness);
        expect(scheme.primary, colors.accent);
        expect(scheme.onPrimary, colors.onAccent);
        expect(scheme.onSurface, colors.text);
        expect(scheme.onSurfaceVariant, colors.sub);
        expect(scheme.outline, colors.line);
        expect(scheme.scrim, colors.scrim);
      });

      test('keeps Material surfaces flat and on surface', () {
        final scheme = theme.colorScheme;

        for (final surface in [
          scheme.surface,
          scheme.surfaceContainerLowest,
          scheme.surfaceContainerLow,
          scheme.surfaceContainer,
          scheme.surfaceContainerHigh,
          scheme.surfaceContainerHighest,
          scheme.surfaceBright,
          scheme.surfaceDim,
        ]) {
          expect(surface, colors.surface);
        }
        expect(scheme.surfaceTint, AppColors.transparent);
        expect(scheme.shadow, AppColors.transparent);
        expect(theme.appBarTheme.elevation, 0);
        expect(theme.appBarTheme.scrolledUnderElevation, 0);
        expect(theme.appBarTheme.backgroundColor, colors.bg);
        expect(theme.cardTheme.elevation, 0);
        expect(theme.cardTheme.color, colors.surface);
        expect(theme.dialogTheme.elevation, 0);
        expect(theme.dialogTheme.backgroundColor, colors.surface);
        expect(theme.dialogTheme.barrierColor, colors.scrim);
        expect(theme.bottomSheetTheme.elevation, 0);
        expect(theme.bottomSheetTheme.modalElevation, 0);
        expect(theme.bottomSheetTheme.backgroundColor, colors.surface);
        expect(theme.bottomSheetTheme.modalBarrierColor, colors.scrim);
        expect(theme.dividerTheme.color, colors.line);
      });

      test('sets Hanken Grotesk with its weight axis on Material text', () {
        final text = theme.textTheme;

        expect(text.bodyMedium?.fontFamily, AppTypography.fontFamily);
        expect(
          text.bodyMedium?.fontVariations,
          AppTypography.standard.body.fontVariations,
        );
        expect(
          text.titleLarge?.fontVariations,
          AppTypography.standard.title.fontVariations,
        );
        expect(
          text.labelLarge?.fontVariations,
          AppTypography.standard.button.fontVariations,
        );
        expect(text.bodyMedium?.color, colors.text);
      });
    });
  }

  group('context accessors', () {
    Future<(AppColors, AppTypography)> read(
      WidgetTester tester,
      ThemeData? theme,
    ) async {
      late AppColors colors;
      late AppTypography styles;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              colors = context.colors;
              styles = context.textStyles;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      return (colors, styles);
    }

    testWidgets('read the tokens of the light theme', (tester) async {
      final (colors, styles) = await read(tester, AppTheme.light());

      expect(colors, AppColors.light);
      expect(styles, AppTypography.standard);
    });

    testWidgets('read the tokens of the dark theme', (tester) async {
      final (colors, _) = await read(tester, AppTheme.dark());

      expect(colors, AppColors.dark);
    });

    testWidgets('fall back to the tokens of the theme brightness', (
      tester,
    ) async {
      final (colors, styles) = await read(
        tester,
        ThemeData(brightness: Brightness.dark),
      );

      expect(colors, AppColors.dark);
      expect(styles, AppTypography.standard);
    });
  });
}
