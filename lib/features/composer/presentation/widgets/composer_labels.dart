import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/l10n/date_labels.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';

/// Phrases dates and sizes for the composer screens.
extension ComposerLabels on BuildContext {
  /// "Edited 2 h ago · no time set" (D12).
  String draftLine(Post draft, {required DateTime now}) {
    final edited = l10n.composerDraftEdited(
      _editedAgo(draft.updatedAt, now: now),
    );
    final at =
        draft.nextScheduledAt ??
        draft.targets.map((t) => t.scheduledAt).nonNulls.firstOrNull;
    return l10n.composerDraftLine(
      edited,
      at == null ? l10n.composerDraftNoTime : dayAndTimeLabel(at, now: now),
    );
  }

  /// "YouTube", "YouTube and Instagram", "YouTube, Instagram and TikTok".
  String platformList(Iterable<PlatformId> platforms) {
    final names = [for (final p in platforms) l10n.platformName(p)];
    if (names.isEmpty) return '';
    if (names.length == 1) return names.single;
    final head = names
        .sublist(0, names.length - 1)
        .reduce((a, b) => l10n.composerListComma(a, b));
    return l10n.composerListAnd(head, names.last);
  }

  /// "Tue 17 Nov".
  String shortDate(DateTime at) => DateFormat(
    'EEE d MMM',
    Localizations.localeOf(this).toString(),
  ).format(at);

  /// The weekday's narrow form: "M", "T"...
  String dayInitial(DateTime day) =>
      DateFormat('EEEEE', Localizations.localeOf(this).toString()).format(day);

  /// The day of the month: "17".
  String dayOfMonth(DateTime day) =>
      DateFormat.d(Localizations.localeOf(this).toString()).format(day);

  /// "19:00".
  String shortTime(DateTime at) =>
      DateFormat.Hm(Localizations.localeOf(this).toString()).format(at);

  /// A platform's duration limit: "90 s", "3 min" or "140 s".
  String limitLabel(Duration limit) {
    final seconds = limit.inSeconds;
    return seconds < Duration.secondsPerMinute * 2 ||
            seconds % Duration.secondsPerMinute != 0
        ? l10n.composerSeconds(seconds)
        : l10n.composerMinutes(limit.inMinutes);
  }

  String _editedAgo(DateTime at, {required DateTime now}) {
    if (relativeDayOf(at, now: now) == RelativeDay.yesterday) {
      return l10n.composerEditedYesterday;
    }
    final (:unit, :count) = elapsedBetween(at, now);
    return switch (unit) {
      ElapsedUnit.justNow => l10n.composerEditedJustNow,
      ElapsedUnit.minutes => l10n.composerEditedMinutesAgo(count),
      ElapsedUnit.hours => l10n.composerEditedHoursAgo(count),
      ElapsedUnit.days => l10n.composerEditedDaysAgo(count),
    };
  }
}

/// Whole megabytes, rounded down.
int megabytesOf(int bytes) => bytes ~/ (1024 * 1024);
