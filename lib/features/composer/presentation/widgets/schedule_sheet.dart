import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/tokens/app_radii.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_bottom_sheet.dart';
import 'package:pushit/core/design_system/widgets/app_list_row.dart';
import 'package:pushit/core/design_system/widgets/app_segmented_control.dart';
import 'package:pushit/core/design_system/widgets/platform_logo.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/composer/domain/schedule_editor.dart';
import 'package:pushit/features/composer/presentation/cubit/schedule_sheet_cubit.dart';
import 'package:pushit/features/composer/presentation/widgets/composer_labels.dart';

/// Opens D9/D10 for [platforms], starting from [initial]. Resolves to the
/// chosen schedule, or `null` when dismissed.
Future<ScheduleChoice?> showScheduleSheet(
  BuildContext context, {
  required Set<PlatformId> platforms,
  ScheduleChoice? initial,
}) {
  final now = context.read<Clock>().now();
  return showAppBottomSheet<ScheduleChoice>(
    context: context,
    title: context.l10n.composerWhenTitle,
    builder: (_) => BlocProvider(
      create: (_) =>
          ScheduleSheetCubit(platforms: platforms, now: now, initial: initial),
      child: const ScheduleSheet(),
    ),
  );
}

/// D9 (one time) and D10 (per platform).
class ScheduleSheet extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ScheduleSheetCubit>();
    final state = context.watch<ScheduleSheetCubit>().state;
    final isPerPlatform = state.mode == ScheduleMode.perPlatform;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSegmentedControl<ScheduleMode>(
          segments: [
            AppSegment(
              value: ScheduleMode.oneTime,
              label: l10n.composerWhenOneTime,
            ),
            AppSegment(
              value: ScheduleMode.perPlatform,
              label: l10n.composerWhenPerPlatform,
            ),
          ],
          selected: state.mode,
          onChanged: cubit.modeChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        _DayStrip(selected: state.current, now: state.now),
        const SizedBox(height: AppSpacing.md),
        if (isPerPlatform)
          for (final platform in state.platforms)
            _PlatformTime(
              platform: platform,
              at: state.times[platform] ?? state.oneTime,
              isEditing: platform == state.editing,
            ),
        _TimeStepper(at: state.current),
        if (!isPerPlatform) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.composerWhenLocalTime(context.shortDate(state.current)),
            textAlign: TextAlign.center,
            style: context.textStyles.small.copyWith(color: context.colors.sub),
          ),
        ],
        if (state.problem != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.composerWhenPast,
            textAlign: TextAlign.center,
            style: context.textStyles.small.copyWith(
              color: context.colors.text,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(
          label: isPerPlatform
              ? l10n.composerWhenSetTimes
              : l10n.composerWhenSet,
          onPressed: state.problem == null
              ? () => Navigator.pop(context, state.choice)
              : null,
        ),
      ],
    );
  }
}

class _DayStrip extends StatelessWidget {
  const new({required this.selected, required this.now});

  final DateTime selected;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final selectedDay = dateOnly(selected);
    return Row(
      children: [
        for (final day in scheduleDays(now))
          Expanded(
            child: Semantics(
              button: true,
              selected: day == selectedDay,
              label: context.l10n.composerWhenDayLabel(
                context.shortDate(day),
                (day == selectedDay).toString(),
              ),
              excludeSemantics: true,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () =>
                    context.read<ScheduleSheetCubit>().daySelected(day),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: AppSizes.minTapTarget,
                  ),
                  child: Column(
                    children: [
                      Text(
                        context.dayInitial(day),
                        style: styles.tiny.copyWith(color: colors.sub),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        width: AppSizes.minTapTarget,
                        height: AppSizes.minTapTarget,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: day == selectedDay
                              ? colors.accent
                              : AppColors.transparent,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                        child: Text(
                          context.dayOfMonth(day),
                          style: styles.bodyStrong.copyWith(
                            color: day == selectedDay
                                ? colors.onAccent
                                : colors.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PlatformTime extends StatelessWidget {
  const new({
    required this.platform,
    required this.at,
    required this.isEditing,
  });

  final PlatformId platform;
  final DateTime at;
  final bool isEditing;

  @override
  Widget build(BuildContext context) => AppListRow(
    padding: EdgeInsets.zero,
    leading: PlatformLogo(
      platform: platform,
      size: PlatformLogoSize.small,
      isSelected: isEditing,
    ),
    title: context.l10n.platformName(platform),
    subtitle: context.shortDate(at),
    value: context.shortTime(at),
    hasChevron: true,
    onTap: () => context.read<ScheduleSheetCubit>().platformTapped(platform),
  );
}

class _TimeStepper extends StatelessWidget {
  const new({required this.at});

  final DateTime at;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ScheduleSheetCubit>();
    final styles = context.textStyles;
    final colors = context.colors;
    Widget neighbour(int steps, String label) => Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: () => cubit.timeShifted(steps),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
          child: Center(
            child: Text(
              context.shortTime(shiftQuarters(at, steps)),
              style: styles.title.copyWith(color: colors.sub),
            ),
          ),
        ),
      ),
    );

    return Column(
      children: [
        neighbour(-1, l10n.composerWhenEarlier),
        Text(
          context.shortTime(at),
          style: styles.time.copyWith(color: colors.text),
        ),
        neighbour(1, l10n.composerWhenLater),
      ],
    );
  }
}
