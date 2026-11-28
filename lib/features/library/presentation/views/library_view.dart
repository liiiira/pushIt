import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_segmented_control.dart';
import 'package:pushit/core/design_system/widgets/empty_state_view.dart';
import 'package:pushit/core/design_system/widgets/error_state_view.dart';
import 'package:pushit/core/design_system/widgets/skeleton_list.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/features/library/domain/library_filter.dart';
import 'package:pushit/features/library/presentation/cubit/library_cubit.dart';
import 'package:pushit/features/library/presentation/widgets/library_post_tile.dart';

/// F1 (Library), F2 (empty), I2 (loading) and I3 (error).
class LibraryView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenMargin,
                AppSpacing.xl,
                AppSpacing.screenMargin,
                AppSpacing.md,
              ),
              child: Text(
                context.l10n.libraryTitle,
                style: context.textStyles.h1.copyWith(color: colors.text),
              ),
            ),
            const Expanded(child: _Body()),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<LibraryCubit>();
    final status = context.select<LibraryCubit, ViewStatus>(
      (cubit) => cubit.state.status,
    );
    return switch (status) {
      ViewStatus.initial || ViewStatus.loading => const SkeletonList(),
      ViewStatus.empty => EmptyStateView(
        icon: LucideIcons.layers,
        title: l10n.libraryEmptyTitle,
        message: l10n.libraryEmptyBody,
        actionLabel: l10n.libraryEmptyAction,
        onAction: () => context.push(RoutePaths.compose),
      ),
      ViewStatus.failure => ErrorStateView(
        message: l10n.libraryErrorBody,
        onRetry: cubit.retryTapped,
      ),
      ViewStatus.ready => const _PostList(),
    };
  }
}

class _PostList extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<LibraryCubit>().state;
    final posts = state.visiblePosts;
    final now = context.read<Clock>().now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenMargin,
          ),
          child: AppSegmentedControl<LibraryFilter>(
            segments: [
              AppSegment(
                value: LibraryFilter.all,
                label: l10n.libraryFilterAll,
              ),
              AppSegment(
                value: LibraryFilter.scheduled,
                label: l10n.libraryFilterScheduled,
              ),
              AppSegment(
                value: LibraryFilter.published,
                label: l10n.libraryFilterPublished,
              ),
              AppSegment(
                value: LibraryFilter.failed,
                label: l10n.libraryFilterFailed,
              ),
            ],
            selected: state.filter,
            onChanged: context.read<LibraryCubit>().filterChanged,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Expanded(
          child: posts.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenMargin),
                  child: Text(
                    l10n.libraryFilterNoMatch,
                    style: context.textStyles.body.copyWith(
                      color: context.colors.sub,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return LibraryPostTile(
                      post: post,
                      now: now,
                      onTap: () =>
                          context.push(RoutePaths.libraryPostFor(post.id)),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
