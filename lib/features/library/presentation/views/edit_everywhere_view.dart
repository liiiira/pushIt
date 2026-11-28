import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_card.dart';
import 'package:pushit/core/design_system/widgets/app_list_row.dart';
import 'package:pushit/core/design_system/widgets/app_text_field.dart';
import 'package:pushit/core/design_system/widgets/app_top_bar.dart';
import 'package:pushit/core/design_system/widgets/empty_state_view.dart';
import 'package:pushit/core/design_system/widgets/error_state_view.dart';
import 'package:pushit/core/design_system/widgets/platform_logo.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/design_system/widgets/skeleton_list.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/domain/edit_plan.dart';
import 'package:pushit/features/library/presentation/cubit/edit_everywhere_cubit.dart';

/// F5: Edit everywhere.
class EditEverywhereView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MultiBlocListener(
      listeners: [
        BlocListener<EditEverywhereCubit, EditEverywhereState>(
          listenWhen: (previous, current) =>
              previous.results == null && current.results != null,
          listener: (context, state) {
            final applied = state.results!
                .where((r) => r.outcome == EditOutcome.applied)
                .length;
            final message = l10n.libraryEditDone(applied);
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(message)));
            context.pop();
          },
        ),
        BlocListener<EditEverywhereCubit, EditEverywhereState>(
          listenWhen: (previous, current) =>
              current.actionFailure != null &&
              previous.actionFailure != current.actionFailure,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.libraryDetailActionFailed)),
            );
            context.read<EditEverywhereCubit>().actionFailureShown();
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: context.colors.bg,
        appBar: AppTopBar(title: l10n.libraryDetailEdit),
        body: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditEverywhereCubit>().state;
    return switch (state.status) {
      ViewStatus.failure when state.failure is NotFoundFailure =>
        EmptyStateView(
          icon: LucideIcons.fileX,
          title: context.l10n.libraryDetailNotFound,
        ),
      ViewStatus.failure => ErrorStateView(
        onRetry: context.read<EditEverywhereCubit>().started,
      ),
      ViewStatus.ready => const _Form(),
      _ => const SkeletonList(rowCount: 2),
    };
  }
}

class _Form extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<EditEverywhereCubit>();
    final state = context.watch<EditEverywhereCubit>().state;
    final plan = state.plan;
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
                AppTextField(
                  label: l10n.libraryEditTitleField,
                  initialValue: state.title,
                  onChanged: cubit.titleChanged,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: l10n.libraryEditCaptionField,
                  initialValue: state.caption,
                  onChanged: cubit.captionChanged,
                  isMultiline: true,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l10n.libraryEditWhere,
                  style: context.textStyles.bodyStrong.copyWith(
                    color: context.colors.text,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Column(
                    children: [for (final row in plan) _PlanRow(row: row)],
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
              label: l10n.libraryEditApply(applicableCount(plan)),
              onPressed: state.canApply && applicableCount(plan) > 0
                  ? cubit.applyTapped
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanRow extends StatelessWidget {
  const new({required this.row});

  final EditPlanRow row;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEditable = row.scope != EditScope.notEditable;
    return AppListRow(
      leading: PlatformLogo(
        platform: row.platform,
        size: PlatformLogoSize.small,
        isSelected: isEditable,
      ),
      title: l10n.platformName(row.platform),
      subtitle: switch (row.scope) {
        EditScope.titleAndCaption => l10n.libraryEditScopeTitleAndCaption,
        EditScope.caption => l10n.libraryEditScopeCaption,
        EditScope.beforePosting => l10n.libraryEditScopeBeforePosting,
        EditScope.notEditable => l10n.libraryEditScopeNone,
      },
      trailing: isEditable
          ? Icon(
              LucideIcons.check,
              size: AppSizes.iconSmall,
              color: context.colors.text,
            )
          : null,
    );
  }
}
