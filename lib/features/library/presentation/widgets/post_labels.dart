import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/domain/post_detail_facts.dart';
import 'package:pushit/features/library/domain/post_summary.dart';

/// Phrases dates and post summaries for the library screens.
extension PostLabels on BuildContext {
  String get _locale => Localizations.localeOf(this).toString();

  /// "today 19:00", "tomorrow 09:00" or "Tue 17 Nov, 19:00".
  String whenLabel(DateTime at, {required DateTime now}) {
    final time = DateFormat.Hm(_locale).format(at);
    return switch (relativeDayOf(at, now: now)) {
      RelativeDay.today => l10n.libraryWhenToday(time),
      RelativeDay.tomorrow => l10n.libraryWhenTomorrow(time),
      RelativeDay.yesterday => l10n.libraryWhenYesterday(time),
      RelativeDay.other => l10n.libraryWhenDate(
        DateFormat('EEE d MMM', _locale).format(at),
        time,
      ),
    };
  }

  /// A count with the locale's grouping, e.g. "8,204".
  String countLabel(int count) =>
      NumberFormat.decimalPattern(_locale).format(count);

  /// The status line of a post row, e.g. "Failed on TikTok · today 13:30".
  String summaryLabel(PostSummary summary, {required DateTime now}) {
    String withTime(String status, DateTime? at) => at == null
        ? status
        : l10n.libraryRowWithTime(status, whenLabel(at, now: now));

    return switch (summary) {
      SummaryScheduled(:final at) => withTime(l10n.libraryRowScheduled, at),
      SummaryPublishing() => l10n.libraryRowPublishing,
      SummaryPublished(:final views?) => l10n.libraryRowPublishedViews(
        views,
        countLabel(views),
      ),
      SummaryPublished() => l10n.libraryRowPublished,
      SummaryFailed(:final platforms, :final at) => withTime(
        platforms.length == 1
            ? l10n.libraryRowFailedOne(l10n.platformName(platforms.single))
            : l10n.libraryRowFailedMany(platforms.length),
        at,
      ),
    };
  }

  /// An absolute date and time, "Thu 12 Nov, 09:00".
  String dateTimeLabel(DateTime at) => l10n.libraryWhenDate(
    DateFormat('EEE d MMM', _locale).format(at),
    DateFormat.Hm(_locale).format(at),
  );

  /// The header line of the post detail (F3, F4).
  String postHeaderLabel(Post post) {
    final at = postHeaderTime(post);
    if (at == null) return '';
    final when = dateTimeLabel(at);
    return switch (post.status) {
      PostStatus.failed ||
      PostStatus.partiallyFailed => l10n.libraryDetailHeaderFailed(when),
      PostStatus.scheduled ||
      PostStatus.draft => l10n.libraryDetailHeaderScheduled(when),
      PostStatus.published => l10n.libraryDetailHeaderPublished(when),
      PostStatus.publishing => l10n.libraryDetailHeaderPublishing(when),
    };
  }

  /// One platform's line in the post detail, e.g.
  /// "Published · 5,120 views · 702 likes" or "Failed · session expired".
  String targetLabel(
    PostTarget target, {
    required bool showsStatistics,
    required DateTime now,
  }) {
    final stats = target.stats;
    final at = target.scheduledAt;
    return switch (target.status) {
      TargetStatus.published when showsStatistics && stats != null =>
        l10n.libraryRowWithTime(
          l10n.libraryTargetPublished,
          l10n.libraryRowWithTime(
            l10n.libraryTargetViews(stats.views, countLabel(stats.views)),
            l10n.libraryTargetLikes(stats.likes, countLabel(stats.likes)),
          ),
        ),
      TargetStatus.published =>
        at == null
            ? l10n.libraryTargetPublished
            : l10n.libraryRowWithTime(
                l10n.libraryTargetPublished,
                DateFormat.Hm(_locale).format(at),
              ),
      TargetStatus.scheduled =>
        at == null
            ? l10n.libraryTargetScheduled
            : l10n.libraryRowWithTime(
                l10n.libraryTargetScheduled,
                whenLabel(at, now: now),
              ),
      TargetStatus.uploading => l10n.libraryTargetUploading,
      TargetStatus.processing => l10n.libraryTargetProcessing,
      TargetStatus.awaitingUser => l10n.libraryTargetWaiting,
      TargetStatus.removed => l10n.libraryTargetRemoved,
      TargetStatus.failed => l10n.libraryRowWithTime(
        l10n.libraryTargetFailed,
        failureReasonLabel(target.failureReason),
      ),
    };
  }

  String failureReasonLabel(TargetFailureReason? reason) => switch (reason) {
    TargetFailureReason.signInExpired => l10n.libraryFailureSignInExpired,
    TargetFailureReason.rejectedByPlatform => l10n.libraryFailureRejected,
    TargetFailureReason.network => l10n.libraryFailureNetwork,
    TargetFailureReason.unknown || null => l10n.libraryFailureUnknown,
  };

  /// "Statistics refreshed 2 h ago."
  String refreshedLabel(DateTime refreshedAt, {required DateTime now}) {
    final (:unit, :count) = elapsedBetween(refreshedAt, now);
    return switch (unit) {
      ElapsedUnit.justNow => l10n.libraryDetailRefreshedJustNow,
      ElapsedUnit.minutes => l10n.libraryDetailRefreshedMinutes(count),
      ElapsedUnit.hours => l10n.libraryDetailRefreshedHours(count),
      ElapsedUnit.days => l10n.libraryDetailRefreshedDays(count),
    };
  }
}
