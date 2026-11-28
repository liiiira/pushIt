import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/widgets/platform_logo.dart';
import 'package:pushit/domain/domain.dart';

import '../../../helpers/helpers.dart';

AppColors _colorsOf(TestLayout layout) =>
    layout.brightness == Brightness.dark ? AppColors.dark : AppColors.light;

BoxDecoration _ringOf(WidgetTester tester, PlatformId platform) =>
    tester
            .widget<Container>(
              find.descendant(
                of: find.byKey(ValueKey(platform)),
                matching: find.byKey(PlatformLogo.ringKey),
              ),
            )
            .decoration!
        as BoxDecoration;

SvgPicture _glyphOf(WidgetTester tester, PlatformId platform) =>
    tester.widget<SvgPicture>(
      find.descendant(
        of: find.byKey(ValueKey(platform)),
        matching: find.byType(SvgPicture),
      ),
    );

void main() {
  testAcrossLayouts('selected: surface fill, text ring, brand glyph', (
    tester,
    layout,
  ) async {
    await tester.pumpApp(
      Scaffold(
        body: Wrap(
          children: [
            for (final platform in PlatformId.values)
              PlatformLogo(key: ValueKey(platform), platform: platform),
          ],
        ),
      ),
      layout: layout,
    );

    final colors = _colorsOf(layout);
    final brands = {
      PlatformId.youtube: colors.brandYouTube,
      PlatformId.instagram: colors.brandInstagram,
      PlatformId.tiktok: colors.brandTikTok,
      PlatformId.facebook: colors.brandFacebook,
      PlatformId.threads: colors.brandThreads,
      PlatformId.linkedin: colors.brandLinkedIn,
      PlatformId.bluesky: colors.brandBluesky,
      PlatformId.x: colors.brandX,
    };
    for (final platform in PlatformId.values) {
      final ring = _ringOf(tester, platform);
      expect(ring.color, colors.surface, reason: '$platform');
      expect(
        ring.border,
        Border.all(color: colors.text, width: AppSizes.ringWidth),
      );
      expect(
        tester.getSize(
          find.descendant(
            of: find.byKey(ValueKey(platform)),
            matching: find.byKey(PlatformLogo.ringKey),
          ),
        ),
        const Size.square(AppSizes.platformLogoLarge),
      );
      final glyph = _glyphOf(tester, platform);
      expect(
        glyph.colorFilter,
        ColorFilter.mode(brands[platform]!, BlendMode.srcIn),
        reason: '$platform',
      );
      expect(glyph.width, AppSizes.platformGlyphLarge);
    }
    expect(find.bySemanticsLabel('YouTube'), findsOneWidget);
  });

  testAcrossLayouts('unselected: no fill, line ring, sub glyph', (
    tester,
    layout,
  ) async {
    await tester.pumpApp(
      const Scaffold(
        body: PlatformLogo(
          key: ValueKey(PlatformId.facebook),
          platform: PlatformId.facebook,
          isSelected: false,
          size: PlatformLogoSize.small,
        ),
      ),
      layout: layout,
    );

    final colors = _colorsOf(layout);
    final ring = _ringOf(tester, PlatformId.facebook);
    expect(ring.color, isNull);
    expect(
      ring.border,
      Border.all(color: colors.line, width: AppSizes.ringWidth),
    );
    expect(
      _glyphOf(tester, PlatformId.facebook).colorFilter,
      ColorFilter.mode(colors.sub, BlendMode.srcIn),
    );
    expect(
      tester.getSize(find.byKey(PlatformLogo.ringKey)),
      const Size.square(AppSizes.platformLogoSmall),
    );
    expect(
      _glyphOf(tester, PlatformId.facebook).width,
      AppSizes.platformGlyphSmall,
    );
  });

  testAcrossLayouts('a tappable small logo is 48 to tap and selectable', (
    tester,
    layout,
  ) async {
    var taps = 0;
    await tester.pumpApp(
      Scaffold(
        body: Center(
          child: PlatformLogo(
            platform: PlatformId.tiktok,
            size: PlatformLogoSize.small,
            onTap: () => taps++,
          ),
        ),
      ),
      layout: layout,
    );

    final size = tester.getSize(find.byType(PlatformLogo));
    expect(size.width, greaterThanOrEqualTo(AppSizes.minTapTarget));
    expect(size.height, greaterThanOrEqualTo(AppSizes.minTapTarget));
    expect(
      tester.getSemantics(find.byType(PlatformLogo)),
      isSemantics(
        label: 'TikTok',
        isSelected: true,
        hasSelectedState: true,
        isButton: true,
        hasTapAction: true,
      ),
    );

    await tester.tap(find.byType(PlatformLogo));
    expect(taps, 1);
  });
}
