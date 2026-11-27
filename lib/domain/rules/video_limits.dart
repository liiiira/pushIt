import 'package:pushit/domain/enums/platform_id.dart';

/// The largest video pushIt accepts: 300 MB.
const int maxVideoSizeBytes = 300 * 1024 * 1024;

/// The longest video each platform accepts as a short.
Duration maxDurationFor(PlatformId platform) => switch (platform) {
  // From the spec.
  PlatformId.facebook => const Duration(seconds: 90),
  // ASSUMPTION: verify against official docs before the backend phase.
  PlatformId.youtube => const Duration(minutes: 3),
  // ASSUMPTION: verify against official docs before the backend phase.
  PlatformId.instagram => const Duration(minutes: 3),
  // ASSUMPTION: verify against official docs before the backend phase.
  PlatformId.tiktok => const Duration(minutes: 10),
  // ASSUMPTION: verify against official docs before the backend phase.
  PlatformId.threads => const Duration(minutes: 5),
  // ASSUMPTION: verify against official docs before the backend phase.
  PlatformId.linkedin => const Duration(minutes: 10),
  // ASSUMPTION: verify against official docs before the backend phase.
  PlatformId.bluesky => const Duration(minutes: 3),
  // ASSUMPTION: verify against official docs before the backend phase.
  PlatformId.x => const Duration(minutes: 2, seconds: 20),
};
