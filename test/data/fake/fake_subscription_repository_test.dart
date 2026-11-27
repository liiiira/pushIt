import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/data/fake/fake_accounts_repository.dart';
import 'package:pushit/data/fake/fake_subscription_repository.dart';
import 'package:pushit/data/fake/scenario.dart';
import 'package:pushit/domain/domain.dart';

import 'fake_support.dart';

void main() {
  for (final scenario in Scenario.values) {
    group(scenario.name, () {
      late FakeSubscriptionRepository repository; // fresh for each test

      setUp(
        () => repository = FakeSubscriptionRepository(fakeDatabase(scenario)),
      );

      test('serves the scenario plan and usage', () async {
        final subscription = await repository.watchSubscription().first;
        final usage = await repository.watchUsage().first;
        expect(usage.resetsOn, DateTime(2026, 12));

        switch (scenario) {
          case Scenario.firstUse:
            expect(subscription, const Subscription(plan: freePlan));
            expect((usage.postsThisMonth, usage.connectedAccounts), (0, 0));
          case Scenario.freeLimit:
            expect(subscription, const Subscription(plan: freePlan));
            expect((usage.postsThisMonth, usage.connectedAccounts), (10, 3));
          case Scenario.populated ||
              Scenario.offline ||
              Scenario.slow ||
              Scenario.error:
            expect(subscription.plan, proPlan);
            expect(subscription.period, BillingPeriod.yearly);
            expect(subscription.renewsOn!.isAfter(testNow), isTrue);
            expect((usage.postsThisMonth, usage.connectedAccounts), (6, 4));
        }
      });

      test('plans lists Free, Pro and Studio', () async {
        expect(await repository.plans(), allPlans);
      });

      test('purchase changes the plan', () async {
        await repository.purchase(PlanTier.studio, BillingPeriod.monthly);
        final subscription = await repository.watchSubscription().first;
        expect(subscription.plan, studioPlan);
        expect(subscription.period, BillingPeriod.monthly);
        expect(subscription.renewsOn, DateTime(2026, 12, 12));

        await repository.purchase(PlanTier.free, BillingPeriod.yearly);
        expect(
          await repository.watchSubscription().first,
          const Subscription(plan: freePlan),
        );
      });

      test('usage follows the connected accounts', () async {
        final database = fakeDatabase(scenario);
        final subscriptions = FakeSubscriptionRepository(database);
        final accounts = FakeAccountsRepository(database);
        final before = await subscriptions.watchUsage().first;
        if (scenario != Scenario.freeLimit) {
          await accounts.connect(PlatformId.threads, AccountMode.automatic);
          final after = await subscriptions.watchUsage().first;
          expect(after.connectedAccounts, before.connectedAccounts + 1);
        }
      });
    });
  }
}
