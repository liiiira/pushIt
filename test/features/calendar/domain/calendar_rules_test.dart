import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/data/fake/fixtures/fixture_ids.dart';
import 'package:pushit/data/fake/fixtures/fixture_posts.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/calendar/domain/calendar_rules.dart';

final DateTime _now = DateTime(2026, 11, 12, 15, 48);
final List<Post> _posts = fixturePosts(_now);

void main() {
  test('weekOf: Monday to Sunday around the day', () {
    final week = weekOf(DateTime(2026, 11, 12, 15));
    expect(week.first, DateTime(2026, 11, 9));
    expect(week.last, DateTime(2026, 11, 15));
    expect(weekOf(DateTime(2026, 11, 9)).first, DateTime(2026, 11, 9));
    expect(weekOf(DateTime(2026, 11, 15)).first, DateTime(2026, 11, 9));
  });

  test('entriesOn: the day posts in time order, without drafts', () {
    final entries = entriesOn(_posts, DateTime(2026, 11, 12));
    expect(entries.map((e) => e.post.id), [
      FixtureIds.morningBroll,
      FixtureIds.micTest,
      FixtureIds.studioTour,
      FixtureIds.behindTheDesk,
    ]);
    expect(entries.first.at, DateTime(2026, 11, 12, 9));
    expect(entriesOn(_posts, DateTime(2026, 11, 10)), isEmpty);
  });

  test('a post with several times appears at its earliest that day', () {
    final post = _posts.first.copyWith(
      targets: [
        PostTarget(
          platform: PlatformId.youtube,
          scheduledAt: DateTime(2026, 11, 13, 20),
          status: TargetStatus.scheduled,
        ),
        PostTarget(
          platform: PlatformId.tiktok,
          scheduledAt: DateTime(2026, 11, 13, 9),
          status: TargetStatus.scheduled,
        ),
      ],
    );
    expect(
      entriesOn([post], DateTime(2026, 11, 13)).single.at,
      DateTime(2026, 11, 13, 9),
    );
  });

  test('daysWithPosts: the days that have entries', () {
    expect(daysWithPosts(_posts), {
      DateTime(2026, 11, 9),
      DateTime(2026, 11, 11),
      DateTime(2026, 11, 12),
    });
  });

  group('summarizeEntry', () {
    Post post(String id) => _posts.firstWhere((p) => p.id == id);

    test('published, failed, scheduled and assisted', () {
      expect(
        summarizeEntry(post(FixtureIds.morningBroll)),
        const EntrySummary.published(platformCount: 3),
      );
      expect(
        summarizeEntry(post(FixtureIds.micTest)),
        const EntrySummary.failed(platforms: [PlatformId.tiktok]),
      );
      expect(
        summarizeEntry(post(FixtureIds.studioTour)),
        const EntrySummary.scheduled(platformCount: 3),
      );
      expect(
        summarizeEntry(post(FixtureIds.behindTheDesk)),
        const EntrySummary.assisted(platforms: [PlatformId.instagram]),
      );
    });
  });
}
