import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/tokens/app_radii.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_card.dart';
import 'package:pushit/core/design_system/widgets/app_segmented_control.dart';
import 'package:pushit/core/design_system/widgets/empty_state_view.dart';
import 'package:pushit/core/design_system/widgets/error_state_view.dart';
import 'package:pushit/core/design_system/widgets/skeleton_list.dart';
import 'package:pushit/core/design_system/widgets/video_thumbnail.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/calendar/domain/calendar_rules.dart';
import 'package:pushit/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:pushit/features/calendar/presentation/widgets/calendar_labels.dart';
import 'package:pushit/features/calendar/presentation/widgets/post_actions_sheet.dart';

/// E1 (day), E2 (week) and E3 (empty day).
class CalendarView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final state = context.watch<CalendarCubit>().state;
    final cubit = context.read<CalendarCubit>();
    return BlocListener<CalendarCubit, CalendarState>(
      listenWhen: (previous, current) =>
          current.actionFailure != null &&
          previous.actionFailure != current.actionFailure,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.calendarActionFailed)));
        cubit.actionFailureShown();
      },
      child: Scaffold(
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
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.calendarTitle,
                        style: context.textStyles.h1.copyWith(
                          color: colors.text,
                        ),
                      ),
                    ),
                    Text(
                      state.mode == CalendarMode.day
                          ? context.monthName(state.selectedDay)
                          : context.weekRange(state.week),
                      style: context.textStyles.small.copyWith(
                        color: colors.sub,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenMargin,
                ),
                child: AppSegmentedControl<CalendarMode>(
                  segments: [
                    AppSegment(
                      value: CalendarMode.day,
                      label: l10n.calendarDay,
                    ),
                    AppSegment(
                      value: CalendarMode.week,
                      label: l10n.calendarWeek,
                    ),
                  ],
                  selected: state.mode,
                  onChanged: cubit.modeChanged,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: switch (state.status) {
                  ViewStatus.failure => ErrorStateView(onRetry: cubit.started),
                  ViewStatus.ready => switch (state.mode) {
                    CalendarMode.day => const _DayView(),
                    CalendarMode.week => const _WeekView(),
                  },
                  _ => const SkeletonList(),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _open(BuildContext context, Post post) {
  if (canReschedule(post)) {
    unawaited(showPostActionsSheet(context, post));
  } else {
    unawaited(context.push(RoutePaths.libraryPostFor(post.id)));
  }
}

class _DayView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<CalendarCubit>().state;
    final entries = state.dayEntries;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WeekStrip(
          week: state.week,
          selected: state.selectedDay,
          busy: state.busyDays,
        ),
        Expanded(
          child: entries.isEmpty
              ? EmptyStateView(
                  icon: LucideIcons.calendar,
                  title: l10n.calendarEmptyTitle(
                    context.weekdayAndDay(state.selectedDay),
                  ),
                  message: l10n.calendarEmptyBody,
                  actionLabel: l10n.calendarNewPost,
                  onAction: () => unawaited(context.push(RoutePaths.compose)),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenMargin,
                    AppSpacing.md,
                    AppSpacing.screenMargin,
                    AppSpacing.xl,
                  ),
                  children: [
                    Text(
                      l10n.calendarDayHeading(
                        entries.length,
                        context.weekdayAndDay(state.selectedDay),
                      ),
                      style: context.textStyles.bodyStrong.copyWith(
                        color: context.colors.text,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (final entry in entries) _EntryRow(entry: entry),
                  ],
                ),
        ),
      ],
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const new({required this.week, required this.selected, required this.busy});

  final List<DateTime> week;
  final DateTime selected;
  final Set<DateTime> busy;

  static const double _dot = AppSpacing.xxs;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          for (final day in week)
            Expanded(
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => context.read<CalendarCubit>().daySelected(day),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                  child: Column(
                    children: [
                      Text(
                        context.narrowWeekday(day),
                        style: styles.tiny.copyWith(color: colors.sub),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Container(
                        width: AppSizes.avatar,
                        height: AppSizes.avatar,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: day == selected
                              ? colors.accent
                              : AppColors.transparent,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                        child: Text(
                          context.dayNumber(day),
                          style: styles.bodyStrong.copyWith(
                            color: day == selected
                                ? colors.onAccent
                                : colors.text,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Container(
                        width: _dot,
                        height: _dot,
                        decoration: BoxDecoration(
                          color: busy.contains(day)
                              ? colors.text
                              : AppColors.transparent,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const new({required this.entry});

  final CalendarEntry entry;

  static const double _timeWidth = 52;
  static const double _thumbnailWidth = 28;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final summary = summarizeEntry(entry.post);
    final isFailed = summary is EntryFailed;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: _timeWidth,
            child: Text(
              context.time(entry.at),
              style: styles.bodyStrong.copyWith(color: colors.text),
            ),
          ),
          Expanded(
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.xs),
              onTap: () => _open(context, entry.post),
              child: Row(
                children: [
                  const VideoThumbnail(width: _thumbnailWidth, isSmall: true),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.post.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: styles.bodyStrong.copyWith(color: colors.text),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Row(
                          children: [
                            if (isFailed) ...[
                              Icon(
                                LucideIcons.circleAlert,
                                size: AppSizes.iconTiny,
                                color: colors.text,
                              ),
                              const SizedBox(width: AppSpacing.xxs),
                            ],
                            Expanded(
                              child: Text(
                                context.entryLabel(summary),
                                style: styles.small.copyWith(
                                  color: isFailed ? colors.text : colors.sub,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isFailed ? LucideIcons.rotateCw : LucideIcons.chevronRight,
                    size: AppSizes.iconSmall,
                    color: colors.sub,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekView extends StatelessWidget {
  const new();

  static const double _dayWidth = 48;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final styles = context.textStyles;
    final state = context.watch<CalendarCubit>().state;
    final today = dateOnly(context.read<Clock>().now());
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenMargin,
        AppSpacing.xs,
        AppSpacing.screenMargin,
        AppSpacing.xl,
      ),
      children: [
        for (final day in state.week)
          InkWell(
            onTap: () => context.read<CalendarCubit>().daySelected(day),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: colors.line)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: _dayWidth,
                    child: Column(
                      children: [
                        Text(
                          context.shortWeekday(day),
                          style: styles.small.copyWith(color: colors.sub),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Container(
                          width: AppSizes.avatar,
                          height: AppSizes.avatar,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: day == today
                                ? colors.accent
                                : AppColors.transparent,
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                          child: Text(
                            context.dayNumber(day),
                            style: styles.bodyStrong.copyWith(
                              color: day == today
                                  ? colors.onAccent
                                  : colors.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _WeekDayEntries(
                      entries: entriesOn(state.posts, day),
                      empty: l10n.calendarNothingScheduled,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _WeekDayEntries extends StatelessWidget {
  const new({required this.entries, required this.empty});

  final List<CalendarEntry> entries;
  final String empty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md),
        child: Text(empty, style: styles.body.copyWith(color: colors.sub)),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.time(entry.at),
                    style: styles.bodyStrong.copyWith(color: colors.text),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      summarizeEntry(entry.post) is EntryFailed
                          ? context.l10n.calendarWeekFailed(entry.post.title)
                          : entry.post.title,
                      style: styles.body.copyWith(color: colors.sub),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
