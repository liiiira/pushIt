/// How a date relates to today, for labels like "today 19:00".
enum RelativeDay { yesterday, today, tomorrow, other }

/// [at] without its time of day.
DateTime dateOnly(DateTime at) => DateTime(at.year, at.month, at.day);

/// Whether [at] falls yesterday, today or tomorrow relative to [now].
RelativeDay relativeDayOf(DateTime at, {required DateTime now}) {
  final today = dateOnly(now);
  final day = dateOnly(at);
  if (day == today) return RelativeDay.today;
  if (day == DateTime(today.year, today.month, today.day - 1)) {
    return RelativeDay.yesterday;
  }
  if (day == DateTime(today.year, today.month, today.day + 1)) {
    return RelativeDay.tomorrow;
  }
  return RelativeDay.other;
}
