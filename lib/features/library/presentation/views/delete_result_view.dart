import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_button_size.dart';
import 'package:pushit/core/design_system/widgets/app_card.dart';
import 'package:pushit/core/design_system/widgets/app_list_row.dart';
import 'package:pushit/core/design_system/widgets/app_top_bar.dart';
import 'package:pushit/core/design_system/widgets/error_state_view.dart';
import 'package:pushit/core/design_system/widgets/platform_logo.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/design_system/widgets/secondary_button.dart';
import 'package:pushit/core/design_system/widgets/skeleton_list.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/domain/deletion_plan.dart';
import 'package:pushit/features/library/presentation/cubit/delete_result_cubit.dart';

/// F7: Delete everywhere, the result per platform.
class DeleteResultView extends StatelessWidget {
  const new({required this.postId, super.key});

  final String postId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DeleteResultCubit>().state;
    void done() => context.go(RoutePaths.library);
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppTopBar(
        title: context.l10n.libraryDeletingTitle,
        leading: AppTopBarLeading.close,
        onLeadingPressed: done,
      ),
      body: switch (state.status) {
        ViewStatus.failure => ErrorStateView(
          onRetry: context.read<DeleteResultCubit>().retryTapped,
        ),
        ViewStatus.ready => _Content(
          postId: postId,
          steps: state.steps,
          onDone: done,
        ),
        _ => const SkeletonList(rowCount: 3),
      },
    );
  }
}

class _Content extends StatelessWidget {
  const new({required this.postId, required this.steps, required this.onDone});

  final String postId;
  final List<DeletionStep> steps;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final summary = summarizeDeletion(steps);
    final String headline;
    if (summary.isRunning) {
      headline = l10n.libraryDeletingRunning(summary.total);
    } else if (summary.isComplete) {
      headline = l10n.libraryDeletingComplete;
    } else {
      headline = l10n.libraryDeletingSummary(
        l10n.libraryDeletingRemoved(summary.removed, summary.total),
        l10n.libraryDeletingAttention(summary.needsAttention),
      );
    }

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
                  headline,
                  style: context.textStyles.body.copyWith(
                    color: context.colors.text,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Column(
                    children: [
                      for (final step in steps)
                        _StepRow(postId: postId, step: step),
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
            child: PrimaryButton(
              label: l10n.libraryDeletingDone,
              onPressed: onDone,
            ),
          ),
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const new({required this.postId, required this.step});

  final String postId;
  final DeletionStep step;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final platform = l10n.platformName(step.platform);
    return AppListRow(
      leading: PlatformLogo(
        platform: step.platform,
        size: PlatformLogoSize.small,
        isSelected: step.outcome != DeletionOutcome.failed,
      ),
      title: platform,
      subtitle: switch (step.outcome) {
        DeletionOutcome.pending => l10n.libraryStepPending,
        DeletionOutcome.removed => l10n.libraryStepRemoved,
        DeletionOutcome.awaitingUser => l10n.libraryTargetWaiting,
        DeletionOutcome.failed => l10n.libraryStepFailed,
      },
      trailing: switch (step.outcome) {
        DeletionOutcome.removed => Icon(
          LucideIcons.check,
          size: AppSizes.iconSmall,
          color: colors.text,
        ),
        DeletionOutcome.awaitingUser => PrimaryButton(
          label: l10n.libraryStepOpen(platform),
          size: AppButtonSize.small,
          onPressed: () => context.push(
            RoutePaths.assistedDeleteFor(postId, step.platform.name),
          ),
        ),
        DeletionOutcome.failed => SecondaryButton(
          label: l10n.libraryDetailRetry,
          size: AppButtonSize.small,
          onPressed: context.read<DeleteResultCubit>().retryTapped,
        ),
        DeletionOutcome.pending => null,
      },
    );
  }
}
