import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/tokens/app_radii.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/widgets/app_bottom_nav.dart';

import '../../../helpers/helpers.dart';

AppColors _colorsOf(TestLayout layout) =>
    layout.brightness == Brightness.dark ? AppColors.dark : AppColors.light;

const _items = [
  AppBottomNavItem(icon: LucideIcons.house, label: 'Home'),
  AppBottomNavItem(icon: LucideIcons.calendar, label: 'Calendar'),
  AppBottomNavItem(icon: LucideIcons.galleryVerticalEnd, label: 'Library'),
  AppBottomNavItem(icon: LucideIcons.user, label: 'Accounts'),
];

void main() {
  testAcrossLayouts('shows four tabs around the create button', (
    tester,
    layout,
  ) async {
    final selected = <int>[];
    var creates = 0;
    await tester.pumpApp(
      Scaffold(
        bottomNavigationBar: AppBottomNav(
          items: _items,
          currentIndex: 3,
          createLabel: 'New post',
          onItemSelected: selected.add,
          onCreatePressed: () => creates++,
        ),
      ),
      layout: layout,
    );

    final colors = _colorsOf(layout);
    Color? colorOf(String label) => tester
        .renderObject<RenderParagraph>(find.text(label))
        .text
        .style
        ?.color;
    expect(colorOf('Accounts'), colors.text);
    expect(colorOf('Home'), colors.sub);
    expect(
      tester.widget<Icon>(find.byIcon(LucideIcons.user)).color,
      colors.text,
    );
    expect(
      tester.widget<Icon>(find.byIcon(LucideIcons.house)).color,
      colors.sub,
    );
    expect(
      tester.widget<ColoredBox>(find.byKey(AppBottomNav.barKey)).color,
      colors.bg,
    );
    expect(
      tester.getSize(find.byType(AppBottomNav)).height,
      AppSizes.bottomNavHeight,
      reason: 'the bar must not grow into the page',
    );

    // Tabs in order, the create button in the middle.
    final xs = [
      for (final item in _items) tester.getCenter(find.text(item.label)).dx,
    ];
    final createX = tester.getCenter(find.byKey(AppBottomNav.createKey)).dx;
    expect(xs, orderedEquals([...xs]..sort()));
    expect(createX, moreOrLessEquals(layout.size.width / 2, epsilon: 1));
    expect(xs[1], lessThan(createX));
    expect(xs[2], greaterThan(createX));

    final create = tester.widget<Container>(find.byKey(AppBottomNav.createKey));
    final box = create.decoration! as BoxDecoration;
    expect(box.color, colors.accent);
    expect(
      box.borderRadius,
      const BorderRadius.all(Radius.circular(AppRadii.createButton)),
    );
    expect(
      tester.getSize(find.byKey(AppBottomNav.createKey)),
      AppSizes.createButton,
    );
    expect(
      tester.widget<Icon>(find.byIcon(LucideIcons.plus)).color,
      colors.onAccent,
    );
    expect(
      tester.getSemantics(find.text('Accounts')),
      isSemantics(
        label: 'Accounts',
        isSelected: true,
        hasSelectedState: true,
        isButton: true,
        hasTapAction: true,
      ),
    );
    expect(find.bySemanticsLabel('New post'), findsOneWidget);

    await tester.tap(find.text('Calendar'));
    await tester.tap(find.byKey(AppBottomNav.createKey));

    expect(selected, [1]);
    expect(creates, 1);
  });
}
