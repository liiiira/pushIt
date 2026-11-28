import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';

part 'post_detail_state.dart';

/// F3–F4: one post, its platforms, statistics and retry.
class PostDetailCubit extends Cubit<PostDetailState> {
  new({
    required this._postId,
    required this._posts,
    required this._accounts,
    required this._subscription,
  }) : super(const PostDetailState());

  final String _postId;
  final PostsRepository _posts;
  final AccountsRepository _accounts;
  final SubscriptionRepository _subscription;
  final List<StreamSubscription<Object?>> _subscriptions = [];

  void started() {
    emit(state.copyWith(status: ViewStatus.loading, failure: () => null));
    unawaited(_cancelSubscriptions());
    _subscriptions
      ..add(
        _subscription.watchSubscription().listen(
          (subscription) => emit(
            state.copyWith(showsStatistics: subscription.plan.hasStatistics),
          ),
          onError: (Object _) {},
        ),
      )
      ..add(
        _posts
            .watchPost(_postId)
            .listen(
              (post) => emit(
                state.copyWith(
                  status: ViewStatus.ready,
                  post: () => post,
                  failure: () => null,
                ),
              ),
              onError: (Object error) => emit(
                state.copyWith(
                  status: ViewStatus.failure,
                  failure: () => _asFailure(error),
                ),
              ),
            ),
      );
  }

  Future<void> retryTapped(PlatformId platform) =>
      _run(platform, () => _posts.retry(_postId, platform));

  /// Reconnects the platform's account, then retries (F4).
  Future<void> reconnectAndRetryTapped(PlatformId platform) =>
      _run(platform, () async {
        final accountId = state.post?.targetFor(platform)?.accountId;
        if (accountId != null) await _accounts.reconnect(accountId);
        await _posts.retry(_postId, platform);
      });

  /// The view showed [PostDetailState.actionFailure].
  void actionFailureShown() => emit(state.copyWith(actionFailure: () => null));

  Future<void> _run(PlatformId platform, Future<void> Function() action) async {
    emit(state.copyWith(busyPlatform: () => platform));
    try {
      await action();
      emit(state.copyWith(busyPlatform: () => null));
    } on Object catch (error) {
      emit(
        state.copyWith(
          busyPlatform: () => null,
          actionFailure: () => _asFailure(error),
        ),
      );
    }
  }

  AppFailure _asFailure(Object error) =>
      error is AppFailure ? error : UnknownFailure(error);

  Future<void> _cancelSubscriptions() async {
    final active = [..._subscriptions];
    _subscriptions.clear();
    for (final subscription in active) {
      await subscription.cancel();
    }
  }

  @override
  Future<void> close() async {
    await _cancelSubscriptions();
    await super.close();
  }
}
