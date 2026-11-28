import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_radii.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/platform_logo.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/design_system/widgets/text_action_button.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/composer/presentation/cubit/composer_cubit.dart';
import 'package:pushit/features/composer/presentation/widgets/composer_labels.dart';

/// D13: the post is scheduled.
class ScheduledView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final cubit = context.read<ComposerCubit>();
    final state = context.watch<ComposerCubit>().state;
    final post = state.scheduledPost;
    void leave(String path) {
      cubit.newPostStarted();
      context.go(path);
    }

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.screenMargin),
                  child: Column(
                    children: [
                      Container(
                        width: AppSizes.avatarLarge,
                        height: AppSizes.avatarLarge,
                        decoration: BoxDecoration(
                          color: colors.accent,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                        child: Icon(
                          LucideIcons.check,
                          size: AppSizes.icon,
                          color: colors.onAccent,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        l10n.composerScheduledTitle,
                        style: context.textStyles.h1.copyWith(
                          color: colors.text,
                        ),
                      ),
                      if (post != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          context.scheduledSummary(post, state.accounts),
                          textAlign: TextAlign.center,
                          style: context.textStyles.body.copyWith(
                            color: colors.sub,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          spacing: AppSpacing.xs,
                          children: [
                            for (final target in post.targets)
                              PlatformLogo(platform: target.platform),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
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
                    label: l10n.composerScheduledViewCalendar,
                    onPressed: () => leave(RoutePaths.calendar),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextActionButton(
                    label: l10n.composerScheduledNewPost,
                    onPressed: () => leave(RoutePaths.compose),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on BuildContext {
  /// "Tue 17 Nov at 19:00 on YouTube and Instagram. TikTok is assisted,
  /// so we will remind you at 19:00."
  String scheduledSummary(Post post, List<ConnectedAccount> accounts) {
    bool isAssisted(PlatformId platform) =>
        (accounts.where((a) => a.platform == platform).firstOrNull?.mode ??
            capabilityOf(platform).publishMethod) ==
        AccountMode.assisted;

    final automatic = post.targets.where((t) => !isAssisted(t.platform));
    final assisted = post.targets.where((t) => isAssisted(t.platform));
    final parts = <String>[];
    final automaticAt = automatic
        .map((t) => t.scheduledAt)
        .nonNulls
        .firstOrNull;
    if (automaticAt != null) {
      parts.add(
        l10n.composerScheduledOn(
          l10n.composerScheduledWhen(
            shortDate(automaticAt),
            shortTime(automaticAt),
          ),
          platformList(automatic.map((t) => t.platform)),
        ),
      );
    }
    final assistedAt = assisted.map((t) => t.scheduledAt).nonNulls.firstOrNull;
    if (assistedAt != null) {
      parts.add(
        l10n.composerScheduledAssisted(
          assisted.length,
          platformList(assisted.map((t) => t.platform)),
          shortTime(assistedAt),
        ),
      );
    }
    return parts.reduce(l10n.composerListSentences);
  }
}
