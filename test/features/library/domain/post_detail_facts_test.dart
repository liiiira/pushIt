import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/domain/post_detail_facts.dart';

final _nine = DateTime(2026, 11, 12, 9);
final _half = DateTime(2026, 11, 12, 13, 30);
final _seven = DateTime(2026, 11, 12, 19);

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

void main() {
  group('postHeaderTime', () {
    test('published: when it went out', () {
      expect(
        postHeaderTime(
          _post([
            PostTarget(
              platform: PlatformId.youtube,
              scheduledAt: _nine,
              status: TargetStatus.published,
            ),
          ]),
        ),
        _nine,
      );
    });

    test('failed: when the failed platform was due', () {
      expect(
        postHeaderTime(
          _post([
            PostTarget(
              platform: PlatformId.youtube,
              scheduledAt: _nine,
              status: TargetStatus.published,
            ),
            PostTarget(
              platform: PlatformId.tiktok,
              scheduledAt: _half,
              status: TargetStatus.failed,
            ),
          ]),
        ),
        _half,
      );
    });

    test('scheduled: the next time; none without a time', () {
      expect(
        postHeaderTime(
          _post([
            PostTarget(
              platform: PlatformId.youtube,
              scheduledAt: _seven,
              status: TargetStatus.scheduled,
            ),
          ]),
        ),
        _seven,
      );
      expect(
        postHeaderTime(
          _post([
            const PostTarget(
              platform: PlatformId.youtube,
              status: TargetStatus.scheduled,
            ),
          ]),
        ),
        isNull,
      );
    });
  });

  group('elapsedBetween', () {
    final now = DateTime(2026, 11, 12, 15, 48);

    test('under a minute is just now', () {
      expect(elapsedBetween(now.subtract(const Duration(seconds: 59)), now), (
        unit: ElapsedUnit.justNow,
        count: 0,
      ));
    });

    test('minutes, hours, then days', () {
      expect(elapsedBetween(now.subtract(const Duration(minutes: 5)), now), (
        unit: ElapsedUnit.minutes,
        count: 5,
      ));
      expect(elapsedBetween(now.subtract(const Duration(hours: 2)), now), (
        unit: ElapsedUnit.hours,
        count: 2,
      ));
      expect(
        elapsedBetween(now.subtract(const Duration(days: 3, hours: 1)), now),
        (unit: ElapsedUnit.days, count: 3),
      );
    });
  });
}
