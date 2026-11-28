import 'dart:async';

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
import 'package:pushit/core/design_system/widgets/app_progress_bar.dart';
import 'package:pushit/core/design_system/widgets/app_top_bar.dart';
import 'package:pushit/core/design_system/widgets/empty_state_view.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/design_system/widgets/secondary_button.dart';
import 'package:pushit/core/design_system/widgets/video_thumbnail.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/composer/presentation/cubit/composer_cubit.dart';
import 'package:pushit/features/composer/presentation/widgets/composer_labels.dart';

/// D2 (Uploading) and D3 (Upload paused).
class UploadView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<ComposerCubit>().state;
    final item = state.uploadItem;
    final upload = state.upload;
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppTopBar(
        title: l10n.composerNewPost,
        leading: AppTopBarLeading.close,
      ),
      body: item == null || upload == null
          ? EmptyStateView(
              icon: LucideIcons.video,
              title: l10n.composerUploadNoneTitle,
              message: l10n.composerUploadNoneBody,
              actionLabel: l10n.composerUploadPick,
              onAction: () => context.go(RoutePaths.compose),
            )
          : _Content(item: item, upload: upload),
    );
  }
}

class _Content extends StatelessWidget {
  const new({required this.item, required this.upload});

  final GalleryItem item;
  final UploadProgress upload;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ComposerCubit>();
    Future<void> cancel() async {
      await cubit.cancelUploadTapped();
      if (context.mounted) context.pop();
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
                Center(
                  child: VideoThumbnail(
                    width: AppSizes.composerPreview.width,
                    duration: item.duration,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _ProgressCard(item: item, upload: upload),
                if (upload is Uploading) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.composerUploadHint,
                    style: context.textStyles.small.copyWith(
                      color: context.colors.sub,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    ...switch (upload) {
                      Uploading() => [
                        SecondaryButton(
                          label: l10n.composerUploadPause,
                          size: AppButtonSize.small,
                          onPressed: () => unawaited(cubit.pauseTapped()),
                        ),
                      ],
                      Paused() => [
                        PrimaryButton(
                          label: l10n.composerUploadRetryNow,
                          size: AppButtonSize.small,
                          onPressed: () => unawaited(cubit.resumeTapped()),
                        ),
                      ],
                      UploadFailed() => [
                        PrimaryButton(
                          label: l10n.composerUploadRetry,
                          size: AppButtonSize.small,
                          onPressed: cubit.retryUploadTapped,
                        ),
                      ],
                      Uploaded() => <Widget>[],
                    },
                    if (upload is! Uploaded)
                      SecondaryButton(
                        label: l10n.composerUploadCancel,
                        size: AppButtonSize.small,
                        onPressed: () => unawaited(cancel()),
                      ),
                  ],
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
              label: l10n.composerContinue,
              onPressed: upload is UploadFailed
                  ? null
                  : () => unawaited(context.push(RoutePaths.composePost)),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const new({required this.item, required this.upload});

  final GalleryItem item;
  final UploadProgress upload;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final styles = context.textStyles;
    final (title, fraction) = switch (upload) {
      Uploading(:final fraction) => (
        l10n.composerUploading(item.fileName),
        fraction,
      ),
      Paused(:final fraction) => (l10n.composerUploadPaused, fraction),
      UploadFailed() => (l10n.composerUploadFailed, 0.0),
      Uploaded() => (l10n.composerUploadDone, 1.0),
    };
    final details = switch (upload) {
      Uploading(:final sentBytes, :final totalBytes) => Row(
        children: [
          Expanded(
            child: Text(
              l10n.composerUploadAmount(
                megabytesOf(sentBytes),
                megabytesOf(totalBytes),
              ),
              style: styles.small.copyWith(color: colors.sub),
            ),
          ),
          Text(
            l10n.composerUploadPercent((fraction * 100).floor()),
            style: styles.small.copyWith(color: colors.sub),
          ),
        ],
      ),
      Paused(:final sentBytes) => Text(
        l10n.composerUploadPausedBody(megabytesOf(sentBytes)),
        style: styles.small.copyWith(color: colors.text),
      ),
      UploadFailed() => Text(
        l10n.composerUploadFailedBody,
        style: styles.small.copyWith(color: colors.text),
      ),
      Uploaded() => Text(
        l10n.composerUploadDoneBody(item.fileName),
        style: styles.small.copyWith(color: colors.sub),
      ),
    };
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (upload is Paused || upload is UploadFailed) ...[
                Icon(
                  upload is Paused
                      ? LucideIcons.wifiOff
                      : LucideIcons.circleAlert,
                  size: AppSizes.iconSmall,
                  color: colors.text,
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Expanded(
                child: Text(
                  title,
                  style: styles.bodyStrong.copyWith(color: colors.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppProgressBar(value: fraction),
          const SizedBox(height: AppSpacing.xs),
          details,
        ],
      ),
    );
  }
}
