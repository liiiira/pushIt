import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/domain/domain.dart';

final _now = DateTime(2026, 11, 12, 15, 48);
final _later = DateTime(2026, 11, 12, 19);
final _earlier = DateTime(2026, 11, 12, 9);

Post _post(List<TargetStatus> statuses, {bool isDraft = false}) => Post(
  id: 'p1',
  video: const VideoAsset(
    id: 'v1',
    fileName: 'clip.mp4',
    duration: Duration(seconds: 30),
    sizeBytes: 1000,
    width: 1080,
    height: 1920,
  ),
  caption: 'Hello',
  targets: [
    for (final (i, status) in statuses.indexed)
      PostTarget(
        platform: PlatformId.values[i],
        accountId: 'a$i',
        scheduledAt: _later,
        status: status,
      ),
  ],
  isDraft: isDraft,
  createdAt: _earlier,
  updatedAt: _earlier,
);

void main() {
  group('canReschedule', () {
    test('is true while every target is still scheduled', () {
      expect(
        canReschedule(_post([TargetStatus.scheduled, TargetStatus.scheduled])),
        isTrue,
      );
    });

    test('is false once any target has started publishing', () {
      for (final started in [
        TargetStatus.uploading,
        TargetStatus.processing,
        TargetStatus.published,
        TargetStatus.awaitingUser,
        TargetStatus.failed,
      ]) {
        expect(
          canReschedule(_post([TargetStatus.scheduled, started])),
          isFalse,
          reason: '$started',
        );
      }
    });

    test('is false for drafts and posts without targets', () {
      expect(
        canReschedule(_post([TargetStatus.scheduled], isDraft: true)),
        isFalse,
      );
      expect(canReschedule(_post([])), isFalse);
    });
  });

  group('validateSchedule', () {
    const platforms = {PlatformId.youtube, PlatformId.tiktok};

    test('a future time for everyone is valid', () {
      expect(
        validateSchedule(SameTime(_later), platforms: platforms, now: _now),
        isNull,
      );
    });

    test('a time in the past is rejected', () {
      expect(
        validateSchedule(SameTime(_earlier), platforms: platforms, now: _now),
        ScheduleProblem.inThePast,
      );
    });

    test('per platform needs a time for every selected platform', () {
      expect(
        validateSchedule(
          PerPlatform({PlatformId.youtube: _later}),
          platforms: platforms,
          now: _now,
        ),
        ScheduleProblem.missingTime,
      );
    });

    test('per platform rejects any time in the past', () {
      expect(
        validateSchedule(
          PerPlatform({
            PlatformId.youtube: _later,
            PlatformId.tiktok: _earlier,
          }),
          platforms: platforms,
          now: _now,
        ),
        ScheduleProblem.inThePast,
      );
    });

    test('per platform with every future time is valid', () {
      expect(
        validateSchedule(
          PerPlatform({PlatformId.youtube: _later, PlatformId.tiktok: _later}),
          platforms: platforms,
          now: _now,
        ),
        isNull,
      );
    });

    test('no platforms selected is rejected', () {
      expect(
        validateSchedule(SameTime(_later), platforms: const {}, now: _now),
        ScheduleProblem.noPlatforms,
      );
    });
  });
}
