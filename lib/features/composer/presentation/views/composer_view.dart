import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_button_size.dart';
import 'package:pushit/core/design_system/widgets/app_list_row.dart';
import 'package:pushit/core/design_system/widgets/app_text_field.dart';
import 'package:pushit/core/design_system/widgets/app_top_bar.dart';
import 'package:pushit/core/design_system/widgets/empty_state_view.dart';
import 'package:pushit/core/design_system/widgets/platform_logo.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/design_system/widgets/text_action_button.dart';
import 'package:pushit/core/design_system/widgets/video_thumbnail.dart';
import 'package:pushit/core/formatters.dart';
import 'package:pushit/core/l10n/date_labels.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/composer/domain/composer_rules.dart';
import 'package:pushit/features/composer/presentation/cubit/composer_cubit.dart';
import 'package:pushit/features/composer/presentation/widgets/close_composer.dart';
import 'package:pushit/features/composer/presentation/widgets/composer_labels.dart';

/// D4: the composer.
class ComposerView extends StatelessWidget {
  const new({super.key});

  Future<void> _close(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = context.l10n.composerSavedDraft;
    final saved = await context.read<ComposerCubit>().closeTapped();
    if (!context.mounted) return;
    closeComposer(context);
    if (saved) messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasAccounts = context.select<ComposerCubit, bool>(
      (cubit) => cubit.state.accounts.isNotEmpty,
    );
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppTopBar(
        title: l10n.composerNewPost,
        leading: AppTopBarLeading.close,
        onLeadingPressed: () => unawaited(_close(context)),
        trailing: TextActionButton(
          label: l10n.composerDraftsButton,
          size: AppButtonSize.small,
          onPressed: () => unawaited(context.push(RoutePaths.composeDrafts)),
        ),
      ),
      body: hasAccounts
          ? const _Content()
          : EmptyStateView(
              icon: LucideIcons.userPlus,
              title: l10n.composerNoAccountsTitle,
              message: l10n.composerNoAccountsBody,
              actionLabel: l10n.composerNoAccountsAction,
              onAction: () => unawaited(context.push(RoutePaths.addAccount)),
            ),
    );
  }
}

class _Content extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ComposerCubit>();
    final state = context.watch<ComposerCubit>().state;
    final draft = state.draft;
    final video = draft.video;
    final warnings = video == null
        ? const <DurationTooLong>[]
        : durationWarnings(state.accounts, video);
    void push(String path) => unawaited(context.push(path));

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
                    duration: video?.duration ?? state.uploadItem?.duration,
                    hasPlayIcon: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: l10n.composerCaptionField,
                  hint: l10n.composerCaptionHint,
                  initialValue: draft.caption,
                  onChanged: cubit.captionChanged,
                  isMultiline: true,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final platform in connectedPlatforms(state.accounts))
                      _PlatformToggle(
                        platform: platform,
                        isSelected: draft.platforms.contains(platform),
                      ),
                  ],
                ),
                for (final warning in warnings) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    context.tooLongLabel(warning),
                    style: context.textStyles.small.copyWith(
                      color: context.colors.sub,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                AppListRow(
                  title: l10n.composerRowCaptions,
                  isTitleMuted: true,
                  value: l10n.composerRowCaptionsValue(draft.copies.length),
                  hasChevron: true,
                  padding: EdgeInsets.zero,
                  onTap: () => push(RoutePaths.composePostCaptions),
                ),
                AppListRow(
                  title: l10n.composerCoverTitle,
                  isTitleMuted: true,
                  value: l10n.composerCoverFrame(
                    formatClipDuration(draft.coverAt),
                  ),
                  hasChevron: true,
                  padding: EdgeInsets.zero,
                  onTap: () => push(RoutePaths.composePostCover),
                ),
                if (draft.platforms.contains(PlatformId.tiktok))
                  AppListRow(
                    title: l10n.composerRowTikTok,
                    isTitleMuted: true,
                    value: context.privacyLabel(draft.tiktok.privacy),
                    hasChevron: true,
                    padding: EdgeInsets.zero,
                    onTap: () => push(RoutePaths.composePostTikTok),
                  ),
                AppListRow(
                  title: l10n.composerRowWhen,
                  isTitleMuted: true,
                  value: context.scheduleLabel(
                    draft.schedule,
                    now: context.read<Clock>().now(),
                  ),
                  hasChevron: true,
                  padding: EdgeInsets.zero,
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
              label: l10n.composerSchedule,
              onPressed: video == null || draft.platforms.isEmpty
                  ? null
                  : () => push(RoutePaths.composePostCheck),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlatformToggle extends StatelessWidget {
  const new({required this.platform, required this.isSelected});

  final PlatformId platform;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = l10n.platformName(platform);
    return Semantics(
      button: true,
      selected: isSelected,
      label: isSelected
          ? l10n.composerPlatformSelected(name)
          : l10n.composerPlatformNotSelected(name),
      excludeSemantics: true,
      child: PlatformLogo(
        platform: platform,
        isSelected: isSelected,
        onTap: () => context.read<ComposerCubit>().platformToggled(platform),
      ),
    );
  }
}

extension on BuildContext {
  String tooLongLabel(DurationTooLong warning) {
    final platform = warning.platform == PlatformId.facebook
        ? l10n.composerTooLongFacebook
        : l10n.platformName(warning.platform);
    return l10n.composerTooLong(
      platform,
      limitLabel(warning.limit),
      formatClipDuration(warning.actual),
    );
  }

  String privacyLabel(TikTokPrivacy? privacy) => switch (privacy) {
    null => l10n.composerChoose,
    TikTokPrivacy.everyone => l10n.composerTikTokEveryone,
    TikTokPrivacy.friends => l10n.composerTikTokFriends,
    TikTokPrivacy.onlyMe => l10n.composerTikTokOnlyMe,
  };

  String scheduleLabel(ScheduleChoice? schedule, {required DateTime now}) =>
      switch (schedule) {
        null => l10n.composerChoose,
        SameTime(:final at) => dayAndTimeLabel(at, now: now),
        PerPlatform(:final times) => l10n.composerScheduleTimes(times.length),
      };
}
