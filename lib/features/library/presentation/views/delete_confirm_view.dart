import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_card.dart';
import 'package:pushit/core/design_system/widgets/app_list_row.dart';
import 'package:pushit/core/design_system/widgets/app_top_bar.dart';
import 'package:pushit/core/design_system/widgets/empty_state_view.dart';
import 'package:pushit/core/design_system/widgets/error_state_view.dart';
import 'package:pushit/core/design_system/widgets/platform_logo.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/design_system/widgets/skeleton_list.dart';
import 'package:pushit/core/design_system/widgets/text_action_button.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/domain/deletion_plan.dart';
import 'package:pushit/features/library/presentation/cubit/delete_confirm_cubit.dart';

/// F6: Delete everywhere, the confirmation.
class DeleteConfirmView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DeleteConfirmCubit>().state;
    final post = state.post;
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppTopBar(title: context.l10n.libraryDetailDelete),
      body: switch (state.status) {
        ViewStatus.failure when state.failure is NotFoundFailure =>
          EmptyStateView(
            icon: LucideIcons.fileX,
            title: context.l10n.libraryDetailNotFound,
          ),
        ViewStatus.failure => ErrorStateView(
          onRetry: context.read<DeleteConfirmCubit>().started,
        ),
        ViewStatus.ready when post != null => _Content(post: post),
        _ => const SkeletonList(rowCount: 3),
      },
    );
  }
}

class _Content extends StatelessWidget {
  const new({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final plan = deletionPlanFor(post);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenMargin,
              AppSpacing.md,
              AppSpacing.screenMargin,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.libraryDeleteIntro(post.title),
                  style: context.textStyles.body.copyWith(color: colors.text),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Column(
                    children: [
                      for (final row in plan)
                        AppListRow(
                          leading: PlatformLogo(
                            platform: row.platform,
                            size: PlatformLogoSize.small,
                          ),
                          title: l10n.platformName(row.platform),
                          subtitle: switch (row.method) {
                            DeleteMethod.automatic =>
                              l10n.libraryDeleteAutomatic,
                            DeleteMethod.assisted => l10n.libraryDeleteAssisted(
                              l10n.platformName(row.platform),
                            ),
                          },
                          trailing: Icon(
                            switch (row.method) {
                              DeleteMethod.automatic => LucideIcons.check,
                              DeleteMethod.assisted => LucideIcons.eye,
                            },
                            size: AppSizes.iconSmall,
                            color: colors.text,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenMargin,
              AppSpacing.xs,
              AppSpacing.screenMargin,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PrimaryButton(
                  label: l10n.libraryDeleteConfirm(plan.length),
                  onPressed: () => context.pushReplacement(
                    RoutePaths.libraryPostDeleteResultFor(post.id),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextActionButton(
                  label: l10n.libraryDeleteCancel,
                  onPressed: () => Navigator.maybePop(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
