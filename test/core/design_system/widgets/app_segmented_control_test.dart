import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/widgets/app_segmented_control.dart';

import '../../../helpers/helpers.dart';

enum _Kind { problem, idea, other }

AppColors _colorsOf(TestLayout layout) =>
    layout.brightness == Brightness.dark ? AppColors.dark : AppColors.light;

Color? _textColor(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text)).text.style?.color;

void main() {
  testAcrossLayouts('highlights the selected segment on a surface pill', (
    tester,
    layout,
  ) async {
    _Kind? picked;
    await tester.pumpApp(
      Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: AppSegmentedControl<_Kind>(
            segments: [
              for (final kind in _Kind.values)
                AppSegment(value: kind, label: kind.name),
            ],
            selected: _Kind.problem,
            onChanged: (kind) => picked = kind,
          ),
        ),
      ),
      layout: layout,
    );

    final colors = _colorsOf(layout);
    final track =
        tester
                .widget<Container>(find.byKey(AppSegmentedControl.trackKey))
                .decoration!
            as BoxDecoration;
    expect(track.color, colors.surface);
    expect(track.borderRadius, isNotNull);
    expect(_textColor(tester, 'problem'), colors.onAccent);
    expect(_textColor(tester, 'idea'), colors.sub);
    expect(
      tester.getSize(find.byKey(AppSegmentedControl.trackKey)).height,
      greaterThanOrEqualTo(AppSizes.minTapTarget),
    );
    expect(
      tester.getSemantics(find.text('problem')),
      isSemantics(
        label: 'problem',
        isSelected: true,
        hasSelectedState: true,
        isButton: true,
        hasTapAction: true,
      ),
    );

    await tester.tap(find.text('other'));
    expect(picked, _Kind.other);
  });

  testAcrossLayouts('splits the width evenly', (tester, layout) async {
    await tester.pumpApp(
      Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: AppSegmentedControl<_Kind>(
            segments: const [
              AppSegment(value: _Kind.problem, label: 'Monthly'),
              AppSegment(value: _Kind.idea, label: 'Yearly'),
            ],
            selected: _Kind.idea,
            onChanged: (_) {},
          ),
        ),
      ),
      layout: layout,
    );

    final monthly = tester.getRect(find.byKey(const ValueKey(_Kind.problem)));
    final yearly = tester.getRect(find.byKey(const ValueKey(_Kind.idea)));
    expect(monthly.width, moreOrLessEquals(yearly.width));
  });
}
