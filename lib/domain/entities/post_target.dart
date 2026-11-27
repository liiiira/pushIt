import 'package:equatable/equatable.dart';
import 'package:pushit/domain/entities/post_stats.dart';
import 'package:pushit/domain/enums/platform_id.dart';
import 'package:pushit/domain/enums/target_failure_reason.dart';
import 'package:pushit/domain/enums/target_status.dart';

/// One post on one platform.
final class PostTarget extends Equatable {
  const new({
    required this.platform,
    required this.status,
    this.accountId,
    this.scheduledAt,
    this.url,
    this.stats,
    this.failureReason,
  });

  final PlatformId platform;

  /// `null` only on a draft whose platform has no connected account yet.
  final String? accountId;

  /// `null` only on a draft that has no schedule yet.
  final DateTime? scheduledAt;
  final TargetStatus status;
  final Uri? url;
  final PostStats? stats;
  final TargetFailureReason? failureReason;

  PostTarget copyWith({
    PlatformId? platform,
    String? Function()? accountId,
    DateTime? Function()? scheduledAt,
    TargetStatus? status,
    Uri? Function()? url,
    PostStats? Function()? stats,
    TargetFailureReason? Function()? failureReason,
  }) => PostTarget(
    platform: platform ?? this.platform,
    accountId: accountId != null ? accountId() : this.accountId,
    scheduledAt: scheduledAt != null ? scheduledAt() : this.scheduledAt,
    status: status ?? this.status,
    url: url != null ? url() : this.url,
    stats: stats != null ? stats() : this.stats,
    failureReason: failureReason != null ? failureReason() : this.failureReason,
  );

  @override
  List<Object?> get props => [
    platform,
    accountId,
    scheduledAt,
    status,
    url,
    stats,
    failureReason,
  ];
}
