import 'package:pushit/domain/entities/plan.dart';
import 'package:pushit/domain/entities/subscription.dart';
import 'package:pushit/domain/entities/usage.dart';
import 'package:pushit/domain/enums/billing_period.dart';
import 'package:pushit/domain/enums/plan_tier.dart';

/// The plan, its usage and purchases. Methods throw `AppFailure`.
abstract interface class SubscriptionRepository {
  Stream<Subscription> watchSubscription();

  Stream<Usage> watchUsage();

  Future<List<Plan>> plans();

  Future<void> purchase(PlanTier tier, BillingPeriod period);
}
