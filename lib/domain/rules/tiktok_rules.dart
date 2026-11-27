import 'package:pushit/domain/entities/tiktok_settings.dart';

/// TikTok needs an explicit privacy choice; there is no default.
bool isTikTokReady(TikTokSettings settings) => settings.privacy != null;
