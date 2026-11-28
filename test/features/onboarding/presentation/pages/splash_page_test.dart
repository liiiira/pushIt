import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/tokens/app_typography.dart';
import 'package:pushit/features/onboarding/presentation/pages/splash_page.dart';

import '../../../../helpers/helpers.dart';

void main() {
  testAcrossLayouts('A1: shows the wordmark and the promise, centred', (
    tester,
    layout,
  ) async {
    await tester.pumpApp(const SplashPage(), layout: layout);

    final colors = layout.brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    final wordmark = tester
        .renderObject<RenderParagraph>(find.text('pushIt'))
        .text
        .style;
    expect(wordmark?.fontSize, AppTypography.standard.time.fontSize);
    expect(wordmark?.color, colors.text);
    final tagline = tester
        .renderObject<RenderParagraph>(
          find.text('Schedule once, post everywhere.'),
        )
        .text
        .style;
    expect(tagline?.color, colors.sub);

    final screen = tester.getRect(find.byType(SplashPage));
    expect(
      tester.getCenter(find.text('pushIt')).dx,
      moreOrLessEquals(screen.center.dx, epsilon: 1),
    );
    expect(
      tester.getBottomLeft(find.text('pushIt')).dy,
      lessThan(
        tester.getTopLeft(find.text('Schedule once, post everywhere.')).dy,
      ),
    );
  });
}
