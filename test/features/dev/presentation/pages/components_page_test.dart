import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/widgets/app_bottom_nav.dart';
import 'package:pushit/core/design_system/widgets/app_bottom_sheet.dart';
import 'package:pushit/core/design_system/widgets/app_card.dart';
import 'package:pushit/core/design_system/widgets/app_checkbox.dart';
import 'package:pushit/core/design_system/widgets/app_list_row.dart';
import 'package:pushit/core/design_system/widgets/app_progress_bar.dart';
import 'package:pushit/core/design_system/widgets/app_radio.dart';
import 'package:pushit/core/design_system/widgets/app_segmented_control.dart';
import 'package:pushit/core/design_system/widgets/app_switch.dart';
import 'package:pushit/core/design_system/widgets/app_text_field.dart';
import 'package:pushit/core/design_system/widgets/app_top_bar.dart';
import 'package:pushit/core/design_system/widgets/empty_state_view.dart';
import 'package:pushit/core/design_system/widgets/error_state_view.dart';
import 'package:pushit/core/design_system/widgets/initials_avatar.dart';
import 'package:pushit/core/design_system/widgets/inline_error.dart';
import 'package:pushit/core/design_system/widgets/offline_banner.dart';
import 'package:pushit/core/design_system/widgets/page_indicator.dart';
import 'package:pushit/core/design_system/widgets/platform_logo.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/design_system/widgets/secondary_button.dart';
import 'package:pushit/core/design_system/widgets/skeleton_list.dart';
import 'package:pushit/core/design_system/widgets/stat_tile.dart';
import 'package:pushit/core/design_system/widgets/text_action_button.dart';
import 'package:pushit/core/design_system/widgets/video_thumbnail.dart';
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
      AppBottomNav,
      AppCard,
      AppListRow,
      AppSwitch,
      AppCheckbox,
      AppRadio<int>,
      AppSegmentedControl<int>,
      AppTextField,
      PlatformLogo,
      VideoThumbnail,
      InitialsAvatar,
      AppProgressBar,
      StatTile,
      PageIndicator,
      EmptyStateView,
      ErrorStateView,
      OfflineBanner,
      InlineError,
      SkeletonList,
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

  testWidgets('opens a sample bottom sheet and dialog', (tester) async {
    await tester.pumpApp(const ComponentsPage());

    final openSheet = find.text(_l10n.devComponentsOpenSheet).first;
    await tester.scrollUntilVisible(
      openSheet,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(openSheet);
    await tester.pumpAndSettle();
    expect(find.byType(AppBottomSheetFrame), findsOneWidget);
    await tester.tap(find.text(_l10n.devComponentsSampleLabel).last);
    await tester.pumpAndSettle();
    expect(find.byType(AppBottomSheetFrame), findsNothing);

    final openDialog = find.text(_l10n.devComponentsOpenDialog).first;
    await tester.tap(openDialog);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    await tester.tap(find.text(_l10n.devComponentsSampleLabel).last);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  });
}
