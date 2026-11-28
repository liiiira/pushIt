import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/data/fake/scenario.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/accounts/accounts.dart';
import 'package:pushit/features/home/domain/build_dashboard.dart';

import '../../../helpers/helpers.dart';

const _video = VideoAsset(
  id: 'v',
  fileName: 'v.mp4',
  duration: Duration(seconds: 42),
  sizeBytes: 1,
  width: 1080,
  height: 1920,
);

Post _post(String id, List<PostTarget> targets, {bool isDraft = false}) => Post(
  id: id,
  video: _video,
  caption: id,
  isDraft: isDraft,
  createdAt: testNow,
  updatedAt: testNow,
  targets: targets,
);

PostTarget _published(DateTime at, int views) => PostTarget(
  platform: PlatformId.youtube,
  accountId: 'yt',
  scheduledAt: at,
  status: TargetStatus.published,
  stats: PostStats(views: views, likes: 1, comments: 1, refreshedAt: at),
);

PostTarget _scheduled(DateTime at, {String accountId = 'yt'}) => PostTarget(
  platform: PlatformId.youtube,
  accountId: accountId,
  scheduledAt: at,
  status: TargetStatus.scheduled,
);

ConnectedAccount _account(String id, AccountHealth health) => ConnectedAccount(
  id: id,
  platform: PlatformId.tiktok,
  handle: '@me',
  label: 'Me',
  accountType: 'creator',
  mode: AccountMode.assisted,
  health: health,
);

void main() {
  const build = BuildDashboard();

  test('matches B1 on the populated fixtures', () async {
    final dependencies = testDependencies();
    final posts = await dependencies.posts.watchPosts().first;
    final accounts = await dependencies.accounts.watchAccounts().first;

    final dashboard = build(
      posts: posts,
      accounts: accounts,
      plan: proPlan,
      now: testNow,
    );

    final next = dashboard.next!;
    expect(next.post.title, 'Studio tour, part 2');
    expect(next.at, DateTime(2026, 11, 12, 19));
    expect(next.day, RelativeDay.today);
    expect(next.countdown, const Countdown(hours: 3, minutes: 12));
    expect(dashboard.reconnects.map((alert) => alert.account.platform), [
      PlatformId.tiktok,
    ]);
    expect(
      dashboard.reconnects.single.risk,
      ReconnectRisk(postCount: 1, firstPostAt: DateTime(2026, 11, 12, 19)),
    );
    final week = dashboard.lastSevenDays!;
    expect((week.views, week.likes, week.comments), (12480, 1932, 214));
    expect(dashboard.accountCount, 4);
    expect(dashboard.firstUse, isNull);
  });

  test('is a first use until a post exists, drafts aside', () async {
    final dependencies = testDependencies(scenario: Scenario.firstUse);
    final posts = await dependencies.posts.watchPosts().first;

    expect(
      build(posts: posts, accounts: const [], plan: freePlan, now: testNow),
      const Dashboard(accountCount: 0, firstUse: FirstUse(hasAccount: false)),
    );
    expect(
      build(
        posts: [
          _post('draft', [_scheduled(testNow)], isDraft: true),
        ],
        accounts: [_account('a', AccountHealth.connected)],
        plan: freePlan,
        now: testNow,
      ).firstUse,
      const FirstUse(hasAccount: true),
    );
  });

  test('the next post is the earliest one still to come', () {
    final dashboard = build(
      posts: [
        _post('past', [_scheduled(testNow.subtract(const Duration(hours: 1)))]),
        _post('later', [_scheduled(testNow.add(const Duration(days: 2)))]),
        _post('sooner', [
          _scheduled(testNow.add(const Duration(days: 1, minutes: 30))),
        ]),
      ],
      accounts: const [],
      plan: proPlan,
      now: testNow,
    );

    expect(dashboard.next?.post.id, 'sooner');
    expect(dashboard.next?.day, RelativeDay.tomorrow);
    expect(dashboard.next?.countdown, const Countdown(days: 1, minutes: 30));
  });

  test('has no next post when nothing is to come', () {
    final dashboard = build(
      posts: [
        _post('done', [_published(testNow, 10)]),
      ],
      accounts: const [],
      plan: proPlan,
      now: testNow,
    );

    expect(dashboard.next, isNull);
    expect(dashboard.firstUse, isNull);
  });

  test('rounds the countdown up, so it never reads 0 min', () {
    expect(
      Countdown.until(const Duration(seconds: 1)),
      const Countdown(minutes: 1),
    );
    expect(
      Countdown.until(const Duration(hours: 1, seconds: 59)),
      const Countdown(hours: 1, minutes: 1),
    );
    expect(Countdown.until(Duration.zero), const Countdown(minutes: 1));
  });

  test('counts only what was published in the last 7 days', () {
    final dashboard = build(
      posts: [
        _post('week', [
          _published(testNow.subtract(const Duration(days: 6, hours: 23)), 5),
          _published(testNow, 7),
        ]),
        _post('older', [
          _published(testNow.subtract(const Duration(days: 8)), 1000),
        ]),
      ],
      accounts: const [],
      plan: proPlan,
      now: testNow,
    );

    expect(dashboard.lastSevenDays?.views, 12);
  });

  test('shows no statistics on a plan without them', () {
    final dashboard = build(
      posts: [
        _post('week', [_published(testNow, 5)]),
      ],
      accounts: const [],
      plan: freePlan,
      now: testNow,
    );

    expect(dashboard.lastSevenDays, isNull);
  });

  test('shows zeros when nothing was published this week', () {
    final dashboard = build(
      posts: const [],
      accounts: [_account('a', AccountHealth.connected)],
      plan: proPlan,
      now: testNow,
    );

    expect(
      dashboard.lastSevenDays,
      PostStats(views: 0, likes: 0, comments: 0, refreshedAt: testNow),
    );
  });

  test('asks to reconnect only signed-out accounts', () {
    final dashboard = build(
      posts: const [],
      accounts: [
        _account('ok', AccountHealth.connected),
        _account('soon', AccountHealth.expiringSoon),
        _account('out', AccountHealth.expired),
      ],
      plan: proPlan,
      now: testNow,
    );

    expect(dashboard.reconnects.map((alert) => alert.account.id), ['out']);
  });
}
