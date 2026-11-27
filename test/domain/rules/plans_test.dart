import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/domain/domain.dart';

void main() {
  group('plans', () {
    test(r'Free: $0, 3 accounts, 10 videos a month, no extras', () {
      expect(
        planFor(PlanTier.free),
        const Plan(
          tier: PlanTier.free,
          monthlyPriceUsd: 0,
          yearlyPriceUsd: 0,
          accountLimit: 3,
          monthlyPostLimit: 10,
          hasStatistics: false,
          hasX: false,
          hasCaptionVariants: false,
        ),
      );
    });

    test(r'Pro: $6 / $48, 10 accounts, unlimited, every extra', () {
      expect(
        planFor(PlanTier.pro),
        const Plan(
          tier: PlanTier.pro,
          monthlyPriceUsd: 6,
          yearlyPriceUsd: 48,
          accountLimit: 10,
          hasStatistics: true,
          hasX: true,
          hasCaptionVariants: true,
        ),
      );
    });

    test(r'Studio: $15 / $120, 30 accounts, unlimited, every extra', () {
      expect(
        planFor(PlanTier.studio),
        const Plan(
          tier: PlanTier.studio,
          monthlyPriceUsd: 15,
          yearlyPriceUsd: 120,
          accountLimit: 30,
          hasStatistics: true,
          hasX: true,
          hasCaptionVariants: true,
        ),
      );
    });

    test('allPlans lists the tiers in order', () {
      expect(allPlans.map((p) => p.tier), PlanTier.values);
    });

    test('a null post limit means unlimited', () {
      expect(planFor(PlanTier.free).hasUnlimitedPosts, isFalse);
      expect(planFor(PlanTier.pro).hasUnlimitedPosts, isTrue);
    });
  });

  group('limits', () {
    final free = planFor(PlanTier.free);
    final pro = planFor(PlanTier.pro);

    test('account limit is reached at the limit', () {
      expect(isAccountLimitReached(free, connectedAccounts: 2), isFalse);
      expect(isAccountLimitReached(free, connectedAccounts: 3), isTrue);
      expect(isAccountLimitReached(pro, connectedAccounts: 4), isFalse);
    });

    test('post limit is reached at the limit, never when unlimited', () {
      expect(isPostLimitReached(free, postsThisMonth: 9), isFalse);
      expect(isPostLimitReached(free, postsThisMonth: 10), isTrue);
      expect(isPostLimitReached(pro, postsThisMonth: 1000), isFalse);
    });
  });
}
