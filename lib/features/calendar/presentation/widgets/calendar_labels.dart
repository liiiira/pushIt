import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/calendar/domain/calendar_rules.dart';

/// Phrases dates and entry summaries for the calendar.
extension CalendarLabels on BuildContext {
  String get _locale => Localizations.localeOf(this).toString();

  String _format(String pattern, DateTime at) =>
      DateFormat(pattern, _locale).format(at);

  /// "Thursday 12".
  String weekdayAndDay(DateTime day) => _format('EEEE d', day);

  /// "Thu".
  String shortWeekday(DateTime day) => _format('EEE', day);

  /// "T".
  String narrowWeekday(DateTime day) => _format('EEEEE', day);

  /// "12".
  String dayNumber(DateTime day) => _format('d', day);

  /// "November".
  String monthName(DateTime day) => _format('MMMM', day);

  /// "19:00".
  String time(DateTime at) => DateFormat.Hm(_locale).format(at);

  /// "9 to 15 Nov".
  String weekRange(List<DateTime> week) => l10n.calendarWeekRange(
    _format('d', week.first),
    _format('d MMM', week.last),
  );

  /// "today 19:00", "tomorrow 09:00" or "Tue 17 Nov, 19:00".
  String whenLabel(DateTime at, {required DateTime now}) =>
      switch (relativeDayOf(at, now: now)) {
        RelativeDay.today => l10n.calendarWhenToday(time(at)),
        RelativeDay.tomorrow => l10n.calendarWhenTomorrow(time(at)),
        RelativeDay.yesterday || RelativeDay.other => l10n.calendarWhenDate(
          _format('EEE d MMM', at),
          time(at),
        ),
      };

  String entryLabel(EntrySummary summary) => switch (summary) {
    EntryPublished(:final platformCount) => l10n.calendarPublished(
      platformCount,
    ),
    EntryScheduled(:final platformCount) => l10n.calendarScheduled(
      platformCount,
    ),
    EntryPublishing() => l10n.calendarPublishing,
    EntryFailed(:final platforms) =>
      platforms.length == 1
          ? l10n.calendarFailedOne(l10n.platformName(platforms.single))
          : l10n.calendarFailedMany(platforms.length),
    EntryAssisted(:final platforms) =>
      platforms.length == 1
          ? l10n.calendarAssistedOne(l10n.platformName(platforms.single))
          : l10n.calendarAssistedMany(platforms.length),
  };
}
