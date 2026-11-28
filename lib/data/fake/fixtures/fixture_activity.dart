import 'package:pushit/data/fake/fixtures/fixture_ids.dart';
import 'package:pushit/domain/domain.dart';

/// The activity list of B3, newest first, consistent with the posts.
List<ActivityItem> fixtureActivity(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  DateTime at(int dayOffset, int hour, int minute) =>
      today.add(Duration(days: dayOffset, hours: hour, minutes: minute));

  return [
    ActivityItem(
      id: 'activity-mic-test-failed',
      kind: ActivityKind.failed,
      occurredAt: at(0, 13, 31),
      postId: FixtureIds.micTest,
      postTitle: 'Mic test',
      platform: PlatformId.tiktok,
    ),
    ActivityItem(
      id: 'activity-morning-broll-published',
      kind: ActivityKind.published,
      occurredAt: at(0, 9, 2),
      postId: FixtureIds.morningBroll,
      postTitle: 'Morning b-roll',
      platformCount: 3,
    ),
    ActivityItem(
      id: 'activity-tiktok-reconnect',
      kind: ActivityKind.reconnectNeeded,
      occurredAt: at(-1, 18, 45),
      platform: PlatformId.tiktok,
    ),
    ActivityItem(
      id: 'activity-lighting-test-published',
      kind: ActivityKind.published,
      occurredAt: at(-1, 18, 32),
      postId: FixtureIds.lightingTest,
      postTitle: 'Lighting test',
      platformCount: 2,
    ),
    ActivityItem(
      id: 'activity-desk-cable-published',
      kind: ActivityKind.published,
      occurredAt: at(-3, 12, 2),
      postId: FixtureIds.deskCableFix,
      postTitle: 'Desk cable fix',
      platformCount: 1,
    ),
  ];
}
