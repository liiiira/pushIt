import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_checkbox.dart';
import 'package:pushit/core/design_system/widgets/app_top_bar.dart';
import 'package:pushit/core/design_system/widgets/empty_state_view.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/design_system/widgets/secondary_button.dart';
import 'package:pushit/core/design_system/widgets/skeleton_list.dart';
import 'package:pushit/core/design_system/widgets/text_action_button.dart';
import 'package:pushit/core/design_system/widgets/video_thumbnail.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/assisted/presentation/cubit/assisted_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

/// G2 (assisted posting) and G3 (assisted delete).
class AssistedView extends StatelessWidget {
  const new({required this.platform, required this.mode, super.key});

  /// `null` when the route named an unknown platform.
  final PlatformId? platform;
  final AssistedMode mode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<AssistedCubit>().state;
    final platform = this.platform;
    final name = platform == null ? '' : l10n.platformName(platform);
    final post = state.post;
    return MultiBlocListener(
      listeners: [
        BlocListener<AssistedCubit, AssistedState>(
          listenWhen: (previous, current) =>
              previous.outcome != current.outcome,
          listener: (context, state) {
            final message = switch (state.outcome) {
              AssistedOutcome.done => l10n.assistedDone,
              AssistedOutcome.snoozed => l10n.assistedReminded,
              AssistedOutcome.none => null,
            };
            if (message == null) return;
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(message)));
            context.pop();
          },
        ),
        BlocListener<AssistedCubit, AssistedState>(
          listenWhen: (previous, current) =>
              current.actionFailure != null &&
              previous.actionFailure != current.actionFailure,
          listener: (context, state) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.assistedActionFailed)));
            context.read<AssistedCubit>().actionFailureShown();
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: context.colors.bg,
        appBar: AppTopBar(
          title: mode == AssistedMode.post
              ? l10n.assistedTitle
              : l10n.assistedDeleteTitle(name),
          leading: AppTopBarLeading.close,
        ),
        body: switch (state.status) {
          ViewStatus.ready when post != null && platform != null => _Content(
            post: post,
            platform: platform,
            mode: mode,
          ),
          ViewStatus.failure => EmptyStateView(
            icon: LucideIcons.circleCheck,
            title: l10n.assistedNotFound,
          ),
          _ => const SkeletonList(rowCount: 2),
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const new({required this.post, required this.platform, required this.mode});

  final Post post;
  final PlatformId platform;
  final AssistedMode mode;

  Future<void> _open(BuildContext context) async {
    final cubit = context.read<AssistedCubit>();
    if (mode == AssistedMode.post) {
      await Clipboard.setData(ClipboardData(text: post.captionFor(platform)));
    }
    final uri = mode == AssistedMode.delete
        ? post.targetFor(platform)?.url ?? platformHomeUri(platform)
        : platformHomeUri(platform);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      // The steps stay on screen; the creator can open the app by hand.
    }
    cubit.openTapped();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final cubit = context.read<AssistedCubit>();
    final state = context.watch<AssistedCubit>().state;
    final name = l10n.platformName(platform);
    final isPost = mode == AssistedMode.post;
    final steps = isPost
        ? [
            l10n.assistedCaptionCopied,
            l10n.assistedOpens(name),
            l10n.assistedPaste,
          ]
        : [l10n.assistedDeleteOpens(name), l10n.assistedDeleteMenu];

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
                    duration: post.video.duration,
                    hasPlayIcon: isPost,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  isPost
                      ? l10n.assistedPostHeading(post.title, name)
                      : l10n.assistedDeleteHeading(post.title, name),
                  style: context.textStyles.title.copyWith(color: colors.text),
                ),
                if (!isPost) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.assistedDeleteBody(name),
                    style: context.textStyles.body.copyWith(color: colors.sub),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                for (final (index, label) in steps.indexed)
                  AppCheckbox(
                    value: state.ticked.contains(index),
                    label: label,
                    onChanged: (_) => cubit.stepToggled(index),
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
                  label: l10n.assistedOpen(name),
                  onPressed: () => unawaited(_open(context)),
                ),
                const SizedBox(height: AppSpacing.xs),
                SecondaryButton(
                  label: isPost ? l10n.assistedPosted : l10n.assistedDeleted,
                  onPressed: () => unawaited(cubit.confirmTapped()),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextActionButton(
                  label: isPost ? l10n.assistedRemind : l10n.assistedKeep(name),
                  onPressed: isPost
                      ? () => unawaited(cubit.remindTapped())
                      : () => context.pop(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
