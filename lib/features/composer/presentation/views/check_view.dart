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
import 'package:pushit/core/design_system/widgets/app_card.dart';
import 'package:pushit/core/design_system/widgets/app_list_row.dart';
import 'package:pushit/core/design_system/widgets/app_top_bar.dart';
import 'package:pushit/core/design_system/widgets/platform_logo.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/design_system/widgets/secondary_button.dart';
import 'package:pushit/core/design_system/widgets/text_action_button.dart';
import 'package:pushit/core/formatters.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/accounts/accounts.dart';
import 'package:pushit/features/composer/presentation/cubit/composer_cubit.dart';
import 'package:pushit/features/composer/presentation/widgets/close_composer.dart';
import 'package:pushit/features/composer/presentation/widgets/composer_labels.dart';
import 'package:pushit/features/composer/presentation/widgets/schedule_sheet.dart';
import 'package:pushit/features/plans/plans.dart';

/// D8: the platform check, then scheduling (D9/D10 → D13, or H3).
class CheckView extends StatelessWidget {
  const new({super.key});

  Future<void> _continue(BuildContext context) async {
    final cubit = context.read<ComposerCubit>()..keepReadyPlatforms();
    final draft = cubit.state.draft;
    if (draft.schedule == null) {
      final choice = await showScheduleSheet(
        context,
        platforms: draft.platforms,
      );
      if (choice == null || !context.mounted) return;
      cubit.scheduleChosen(choice);
    }
    await cubit.scheduleTapped();
  }

  Future<void> _onSubmission(BuildContext context, ComposerState state) async {
    final cubit = context.read<ComposerCubit>();
    switch (state.submission) {
      case Submission.scheduled:
        context.go(RoutePaths.composeScheduled);
      case Submission.limitReached:
        cubit.submissionShown();
        final choice = await showLimitReachedSheet(
          context: context,
          plan: state.plan,
          usage:
              state.usage ??
              Usage(
                postsThisMonth: state.plan.monthlyPostLimit ?? 0,
                connectedAccounts: state.accounts.length,
                resetsOn: context.read<Clock>().now(),
              ),
        );
        if (!context.mounted) return;
        switch (choice) {
          case LimitReachedChoice.seePlans:
            unawaited(context.push(RoutePaths.plans));
          case LimitReachedChoice.saveDraft:
            await cubit.closeTapped();
            if (context.mounted) closeComposer(context);
          case LimitReachedChoice.dismissed:
            break;
        }
      case Submission.failed:
        cubit.submissionShown();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.composerScheduleFailed)),
        );
      case Submission.idle || Submission.submitting:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<ComposerCubit>().state;
    final issues = state.issues;
    final ready = state.readyPlatforms;
    final fileTooLarge = issues.whereType<FileTooLarge>().firstOrNull;
    return BlocListener<ComposerCubit, ComposerState>(
      listenWhen: (previous, current) =>
          previous.submission != current.submission,
      listener: (context, state) => unawaited(_onSubmission(context, state)),
      child: Scaffold(
        backgroundColor: context.colors.bg,
        appBar: AppTopBar(title: l10n.composerCheckTitle),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenMargin,
                  AppSpacing.xs,
                  AppSpacing.screenMargin,
                  AppSpacing.xl,
                ),
                children: [
                  Text(
                    l10n.composerCheckIntro,
                    style: context.textStyles.body.copyWith(
                      color: context.colors.sub,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (fileTooLarge != null) ...[
                    Text(
                      l10n.composerCheckFileTooLarge(
                        l10n.composerMegabytes(
                          megabytesOf(fileTooLarge.actualBytes),
                        ),
                        l10n.composerMegabytes(
                          megabytesOf(fileTooLarge.limitBytes),
                        ),
                      ),
                      style: context.textStyles.body.copyWith(
                        color: context.colors.text,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    child: Column(
                      children: [
                        for (final platform in PlatformId.values.where(
                          state.draft.platforms.contains,
                        ))
                          _CheckRow(
                            platform: platform,
                            issue: _issueOf(issues, platform),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Icon(
                        issues.isEmpty
                            ? LucideIcons.circleCheck
                            : LucideIcons.circleAlert,
                        size: AppSizes.iconSmall,
                        color: context.colors.text,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          issues.isEmpty
                              ? l10n.composerCheckReadyAll
                              : l10n.composerCheckProblems(issues.length),
                          style: context.textStyles.body.copyWith(
                            color: context.colors.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
                      label: l10n.composerCheckContinue(ready.length),
                      onPressed:
                          ready.isEmpty ||
                              state.submission == Submission.submitting
                          ? null
                          : () => unawaited(_continue(context)),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextActionButton(
                      label: l10n.composerCheckBack,
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static PlatformCheckIssue? _issueOf(
    List<PlatformCheckIssue> issues,
    PlatformId platform,
  ) => issues.where((issue) {
    return switch (issue) {
      DurationTooLong(platform: final p) ||
      NotConnected(platform: final p) ||
      PaidPlanRequired(platform: final p) => p == platform,
      PrivacyNotChosen() => platform == PlatformId.tiktok,
      FileTooLarge() => false,
    };
  }).firstOrNull;
}

class _CheckRow extends StatelessWidget {
  const new({required this.platform, required this.issue});

  final PlatformId platform;
  final PlatformCheckIssue? issue;

  Future<void> _reconnect(BuildContext context) async {
    final cubit = context.read<ComposerCubit>();
    final account = cubit.state.accounts
        .where((a) => a.platform == platform)
        .firstOrNull;
    if (account == null) {
      unawaited(context.push(RoutePaths.addAccount));
      return;
    }
    final confirmed = await showReconnectDialog(
      context: context,
      account: account,
    );
    if (confirmed) await cubit.reconnectTapped(platform);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ComposerCubit>();
    Widget action(String label, VoidCallback onPressed) => SecondaryButton(
      label: label,
      size: AppButtonSize.small,
      onPressed: onPressed,
    );

    final issue = this.issue;
    return AppListRow(
      leading: PlatformLogo(
        platform: platform,
        size: PlatformLogoSize.small,
        isSelected: issue == null,
      ),
      title: l10n.platformName(platform),
      subtitle: switch (issue) {
        null => l10n.composerCheckReady,
        DurationTooLong(:final actual, :final limit) =>
          l10n.composerCheckTooLong(
            formatClipDuration(actual),
            formatClipDuration(limit),
          ),
        PrivacyNotChosen() => l10n.composerCheckPrivacy,
        NotConnected() => l10n.composerCheckNotConnected,
        PaidPlanRequired() => l10n.composerCheckPaidPlan,
        FileTooLarge() => l10n.composerCheckReady,
      },
      trailing: switch (issue) {
        null || FileTooLarge() => Icon(
          LucideIcons.check,
          size: AppSizes.iconSmall,
          color: context.colors.text,
        ),
        DurationTooLong() => action(
          l10n.composerCheckRemove,
          () => cubit.platformToggled(platform),
        ),
        PrivacyNotChosen() => action(
          l10n.composerChoose,
          () => unawaited(context.push(RoutePaths.composePostTikTok)),
        ),
        NotConnected() => action(
          l10n.composerCheckReconnect,
          () => unawaited(_reconnect(context)),
        ),
        PaidPlanRequired() => action(
          l10n.composerVariantsSeePlans,
          () => unawaited(context.push(RoutePaths.plans)),
        ),
      },
    );
  }
}
