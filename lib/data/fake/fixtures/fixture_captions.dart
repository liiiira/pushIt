import 'package:pushit/domain/domain.dart';

/// A canned caption variant for [platform], built from [caption] (D11).
String fixtureCaptionVariant(PlatformId platform, String caption) {
  final base = caption.trim();
  final lower = base.isEmpty
      ? base
      : '${base[0].toLowerCase()}${base.substring(1)}';
  return switch (platform) {
    PlatformId.youtube => '$base\n\n#shorts',
    PlatformId.instagram => '$base Save it for later.\n\n#reels #creator',
    PlatformId.tiktok => 'POV: $lower #fyp',
    PlatformId.facebook => '$base What would you add?',
    PlatformId.threads => 'Quick one: $lower',
    PlatformId.linkedin => 'Behind the scenes: $lower',
    PlatformId.bluesky => 'New short: $lower',
    PlatformId.x => 'New short: $lower',
  };
}
