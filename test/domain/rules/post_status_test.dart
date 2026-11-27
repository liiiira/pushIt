import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/domain/domain.dart';

PostTarget _target(PlatformId platform, TargetStatus status) => PostTarget(
  platform: platform,
  accountId: 'acc-${platform.name}',
  scheduledAt: DateTime(2026, 11, 12, 19),
  status: status,
);

PostStatus _derive(List<TargetStatus> statuses, {bool isDraft = false}) =>
    derivePostStatus(
      isDraft: isDraft,
      targets: [
        for (final (i, status) in statuses.indexed)
          _target(PlatformId.values[i], status),
      ],
    );

void main() {
  group('derivePostStatus', () {
    test('a draft is a draft whatever its targets', () {
      expect(
        _derive([TargetStatus.published], isDraft: true),
        PostStatus.draft,
      );
      expect(_derive([], isDraft: true), PostStatus.draft);
    });

    test('every target scheduled is scheduled', () {
      expect(
        _derive([TargetStatus.scheduled, TargetStatus.scheduled]),
        PostStatus.scheduled,
      );
    });

    test('no targets on a non-draft is scheduled', () {
      expect(_derive([]), PostStatus.scheduled);
    });

    test('every target published is published', () {
      expect(
        _derive([TargetStatus.published, TargetStatus.published]),
        PostStatus.published,
      );
    });

    test('removed targets count as done', () {
      expect(
        _derive([TargetStatus.published, TargetStatus.removed]),
        PostStatus.published,
      );
    });

    test('every target failed is failed', () {
      expect(_derive([TargetStatus.failed]), PostStatus.failed);
      expect(
        _derive([TargetStatus.failed, TargetStatus.failed]),
        PostStatus.failed,
      );
    });

    test('some failed and some published is partially failed', () {
      expect(
        _derive([TargetStatus.published, TargetStatus.failed]),
        PostStatus.partiallyFailed,
      );
    });

    test('some failed and some still pending is partially failed', () {
      expect(
        _derive([TargetStatus.scheduled, TargetStatus.failed]),
        PostStatus.partiallyFailed,
      );
    });

    test('uploading, processing or awaiting the user is publishing', () {
      for (final status in [
        TargetStatus.uploading,
        TargetStatus.processing,
        TargetStatus.awaitingUser,
      ]) {
        expect(
          _derive([TargetStatus.published, status]),
          PostStatus.publishing,
          reason: '$status',
        );
      }
    });

    test('some published and some still scheduled is scheduled', () {
      expect(
        _derive([TargetStatus.published, TargetStatus.scheduled]),
        PostStatus.scheduled,
      );
    });
  });
}
