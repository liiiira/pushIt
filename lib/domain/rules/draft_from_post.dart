import 'package:pushit/domain/entities/post.dart';
import 'package:pushit/domain/entities/post_draft.dart';
import 'package:pushit/domain/entities/schedule_choice.dart';
import 'package:pushit/domain/entities/tiktok_settings.dart';
import 'package:pushit/domain/enums/platform_id.dart';

/// The editable draft of a saved [post], to resume it in the composer.
///
/// One time shared by every target becomes `SameTime`; different times
/// become `PerPlatform`; no time leaves the schedule empty.
PostDraft draftFromPost(Post post) {
  final times = <PlatformId, DateTime>{
    for (final target in post.targets) target.platform: ?target.scheduledAt,
  };
  final distinct = times.values.toSet();
  final schedule = switch (distinct.length) {
    0 => null,
    1 when times.length == post.targets.length => SameTime(distinct.single),
    _ => PerPlatform(times),
  };
  return PostDraft(
    video: post.video,
    caption: post.caption,
    platforms: {for (final target in post.targets) target.platform},
    copies: post.copies,
    coverAt: post.coverAt,
    tiktok: post.tiktok ?? const TikTokSettings(),
    schedule: schedule,
  );
}
