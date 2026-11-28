import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_bottom_sheet.dart';
import 'package:pushit/core/design_system/widgets/app_list_row.dart';
import 'package:pushit/core/design_system/widgets/empty_state_view.dart';
import 'package:pushit/core/design_system/widgets/error_state_view.dart';
import 'package:pushit/core/design_system/widgets/skeleton_list.dart';
import 'package:pushit/core/design_system/widgets/video_thumbnail.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/composer/presentation/cubit/composer_cubit.dart';
import 'package:pushit/features/composer/presentation/cubit/drafts_cubit.dart';
import 'package:pushit/features/composer/presentation/widgets/composer_labels.dart';

/// The saved drafts (D12, and D1's Drafts tab). Tapping one resumes it in
/// the composer.
class DraftsList extends StatelessWidget {
  const new({super.key});

  static const double thumbnailWidth = 46;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<DraftsCubit>().state;
    return switch (state.status) {
      ViewStatus.empty => EmptyStateView(
        icon: LucideIcons.fileText,
        title: l10n.composerDraftsEmptyTitle,
        message: l10n.composerDraftsEmptyBody,
      ),
      ViewStatus.failure => ErrorStateView(
        onRetry: context.read<DraftsCubit>().started,
      ),
      ViewStatus.ready => ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        children: [
          for (final draft in state.drafts) _DraftRow(draft: draft),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenMargin,
              AppSpacing.md,
              AppSpacing.screenMargin,
              AppSpacing.xl,
            ),
            child: Text(
              l10n.composerDraftsFooter,
              style: context.textStyles.small.copyWith(
                color: context.colors.sub,
              ),
            ),
          ),
        ],
      ),
      _ => const SkeletonList(rowCount: 2),
    };
  }
}

class _DraftRow extends StatelessWidget {
  const new({required this.draft});

  final Post draft;

  void _resume(BuildContext context) {
    context.read<ComposerCubit>().draftResumed(draft);
    unawaited(context.push(RoutePaths.composePost));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = context.read<Clock>().now();
    return AppListRow(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenMargin,
        vertical: AppSpacing.xs,
      ),
      leading: const VideoThumbnail(
        width: DraftsList.thumbnailWidth,
        isSmall: true,
      ),
      title: draft.title,
      subtitle: context.draftLine(draft, now: now),
      onTap: () => _resume(context),
      trailing: IconButton(
        icon: const Icon(LucideIcons.ellipsis),
        color: context.colors.sub,
        tooltip: l10n.composerDraftActions,
        onPressed: () => unawaited(
          showAppBottomSheet<void>(
            context: context,
            title: draft.title,
            builder: (sheetContext) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppListRow(
                  title: l10n.composerDraftResume,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _resume(context);
                  },
                ),
                AppListRow(
                  title: l10n.composerDraftDiscard,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    unawaited(
                      context.read<DraftsCubit>().discardTapped(draft.id),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
