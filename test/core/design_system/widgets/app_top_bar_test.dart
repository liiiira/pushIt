import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/widgets/app_button_size.dart';
import 'package:pushit/core/design_system/widgets/app_top_bar.dart';
import 'package:pushit/core/design_system/widgets/text_action_button.dart';
import 'package:pushit/core/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

final AppLocalizations _l10n = lookupAppLocalizations(const Locale('en'));

void main() {
  testAcrossLayouts('shows back, a centred title and a trailing action', (
    tester,
    layout,
  ) async {
    await tester.pumpApp(
      Scaffold(
        appBar: AppTopBar(
          title: 'Plans',
          trailing: TextActionButton(
            label: 'Drafts',
            size: AppButtonSize.small,
            onPressed: () {},
          ),
        ),
      ),
      layout: layout,
    );

    expect(find.byIcon(LucideIcons.arrowLeft), findsOneWidget);
    expect(find.byTooltip(_l10n.commonBack), findsOneWidget);
    expect(find.text('Plans'), findsOneWidget);
    expect(find.text('Drafts'), findsOneWidget);
    expect(
      tester.getCenter(find.text('Plans')).dx,
      moreOrLessEquals(layout.size.width / 2, epsilon: 1),
    );
    expect(
      tester.getSize(find.byType(AppTopBar)).height,
      AppSizes.topBarHeight,
    );
  });

  testAcrossLayouts('keeps a long title on one line', (tester, layout) async {
    await tester.pumpApp(
      Scaffold(
        appBar: AppTopBar(
          title: 'A very long screen title that never fits on a phone',
          trailing: TextActionButton(
            label: 'Drafts',
            size: AppButtonSize.small,
            onPressed: () {},
          ),
        ),
      ),
      layout: layout,
    );

    final title = tester.widget<Text>(find.textContaining('A very long'));
    expect(title.maxLines, 1);
    expect(title.overflow, TextOverflow.ellipsis);
  });

  testWidgets('shows close instead of back', (tester) async {
    await tester.pumpApp(
      const Scaffold(
        appBar: AppTopBar(title: 'New post', leading: AppTopBarLeading.close),
      ),
    );

    expect(find.byIcon(LucideIcons.x), findsOneWidget);
    expect(find.byTooltip(_l10n.commonClose), findsOneWidget);
    expect(find.byIcon(LucideIcons.arrowLeft), findsNothing);
  });

  testWidgets('shows no leading button when asked', (tester) async {
    await tester.pumpApp(
      const Scaffold(
        appBar: AppTopBar(title: 'Plans', leading: AppTopBarLeading.none),
      ),
    );

    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('calls onLeadingPressed instead of popping', (tester) async {
    var presses = 0;
    await tester.pumpApp(
      Scaffold(
        appBar: AppTopBar(title: 'Plans', onLeadingPressed: () => presses++),
      ),
    );

    await tester.tap(find.byIcon(LucideIcons.arrowLeft));

    expect(presses, 1);
  });

  testWidgets('pops the route by default', (tester) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  const Scaffold(appBar: AppTopBar(title: 'Second')),
            ),
          ),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Second'), findsOneWidget);

    await tester.tap(find.byTooltip(_l10n.commonBack));
    await tester.pumpAndSettle();

    expect(find.text('Second'), findsNothing);
  });
}
