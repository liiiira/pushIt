import 'package:pushit/domain/enums/platform_id.dart';

/// Where assisted posting opens a platform (G2): its app or website.
Uri platformHomeUri(PlatformId platform) => Uri.https(switch (platform) {
  PlatformId.youtube => 'www.youtube.com',
  PlatformId.instagram => 'www.instagram.com',
  PlatformId.tiktok => 'www.tiktok.com',
  PlatformId.facebook => 'www.facebook.com',
  PlatformId.threads => 'www.threads.net',
  PlatformId.linkedin => 'www.linkedin.com',
  PlatformId.bluesky => 'bsky.app',
  PlatformId.x => 'x.com',
});
