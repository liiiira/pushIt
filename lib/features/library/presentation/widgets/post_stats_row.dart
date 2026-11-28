import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/stat_tile.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/presentation/widgets/post_labels.dart';

/// Total views, likes and comments (F3).
class PostStatsRow extends StatelessWidget {
  const new({required this.totals, super.key});

  final PostStats totals;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: AppSpacing.xxxl,
      runSpacing: AppSpacing.md,
      children: [
        StatTile(
          value: context.countLabel(totals.views),
          label: l10n.libraryDetailViews,
        ),
        StatTile(
          value: context.countLabel(totals.likes),
          label: l10n.libraryDetailLikes,
        ),
        StatTile(
          value: context.countLabel(totals.comments),
          label: l10n.libraryDetailComments,
        ),
      ],
    );
  }
}
