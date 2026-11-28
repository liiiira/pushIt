import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/composer/domain/composer_rules.dart';

ConnectedAccount _account(PlatformId platform, {String? id}) =>
    ConnectedAccount(
      id: id ?? 'acc-${platform.name}',
      platform: platform,
      handle: '@me',
      label: 'Me',
      accountType: 'creator',
      mode: AccountMode.automatic,
      health: AccountHealth.connected,
    );

VideoAsset _video(Duration duration) => VideoAsset(
  id: 'v',
  fileName: 'v.mp4',
  duration: duration,
  sizeBytes: 1,
  width: 1080,
  height: 1920,
);

void main() {
  final accounts = [
    _account(PlatformId.tiktok),
    _account(PlatformId.facebook),
    _account(PlatformId.youtube),
    _account(PlatformId.youtube, id: 'second-channel'),
    _account(PlatformId.x),
  ];

  test('connectedPlatforms: unique, in platform order', () {
    expect(connectedPlatforms(accounts), [
      PlatformId.youtube,
      PlatformId.tiktok,
      PlatformId.facebook,
      PlatformId.x,
    ]);
  });

  group('defaultPlatforms', () {
    test('every connected platform the video fits', () {
      expect(
        defaultPlatforms(
          accounts,
          _video(const Duration(minutes: 1, seconds: 42)),
          proPlan,
        ),
        {PlatformId.youtube, PlatformId.tiktok, PlatformId.x},
      );
    });

    test('X only on plans that have it', () {
      expect(
        defaultPlatforms(
          accounts,
          _video(const Duration(seconds: 30)),
          freePlan,
        ),
        {PlatformId.youtube, PlatformId.tiktok, PlatformId.facebook},
      );
    });
  });

  test('durationWarnings: connected platforms the video is too long for', () {
    const actual = Duration(minutes: 1, seconds: 42);
    expect(durationWarnings(accounts, _video(actual)), const [
      DurationTooLong(
        platform: PlatformId.facebook,
        limit: Duration(seconds: 90),
        actual: actual,
      ),
    ]);
  });

  group('coverFrames', () {
    test('evenly spaced whole seconds from the start', () {
      expect(coverFrames(const Duration(seconds: 60)), const [
        Duration.zero,
        Duration(seconds: 10),
        Duration(seconds: 20),
        Duration(seconds: 30),
        Duration(seconds: 40),
        Duration(seconds: 50),
      ]);
    });

    test('short videos repeat no frame', () {
      expect(coverFrames(const Duration(seconds: 3)), const [
        Duration.zero,
        Duration(seconds: 1),
        Duration(seconds: 2),
      ]);
    });
  });
}
