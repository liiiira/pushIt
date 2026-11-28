import 'package:pushit/domain/domain.dart';

/// The time the post detail header shows (F3, F4): when it failed, went
/// out, or goes out next.
DateTime? postHeaderTime(Post post) {
  DateTime? firstOf(Iterable<PostTarget> targets) =>
      targets.map((t) => t.scheduledAt).nonNulls.firstOrNull;

  return switch (post.status) {
    PostStatus.failed || PostStatus.partiallyFailed => firstOf(
      post.targets.where((t) => t.status == TargetStatus.failed),
    ),
    PostStatus.scheduled || PostStatus.draft => post.nextScheduledAt,
    PostStatus.published || PostStatus.publishing => firstOf(post.targets),
  };
}

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
