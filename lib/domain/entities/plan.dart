import 'package:equatable/equatable.dart';
import 'package:pushit/domain/enums/plan_tier.dart';

/// A subscription plan. The real values live in `rules/plans.dart`.
final class Plan extends Equatable {
  const new({
    required this.tier,
    required this.monthlyPriceUsd,
    required this.yearlyPriceUsd,
    required this.accountLimit,
    required this.hasStatistics,
    required this.hasX,
    required this.hasCaptionVariants,
    this.monthlyPostLimit,
  });

  final PlanTier tier;
  final int monthlyPriceUsd;
  final int yearlyPriceUsd;
  final int accountLimit;

  /// Videos a month; `null` means unlimited.
  final int? monthlyPostLimit;
  final bool hasStatistics;
  final bool hasX;
  final bool hasCaptionVariants;

  bool get hasUnlimitedPosts => monthlyPostLimit == null;

  Plan copyWith({
    PlanTier? tier,
    int? monthlyPriceUsd,
    int? yearlyPriceUsd,
    int? accountLimit,
    int? Function()? monthlyPostLimit,
    bool? hasStatistics,
    bool? hasX,
    bool? hasCaptionVariants,
  }) => Plan(
    tier: tier ?? this.tier,
    monthlyPriceUsd: monthlyPriceUsd ?? this.monthlyPriceUsd,
    yearlyPriceUsd: yearlyPriceUsd ?? this.yearlyPriceUsd,
    accountLimit: accountLimit ?? this.accountLimit,
    monthlyPostLimit: monthlyPostLimit != null
        ? monthlyPostLimit()
        : this.monthlyPostLimit,
    hasStatistics: hasStatistics ?? this.hasStatistics,
    hasX: hasX ?? this.hasX,
    hasCaptionVariants: hasCaptionVariants ?? this.hasCaptionVariants,
  );

  @override
  List<Object?> get props => [
    tier,
    monthlyPriceUsd,
    yearlyPriceUsd,
    accountLimit,
    monthlyPostLimit,
    hasStatistics,
    hasX,
    hasCaptionVariants,
  ];
}
