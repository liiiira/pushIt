import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/domain/domain.dart';

const _check = CheckPlatforms();

VideoAsset _video({
  Duration duration = const Duration(seconds: 60),
  int sizeBytes = 50 * 1024 * 1024,
}) => VideoAsset(
  id: 'v1',
  fileName: 'clip.mp4',
  duration: duration,
  sizeBytes: sizeBytes,
  width: 1080,
  height: 1920,
);

ConnectedAccount _account(
  PlatformId platform, {
  AccountHealth health = AccountHealth.connected,
}) => ConnectedAccount(
  id: 'acc-${platform.name}',
  platform: platform,
  handle: '@me',
  label: 'Me',
  accountType: 'creator',
  mode: AccountMode.automatic,
  health: health,
);

final List<ConnectedAccount> _allAccounts = [
  for (final p in PlatformId.values) _account(p),
];

PostDraft _draft(
  Set<PlatformId> platforms, {
  VideoAsset? video,
  TikTokSettings tiktok = const TikTokSettings(privacy: TikTokPrivacy.everyone),
}) => PostDraft(
  video: video ?? _video(),
  caption: 'Hello',
  platforms: platforms,
  tiktok: tiktok,
);

void main() {
  final pro = planFor(PlanTier.pro);
  final free = planFor(PlanTier.free);

  test('a valid draft has no issues', () {
    expect(
      _check(_draft(PlatformId.values.toSet()), _allAccounts, pro),
      isEmpty,
    );
  });

  test('a file over 300 MB is reported once', () {
    final big = _video(sizeBytes: maxVideoSizeBytes + 1);
    expect(
      _check(
        _draft({PlatformId.youtube, PlatformId.facebook}, video: big),
        _allAccounts,
        pro,
      ),
      [FileTooLarge(limitBytes: maxVideoSizeBytes, actualBytes: big.sizeBytes)],
    );
  });

  test('a video longer than a platform allows is reported per platform', () {
    const actual = Duration(seconds: 120);
    expect(
      _check(
        _draft({PlatformId.facebook}, video: _video(duration: actual)),
        _allAccounts,
        pro,
      ),
      [
        DurationTooLong(
          platform: PlatformId.facebook,
          limit: maxDurationFor(PlatformId.facebook),
          actual: actual,
        ),
      ],
    );
  });

  test('a duration exactly at the limit is fine', () {
    expect(
      _check(
        _draft({
          PlatformId.facebook,
        }, video: _video(duration: maxDurationFor(PlatformId.facebook))),
        _allAccounts,
        pro,
      ),
      isEmpty,
    );
  });

  test('TikTok without a privacy choice is reported', () {
    expect(
      _check(
        _draft({PlatformId.tiktok}, tiktok: const TikTokSettings()),
        _allAccounts,
        pro,
      ),
      [const PrivacyNotChosen()],
    );
  });

  test('TikTok privacy is ignored when TikTok is not selected', () {
    expect(
      _check(
        _draft({PlatformId.youtube}, tiktok: const TikTokSettings()),
        _allAccounts,
        pro,
      ),
      isEmpty,
    );
  });

  test('a platform without an account is not connected', () {
    expect(
      _check(_draft({PlatformId.youtube, PlatformId.threads}), [
        _account(PlatformId.youtube),
      ], pro),
      [const NotConnected(PlatformId.threads)],
    );
  });

  test('an account whose sign-in expired is not connected', () {
    expect(
      _check(_draft({PlatformId.tiktok}), [
        _account(PlatformId.tiktok, health: AccountHealth.expired),
      ], pro),
      [const NotConnected(PlatformId.tiktok)],
    );
  });

  test('an account expiring soon still counts as connected', () {
    expect(
      _check(_draft({PlatformId.tiktok}), [
        _account(PlatformId.tiktok, health: AccountHealth.expiringSoon),
      ], pro),
      isEmpty,
    );
  });

  test('X on the Free plan requires a paid plan', () {
    expect(_check(_draft({PlatformId.x}), _allAccounts, free), [
      const PaidPlanRequired(PlatformId.x),
    ]);
  });

  test('issues come in a stable order: file, then platforms in order', () {
    final issues = _check(
      _draft(
        {PlatformId.x, PlatformId.tiktok, PlatformId.facebook},
        video: _video(
          duration: const Duration(minutes: 2),
          sizeBytes: maxVideoSizeBytes + 1,
        ),
        tiktok: const TikTokSettings(),
      ),
      [_account(PlatformId.facebook), _account(PlatformId.x)],
      free,
    );

    expect(issues.map((i) => i.runtimeType), [
      FileTooLarge,
      NotConnected,
      PrivacyNotChosen,
      DurationTooLong,
      PaidPlanRequired,
    ]);
  });

  test('a draft without a video only gets platform issues', () {
    expect(
      _check(const PostDraft(platforms: {PlatformId.threads}), const [], pro),
      [const NotConnected(PlatformId.threads)],
    );
  });
}
