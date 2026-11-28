import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/widgets/app_switch.dart';

import '../../../helpers/helpers.dart';

AppColors _colorsOf(TestLayout layout) =>
    layout.brightness == Brightness.dark ? AppColors.dark : AppColors.light;

BoxDecoration _decorationOf(WidgetTester tester, Key key) =>
    tester.widget<AnimatedContainer>(find.byKey(key)).decoration!
        as BoxDecoration;

void main() {
  testAcrossLayouts('on: accent track, onAccent thumb', (tester, layout) async {
    bool? changed;
    await tester.pumpApp(
      Scaffold(
        body: Center(
          child: AppSwitch(value: true, onChanged: (value) => changed = value),
        ),
      ),
      layout: layout,
    );

    final colors = _colorsOf(layout);
    expect(_decorationOf(tester, AppSwitch.trackKey).color, colors.accent);
    expect(_decorationOf(tester, AppSwitch.thumbKey).color, colors.onAccent);
    expect(
      tester.getSize(find.byKey(AppSwitch.trackKey)),
      AppSizes.switchTrack,
    );
    expect(
      tester.getSize(find.byKey(AppSwitch.thumbKey)),
      const Size.square(AppSizes.switchThumb),
    );
    expect(
      tester.getSize(find.byType(AppSwitch)).height,
      greaterThanOrEqualTo(AppSizes.minTapTarget),
    );
    expect(
      tester.getSemantics(find.byType(AppSwitch)),
      isSemantics(isToggled: true, hasToggledState: true, hasTapAction: true),
    );

    await tester.tap(find.byType(AppSwitch));
    expect(changed, isFalse);
  });

  testAcrossLayouts('off: block track, surface thumb on the left', (
    tester,
    layout,
  ) async {
    bool? changed;
    await tester.pumpApp(
      Scaffold(
        body: Center(
          child: AppSwitch(value: false, onChanged: (value) => changed = value),
        ),
      ),
      layout: layout,
    );
    await tester.pumpAndSettle();

    final colors = _colorsOf(layout);
    expect(_decorationOf(tester, AppSwitch.trackKey).color, colors.block);
    expect(_decorationOf(tester, AppSwitch.thumbKey).color, colors.surface);
    expect(
      tester.getCenter(find.byKey(AppSwitch.thumbKey)).dx,
      lessThan(tester.getCenter(find.byKey(AppSwitch.trackKey)).dx),
    );

    await tester.tap(find.byType(AppSwitch));
    expect(changed, isTrue);
  });

  testWidgets('does nothing without onChanged', (tester) async {
    await tester.pumpApp(
      const Scaffold(
        body: Center(child: AppSwitch(value: true, onChanged: null)),
      ),
    );

    expect(
      tester.getSemantics(find.byType(AppSwitch)),
      isSemantics(
        isToggled: true,
        hasToggledState: true,
        hasEnabledState: true,
        isEnabled: false,
      ),
    );
  });
}
