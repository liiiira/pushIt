import 'package:pushit/domain/entities/connected_account.dart';
import 'package:pushit/domain/entities/plan.dart';
import 'package:pushit/domain/entities/platform_check_issue.dart';
import 'package:pushit/domain/entities/post_draft.dart';
import 'package:pushit/domain/enums/account_health.dart';
import 'package:pushit/domain/enums/platform_id.dart';
import 'package:pushit/domain/rules/platform_capabilities.dart';
import 'package:pushit/domain/rules/tiktok_rules.dart';
import 'package:pushit/domain/rules/video_limits.dart';

/// The platform check (D8). An empty list means the draft is ready.
///
/// Issues come in a stable order: the file size first, then each selected
/// platform in [PlatformId] order (connection, TikTok privacy, duration,
/// plan).
final class CheckPlatforms {
  const new();

  List<PlatformCheckIssue> call(
    PostDraft draft,
    List<ConnectedAccount> accounts,
    Plan plan,
  ) {
    final video = draft.video;
    final usable = {
      for (final account in accounts)
        if (account.health != AccountHealth.expired) account.platform,
    };

    return List.unmodifiable([
      if (video != null && video.sizeBytes > maxVideoSizeBytes)
        FileTooLarge(
          limitBytes: maxVideoSizeBytes,
          actualBytes: video.sizeBytes,
        ),
      for (final platform in PlatformId.values)
        if (draft.platforms.contains(platform)) ...[
          if (!usable.contains(platform)) NotConnected(platform),
          if (platform == PlatformId.tiktok && !isTikTokReady(draft.tiktok))
            const PrivacyNotChosen(),
          if (video != null && video.duration > maxDurationFor(platform))
            DurationTooLong(
              platform: platform,
              limit: maxDurationFor(platform),
              actual: video.duration,
            ),
          if (capabilityOf(platform).requiresPaidPlan && !plan.hasX)
            PaidPlanRequired(platform),
        ],
    ]);
  }
}
