import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';

/// Dates as the designs phrase them. Import this file where needed; it is
/// not exported from `l10n.dart`, so it never clashes with a feature's own
/// labels.
extension DateLabels on BuildContext {
  /// "today, 19:00", "tomorrow, 09:00", "yesterday, 23:30" or
  /// "Tue 17 Nov, 19:00" (C5: "reconnect before today, 19:00").
  String dayAndTimeLabel(DateTime at, {required DateTime now}) {
    final locale = Localizations.localeOf(this).toString();
    final time = DateFormat.Hm(locale).format(at);
    return switch (relativeDayOf(at, now: now)) {
      RelativeDay.today => l10n.commonWhenToday(time),
      RelativeDay.tomorrow => l10n.commonWhenTomorrow(time),
      RelativeDay.yesterday => l10n.commonWhenYesterday(time),
      RelativeDay.other => l10n.commonWhenDate(
        DateFormat('EEE d MMM', locale).format(at),
        time,
      ),
    };
  }
}
