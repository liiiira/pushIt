import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/domain/edit_plan.dart';

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

PostTarget _target(PlatformId platform, TargetStatus status) =>
    PostTarget(platform: platform, status: status);

void main() {
  test('published platforms follow their capabilities', () {
    final plan = editPlanFor(
      _post([
        _target(PlatformId.youtube, TargetStatus.published),
        _target(PlatformId.facebook, TargetStatus.published),
        _target(PlatformId.instagram, TargetStatus.published),
        _target(PlatformId.tiktok, TargetStatus.published),
      ]),
    );
    expect(plan, [
      (platform: PlatformId.youtube, scope: EditScope.titleAndCaption),
      (platform: PlatformId.facebook, scope: EditScope.caption),
      (platform: PlatformId.instagram, scope: EditScope.notEditable),
      (platform: PlatformId.tiktok, scope: EditScope.notEditable),
    ]);
    expect(applicableCount(plan), 2);
  });

  test('platforms not posted yet take every change before posting', () {
    final plan = editPlanFor(
      _post([
        _target(PlatformId.tiktok, TargetStatus.scheduled),
        _target(PlatformId.instagram, TargetStatus.failed),
      ]),
    );
    expect(plan, [
      (platform: PlatformId.tiktok, scope: EditScope.beforePosting),
      (platform: PlatformId.instagram, scope: EditScope.beforePosting),
    ]);
    expect(applicableCount(plan), 2);
  });

  test('removed platforms are left out', () {
    expect(
      editPlanFor(_post([_target(PlatformId.youtube, TargetStatus.removed)])),
      isEmpty,
    );
  });
}
