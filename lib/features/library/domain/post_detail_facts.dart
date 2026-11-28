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
