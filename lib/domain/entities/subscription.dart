import 'package:equatable/equatable.dart';
import 'package:pushit/domain/entities/plan.dart';
import 'package:pushit/domain/enums/billing_period.dart';

final class Subscription extends Equatable {
  const new({required this.plan, this.period, this.renewsOn});

  final Plan plan;

  /// `null` on the Free plan.
  final BillingPeriod? period;

  /// `null` on the Free plan.
  final DateTime? renewsOn;

  Subscription copyWith({
    Plan? plan,
    BillingPeriod? Function()? period,
    DateTime? Function()? renewsOn,
  }) => Subscription(
    plan: plan ?? this.plan,
    period: period != null ? period() : this.period,
    renewsOn: renewsOn != null ? renewsOn() : this.renewsOn,
  );

  @override
  List<Object?> get props => [plan, period, renewsOn];
}
