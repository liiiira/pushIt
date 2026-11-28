import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/tokens/app_radii.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_card.dart';

import '../../../helpers/helpers.dart';

Material _materialOf(WidgetTester tester) => tester.widget<Material>(
  find.descendant(of: find.byType(AppCard), matching: find.byType(Material)),
);

void main() {
  testAcrossLayouts('is a flat surface with card corners and padding', (
    tester,
    layout,
  ) async {
    await tester.pumpApp(
      const Scaffold(body: AppCard(child: SizedBox(width: 100, height: 40))),
      layout: layout,
    );

    final colors = layout.brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    final material = _materialOf(tester);
    expect(material.color, colors.surface);
    expect(material.elevation, 0);
    expect(
      material.borderRadius,
      const BorderRadius.all(Radius.circular(AppRadii.card)),
    );
    expect(
      tester.getSize(find.byType(AppCard)),
      const Size(
        100 + 2 * AppSpacing.cardPadding,
        40 + 2 * AppSpacing.cardPadding,
      ),
    );
    expect(find.byType(InkWell), findsNothing);
  });

  testWidgets('takes a custom padding', (tester) async {
    await tester.pumpApp(
      const Scaffold(
        body: AppCard(
          padding: EdgeInsets.zero,
          child: SizedBox(width: 100, height: 40),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AppCard)), const Size(100, 40));
  });

  testWidgets('is tappable when given onTap', (tester) async {
    var taps = 0;
    await tester.pumpApp(
      Scaffold(
        body: AppCard(
          onTap: () => taps++,
          child: const SizedBox(width: 100, height: 40),
        ),
      ),
    );

    await tester.tap(find.byType(AppCard));

    expect(taps, 1);
  });
}
