import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/widgets/app_card.dart';
import 'package:pushit/core/design_system/widgets/app_list_row.dart';

import '../../../helpers/helpers.dart';

AppColors _colorsOf(TestLayout layout) =>
    layout.brightness == Brightness.dark ? AppColors.dark : AppColors.light;

Color? _colorOf(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text)).text.style?.color;

void main() {
  testAcrossLayouts('shows leading, title, subtitle and trailing', (
    tester,
    layout,
  ) async {
    var taps = 0;
    await tester.pumpApp(
      Scaffold(
        body: AppCard(
          padding: EdgeInsets.zero,
          child: AppListRow(
            leading: const Icon(LucideIcons.bell),
            title: 'Published',
            subtitle: 'With the links to each platform.',
            hasChevron: true,
            onTap: () => taps++,
          ),
        ),
      ),
      layout: layout,
    );

    final colors = _colorsOf(layout);
    expect(find.byIcon(LucideIcons.bell), findsOneWidget);
    expect(find.byIcon(LucideIcons.chevronRight), findsOneWidget);
    expect(_colorOf(tester, 'Published'), colors.text);
    expect(_colorOf(tester, 'With the links to each platform.'), colors.sub);
    expect(
      tester.getSize(find.byType(AppListRow)).height,
      greaterThanOrEqualTo(AppSizes.minTapTarget),
    );

    await tester.tap(find.byType(AppListRow));
    expect(taps, 1);
  });

  testAcrossLayouts('shows a muted label and a strong value', (
    tester,
    layout,
  ) async {
    await tester.pumpApp(
      const Scaffold(
        body: AppListRow(
          title: 'Statistics',
          value: 'Not available yet',
          isTitleMuted: true,
        ),
      ),
      layout: layout,
    );

    final colors = _colorsOf(layout);
    expect(_colorOf(tester, 'Statistics'), colors.sub);
    expect(_colorOf(tester, 'Not available yet'), colors.text);
    expect(find.byType(InkWell), findsNothing);
  });

  testAcrossLayouts(
    'ellipsises a long title and value instead of overflowing',
    (tester, layout) async {
      await tester.pumpApp(
        const Scaffold(
          body: AppListRow(
            title: 'A label that is far too long to fit next to its value',
            value: 'A value that is also far too long to fit in the row',
            hasChevron: true,
          ),
        ),
        layout: layout,
      );

      for (final text in ['A label', 'A value']) {
        final widget = tester.widget<Text>(find.textContaining(text));
        expect(widget.overflow, TextOverflow.ellipsis, reason: text);
      }
    },
  );

  testAcrossLayouts('takes any trailing widget', (tester, layout) async {
    await tester.pumpApp(
      const Scaffold(
        body: AppListRow(
          title: 'YouTube',
          subtitle: 'Lyes makes · Automatic',
          trailing: Icon(LucideIcons.check),
        ),
      ),
      layout: layout,
    );

    expect(find.byIcon(LucideIcons.check), findsOneWidget);
  });
}
