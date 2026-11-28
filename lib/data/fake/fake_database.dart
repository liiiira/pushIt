import 'dart:async';

import 'package:pushit/core/clock.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/data/fake/fake_store.dart';
import 'package:pushit/data/fake/fixtures/fixture_accounts.dart';
import 'package:pushit/data/fake/fixtures/fixture_activity.dart';
import 'package:pushit/data/fake/fixtures/fixture_posts.dart';
import 'package:pushit/data/fake/fixtures/fixture_user.dart';
import 'package:pushit/data/fake/scenario.dart';
import 'package:pushit/domain/domain.dart';

/// The in-memory state every fake repository shares, seeded for one
/// [Scenario], plus the scenario's simulated latency and failures.
final class FakeDatabase {
  new({
    required this.scenario,
    required this.clock,
    Duration? latency,
    this.uploadTick = const Duration(milliseconds: 120),
  }) : latency = latency ?? defaultLatencyFor(scenario) {
    final now = clock.now();
    final hasData = scenario != Scenario.firstUse;
    final allAccounts = hasData ? fixtureAccounts(now) : <ConnectedAccount>[];

    accounts = FakeStore(
      List.unmodifiable(
        scenario == Scenario.freeLimit
            ? allAccounts.where((a) => a.platform != PlatformId.tiktok)
            : allAccounts,
      ),
    );
    posts = FakeStore(
      List<Post>.unmodifiable(
        hasData
            ? (fixturePosts(now)
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt)))
            : const <Post>[],
      ),
    );
    activity = FakeStore(
      List.unmodifiable(hasData ? fixtureActivity(now) : const []),
    );
    subscription = FakeStore(switch (scenario) {
      Scenario.firstUse ||
      Scenario.freeLimit => const Subscription(plan: freePlan),
      _ => Subscription(
        plan: proPlan,
        period: BillingPeriod.yearly,
        renewsOn: DateTime(now.year + 1, 2, 3),
      ),
    });
    postsThisMonth = FakeStore(switch (scenario) {
      Scenario.firstUse => 0,
      Scenario.freeLimit => freePlan.monthlyPostLimit!,
      _ => fixturePostsThisMonth,
    });
    notificationPreferences = FakeStore(fixtureNotificationPreferences);
    online = FakeStore(scenario != Scenario.offline);
    referral = scenario == Scenario.firstUse
        ? fixtureReferral.copyWith(joinedCount: 0, monthsEarned: 0)
        : fixtureReferral;
  }

  /// Two seconds in [Scenario.slow], none otherwise.
  static Duration defaultLatencyFor(Scenario scenario) =>
      scenario == Scenario.slow ? const Duration(seconds: 2) : Duration.zero;

  final Scenario scenario;
  final Clock clock;
  final Duration latency;

  /// The time between two simulated upload chunks.
  final Duration uploadTick;

  // Seeded in the constructor body from one `clock.now()`.
  late final FakeStore<List<ConnectedAccount>> accounts;
  late final FakeStore<List<Post>> posts;
  late final FakeStore<List<ActivityItem>> activity;
  late final FakeStore<Subscription> subscription;
  late final FakeStore<int> postsThisMonth;
  late final FakeStore<NotificationPreferences> notificationPreferences;
  late final FakeStore<bool> online;
  late final Referral referral;

  int _nextId = 1;

  DateTime now() => clock.now();

  /// A new unique id, e.g. `post-1`.
  String newId(String prefix) => '$prefix-${_nextId++}';

  bool get isOffline => !online.value;

  /// Waits for the scenario's latency.
  Future<void> delay() =>
      latency == Duration.zero ? Future.value() : Future.delayed(latency);

  /// A list load: waits, then fails in [Scenario.error].
  Future<T> load<T>(T Function() read) async {
    await delay();
    if (scenario == Scenario.error) throw const NetworkFailure();
    return read();
  }

  /// An action: waits, then runs [run].
  Future<T> act<T>(FutureOr<T> Function() run) => delay().then((_) => run());

  /// Watches [store] as a list load: the first value comes after the
  /// latency, and [Scenario.error] emits a `NetworkFailure` instead.
  Stream<T> watchLoad<T>(FakeStore<T> store) => Stream.multi((controller) {
    StreamSubscription<T>? subscription;
    var isCancelled = false;
    controller.onCancel = () {
      isCancelled = true;
      return subscription?.cancel();
    };
    unawaited(
      delay().then((_) {
        if (isCancelled) return;
        if (scenario == Scenario.error) {
          controller.addError(const NetworkFailure());
          unawaited(controller.close());
          return;
        }
        subscription = store.watch().listen(
          controller.add,
          onError: controller.addError,
        );
      }),
    );
  });

  /// Watches [store] without failing: only the latency applies.
  Stream<T> watch<T>(FakeStore<T> store) => Stream.multi((controller) {
    StreamSubscription<T>? subscription;
    var isCancelled = false;
    controller.onCancel = () {
      isCancelled = true;
      return subscription?.cancel();
    };
    unawaited(
      delay().then((_) {
        if (isCancelled) return;
        subscription = store.watch().listen(controller.add);
      }),
    );
  });

  /// Adds [item] to the activity list, newest first.
  void log(ActivityItem item) {
    activity.value = List.unmodifiable([item, ...activity.value]);
  }
}
