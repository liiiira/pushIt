import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/widgets/app_checkbox.dart';

import '../../../helpers/helpers.dart';

AppColors _colorsOf(TestLayout layout) =>
    layout.brightness == Brightness.dark ? AppColors.dark : AppColors.light;

BoxDecoration _boxOf(WidgetTester tester) =>
    tester.widget<AnimatedContainer>(find.byKey(AppCheckbox.boxKey)).decoration!
        as BoxDecoration;

void main() {
  testAcrossLayouts('checked: accent box with a check, label tappable', (
    tester,
    layout,
  ) async {
    bool? changed;
    await tester.pumpApp(
      Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: AppCheckbox(
            value: true,
            label: 'I agree to the terms and privacy policy',
            onChanged: (value) => changed = value,
          ),
        ),
      ),
      layout: layout,
    );

    final colors = _colorsOf(layout);
    expect(_boxOf(tester).color, colors.accent);
    expect(find.byIcon(LucideIcons.check), findsOneWidget);
    expect(
      tester.getSize(find.byKey(AppCheckbox.boxKey)),
      const Size.square(AppSizes.checkbox),
    );
    expect(
      tester
          .renderObject<RenderParagraph>(find.textContaining('I agree'))
          .text
          .style
          ?.color,
      colors.text,
    );
    expect(
      tester.getSemantics(find.byType(AppCheckbox)),
      isSemantics(
        label: 'I agree to the terms and privacy policy',
        isChecked: true,
        hasCheckedState: true,
        hasTapAction: true,
      ),
    );

    await tester.tap(find.textContaining('I agree'));
    expect(changed, isFalse);
  });

  testAcrossLayouts('unchecked: outlined box, 48 to tap without a label', (
    tester,
    layout,
  ) async {
    bool? changed;
    await tester.pumpApp(
      Scaffold(
        body: Center(
          child: AppCheckbox(
            value: false,
            onChanged: (value) => changed = value,
          ),
        ),
      ),
      layout: layout,
    );

    final colors = _colorsOf(layout);
    final box = _boxOf(tester);
    expect(box.color, AppColors.transparent);
    expect(
      box.border,
      Border.all(color: colors.text, width: AppSizes.ringWidth),
    );
    expect(find.byIcon(LucideIcons.check), findsNothing);
    final size = tester.getSize(find.byType(AppCheckbox));
    expect(size.width, greaterThanOrEqualTo(AppSizes.minTapTarget));
    expect(size.height, greaterThanOrEqualTo(AppSizes.minTapTarget));

    await tester.tap(find.byType(AppCheckbox));
    expect(changed, isTrue);
  });
}
