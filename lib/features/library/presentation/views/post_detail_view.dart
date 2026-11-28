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
import 'package:pushit/core/design_system/widgets/app_top_bar.dart';
import 'package:pushit/core/design_system/widgets/empty_state_view.dart';
import 'package:pushit/core/design_system/widgets/error_state_view.dart';
import 'package:pushit/core/design_system/widgets/secondary_button.dart';
import 'package:pushit/core/design_system/widgets/skeleton_list.dart';
import 'package:pushit/core/design_system/widgets/text_action_button.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/presentation/cubit/post_detail_cubit.dart';
import 'package:pushit/features/library/presentation/widgets/post_detail_header.dart';
import 'package:pushit/features/library/presentation/widgets/post_failure_card.dart';
import 'package:pushit/features/library/presentation/widgets/post_labels.dart';
import 'package:pushit/features/library/presentation/widgets/post_stats_row.dart';
import 'package:pushit/features/library/presentation/widgets/post_targets_card.dart';
import 'package:url_launcher/url_launcher.dart';

/// F3 (Post detail) and F4 (Post, failed).
class PostDetailView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocListener<PostDetailCubit, PostDetailState>(
      listenWhen: (previous, current) =>
          current.actionFailure != null &&
          previous.actionFailure != current.actionFailure,
      listener: (context, state) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.libraryDetailActionFailed)));
        context.read<PostDetailCubit>().actionFailureShown();
      },
      child: Scaffold(
        backgroundColor: context.colors.bg,
        appBar: AppTopBar(
          title: l10n.libraryDetailTitle,
          trailing: const _MoreButton(),
        ),
        body: const _Body(),
      ),
    );
  }
}

class _MoreButton extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final post = context.select<PostDetailCubit, Post?>(
      (cubit) => cubit.state.post,
    );
    if (post == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    return IconButton(
      icon: const Icon(LucideIcons.ellipsis),
      color: context.colors.text,
      tooltip: l10n.libraryDetailMore,
      onPressed: () => unawaited(
        showAppBottomSheet<void>(
          context: context,
          title: l10n.libraryDetailMore,
          builder: (sheetContext) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppListRow(
                title: l10n.libraryDetailEdit,
                onTap: () {
                  Navigator.pop(sheetContext);
                  unawaited(
                    context.push(RoutePaths.libraryPostEditFor(post.id)),
                  );
                },
              ),
              AppListRow(
                title: l10n.libraryDetailDelete,
                onTap: () {
                  Navigator.pop(sheetContext);
                  unawaited(
                    context.push(RoutePaths.libraryPostDeleteFor(post.id)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PostDetailCubit>().state;
    final post = state.post;
    return switch (state.status) {
      ViewStatus.failure when state.failure is NotFoundFailure =>
        EmptyStateView(
          icon: LucideIcons.fileX,
          title: context.l10n.libraryDetailNotFound,
        ),
      ViewStatus.failure => ErrorStateView(
        onRetry: context.read<PostDetailCubit>().started,
      ),
      ViewStatus.ready when post != null => _Content(
        post: post,
        showsStatistics: state.showsStatistics,
        busyPlatform: state.busyPlatform,
      ),
      _ => const SkeletonList(rowCount: 3),
    };
  }
}

class _Content extends StatelessWidget {
  const new({
    required this.post,
    required this.showsStatistics,
    required this.busyPlatform,
  });

  final Post post;
  final bool showsStatistics;
  final PlatformId? busyPlatform;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<PostDetailCubit>();
    final now = context.read<Clock>().now();
    final failed = post.targets
        .where((t) => t.status == TargetStatus.failed)
        .firstOrNull;
    final totals = post.totals;
    final showsTotals =
        showsStatistics &&
        totals != null &&
        post.status == PostStatus.published;

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
                PostDetailHeader(post: post),
                const SizedBox(height: AppSpacing.xl),
                if (failed != null) ...[
                  PostFailureCard(
                    target: failed,
                    isBusy: busyPlatform != null,
                    onRetry: () => cubit.retryTapped(failed.platform),
                    onReconnectAndRetry: () =>
                        cubit.reconnectAndRetryTapped(failed.platform),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (showsTotals) ...[
                  PostStatsRow(totals: totals),
                  const SizedBox(height: AppSpacing.xl),
                ],
                PostTargetsCard(
                  post: post,
                  showsStatistics: showsStatistics,
                  now: now,
                  busyPlatform: busyPlatform,
                  onOpen: (url) => unawaited(launchUrl(url)),
                  onRetry: cubit.retryTapped,
                ),
                if (showsTotals) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    context.refreshedLabel(totals.refreshedAt, now: now),
                    style: context.textStyles.small.copyWith(
                      color: context.colors.sub,
                    ),
                  ),
                ],
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
                SecondaryButton(
                  label: l10n.libraryDetailEdit,
                  onPressed: () =>
                      context.push(RoutePaths.libraryPostEditFor(post.id)),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextActionButton(
                  label: l10n.libraryDetailDelete,
                  onPressed: () =>
                      context.push(RoutePaths.libraryPostDeleteFor(post.id)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
