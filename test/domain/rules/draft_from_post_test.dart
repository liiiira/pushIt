import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/domain/domain.dart';

const _video = VideoAsset(
  id: 'v',
  fileName: 'v.mp4',
  duration: Duration(seconds: 59),
  sizeBytes: 1,
  width: 1080,
  height: 1920,
);

final _seven = DateTime(2026, 11, 17, 19);
final _half = DateTime(2026, 11, 17, 20, 30);

Post _post(List<PostTarget> targets, {TikTokSettings? tiktok}) => Post(
  id: 'd1',
  video: _video,
  caption: 'Unboxing the lav mic',
  copies: const [PlatformCopy(platform: PlatformId.youtube, text: 'yt')],
  coverAt: const Duration(seconds: 4),
  tiktok: tiktok,
  targets: targets,
  isDraft: true,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  test('copies the content and the platforms', () {
    final draft = draftFromPost(
      _post(const [
        PostTarget(
          platform: PlatformId.youtube,
          status: TargetStatus.scheduled,
        ),
        PostTarget(platform: PlatformId.tiktok, status: TargetStatus.scheduled),
      ], tiktok: const TikTokSettings(privacy: TikTokPrivacy.friends)),
    );
    expect(draft.video, _video);
    expect(draft.caption, 'Unboxing the lav mic');
    expect(draft.platforms, {PlatformId.youtube, PlatformId.tiktok});
    expect(draft.copies, const [
      PlatformCopy(platform: PlatformId.youtube, text: 'yt'),
    ]);
    expect(draft.coverAt, const Duration(seconds: 4));
    expect(draft.tiktok.privacy, TikTokPrivacy.friends);
    expect(draft.schedule, isNull);
  });

  test('one shared time becomes SameTime', () {
    final draft = draftFromPost(
      _post([
        PostTarget(
          platform: PlatformId.youtube,
          scheduledAt: _seven,
          status: TargetStatus.scheduled,
        ),
        PostTarget(
          platform: PlatformId.instagram,
          scheduledAt: _seven,
          status: TargetStatus.scheduled,
        ),
      ]),
    );
    expect(draft.schedule, SameTime(_seven));
  });

  test('different times become PerPlatform', () {
    final draft = draftFromPost(
      _post([
        PostTarget(
          platform: PlatformId.youtube,
          scheduledAt: _seven,
          status: TargetStatus.scheduled,
        ),
        PostTarget(
          platform: PlatformId.tiktok,
          scheduledAt: _half,
          status: TargetStatus.scheduled,
        ),
      ]),
    );
    expect(
      draft.schedule,
      PerPlatform({PlatformId.youtube: _seven, PlatformId.tiktok: _half}),
    );
  });

  test('without TikTok settings, the defaults apply', () {
    expect(draftFromPost(_post(const [])).tiktok, const TikTokSettings());
  });
}
