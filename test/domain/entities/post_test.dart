import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/domain/domain.dart';

final _created = DateTime(2026, 11, 10, 8);
final _seven = DateTime(2026, 11, 12, 19);
final _nine = DateTime(2026, 11, 13, 9);

const _video = VideoAsset(
  id: 'v1',
  fileName: 'studio_tour_2.mp4',
  duration: Duration(minutes: 1, seconds: 42),
  sizeBytes: 84 * 1024 * 1024,
  width: 1080,
  height: 1920,
);

PostStats _stats(int views, DateTime refreshedAt) => PostStats(
  views: views,
  likes: views ~/ 10,
  comments: views ~/ 100,
  refreshedAt: refreshedAt,
);

Post _post({
  String caption = 'Studio tour, part 2\nThe desk, the lights.',
  List<PlatformCopy> copies = const [],
  List<PostTarget> targets = const [],
  bool isDraft = false,
}) => Post(
  id: 'p1',
  video: _video,
  caption: caption,
  copies: copies,
  targets: targets,
  isDraft: isDraft,
  createdAt: _created,
  updatedAt: _created,
);

void main() {
  group('Post', () {
    test('status is derived from the targets', () {
      final post = _post(
        targets: [
          PostTarget(
            platform: PlatformId.youtube,
            accountId: 'a1',
            scheduledAt: _seven,
            status: TargetStatus.published,
          ),
          PostTarget(
            platform: PlatformId.tiktok,
            accountId: 'a2',
            scheduledAt: _seven,
            status: TargetStatus.failed,
          ),
        ],
      );
      expect(post.status, PostStatus.partiallyFailed);
      expect(_post(isDraft: true).status, PostStatus.draft);
    });

    test('nextScheduledAt is the earliest still-scheduled time', () {
      final post = _post(
        targets: [
          PostTarget(
            platform: PlatformId.youtube,
            accountId: 'a1',
            scheduledAt: _nine,
            status: TargetStatus.scheduled,
          ),
          PostTarget(
            platform: PlatformId.instagram,
            accountId: 'a2',
            scheduledAt: _seven,
            status: TargetStatus.scheduled,
          ),
          PostTarget(
            platform: PlatformId.facebook,
            accountId: 'a3',
            scheduledAt: DateTime(2026, 11, 12, 9),
            status: TargetStatus.published,
          ),
        ],
      );
      expect(post.nextScheduledAt, _seven);
    });

    test('nextScheduledAt is null when nothing is scheduled', () {
      expect(_post().nextScheduledAt, isNull);
      expect(
        _post(
          targets: [
            const PostTarget(
              platform: PlatformId.youtube,
              accountId: 'a1',
              status: TargetStatus.scheduled,
            ),
          ],
        ).nextScheduledAt,
        isNull,
      );
    });

    test('totals sum the stats of every target, latest refresh wins', () {
      final post = _post(
        targets: [
          PostTarget(
            platform: PlatformId.youtube,
            accountId: 'a1',
            scheduledAt: _seven,
            status: TargetStatus.published,
            stats: _stats(8000, _seven),
          ),
          PostTarget(
            platform: PlatformId.facebook,
            accountId: 'a2',
            scheduledAt: _seven,
            status: TargetStatus.published,
            stats: _stats(204, _nine),
          ),
          PostTarget(
            platform: PlatformId.tiktok,
            accountId: 'a3',
            scheduledAt: _seven,
            status: TargetStatus.scheduled,
          ),
        ],
      );
      expect(
        post.totals,
        PostStats(views: 8204, likes: 820, comments: 82, refreshedAt: _nine),
      );
    });

    test('totals is null when no target has stats', () {
      expect(_post().totals, isNull);
    });

    test('title prefers the YouTube title', () {
      final post = _post(
        copies: const [
          PlatformCopy(
            platform: PlatformId.youtube,
            title: 'Studio tour (part 2)',
            text: 'desc',
          ),
        ],
      );
      expect(post.title, 'Studio tour (part 2)');
    });

    test('title falls back to the first caption line', () {
      expect(_post().title, 'Studio tour, part 2');
      expect(
        _post(
          copies: const [
            PlatformCopy(platform: PlatformId.youtube, title: '  ', text: 'd'),
          ],
        ).title,
        'Studio tour, part 2',
      );
      expect(_post(caption: '').title, '');
    });

    test('copyFor returns the override for a platform, if any', () {
      const copy = PlatformCopy(platform: PlatformId.tiktok, text: 'tt');
      final post = _post(copies: const [copy]);
      expect(post.copyFor(PlatformId.tiktok), copy);
      expect(post.copyFor(PlatformId.youtube), isNull);
    });

    test('captionFor uses the override text or the shared caption', () {
      final post = _post(
        caption: 'shared',
        copies: const [PlatformCopy(platform: PlatformId.tiktok, text: 'tt')],
      );
      expect(post.captionFor(PlatformId.tiktok), 'tt');
      expect(post.captionFor(PlatformId.youtube), 'shared');
    });

    test('targetFor finds the target of a platform', () {
      const target = PostTarget(
        platform: PlatformId.tiktok,
        accountId: 'a',
        status: TargetStatus.failed,
      );
      final post = _post(targets: const [target]);
      expect(post.targetFor(PlatformId.tiktok), target);
      expect(post.targetFor(PlatformId.youtube), isNull);
    });

    test('exposes unmodifiable lists', () {
      final post = _post(
        targets: [
          const PostTarget(
            platform: PlatformId.youtube,
            accountId: 'a',
            status: TargetStatus.scheduled,
          ),
        ],
      );
      expect(post.targets.clear, throwsUnsupportedError);
      expect(post.copies.clear, throwsUnsupportedError);
    });

    test('copyWith replaces fields and can clear tiktok', () {
      final post = _post().copyWith(
        tiktok: () => const TikTokSettings(privacy: TikTokPrivacy.friends),
      );
      expect(post.tiktok?.privacy, TikTokPrivacy.friends);
      expect(post.copyWith(caption: 'x').caption, 'x');
      expect(post.copyWith(tiktok: () => null).tiktok, isNull);
      expect(post.copyWith(), post);
    });
  });

  group('PostTarget', () {
    test('copyWith can clear nullable fields', () {
      final target = PostTarget(
        platform: PlatformId.tiktok,
        accountId: 'a',
        scheduledAt: _seven,
        status: TargetStatus.failed,
        failureReason: TargetFailureReason.signInExpired,
      );
      final retried = target.copyWith(
        status: TargetStatus.scheduled,
        failureReason: () => null,
      );
      expect(retried.status, TargetStatus.scheduled);
      expect(retried.failureReason, isNull);
      expect(retried.scheduledAt, _seven);
    });
  });
}
