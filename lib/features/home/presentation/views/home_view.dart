import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_button_size.dart';
import 'package:pushit/core/design_system/widgets/error_state_view.dart';
import 'package:pushit/core/design_system/widgets/skeleton_list.dart';
import 'package:pushit/core/design_system/widgets/stat_tile.dart';
import 'package:pushit/core/design_system/widgets/text_action_button.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/core/l10n/number_labels.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/accounts/accounts.dart';
import 'package:pushit/features/home/domain/build_dashboard.dart';
import 'package:pushit/features/home/presentation/cubit/home_cubit.dart';
import 'package:pushit/features/home/presentation/widgets/first_steps_card.dart';
import 'package:pushit/features/home/presentation/widgets/home_header.dart';
import 'package:pushit/features/home/presentation/widgets/next_post_card.dart';
import 'package:pushit/features/home/presentation/widgets/next_post_section.dart';

/// B1 and B2, with the loading (I2) and error (I3) states.
class HomeView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (previous, current) =>
          current.actionFailure != null &&
          previous.actionFailure != current.actionFailure,
      listener: (context, state) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.homeReconnectFailed))),
      child: Scaffold(
        backgroundColor: context.colors.bg,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              final dashboard = state.dashboard;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xs),
                  HomeHeader(userName: state.userName),
                  Expanded(
                    child: switch (state.status) {
                      ViewStatus.failure => ErrorStateView(
                        onRetry: context.read<HomeCubit>().retryTapped,
                      ),
                      ViewStatus.ready when dashboard != null => _Dashboard(
                        dashboard: dashboard,
                      ),
                      _ => const SkeletonList(),
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const new({required this.dashboard});

  final Dashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final next = dashboard.next;
    final firstUse = dashboard.firstUse;
    final week = dashboard.lastSevenDays;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenMargin,
        AppSpacing.xl,
        AppSpacing.screenMargin,
        AppSpacing.xl,
      ),
      children: [
        NextPostSection(next: next),
        if (next != null) ...[
          const SizedBox(height: AppSpacing.xl),
          NextPostCard(
            post: next.post,
            onTap: () => context.push(RoutePaths.libraryPostFor(next.post.id)),
          ),
        ],
        if (firstUse != null) ...[
          const SizedBox(height: AppSpacing.xl),
          FirstStepsCard(
            firstUse: firstUse,
            onConnect: () => context.push(RoutePaths.addAccount),
            onSchedule: () => context.push(RoutePaths.compose),
          ),
        ],
        if (dashboard.reconnects.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          for (final alert in dashboard.reconnects) _ReconnectRow(alert: alert),
        ],
        if (week != null && firstUse == null) ...[
          const SizedBox(height: AppSpacing.xl),
          _LastSevenDays(stats: week, accountCount: dashboard.accountCount),
        ],
      ],
    );
  }
}

/// "TikTok needs reconnecting · Fix": asks with C5, then reconnects.
class _ReconnectRow extends StatelessWidget {
  const new({required this.alert});

  final ReconnectAlert alert;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.homeReconnectNeeded(l10n.platformName(alert.account.platform)),
            style: context.textStyles.body.copyWith(color: colors.text),
          ),
        ),
        TextActionButton(
          label: l10n.homeFix,
          size: AppButtonSize.small,
          isUnderlined: true,
          onPressed: () async {
            final cubit = context.read<HomeCubit>();
            final shouldReconnect = await showReconnectDialog(
              context: context,
              account: alert.account,
              risk: alert.risk,
            );
            if (shouldReconnect) await cubit.reconnectTapped(alert.account);
          },
        ),
      ],
    );
  }
}

/// "Last 7 days · 4 accounts" and three numbers.
class _LastSevenDays extends StatelessWidget {
  const new({required this.stats, required this.accountCount});

  final PostStats stats;
  final int accountCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeLastSevenDays(accountCount),
          style: context.textStyles.small.copyWith(color: context.colors.sub),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xxl,
          runSpacing: AppSpacing.md,
          children: [
            StatTile(
              value: context.groupedNumber(stats.views),
              label: l10n.homeViews,
            ),
            StatTile(
              value: context.groupedNumber(stats.likes),
              label: l10n.homeLikes,
            ),
            StatTile(
              value: context.groupedNumber(stats.comments),
              label: l10n.homeComments,
            ),
          ],
        ),
      ],
    );
  }
}
