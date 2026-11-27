import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';
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
}
