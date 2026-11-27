import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/domain/post_summary.dart';

final _seven = DateTime(2026, 11, 12, 19);
final _half = DateTime(2026, 11, 12, 13, 30);

Post _post(List<PostTarget> targets) => Post(
  id: 'p',
  video: const VideoAsset(
    id: 'v',
    fileName: 'v.mp4',
    duration: Duration(seconds: 10),
    sizeBytes: 1,
    width: 1080,
    height: 1920,
  ),
  caption: 'p',
  targets: targets,
  isDraft: false,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

PostStats _views(int views) =>
    PostStats(views: views, likes: 0, comments: 0, refreshedAt: _seven);

void main() {
  test('scheduled: the next time', () {
    expect(
      summarizePost(
        _post([
          PostTarget(
            platform: PlatformId.youtube,
            scheduledAt: _seven,
            status: TargetStatus.scheduled,
          ),
        ]),
      ),
      PostSummary.scheduled(_seven),
    );
  });

  test('publishing', () {
    expect(
      summarizePost(
        _post([
          const PostTarget(
            platform: PlatformId.youtube,
            status: TargetStatus.processing,
          ),
        ]),
      ),
      const PostSummary.publishing(),
    );
  });

  test('published: total views, or none without stats', () {
    expect(
      summarizePost(
        _post([
          PostTarget(
            platform: PlatformId.youtube,
            status: TargetStatus.published,
            stats: _views(8000),
          ),
          PostTarget(
            platform: PlatformId.tiktok,
            status: TargetStatus.published,
            stats: _views(204),
          ),
        ]),
      ),
      const PostSummary.published(views: 8204),
    );
    expect(
      summarizePost(
        _post([
          const PostTarget(
            platform: PlatformId.youtube,
            status: TargetStatus.published,
          ),
        ]),
      ),
      const PostSummary.published(),
    );
  });

  test('failed: the failed platforms and when they failed', () {
    expect(
      summarizePost(
        _post([
          PostTarget(
            platform: PlatformId.youtube,
            scheduledAt: _half,
            status: TargetStatus.published,
          ),
          PostTarget(
            platform: PlatformId.tiktok,
            scheduledAt: _half,
            status: TargetStatus.failed,
          ),
        ]),
      ),
      PostSummary.failed(platforms: const [PlatformId.tiktok], at: _half),
    );
    expect(
      summarizePost(
        _post([
          const PostTarget(
            platform: PlatformId.youtube,
            status: TargetStatus.failed,
          ),
          const PostTarget(
            platform: PlatformId.tiktok,
            status: TargetStatus.failed,
          ),
        ]),
      ),
      const PostSummary.failed(
        platforms: [PlatformId.youtube, PlatformId.tiktok],
      ),
    );
  });
}
