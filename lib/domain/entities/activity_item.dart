import 'package:equatable/equatable.dart';
import 'package:pushit/domain/enums/activity_kind.dart';
import 'package:pushit/domain/enums/platform_id.dart';

/// One entry of the activity list (B3).
final class ActivityItem extends Equatable {
  const new({
    required this.id,
    required this.kind,
    required this.occurredAt,
    this.postId,
    this.postTitle,
    this.platform,
    this.platformCount,
  });

  final String id;
  final ActivityKind kind;
  final DateTime occurredAt;
  final String? postId;

  /// The post's title (creator data), for display without loading the post.
  final String? postTitle;
  final PlatformId? platform;

  /// How many platforms the event covers, e.g. "published on 3 platforms".
  final int? platformCount;

  ActivityItem copyWith({
    String? id,
    ActivityKind? kind,
    DateTime? occurredAt,
    String? Function()? postId,
    String? Function()? postTitle,
    PlatformId? Function()? platform,
    int? Function()? platformCount,
  }) => ActivityItem(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    occurredAt: occurredAt ?? this.occurredAt,
    postId: postId != null ? postId() : this.postId,
    postTitle: postTitle != null ? postTitle() : this.postTitle,
    platform: platform != null ? platform() : this.platform,
    platformCount: platformCount != null ? platformCount() : this.platformCount,
  );

  @override
  List<Object?> get props => [
    id,
    kind,
    occurredAt,
    postId,
    postTitle,
    platform,
    platformCount,
  ];
}
