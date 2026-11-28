import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/home/domain/build_dashboard.dart';

/// "Next post · today", the time and the countdown (B1); or the empty time
/// and "Nothing scheduled yet" (B1, B2).
class NextPostSection extends StatelessWidget {
  const new({required this.next, super.key});

  final NextPost? next;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final styles = context.textStyles;
    final locale = Localizations.localeOf(context).toString();
    final next = this.next;
    final countdown = next?.countdown;
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            next == null
                ? l10n.homeNextPost
                : switch (next.day) {
                    RelativeDay.today => l10n.homeNextPostToday,
                    RelativeDay.tomorrow => l10n.homeNextPostTomorrow,
                    RelativeDay.yesterday ||
                    RelativeDay.other => l10n.homeNextPostOn(
                      DateFormat('EEE d MMM', locale).format(next.at),
                    ),
                  },
            style: styles.small.copyWith(color: colors.sub),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            next == null
                ? l10n.homeNoTime
                : DateFormat.Hm(locale).format(next.at),
            style: styles.time.copyWith(
              color: next == null ? colors.sub : colors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(switch (countdown) {
            null => l10n.homeNothingScheduled,
            Countdown(:final days, :final hours) when days > 0 =>
              l10n.homeCountdownDays(days, hours),
            Countdown(:final hours, :final minutes) when hours > 0 =>
              l10n.homeCountdownHours(hours, minutes),
            Countdown(:final minutes) => l10n.homeCountdownMinutes(minutes),
          }, style: styles.body.copyWith(color: colors.sub)),
        ],
      ),
    );
  }
}
