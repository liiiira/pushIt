import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_button_size.dart';
import 'package:pushit/core/design_system/widgets/app_list_row.dart';
import 'package:pushit/core/design_system/widgets/secondary_button.dart';
import 'package:pushit/core/l10n/date_labels.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';

/// One event of the activity list (B3): an icon, what happened and when,
/// and Retry on a failure that can still be retried.
class ActivityRow extends StatelessWidget {
  const new({
    required this.item,
    required this.now,
    required this.showsDate,
    this.failureReason,
    this.onRetry,
    super.key,
  });

  final ActivityItem item;
  final DateTime now;

  /// Older than yesterday: the time comes with its date.
  final bool showsDate;

  /// Why the platform failed, while it still is.
  final TargetFailureReason? failureReason;

  /// Shown as Retry when given; null hides it.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final at = item.occurredAt;
    final time = showsDate
        ? context.dayAndTimeLabel(at, now: now)
        : DateFormat.Hm(Localizations.localeOf(context).toString()).format(at);
    final title = item.postTitle ?? '';
    final platform = switch (item.platform) {
      final platform? => l10n.platformName(platform),
      null => '',
    };
    final (icon, heading, subtitle) = switch (item.kind) {
      ActivityKind.failed => (
        LucideIcons.circleAlert,
        l10n.activityFailedTitle(title, platform),
        l10n.activityWithReason(_reasonText(l10n), time),
      ),
      ActivityKind.published => (
        LucideIcons.check,
        l10n.activityPublishedTitle(title),
        l10n.activityPublishedSubtitle(item.platformCount ?? 1, time),
      ),
      ActivityKind.reconnectNeeded => (
        LucideIcons.circleAlert,
        l10n.activityReconnectTitle(platform),
        l10n.activityReconnectSubtitle(time),
      ),
      ActivityKind.assistedReminder => (
        LucideIcons.bell,
        l10n.activityAssistedTitle(title, platform),
        l10n.activityAssistedReminder(time),
      ),
      ActivityKind.assistedConfirmed => (
        LucideIcons.bell,
        l10n.activityAssistedTitle(title, platform),
        l10n.activityAssistedConfirmed(time),
      ),
    };
    final onRetry = this.onRetry;
    return AppListRow(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenMargin,
        vertical: AppSpacing.xs,
      ),
      leading: Container(
        width: AppSizes.avatar,
        height: AppSizes.avatar,
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: AppSizes.iconSmall, color: colors.text),
      ),
      title: heading,
      subtitle: subtitle,
      trailing: onRetry == null
          ? null
          : SecondaryButton(
              label: l10n.activityRetry,
              size: AppButtonSize.small,
              onPressed: onRetry,
            ),
    );
  }

  String _reasonText(AppLocalizations l10n) => switch (failureReason) {
    TargetFailureReason.signInExpired => l10n.activityReasonSessionExpired,
    TargetFailureReason.rejectedByPlatform => l10n.activityReasonRejected,
    TargetFailureReason.network => l10n.activityReasonNetwork,
    TargetFailureReason.unknown || null => l10n.activityReasonUnknown,
  };
}
