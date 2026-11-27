import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/widgets/placeholder_page.dart';
import 'package:pushit/core/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

void main() {
  testAcrossLayouts('names the screen that is not built yet', (
    tester,
    layout,
  ) async {
    await tester.pumpApp(const PlaceholderPage(screenId: 'F1'), layout: layout);

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.commonPlaceholderBody('F1')), findsOneWidget);
  });
}
