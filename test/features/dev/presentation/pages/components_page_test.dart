import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/widgets/app_card.dart';
import 'package:pushit/core/design_system/widgets/app_checkbox.dart';
import 'package:pushit/core/design_system/widgets/app_list_row.dart';
import 'package:pushit/core/design_system/widgets/app_radio.dart';
import 'package:pushit/core/design_system/widgets/app_segmented_control.dart';
import 'package:pushit/core/design_system/widgets/app_switch.dart';
import 'package:pushit/core/design_system/widgets/app_text_field.dart';
import 'package:pushit/core/design_system/widgets/app_top_bar.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/design_system/widgets/secondary_button.dart';
import 'package:pushit/core/design_system/widgets/text_action_button.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/features/dev/presentation/pages/components_page.dart';

import '../../../../helpers/helpers.dart';

final AppLocalizations _l10n = lookupAppLocalizations(const Locale('en'));

/// The [Theme] a gallery sample paints under.
Theme _themeOf(WidgetTester tester, Finder sample) => tester.widget<Theme>(
  find
      .descendant(of: sample, matching: find.byType(Theme, skipOffstage: false))
      .first,
);

void main() {
  testAcrossLayouts('shows the shared widgets in light and dark', (
    tester,
    layout,
  ) async {
    await tester.pumpApp(const ComponentsPage(), layout: layout);

    expect(find.text(_l10n.devComponentsTitle), findsOneWidget);
    final light = find.byKey(
      ComponentsPage.lightSampleKey,
      skipOffstage: false,
    );
    final dark = find.byKey(ComponentsPage.darkSampleKey, skipOffstage: false);
    expect(
      _themeOf(tester, light).data.extension<AppColors>(),
      AppColors.light,
    );
    expect(_themeOf(tester, dark).data.extension<AppColors>(), AppColors.dark);

    for (final type in [
      PrimaryButton,
      SecondaryButton,
      TextActionButton,
      AppTopBar,
      AppCard,
      AppListRow,
      AppSwitch,
      AppCheckbox,
      AppRadio<int>,
      AppSegmentedControl<int>,
      AppTextField,
    ]) {
      for (final sample in [light, dark]) {
        expect(
          find.descendant(
            of: sample,
            matching: find.byType(type, skipOffstage: false),
          ),
          findsWidgets,
          reason: '$type in $sample',
        );
      }
    }
  });
}
