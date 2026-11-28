import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/widgets/app_button_size.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/design_system/widgets/secondary_button.dart';
import 'package:pushit/core/design_system/widgets/text_action_button.dart';

import '../../../helpers/helpers.dart';

AppColors _colorsOf(TestLayout layout) =>
    layout.brightness == Brightness.dark ? AppColors.dark : AppColors.light;

Material _surfaceOf(WidgetTester tester, Type button) =>
    tester.widget<Material>(
      find.descendant(of: find.byType(button), matching: find.byType(Material)),
    );

Size _visibleSizeOf(WidgetTester tester, Type button) => tester.getSize(
  find.descendant(of: find.byType(button), matching: find.byType(Material)),
);

Widget _column(List<Widget> children) => Scaffold(
  body: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(mainAxisSize: MainAxisSize.min, children: children),
  ),
);

void main() {
  group('PrimaryButton', () {
    testAcrossLayouts('is a full-width accent pill, 56 high', (
      tester,
      layout,
    ) async {
      var taps = 0;
      await tester.pumpApp(
        _column([PrimaryButton(label: 'Schedule', onPressed: () => taps++)]),
        layout: layout,
      );

      final colors = _colorsOf(layout);
      final surface = _surfaceOf(tester, PrimaryButton);
      expect(surface.color, colors.accent);
      expect(surface.shape, isA<StadiumBorder>());
      expect(surface.elevation, 0);
      expect(
        _visibleSizeOf(tester, PrimaryButton),
        Size(layout.size.width - 48, AppSizes.buttonHeight),
      );
      expect(
        tester
            .renderObject<RenderParagraph>(find.text('Schedule'))
            .text
            .style
            ?.color,
        colors.onAccent,
      );

      await tester.tap(find.byType(PrimaryButton));
      expect(taps, 1);
    });

    testAcrossLayouts('small hugs its label, 40 high, 48 to tap', (
      tester,
      layout,
    ) async {
      await tester.pumpApp(
        _column([
          PrimaryButton(
            label: 'See plans',
            size: AppButtonSize.small,
            onPressed: () {},
          ),
        ]),
        layout: layout,
      );

      final visible = _visibleSizeOf(tester, PrimaryButton);
      expect(visible.height, AppSizes.buttonHeightSmall);
      expect(visible.width, lessThan(layout.size.width - 48));
      expect(
        tester.getSize(find.byType(PrimaryButton)).height,
        greaterThanOrEqualTo(AppSizes.minTapTarget),
      );
    });

    testWidgets('is disabled without onPressed', (tester) async {
      await tester.pumpApp(
        _column([const PrimaryButton(label: 'Schedule', onPressed: null)]),
      );

      expect(_surfaceOf(tester, PrimaryButton).color, AppColors.light.block);
      final button = tester.widget<ButtonStyleButton>(
        find.descendant(
          of: find.byType(PrimaryButton),
          matching: find.bySubtype<ButtonStyleButton>(),
        ),
      );
      expect(button.enabled, isFalse);
    });
  });

  group('SecondaryButton', () {
    testAcrossLayouts('is an outlined pill on no fill, 56 high', (
      tester,
      layout,
    ) async {
      var taps = 0;
      await tester.pumpApp(
        _column([
          SecondaryButton(
            label: 'Continue with Google',
            onPressed: () => taps++,
          ),
        ]),
        layout: layout,
      );

      final colors = _colorsOf(layout);
      final surface = _surfaceOf(tester, SecondaryButton);
      expect(surface.color, AppColors.transparent);
      final shape = surface.shape! as StadiumBorder;
      expect(shape.side.color, colors.text);
      expect(shape.side.width, AppSizes.ringWidth);
      expect(
        _visibleSizeOf(tester, SecondaryButton).height,
        AppSizes.buttonHeight,
      );

      await tester.tap(find.byType(SecondaryButton));
      expect(taps, 1);
    });

    testAcrossLayouts('small is 40 high, 48 to tap', (tester, layout) async {
      await tester.pumpApp(
        _column([
          SecondaryButton(
            label: 'Add account',
            size: AppButtonSize.small,
            onPressed: () {},
          ),
        ]),
        layout: layout,
      );

      expect(
        _visibleSizeOf(tester, SecondaryButton).height,
        AppSizes.buttonHeightSmall,
      );
      expect(
        tester.getSize(find.byType(SecondaryButton)).height,
        greaterThanOrEqualTo(AppSizes.minTapTarget),
      );
    });
  });

  group('TextActionButton', () {
    testAcrossLayouts('is a plain label in text colour', (
      tester,
      layout,
    ) async {
      var taps = 0;
      await tester.pumpApp(
        _column([
          TextActionButton(label: 'Disconnect', onPressed: () => taps++),
          TextActionButton(
            label: 'Fix',
            size: AppButtonSize.small,
            isUnderlined: true,
            onPressed: () {},
          ),
        ]),
        layout: layout,
      );

      final colors = _colorsOf(layout);
      final style = tester
          .renderObject<RenderParagraph>(find.text('Disconnect'))
          .text
          .style;
      expect(style?.color, colors.text);
      expect(style?.decoration, TextDecoration.none);
      final fix = tester.renderObject<RenderParagraph>(find.text('Fix'));
      expect(fix.text.style?.decoration, TextDecoration.underline);
      expect(
        tester.getSize(find.byType(TextActionButton).last).height,
        greaterThanOrEqualTo(AppSizes.minTapTarget),
      );

      await tester.tap(find.text('Disconnect'));
      expect(taps, 1);
    });
  });

  testWidgets('read their colours from the surrounding theme', (tester) async {
    await tester.pumpApp(
      Theme(
        data: AppTheme.dark(),
        child: _column([PrimaryButton(label: 'Go', onPressed: () {})]),
      ),
    );

    expect(_surfaceOf(tester, PrimaryButton).color, AppColors.dark.accent);
  });
}
