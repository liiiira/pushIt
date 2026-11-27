import 'dart:async';

import 'package:pushit/data/fake/fake_database.dart';
import 'package:pushit/domain/domain.dart';

final class FakeSubscriptionRepository implements SubscriptionRepository {
  const new(this._database);

  final FakeDatabase _database;

  @override
  Stream<Subscription> watchSubscription() =>
      _database.watch(_database.subscription);

  /// This month's videos and the connected accounts. Emits after the
  /// latency, then whenever either changes.
  @override
  Stream<Usage> watchUsage() => Stream.multi((controller) {
    void emit([Object? _]) => controller.add(_currentUsage());
    final changes = [
      _database.postsThisMonth.watch().skip(1).listen(emit),
      _database.accounts.watch().skip(1).listen(emit),
    ];
    controller.onCancel = () => Future.wait(changes.map((s) => s.cancel()));
    unawaited(_database.delay().then(emit));
  });

  Usage _currentUsage() {
    final now = _database.now();
    return Usage(
      postsThisMonth: _database.postsThisMonth.value,
      connectedAccounts: _database.accounts.value.length,
      resetsOn: DateTime(now.year, now.month + 1),
    );
  }

  @override
  Future<List<Plan>> plans() => _database.act(() => allPlans);

  @override
  Future<void> purchase(PlanTier tier, BillingPeriod period) =>
      _database.act(() {
        final now = _database.now();
        _database.subscription.value = tier == PlanTier.free
            ? const Subscription(plan: freePlan)
            : Subscription(
                plan: planFor(tier),
                period: period,
                renewsOn: switch (period) {
                  BillingPeriod.monthly => DateTime(
                    now.year,
                    now.month + 1,
                    now.day,
                  ),
                  BillingPeriod.yearly => DateTime(
                    now.year + 1,
                    now.month,
                    now.day,
                  ),
                },
              );
      });
}
