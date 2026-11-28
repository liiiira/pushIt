import 'package:pushit/domain/entities/post_target.dart';
import 'package:pushit/domain/enums/post_status.dart';
import 'package:pushit/domain/enums/target_status.dart';

/// The overall status of a post, from its targets.
///
/// In order of precedence:
/// 1. a draft is [PostStatus.draft]
/// 2. every target failed: [PostStatus.failed]; some failed:
///    [PostStatus.partiallyFailed]
/// 3. any target uploading, processing or waiting for the creator:
///    [PostStatus.publishing]
/// 4. every target published (or removed): [PostStatus.published]
/// 5. otherwise some targets are still to come: [PostStatus.scheduled]
PostStatus derivePostStatus({
  required bool isDraft,
  required List<PostTarget> targets,
}) {
  if (isDraft) return PostStatus.draft;
  if (targets.isEmpty) return PostStatus.scheduled;

  final statuses = targets.map((t) => t.status).toSet();

  if (statuses.contains(TargetStatus.failed)) {
    return statuses.length == 1
        ? PostStatus.failed
        : PostStatus.partiallyFailed;
  }
  if (statuses.any(_inProgress.contains)) return PostStatus.publishing;
  if (statuses.every(_done.contains)) return PostStatus.published;
  return PostStatus.scheduled;
}

const Set<TargetStatus> _inProgress = {
  TargetStatus.uploading,
  TargetStatus.processing,
  TargetStatus.awaitingUser,
};

const Set<TargetStatus> _done = {TargetStatus.published, TargetStatus.removed};
