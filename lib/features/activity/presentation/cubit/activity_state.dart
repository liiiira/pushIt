part of 'activity_cubit.dart';

final class ActivityState extends Equatable {
  const new({
    this.status = ViewStatus.initial,
    this.groups = const [],
    this.failedTargets = const {},
    this.retryingIds = const {},
    this.failure,
    this.actionFailure,
  });

  final ViewStatus status;
  final List<ActivityGroup> groups;

  /// Platforms still failed, by post id and platform, with their reason.
  final Map<(String, PlatformId), TargetFailureReason?> failedTargets;

  /// Activity items whose retry is running.
  final Set<String> retryingIds;

  /// Why loading failed (I3).
  final AppFailure? failure;

  /// Why the last retry failed; set for one emission.
  final AppFailure? actionFailure;

  /// Whether [item] is a failure that can still be retried.
  bool canRetry(ActivityItem item) =>
      item.kind == ActivityKind.failed &&
      failedTargets.containsKey(_keyOf(item));

  bool isRetrying(ActivityItem item) => retryingIds.contains(item.id);

  /// Why [item]'s platform failed, while it still is.
  TargetFailureReason? failureReasonOf(ActivityItem item) =>
      failedTargets[_keyOf(item)];

  (String, PlatformId)? _keyOf(ActivityItem item) {
    final postId = item.postId;
    final platform = item.platform;
    return postId == null || platform == null ? null : (postId, platform);
  }

  ActivityState copyWith({
    ViewStatus? status,
    List<ActivityGroup>? groups,
    Map<(String, PlatformId), TargetFailureReason?>? failedTargets,
    Set<String>? retryingIds,
    AppFailure? Function()? failure,
    AppFailure? Function()? actionFailure,
  }) => ActivityState(
    status: status ?? this.status,
    groups: groups == null ? this.groups : List.unmodifiable(groups),
    failedTargets: failedTargets == null
        ? this.failedTargets
        : Map.unmodifiable(failedTargets),
    retryingIds: retryingIds == null
        ? this.retryingIds
        : Set.unmodifiable(retryingIds),
    failure: failure != null ? failure() : this.failure,
    actionFailure: actionFailure != null ? actionFailure() : this.actionFailure,
  );

  @override
  List<Object?> get props => [
    status,
    groups,
    failedTargets,
    retryingIds,
    failure,
    actionFailure,
  ];
}
