import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';

import 'helpers.dart';

void main() {
  test('covers 2 sizes, light and dark, and 2 text scales', () {
    expect(testLayouts, hasLength(8));
    expect(testLayouts.map((layout) => layout.size).toSet(), {
      const Size(360, 800),
      const Size(412, 915),
    });
    expect(testLayouts.map((layout) => layout.brightness).toSet(), {
      Brightness.light,
      Brightness.dark,
    });
    expect(testLayouts.map((layout) => layout.textScale).toSet(), {1.0, 1.3});
  });

  testAcrossLayouts('applies each layout to the pumped app', (
    tester,
    layout,
  ) async {
    MediaQueryData? media;
    ThemeData? theme;

    await tester.pumpApp(
      Builder(
        builder: (context) {
          media = MediaQuery.of(context);
          theme = Theme.of(context);
          return const SizedBox.shrink();
        },
      ),
      layout: layout,
    );

    expect(media?.size, layout.size);
    expect(media?.textScaler, TextScaler.linear(layout.textScale));
    expect(theme?.brightness, layout.brightness);
    expect(
      theme?.extension<AppColors>(),
      layout.brightness == Brightness.dark ? AppColors.dark : AppColors.light,
      reason: 'pumpApp uses AppTheme',
    );
  });
}
