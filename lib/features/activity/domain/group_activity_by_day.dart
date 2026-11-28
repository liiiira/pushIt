import 'package:equatable/equatable.dart';
import 'package:pushit/domain/domain.dart';

/// How long the activity list keeps an event (B3's footer); the server
/// drops older ones.
const Duration activityRetention = Duration(days: 30);

/// The headings of the activity list (B3).
enum ActivityDay { today, yesterday, earlier }

/// The activity of one heading, newest first.
final class ActivityGroup extends Equatable {
  const new({required this.day, required this.items});

  final ActivityDay day;
  final List<ActivityItem> items;

  @override
  List<Object?> get props => [day, items];
}

/// Sorts [ActivityItem]s newest first and groups them under today,
/// yesterday and earlier, leaving out empty headings.
final class GroupActivityByDay {
  const new();

  List<ActivityGroup> call(List<ActivityItem> items, {required DateTime now}) {
    final sorted = [...items]
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    final byDay = <ActivityDay, List<ActivityItem>>{};
    for (final item in sorted) {
      final day = switch (relativeDayOf(item.occurredAt, now: now)) {
        RelativeDay.today || RelativeDay.tomorrow => ActivityDay.today,
        RelativeDay.yesterday => ActivityDay.yesterday,
        RelativeDay.other => ActivityDay.earlier,
      };
      (byDay[day] ??= []).add(item);
    }
    return [
      for (final day in ActivityDay.values)
        if (byDay[day] case final items?)
          ActivityGroup(day: day, items: List.unmodifiable(items)),
    ];
  }
}
