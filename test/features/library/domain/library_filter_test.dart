import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/domain/library_filter.dart';

Post _post(String id, List<TargetStatus> statuses, {bool isDraft = false}) =>
    Post(
      id: id,
      video: const VideoAsset(
        id: 'v',
        fileName: 'v.mp4',
        duration: Duration(seconds: 10),
        sizeBytes: 1,
        width: 1080,
        height: 1920,
      ),
      caption: id,
      targets: [
        for (final (i, status) in statuses.indexed)
          PostTarget(platform: PlatformId.values[i], status: status),
      ],
      isDraft: isDraft,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  final posts = [
    _post('scheduled', [TargetStatus.scheduled]),
    _post('publishing', [TargetStatus.published, TargetStatus.processing]),
    _post('published', [TargetStatus.published]),
    _post('partial', [TargetStatus.published, TargetStatus.failed]),
    _post('failed', [TargetStatus.failed]),
    _post('draft', [TargetStatus.scheduled], isDraft: true),
  ];

  List<String> ids(LibraryFilter filter) =>
      filterLibrary(posts, filter).map((p) => p.id).toList();

  test('all shows every post but drafts, in order', () {
    expect(ids(LibraryFilter.all), [
      'scheduled',
      'publishing',
      'published',
      'partial',
      'failed',
    ]);
  });

  test('scheduled shows posts still to go out', () {
    expect(ids(LibraryFilter.scheduled), ['scheduled', 'publishing']);
  });

  test('published shows fully published posts', () {
    expect(ids(LibraryFilter.published), ['published']);
  });

  test('failed shows posts with any failed platform', () {
    expect(ids(LibraryFilter.failed), ['partial', 'failed']);
  });
}
