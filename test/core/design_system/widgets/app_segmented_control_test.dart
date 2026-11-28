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

  group('keeps every label whole', () {
    Future<void> pumpLabels(
      WidgetTester tester,
      TestLayout layout,
      List<String> labels,
    ) => tester.pumpApp(
      Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: AppSegmentedControl<String>(
            segments: [
              for (final label in labels)
                AppSegment(value: label, label: label),
            ],
            selected: labels.first,
            onChanged: (_) {},
          ),
        ),
      ),
      layout: layout,
    );

    void expectWhole(WidgetTester tester, String label) {
      final paragraph = tester.renderObject<RenderParagraph>(find.text(label));
      expect(paragraph.didExceedMaxLines, isFalse, reason: label);
      final segment = tester.getRect(find.byKey(ValueKey(label)));
      final text = tester.getRect(find.text(label));
      expect(segment.left, lessThanOrEqualTo(text.left), reason: label);
      expect(segment.right, greaterThanOrEqualTo(text.right), reason: label);
    }

    // The test font draws every glyph 1 em wide, so 'Scheduled' needs
    // 9 × 15 dp: more than a third of the track, less than the whole.
    testAcrossLayouts('by giving long labels the room they need', (
      tester,
      layout,
    ) async {
      await pumpLabels(tester, layout, const ['A', 'Scheduled', 'B']);

      for (final label in const ['A', 'Scheduled', 'B']) {
        expectWhole(tester, label);
      }
      final text = find.text('Scheduled');
      expect(
        tester.getRect(text).width,
        moreOrLessEquals(tester.getSize(text).width),
        reason: 'not scaled down',
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('A'))).width,
        moreOrLessEquals(tester.getSize(find.byKey(const ValueKey('B'))).width),
        reason: 'the short labels share the rest evenly',
      );
    });

    testAcrossLayouts('by scaling them down when the track is too narrow', (
      tester,
      layout,
    ) async {
      const labels = ['Scheduled', 'Published', 'Cancelled', 'Failed'];
      await pumpLabels(tester, layout, labels);

      for (final label in labels) {
        expectWhole(tester, label);
      }
    });
  });

  group('segmentWidths', () {
    test('splits evenly when every label fits its share', () {
      expect(segmentWidths(available: 300, natural: [50, 90, 100]), [
        100,
        100,
        100,
      ]);
    });

    test('gives long labels their width and shares the rest evenly', () {
      expect(segmentWidths(available: 300, natural: [20, 130, 120, 10]), [
        25,
        130,
        120,
        25,
      ]);
    });

    test('scales every width by the same ratio when they cannot fit', () {
      expect(segmentWidths(available: 200, natural: [100, 300]), [50, 150]);
    });

    test('never goes under the minimum, scaling only what is above it', () {
      expect(segmentWidths(available: 200, natural: [20, 300], minimum: 48), [
        48,
        152,
      ]);
      expect(segmentWidths(available: 300, natural: [20, 200], minimum: 48), [
        100,
        200,
      ]);
    });

    test('keeps the natural widths when the space is unbounded', () {
      expect(segmentWidths(available: double.infinity, natural: [40, 60]), [
        40,
        60,
      ]);
    });
  });
}
