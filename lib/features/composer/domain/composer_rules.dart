import 'package:pushit/domain/domain.dart';

/// The platforms with at least one connected account, in [PlatformId]
/// order (D4's logo row).
List<PlatformId> connectedPlatforms(List<ConnectedAccount> accounts) {
  final connected = {for (final account in accounts) account.platform};
  return List.unmodifiable(PlatformId.values.where(connected.contains));
}

/// What a new post starts with: every connected platform the video fits,
/// and X only on plans that include it.
Set<PlatformId> defaultPlatforms(
  List<ConnectedAccount> accounts,
  VideoAsset video,
  Plan plan,
) => Set.unmodifiable(
  connectedPlatforms(accounts).where(
    (platform) =>
        video.duration <= maxDurationFor(platform) &&
        (!capabilityOf(platform).requiresPaidPlan || plan.hasX),
  ),
);

/// The connected platforms the video is too long for (D4's warning).
List<DurationTooLong> durationWarnings(
  List<ConnectedAccount> accounts,
  VideoAsset video,
) => List.unmodifiable([
  for (final platform in connectedPlatforms(accounts))
    if (video.duration > maxDurationFor(platform))
      DurationTooLong(
        platform: platform,
        limit: maxDurationFor(platform),
        actual: video.duration,
      ),
]);

/// The cover choices of D6: [count] frames spread evenly from the start,
/// in whole seconds, without repeats.
List<Duration> coverFrames(Duration duration, {int count = 6}) {
  final seconds = duration.inSeconds;
  return List.unmodifiable(
    {for (var i = 0; i < count; i++) Duration(seconds: seconds * i ~/ count)}
        .toList(),
  );
}
