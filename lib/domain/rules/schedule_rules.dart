import 'package:pushit/domain/entities/post.dart';
import 'package:pushit/domain/entities/schedule_choice.dart';
import 'package:pushit/domain/enums/platform_id.dart';
import 'package:pushit/domain/enums/target_status.dart';

/// Why a schedule cannot be used.
enum ScheduleProblem { noPlatforms, missingTime, inThePast }

/// Reschedule and cancel are allowed only until publishing starts: the post
/// is not a draft and every target is still scheduled.
bool canReschedule(Post post) =>
    !post.isDraft &&
    post.targets.isNotEmpty &&
    post.targets.every((t) => t.status == TargetStatus.scheduled);

/// `null` when [choice] gives every platform a time after [now].
ScheduleProblem? validateSchedule(
  ScheduleChoice choice, {
  required Set<PlatformId> platforms,
  required DateTime now,
}) {
  if (platforms.isEmpty) return ScheduleProblem.noPlatforms;
  for (final platform in platforms) {
    final at = choice.timeFor(platform);
    if (at == null) return ScheduleProblem.missingTime;
    if (!at.isAfter(now)) return ScheduleProblem.inThePast;
  }
  return null;
}
