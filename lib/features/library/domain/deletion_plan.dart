import 'package:pushit/domain/domain.dart';

typedef DeletionPlanRow = ({PlatformId platform, DeleteMethod method});

/// How each platform the post is still on gets deleted (F6).
List<DeletionPlanRow> deletionPlanFor(Post post) => List.unmodifiable([
  for (final target in post.targets)
    if (target.status != TargetStatus.removed)
      (
        platform: target.platform,
        method: capabilityOf(target.platform).deleteMethod,
      ),
]);

/// Where a "delete everywhere" stands (F7).
typedef DeletionSummary = ({
  int total,
  int removed,
  int needsAttention,
  bool isRunning,
  bool isComplete,
});

DeletionSummary summarizeDeletion(List<DeletionStep> steps) {
  int count(Set<DeletionOutcome> outcomes) =>
      steps.where((s) => outcomes.contains(s.outcome)).length;
  final removed = count({DeletionOutcome.removed});
  return (
    total: steps.length,
    removed: removed,
    needsAttention: count({
      DeletionOutcome.awaitingUser,
      DeletionOutcome.failed,
    }),
    isRunning: count({DeletionOutcome.pending}) > 0,
    isComplete: steps.isNotEmpty && removed == steps.length,
  );
}
