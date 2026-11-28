import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/widgets/app_progress_bar.dart';
import 'package:pushit/core/design_system/widgets/initials_avatar.dart';
import 'package:pushit/core/design_system/widgets/page_indicator.dart';
import 'package:pushit/core/design_system/widgets/stat_tile.dart';
import 'package:pushit/core/design_system/widgets/video_thumbnail.dart';

import '../../../helpers/helpers.dart';

AppColors _colorsOf(TestLayout layout) =>
    layout.brightness == Brightness.dark ? AppColors.dark : AppColors.light;

Color? _textColor(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text)).text.style?.color;

Widget _frame(Widget child) => Scaffold(
  body: Padding(padding: const EdgeInsets.all(24), child: child),
);

void main() {
  group('VideoThumbnail', () {
    testAcrossLayouts('is a 9:16 block with its duration', (
      tester,
      layout,
    ) async {
      await tester.pumpApp(
        _frame(
          const Align(
            alignment: Alignment.topLeft,
            child: VideoThumbnail(
              width: 126,
              duration: Duration(minutes: 1, seconds: 42),
              hasPlayIcon: true,
            ),
          ),
        ),
        layout: layout,
      );

      final colors = _colorsOf(layout);
      expect(tester.getSize(find.byType(VideoThumbnail)), const Size(126, 224));
      final box =
          tester
                  .widget<Container>(find.byKey(VideoThumbnail.frameKey))
                  .decoration!
              as BoxDecoration;
      expect(box.color, colors.block);
      expect(box.border, isNull);
      expect(find.text('1:42'), findsOneWidget);
      expect(_textColor(tester, '1:42'), colors.text);
      expect(find.byKey(VideoThumbnail.playKey), findsOneWidget);
    });

    testAcrossLayouts('shows a ring when selected and is tappable', (
      tester,
      layout,
    ) async {
      var taps = 0;
      await tester.pumpApp(
        _frame(
          Align(
            alignment: Alignment.topLeft,
            child: VideoThumbnail(
              width: 110,
              isSelected: true,
              semanticLabel: 'studio_tour_p2.mp4',
              onTap: () => taps++,
            ),
          ),
        ),
        layout: layout,
      );

      final colors = _colorsOf(layout);
      final box =
          tester
                  .widget<Container>(find.byKey(VideoThumbnail.frameKey))
                  .decoration!
              as BoxDecoration;
      expect(
        box.border,
        Border.all(color: colors.text, width: AppSizes.selectionRingWidth),
      );
      expect(find.byKey(VideoThumbnail.playKey), findsNothing);
      expect(
        tester.getSemantics(find.byType(VideoThumbnail)),
        isSemantics(
          label: 'studio_tour_p2.mp4',
          isSelected: true,
          hasSelectedState: true,
          isButton: true,
          hasTapAction: true,
        ),
      );

      await tester.tap(find.byType(VideoThumbnail));
      expect(taps, 1);
    });

    testWidgets('fills the width it is given', (tester) async {
      await tester.pumpApp(
        const Center(child: SizedBox(width: 90, child: VideoThumbnail())),
      );

      expect(tester.getSize(find.byType(VideoThumbnail)), const Size(90, 160));
    });
  });

  group('InitialsAvatar', () {
    testAcrossLayouts('shows initials on a surface circle', (
      tester,
      layout,
    ) async {
      var taps = 0;
      await tester.pumpApp(
        _frame(
          Row(
            children: [
              InitialsAvatar(
                name: 'Lyes B.',
                semanticLabel: 'Settings',
                onTap: () => taps++,
              ),
              const InitialsAvatar(
                name: 'Lyes B.',
                size: InitialsAvatarSize.large,
              ),
            ],
          ),
        ),
        layout: layout,
      );

      final colors = _colorsOf(layout);
      expect(find.text('LB'), findsNWidgets(2));
      expect(
        tester
            .renderObject<RenderParagraph>(find.text('LB').first)
            .text
            .style
            ?.color,
        colors.text,
      );
      final circles = find.byKey(InitialsAvatar.circleKey);
      final small = tester.widget<Container>(circles.first);
      expect((small.decoration! as BoxDecoration).color, colors.surface);
      expect(tester.getSize(circles.first), const Size.square(AppSizes.avatar));
      expect(
        tester.getSize(circles.last),
        const Size.square(AppSizes.avatarLarge),
      );
      expect(
        tester.getSize(find.byType(InitialsAvatar).first).height,
        greaterThanOrEqualTo(AppSizes.minTapTarget),
      );
      expect(find.bySemanticsLabel('Settings'), findsOneWidget);

      await tester.tap(find.byType(InitialsAvatar).first);
      expect(taps, 1);
    });
  });

  group('AppProgressBar', () {
    testAcrossLayouts('fills its share of a line track', (
      tester,
      layout,
    ) async {
      await tester.pumpApp(
        _frame(const AppProgressBar(value: 0.61)),
        layout: layout,
      );

      final colors = _colorsOf(layout);
      final track = tester.getSize(find.byKey(AppProgressBar.trackKey));
      final fill = tester.getSize(find.byKey(AppProgressBar.fillKey));
      expect(track.height, AppSizes.progressBar);
      expect(fill.width, moreOrLessEquals(track.width * 0.61));
      expect(
        tester.widget<ColoredBox>(find.byKey(AppProgressBar.trackKey)).color,
        colors.line,
      );
      expect(
        tester.widget<ColoredBox>(find.byKey(AppProgressBar.fillKey)).color,
        colors.accent,
      );
      expect(
        tester.getSemantics(find.byType(AppProgressBar)),
        isSemantics(value: '61%'),
      );
    });

    testWidgets('clamps the value between 0 and 1', (tester) async {
      await tester.pumpApp(_frame(const AppProgressBar(value: 1.4)));

      expect(
        tester.getSize(find.byKey(AppProgressBar.fillKey)).width,
        tester.getSize(find.byKey(AppProgressBar.trackKey)).width,
      );
    });
  });

  group('StatTile', () {
    testAcrossLayouts('shows a big value over a sub label', (
      tester,
      layout,
    ) async {
      await tester.pumpApp(
        _frame(
          const Row(
            children: [
              Expanded(
                child: StatTile(value: '12 480', label: 'Views'),
              ),
              Expanded(
                child: StatTile(value: '1 932', label: 'Likes'),
              ),
              Expanded(
                child: StatTile(value: '214', label: 'Comments'),
              ),
            ],
          ),
        ),
        layout: layout,
      );

      final colors = _colorsOf(layout);
      expect(_textColor(tester, '12 480'), colors.text);
      expect(_textColor(tester, 'Views'), colors.sub);
    });
  });

  group('PageIndicator', () {
    testAcrossLayouts('stretches the current dot', (tester, layout) async {
      await tester.pumpApp(
        _frame(const PageIndicator(count: 3, index: 0)),
        layout: layout,
      );
      await tester.pumpAndSettle();

      final colors = _colorsOf(layout);
      final dots = find.descendant(
        of: find.byType(PageIndicator),
        matching: find.byType(AnimatedContainer),
      );
      expect(dots, findsNWidgets(3));
      expect(
        tester.getSize(dots.at(0)),
        const Size(AppSizes.pageDotActiveWidth, AppSizes.pageDot),
      );
      expect(tester.getSize(dots.at(1)), const Size.square(AppSizes.pageDot));
      final current = tester.widget<AnimatedContainer>(dots.at(0));
      final other = tester.widget<AnimatedContainer>(dots.at(1));
      expect((current.decoration! as BoxDecoration).color, colors.accent);
      expect((other.decoration! as BoxDecoration).color, colors.block);
      expect(find.bySemanticsLabel('Page 1 of 3'), findsOneWidget);
    });
  });
}
