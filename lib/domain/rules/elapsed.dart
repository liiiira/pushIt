/// How long ago something happened, for "2 h ago" labels.
enum ElapsedUnit { justNow, minutes, hours, days }

typedef Elapsed = ({ElapsedUnit unit, int count});

/// How long ago [from] was, in the largest whole unit.
Elapsed elapsedBetween(DateTime from, DateTime now) {
  final elapsed = now.difference(from);
  if (elapsed.inMinutes < 1) return (unit: ElapsedUnit.justNow, count: 0);
  if (elapsed.inHours < 1) {
    return (unit: ElapsedUnit.minutes, count: elapsed.inMinutes);
  }
  if (elapsed.inDays < 1) {
    return (unit: ElapsedUnit.hours, count: elapsed.inHours);
  }
  return (unit: ElapsedUnit.days, count: elapsed.inDays);
}
