import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/widgets/app_top_bar.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/features/composer/presentation/widgets/drafts_list.dart';

/// D12: Drafts.
class DraftsView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.bg,
    appBar: AppTopBar(title: context.l10n.composerDraftsTitle),
    body: const DraftsList(),
  );
}
