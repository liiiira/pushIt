import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_top_bar.dart';
import 'package:pushit/core/design_system/widgets/empty_state_view.dart';
import 'package:pushit/core/design_system/widgets/error_state_view.dart';
import 'package:pushit/core/design_system/widgets/skeleton_list.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/features/activity/domain/group_activity_by_day.dart';
import 'package:pushit/features/activity/presentation/cubit/activity_cubit.dart';
import 'package:pushit/features/activity/presentation/widgets/activity_row.dart';

/// B3, with the empty, loading (I2) and error (I3) states.
class ActivityView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocListener<ActivityCubit, ActivityState>(
      listenWhen: (previous, current) =>
          current.actionFailure != null &&
          previous.actionFailure != current.actionFailure,
      listener: (context, state) =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.activityRetryFailed))),
      child: Scaffold(
        backgroundColor: context.colors.bg,
        appBar: AppTopBar(title: l10n.activityTitle),
        body: BlocBuilder<ActivityCubit, ActivityState>(
          builder: (context, state) => switch (state.status) {
            ViewStatus.failure => ErrorStateView(
              onRetry: context.read<ActivityCubit>().reloadTapped,
            ),
            ViewStatus.empty => EmptyStateView(
              icon: LucideIcons.bell,
              title: l10n.activityEmptyTitle,
              message: l10n.activityEmptyMessage,
            ),
            ViewStatus.ready => _ActivityList(state: state),
            ViewStatus.initial || ViewStatus.loading => const SkeletonList(),
          },
        ),
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  const new({required this.state});

  final ActivityState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final styles = context.textStyles;
    final cubit = context.read<ActivityCubit>();
    final now = context.read<Clock>().now();
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        for (final group in state.groups) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenMargin,
              AppSpacing.md,
              AppSpacing.screenMargin,
              AppSpacing.xxs,
            ),
            child: Semantics(
              header: true,
              child: Text(switch (group.day) {
                ActivityDay.today => l10n.activityToday,
                ActivityDay.yesterday => l10n.activityYesterday,
                ActivityDay.earlier => l10n.activityEarlier,
              }, style: styles.small.copyWith(color: colors.sub)),
            ),
          ),
          for (final item in group.items)
            ActivityRow(
              item: item,
              now: now,
              showsDate: group.day == ActivityDay.earlier,
              failureReason: state.failureReasonOf(item),
              onRetry: state.canRetry(item) && !state.isRetrying(item)
                  ? () => cubit.retryTapped(item)
                  : null,
            ),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenMargin,
            AppSpacing.xl,
            AppSpacing.screenMargin,
            0,
          ),
          child: Text(
            l10n.activityKeptFor(activityRetention.inDays),
            style: styles.small.copyWith(color: colors.sub),
          ),
        ),
      ],
    );
  }
}
