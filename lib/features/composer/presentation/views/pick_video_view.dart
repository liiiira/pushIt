import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_segmented_control.dart';
import 'package:pushit/core/design_system/widgets/app_top_bar.dart';
import 'package:pushit/core/design_system/widgets/empty_state_view.dart';
import 'package:pushit/core/design_system/widgets/error_state_view.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/design_system/widgets/skeleton_list.dart';
import 'package:pushit/core/design_system/widgets/video_thumbnail.dart';
import 'package:pushit/core/formatters.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/composer/presentation/cubit/composer_cubit.dart';
import 'package:pushit/features/composer/presentation/cubit/drafts_cubit.dart';
import 'package:pushit/features/composer/presentation/cubit/pick_video_cubit.dart';
import 'package:pushit/features/composer/presentation/widgets/composer_labels.dart';
import 'package:pushit/features/composer/presentation/widgets/drafts_list.dart';

/// D1: Pick video, with the Gallery and Drafts tabs.
class PickVideoView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pick = context.watch<PickVideoCubit>().state;
    final draftCount = context.select<DraftsCubit, int>(
      (cubit) => cubit.state.drafts.length,
    );
    final selected = pick.selected;
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppTopBar(
        title: l10n.composerNewPost,
        leading: AppTopBarLeading.close,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenMargin,
              AppSpacing.xs,
              AppSpacing.screenMargin,
              AppSpacing.md,
            ),
            child: AppSegmentedControl<PickVideoTab>(
              segments: [
                AppSegment(
                  value: PickVideoTab.gallery,
                  label: l10n.composerTabGallery,
                ),
                AppSegment(
                  value: PickVideoTab.drafts,
                  label: l10n.composerTabDrafts(draftCount),
                ),
              ],
              selected: pick.tab,
              onChanged: context.read<PickVideoCubit>().tabChanged,
            ),
          ),
          Expanded(
            child: switch (pick.tab) {
              PickVideoTab.gallery => const _Gallery(),
              PickVideoTab.drafts => const DraftsList(),
            },
          ),
          if (pick.tab == PickVideoTab.gallery)
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
                  label: l10n.composerUseVideo,
                  onPressed: selected == null
                      ? null
                      : () {
                          context.read<ComposerCubit>().uploadStarted(selected);
                          unawaited(context.push(RoutePaths.composeUpload));
                        },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<PickVideoCubit>().state;
    return switch (state.status) {
      ViewStatus.empty => EmptyStateView(
        icon: LucideIcons.video,
        title: l10n.composerGalleryEmptyTitle,
        message: l10n.composerGalleryEmptyBody,
      ),
      ViewStatus.failure => ErrorStateView(
        onRetry: context.read<PickVideoCubit>().started,
      ),
      ViewStatus.ready => CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenMargin,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: AppSizes.galleryColumns,
                mainAxisSpacing: AppSizes.galleryGap,
                crossAxisSpacing: AppSizes.galleryGap,
                childAspectRatio: AppSizes.videoAspectRatio,
              ),
              delegate: SliverChildListDelegate([
                for (final item in state.gallery) _GalleryTile(item: item),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.screenMargin),
            sliver: SliverToBoxAdapter(
              child: Text(
                l10n.composerGalleryHint(
                  l10n.composerMegabytes(megabytesOf(maxVideoSizeBytes)),
                ),
                style: context.textStyles.small.copyWith(
                  color: context.colors.sub,
                ),
              ),
            ),
          ),
        ],
      ),
      _ => const SkeletonList(rowCount: 2),
    };
  }
}

class _GalleryTile extends StatelessWidget {
  const new({required this.item});

  final GalleryItem item;

  @override
  Widget build(BuildContext context) {
    final selectedId = context.select<PickVideoCubit, String?>(
      (cubit) => cubit.state.selectedId,
    );
    final duration = formatClipDuration(item.duration);
    return VideoThumbnail(
      duration: item.duration,
      isSelected: item.id == selectedId,
      semanticLabel: context.l10n.composerVideoLabel(duration),
      onTap: () => context.read<PickVideoCubit>().itemTapped(item.id),
    );
  }
}
