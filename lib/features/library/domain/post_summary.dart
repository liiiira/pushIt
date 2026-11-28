import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:pushit/domain/domain.dart';

/// The one-line status of a post in lists (F1), as data for the view to
/// phrase.
sealed class PostSummary extends Equatable {
  const new();

  const factory scheduled(DateTime? at) = SummaryScheduled;
  const factory publishing() = SummaryPublishing;
  const factory published({int? views}) = SummaryPublished;
  const factory failed({required List<PlatformId> platforms, DateTime? at}) =
      SummaryFailed;

  @override
  List<Object?> get props => const [];
}

final class SummaryScheduled extends PostSummary {
  const new(this.at);

  /// The next scheduled time; `null` when none is set.
  final DateTime? at;

  @override
  List<Object?> get props => [at];
}

final class SummaryPublishing extends PostSummary {
  const new();
}

final class SummaryPublished extends PostSummary {
  const new({this.views});

  /// Total views; `null` without statistics.
  final int? views;

  @override
  List<Object?> get props => [views];
}

final class SummaryFailed extends PostSummary {
  const new({required this._platforms, this.at});

  final List<PlatformId> _platforms;

  /// When the first failed platform was scheduled.
  final DateTime? at;

  List<PlatformId> get platforms => UnmodifiableListView(_platforms);

  @override
  List<Object?> get props => [_platforms, at];
}

/// The summary line of [post].
PostSummary summarizePost(Post post) {
  final failed = post.targets.where((t) => t.status == TargetStatus.failed);
  return switch (post.status) {
    PostStatus.failed || PostStatus.partiallyFailed => PostSummary.failed(
      platforms: failed.map((t) => t.platform).toList(),
      at: failed.first.scheduledAt,
    ),
    PostStatus.publishing => const PostSummary.publishing(),
    PostStatus.published => PostSummary.published(views: post.totals?.views),
    PostStatus.scheduled ||
    PostStatus.draft => PostSummary.scheduled(post.nextScheduledAt),
  };
}
