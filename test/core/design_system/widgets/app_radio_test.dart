import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/widgets/app_radio.dart';

import '../../../helpers/helpers.dart';

enum _Privacy { everyone, friends }

AppColors _colorsOf(TestLayout layout) =>
    layout.brightness == Brightness.dark ? AppColors.dark : AppColors.light;

void main() {
  testAcrossLayouts('marks the selected value with a dot', (
    tester,
    layout,
  ) async {
    _Privacy? picked;
    await tester.pumpApp(
      Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              for (final privacy in _Privacy.values)
                AppRadio<_Privacy>(
                  key: ValueKey(privacy),
                  value: privacy,
                  groupValue: _Privacy.friends,
                  label: privacy.name,
                  onChanged: (value) => picked = value,
                ),
            ],
          ),
        ),
      ),
      layout: layout,
    );

    final colors = _colorsOf(layout);
    final dots = find.byKey(AppRadio.dotKey);
    expect(dots, findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey(_Privacy.friends)),
        matching: dots,
      ),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byKey(AppRadio.ringKey).first),
      const Size.square(AppSizes.radio),
    );
    final ring =
        tester.widget<Container>(find.byKey(AppRadio.ringKey).first).decoration!
            as BoxDecoration;
    expect(
      ring.border,
      Border.all(color: colors.text, width: AppSizes.ringWidth),
    );
    expect(
      tester
          .renderObject<RenderParagraph>(find.text('everyone'))
          .text
          .style
          ?.color,
      colors.text,
    );
    expect(
      tester.getSemantics(find.byKey(const ValueKey(_Privacy.friends))),
      isSemantics(
        label: 'friends',
        isChecked: true,
        hasCheckedState: true,
        isInMutuallyExclusiveGroup: true,
        hasTapAction: true,
      ),
    );

    await tester.tap(find.text('everyone'));
    expect(picked, _Privacy.everyone);
  });

  testAcrossLayouts('is 48 to tap without a label', (tester, layout) async {
    await tester.pumpApp(
      Scaffold(
        body: Center(
          child: AppRadio<_Privacy>(
            value: _Privacy.everyone,
            groupValue: null,
            onChanged: (_) {},
          ),
        ),
      ),
      layout: layout,
    );

    final size = tester.getSize(find.byType(AppRadio<_Privacy>));
    expect(size.width, greaterThanOrEqualTo(AppSizes.minTapTarget));
    expect(size.height, greaterThanOrEqualTo(AppSizes.minTapTarget));
    expect(find.byKey(AppRadio.dotKey), findsNothing);
  });
}
