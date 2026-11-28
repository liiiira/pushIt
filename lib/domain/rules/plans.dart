import 'package:pushit/domain/entities/plan.dart';
import 'package:pushit/domain/enums/plan_tier.dart';

const Plan freePlan = Plan(
  tier: PlanTier.free,
  monthlyPriceUsd: 0,
  yearlyPriceUsd: 0,
  accountLimit: 3,
  monthlyPostLimit: 10,
  hasStatistics: false,
  hasX: false,
  hasCaptionVariants: false,
);

const Plan proPlan = Plan(
  tier: PlanTier.pro,
  monthlyPriceUsd: 6,
  yearlyPriceUsd: 48,
  accountLimit: 10,
  hasStatistics: true,
  hasX: true,
  hasCaptionVariants: true,
);

/// Studio adds several brands on top of Pro.
const Plan studioPlan = Plan(
  tier: PlanTier.studio,
  monthlyPriceUsd: 15,
  yearlyPriceUsd: 120,
  accountLimit: 30,
  hasStatistics: true,
  hasX: true,
  hasCaptionVariants: true,
);

const List<Plan> allPlans = [freePlan, proPlan, studioPlan];

Plan planFor(PlanTier tier) => switch (tier) {
  PlanTier.free => freePlan,
  PlanTier.pro => proPlan,
  PlanTier.studio => studioPlan,
};

bool isAccountLimitReached(Plan plan, {required int connectedAccounts}) =>
    connectedAccounts >= plan.accountLimit;

bool isPostLimitReached(Plan plan, {required int postsThisMonth}) {
  final limit = plan.monthlyPostLimit;
  return limit != null && postsThisMonth >= limit;
}
