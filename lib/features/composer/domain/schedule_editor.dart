import 'package:pushit/domain/domain.dart';

/// The step of the time picker (D9, D10).
const Duration scheduleStep = Duration(minutes: 15);

/// A first proposal: an hour from now, rounded up to the next quarter.
DateTime defaultScheduleTime(DateTime now) {
  final inAnHour = now.add(const Duration(hours: 1));
  final minutes = inAnHour.minute;
  final rounded =
      (minutes + scheduleStep.inMinutes - 1) ~/
      scheduleStep.inMinutes *
      scheduleStep.inMinutes;
  return DateTime(
    inAnHour.year,
    inAnHour.month,
    inAnHour.day,
    inAnHour.hour,
  ).add(Duration(minutes: rounded));
}

/// The days the strip offers: today and the [count] - 1 next.
List<DateTime> scheduleDays(DateTime now, {int count = 7}) {
  final today = dateOnly(now);
  return List.unmodifiable([
    for (var i = 0; i < count; i++)
      DateTime(today.year, today.month, today.day + i),
  ]);
}

/// [at]'s time of day on [day].
DateTime withDay(DateTime at, DateTime day) =>
    DateTime(day.year, day.month, day.day, at.hour, at.minute);

/// [at] moved by [steps] quarters of an hour (negative goes back).
DateTime shiftQuarters(DateTime at, int steps) => at.add(scheduleStep * steps);
