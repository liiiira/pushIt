import 'package:pushit/core/l10n/generated/app_localizations.dart';
import 'package:pushit/domain/domain.dart';

extension PlatformNames on AppLocalizations {
  /// The display name of [platform], e.g. `YouTube`.
  String platformName(PlatformId platform) => switch (platform) {
    PlatformId.youtube => commonPlatformYouTube,
    PlatformId.instagram => commonPlatformInstagram,
    PlatformId.tiktok => commonPlatformTikTok,
    PlatformId.facebook => commonPlatformFacebook,
    PlatformId.threads => commonPlatformThreads,
    PlatformId.linkedin => commonPlatformLinkedIn,
    PlatformId.bluesky => commonPlatformBluesky,
    PlatformId.x => commonPlatformX,
  };
}
