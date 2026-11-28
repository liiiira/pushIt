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
import 'package:pushit/core/design_system/widgets/app_dialog.dart';
import 'package:pushit/core/design_system/widgets/app_list_row.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:pushit/features/calendar/presentation/widgets/calendar_labels.dart';
import 'package:pushit/features/composer/composer.dart';

/// Opens E4 for [post].
Future<void> showPostActionsSheet(BuildContext context, Post post) {
  final cubit = context.read<CalendarCubit>();
  return showAppBottomSheet<void>(
    context: context,
    title: post.title,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: PostActionsSheet(post: post),
    ),
  );
}

/// E4: Reschedule, Edit post or Cancel post.
class PostActionsSheet extends StatelessWidget {
  const new({required this.post, super.key});

  final Post post;

  Future<void> _reschedule(BuildContext context) async {
    final cubit = context.read<CalendarCubit>();
    final choice = await showScheduleSheet(
      context,
      platforms: {for (final t in post.targets) t.platform},
      initial: draftFromPost(post).schedule,
    );
    if (choice == null) return;
    await cubit.rescheduleTapped(post.id, choice);
    if (context.mounted) Navigator.maybePop(context).ignore();
  }

  Future<void> _cancel(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<CalendarCubit>();
    final confirmed = await showAppDialog<bool>(
      context: context,
      title: l10n.calendarCancelTitle,
      message: l10n.calendarCancelBody,
      actions: [
        AppDialogAction(label: l10n.calendarCancelConfirm, value: true),
        AppDialogAction(
          label: l10n.calendarCancelKeep,
          value: false,
          kind: AppDialogActionKind.text,
        ),
      ],
    );
    if (confirmed != true) return;
    await cubit.cancelTapped(post.id);
    if (context.mounted) Navigator.maybePop(context).ignore();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final at = post.nextScheduledAt;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (at != null)
          Text(
            l10n.calendarSheetLine(
              post.targets.length,
              context.whenLabel(at, now: context.read<Clock>().now()),
            ),
            style: context.textStyles.small.copyWith(color: colors.sub),
          ),
        const SizedBox(height: AppSpacing.md),
        AppListRow(
          padding: EdgeInsets.zero,
          leading: Icon(LucideIcons.clock, color: colors.text),
          title: l10n.calendarReschedule,
          hasChevron: true,
          onTap: () => unawaited(_reschedule(context)),
        ),
        AppListRow(
          padding: EdgeInsets.zero,
          leading: Icon(LucideIcons.pencil, color: colors.text),
          title: l10n.calendarEditPost,
          hasChevron: true,
          onTap: () {
            final router = GoRouter.of(context);
            Navigator.maybePop(context).ignore();
            unawaited(router.push(RoutePaths.libraryPostEditFor(post.id)));
          },
        ),
        AppListRow(
          padding: EdgeInsets.zero,
          leading: Icon(LucideIcons.trash2, color: colors.text),
          title: l10n.calendarCancelPost,
          hasChevron: true,
          onTap: () => unawaited(_cancel(context)),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.calendarSheetFooter,
          style: context.textStyles.small.copyWith(color: colors.sub),
        ),
      ],
    );
  }
}
