import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/widgets/inline_error.dart';

import '../../../helpers/helpers.dart';

void main() {
  testAcrossLayouts('says what is wrong with an icon, never colour alone', (
    tester,
    layout,
  ) async {
    await tester.pumpApp(
      const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(24),
          child: InlineError('Agree to the terms to continue.'),
        ),
      ),
      layout: layout,
    );

    final colors = layout.brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    expect(find.byIcon(LucideIcons.circleAlert), findsOneWidget);
    expect(
      tester
          .renderObject<RenderParagraph>(
            find.text('Agree to the terms to continue.'),
          )
          .text
          .style
          ?.color,
      colors.text,
    );
    expect(
      tester.getSemantics(find.byType(InlineError)),
      isSemantics(label: 'Agree to the terms to continue.', isLiveRegion: true),
    );
  });
}
