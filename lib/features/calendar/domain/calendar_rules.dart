import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:pushit/domain/domain.dart';

/// The Monday-to-Sunday week around [day].
List<DateTime> weekOf(DateTime day) {
  final date = dateOnly(day);
  final monday = DateTime(
    date.year,
    date.month,
    date.day - (date.weekday - DateTime.monday),
  );
  return List.unmodifiable([
    for (var i = 0; i < DateTime.daysPerWeek; i++)
      DateTime(monday.year, monday.month, monday.day + i),
  ]);
}

/// One post on one day of the calendar, at its earliest time that day.
final class CalendarEntry extends Equatable {
  const new({required this.post, required this.at});

  final Post post;
  final DateTime at;

  @override
  List<Object?> get props => [post, at];
}

/// The posts of [day] (drafts aside), in time order.
List<CalendarEntry> entriesOn(List<Post> posts, DateTime day) {
  final date = dateOnly(day);
  final entries = <CalendarEntry>[];
  for (final post in posts) {
    if (post.isDraft) continue;
    final times =
        post.targets
            .map((t) => t.scheduledAt)
            .nonNulls
            .where((at) => dateOnly(at) == date)
            .toList()
          ..sort();
    if (times.isNotEmpty) {
      entries.add(CalendarEntry(post: post, at: times.first));
    }
  }
  entries.sort((a, b) => a.at.compareTo(b.at));
  return List.unmodifiable(entries);
}

/// The days that have at least one post (the dots of E1).
Set<DateTime> daysWithPosts(List<Post> posts) => Set.unmodifiable({
  for (final post in posts)
    if (!post.isDraft)
      for (final at in post.targets.map((t) => t.scheduledAt).nonNulls)
        dateOnly(at),
});

/// The status line of a calendar entry, as data for the view to phrase.
sealed class EntrySummary extends Equatable {
  const new();

  const factory published({required int platformCount}) = EntryPublished;
  const factory failed({required List<PlatformId> platforms}) = EntryFailed;
  const factory scheduled({required int platformCount}) = EntryScheduled;
  const factory assisted({required List<PlatformId> platforms}) = EntryAssisted;
  const factory publishing() = EntryPublishing;

  @override
  List<Object?> get props => const [];
}

final class EntryPublished extends EntrySummary {
  const new({required this.platformCount});

  final int platformCount;

  @override
  List<Object?> get props => [platformCount];
}

final class EntryFailed extends EntrySummary {
  const new({required this._platforms});

  final List<PlatformId> _platforms;

  List<PlatformId> get platforms => UnmodifiableListView(_platforms);

  @override
  List<Object?> get props => [_platforms];
}

final class EntryScheduled extends EntrySummary {
  const new({required this.platformCount});

  final int platformCount;

  @override
  List<Object?> get props => [platformCount];
}

/// Every platform of the post is assisted: the creator posts it.
final class EntryAssisted extends EntrySummary {
  const new({required this._platforms});

  final List<PlatformId> _platforms;

  List<PlatformId> get platforms => UnmodifiableListView(_platforms);

  @override
  List<Object?> get props => [_platforms];
}

final class EntryPublishing extends EntrySummary {
  const new();
}

EntrySummary summarizeEntry(Post post) {
  final platforms = post.targets.map((t) => t.platform).toList();
  return switch (post.status) {
    PostStatus.failed || PostStatus.partiallyFailed => EntrySummary.failed(
      platforms: [
        for (final target in post.targets)
          if (target.status == TargetStatus.failed) target.platform,
      ],
    ),
    PostStatus.published => EntrySummary.published(
      platformCount: platforms.length,
    ),
    PostStatus.publishing => const EntrySummary.publishing(),
    PostStatus.scheduled || PostStatus.draft
        when platforms.isNotEmpty &&
            platforms.every(
              (p) => capabilityOf(p).publishMethod == AccountMode.assisted,
            ) =>
      EntrySummary.assisted(platforms: platforms),
    PostStatus.scheduled ||
    PostStatus.draft => EntrySummary.scheduled(platformCount: platforms.length),
  };
}
