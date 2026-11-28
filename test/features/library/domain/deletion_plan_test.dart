import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/domain/deletion_plan.dart';

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

DeletionStep _step(PlatformId platform, DeletionOutcome outcome) =>
    DeletionStep(
      platform: platform,
      method: capabilityOf(platform).deleteMethod,
      outcome: outcome,
    );

void main() {
  group('deletionPlanFor', () {
    test('each platform the post is on, with how it is deleted', () {
      expect(
        deletionPlanFor(
          _post(const [
            PostTarget(
              platform: PlatformId.youtube,
              status: TargetStatus.published,
            ),
            PostTarget(
              platform: PlatformId.tiktok,
              status: TargetStatus.published,
            ),
            PostTarget(
              platform: PlatformId.facebook,
              status: TargetStatus.removed,
            ),
          ]),
        ),
        [
          (platform: PlatformId.youtube, method: DeleteMethod.automatic),
          (platform: PlatformId.tiktok, method: DeleteMethod.assisted),
        ],
      );
    });
  });

  group('summarizeDeletion', () {
    test('running while any step is pending', () {
      final summary = summarizeDeletion([
        _step(PlatformId.youtube, DeletionOutcome.removed),
        _step(PlatformId.tiktok, DeletionOutcome.pending),
      ]);
      expect(summary.isRunning, isTrue);
      expect(summary.total, 2);
    });

    test('counts removed steps and the ones that need the creator', () {
      final summary = summarizeDeletion([
        _step(PlatformId.youtube, DeletionOutcome.removed),
        _step(PlatformId.instagram, DeletionOutcome.awaitingUser),
        _step(PlatformId.tiktok, DeletionOutcome.awaitingUser),
        _step(PlatformId.facebook, DeletionOutcome.failed),
      ]);
      expect(summary.isRunning, isFalse);
      expect(summary.removed, 1);
      expect(summary.needsAttention, 3);
      expect(summary.isComplete, isFalse);
    });

    test('complete once everything is removed', () {
      final summary = summarizeDeletion([
        _step(PlatformId.youtube, DeletionOutcome.removed),
      ]);
      expect(summary.isComplete, isTrue);
      expect(summary.needsAttention, 0);
    });
  });
}
