import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/widgets/empty_state_view.dart';
import 'package:pushit/core/design_system/widgets/error_state_view.dart';
import 'package:pushit/core/design_system/widgets/offline_banner.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/design_system/widgets/skeleton_list.dart';
import 'package:pushit/core/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

final AppLocalizations _l10n = lookupAppLocalizations(const Locale('en'));

AppColors _colorsOf(TestLayout layout) =>
    layout.brightness == Brightness.dark ? AppColors.dark : AppColors.light;

Color? _textColor(WidgetTester tester, Finder finder) =>
    tester.renderObject<RenderParagraph>(finder).text.style?.color;

void main() {
  group('EmptyStateView', () {
    testAcrossLayouts('shows an icon, a title, a message and an action', (
      tester,
      layout,
    ) async {
      var taps = 0;
      await tester.pumpApp(
        Scaffold(
          body: EmptyStateView(
            icon: LucideIcons.layers,
            title: 'No videos yet',
            message:
                'Every video you schedule appears here, with its status on '
                'each platform.',
            actionLabel: 'New post',
            onAction: () => taps++,
          ),
        ),
        layout: layout,
      );

      final colors = _colorsOf(layout);
      expect(find.byIcon(LucideIcons.layers), findsOneWidget);
      expect(_textColor(tester, find.text('No videos yet')), colors.text);
      expect(
        _textColor(tester, find.textContaining('Every video')),
        colors.sub,
      );

      await tester.tap(find.widgetWithText(PrimaryButton, 'New post'));
      expect(taps, 1);
    });

    testWidgets('has no button without an action', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: EmptyStateView(
            icon: LucideIcons.calendar,
            title: 'Nothing scheduled',
          ),
        ),
      );

      expect(find.byType(PrimaryButton), findsNothing);
    });
  });

  group('ErrorStateView', () {
    testAcrossLayouts('says something went wrong and offers a retry', (
      tester,
      layout,
    ) async {
      var retries = 0;
      await tester.pumpApp(
        Scaffold(
          body: ErrorStateView(
            message:
                'We could not load your library. Your scheduled posts are not '
                'affected.',
            onRetry: () => retries++,
          ),
        ),
        layout: layout,
      );

      expect(find.byIcon(LucideIcons.circleAlert), findsOneWidget);
      expect(find.text(_l10n.commonErrorTitle), findsOneWidget);
      expect(find.textContaining('We could not load'), findsOneWidget);

      await tester.tap(find.text(_l10n.commonRetry));
      expect(retries, 1);
    });

    testWidgets('falls back to a generic message', (tester) async {
      await tester.pumpApp(Scaffold(body: ErrorStateView(onRetry: () {})));

      expect(find.text(_l10n.commonErrorBody), findsOneWidget);
    });
  });

  group('OfflineBanner', () {
    testAcrossLayouts('is an accent band with an icon and a word', (
      tester,
      layout,
    ) async {
      await tester.pumpApp(
        const Scaffold(body: Column(children: [OfflineBanner()])),
        layout: layout,
      );

      final colors = _colorsOf(layout);
      expect(find.byIcon(LucideIcons.wifiOff), findsOneWidget);
      final text = find.text(_l10n.commonOfflineBanner);
      expect(_textColor(tester, text), colors.onAccent);
      expect(
        tester.widget<ColoredBox>(find.byKey(OfflineBanner.bandKey)).color,
        colors.accent,
      );
      expect(
        tester.getSize(find.byType(OfflineBanner)).width,
        layout.size.width,
      );
      expect(
        tester.getSemantics(text),
        isSemantics(label: _l10n.commonOfflineBanner, isLiveRegion: true),
      );
    });
  });

  group('SkeletonList', () {
    testAcrossLayouts('shows placeholder rows labelled as loading', (
      tester,
      layout,
    ) async {
      await tester.pumpApp(
        const Scaffold(body: SkeletonList(rowCount: 3)),
        layout: layout,
      );

      final colors = _colorsOf(layout);
      final blocks = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(SkeletonList),
              matching: find.byType(Container),
            ),
          )
          .map((block) => (block.decoration as BoxDecoration?)?.color)
          .whereType<Color>()
          .toList();
      // A thumbnail and two text bars per row.
      expect(blocks, hasLength(3 * 3));
      expect(blocks.toSet(), {colors.block});
      expect(find.bySemanticsLabel(_l10n.commonLoading), findsOneWidget);
    });
  });
}
