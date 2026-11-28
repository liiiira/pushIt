import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/activity/domain/group_activity_by_day.dart';

part 'activity_state.dart';

/// B3: the last 30 days of activity, grouped by day. Failed platforms that
/// are still failed can be retried; their reason comes from the posts.
class ActivityCubit extends Cubit<ActivityState> {
  new({
    required this._activity,
    required this._posts,
    required this._clock,
    this._group = const GroupActivityByDay(),
  }) : super(const ActivityState());

  final ActivityRepository _activity;
  final PostsRepository _posts;
  final Clock _clock;
  final GroupActivityByDay _group;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  List<ActivityItem>? _items;
  List<Post>? _latestPosts;

  void started() => _listen();

  /// I3: loads everything again.
  void reloadTapped() => _listen();

  /// Posts a failed platform again; the posts stream then hides Retry.
  Future<void> retryTapped(ActivityItem item) async {
    final postId = item.postId;
    final platform = item.platform;
    if (postId == null || platform == null || state.isRetrying(item)) return;
    emit(state.copyWith(retryingIds: {...state.retryingIds, item.id}));
    AppFailure? failure;
    try {
      await _posts.retry(postId, platform);
    } on AppFailure catch (error) {
      failure = error;
    }
    if (isClosed) return;
    emit(
      state.copyWith(
        retryingIds: {...state.retryingIds}..remove(item.id),
        actionFailure: () => failure,
      ),
    );
    if (failure != null) emit(state.copyWith(actionFailure: () => null));
  }

  void _listen() {
    _cancel();
    _items = null;
    _latestPosts = null;
    emit(state.copyWith(status: ViewStatus.loading, failure: () => null));
    _subscriptions.addAll([
      _activity.watchActivity().listen((items) {
        _items = items;
        _publish();
      }, onError: _failed),
      _posts.watchPosts().listen((posts) {
        _latestPosts = posts;
        _publish();
      }, onError: _failed),
    ]);
  }

  void _publish() {
    final items = _items;
    final posts = _latestPosts;
    if (items == null || posts == null) return;
    emit(
      state.copyWith(
        status: items.isEmpty ? ViewStatus.empty : ViewStatus.ready,
        groups: _group(items, now: _clock.now()),
        failedTargets: {
          for (final post in posts)
            for (final target in post.targets)
              if (target.status == TargetStatus.failed)
                (post.id, target.platform): target.failureReason,
        },
      ),
    );
  }

  void _failed(Object error) {
    _cancel();
    emit(
      state.copyWith(
        status: ViewStatus.failure,
        failure: () => error is AppFailure ? error : UnknownFailure(error),
      ),
    );
  }

  void _cancel() {
    final active = [..._subscriptions];
    _subscriptions.clear();
    for (final subscription in active) {
      unawaited(subscription.cancel());
    }
  }

  @override
  Future<void> close() async {
    _cancel();
    await super.close();
  }
}
