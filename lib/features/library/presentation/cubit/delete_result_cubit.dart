import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';

part 'delete_result_state.dart';

/// F7: runs "delete everywhere" and follows each platform.
class DeleteResultCubit extends Cubit<DeleteResultState> {
  new({required this._postId, required this._posts})
    : super(const DeleteResultState());

  final String _postId;
  final PostsRepository _posts;
  StreamSubscription<List<DeletionStep>>? _subscription;

  void started() {
    emit(state.copyWith(status: ViewStatus.loading, failure: () => null));
    _follow();
  }

  /// Starts the deletion again: failed platforms are retried, and the
  /// ones waiting for the creator keep waiting.
  void retryTapped() => _follow();

  void _follow() {
    unawaited(_subscription?.cancel());
    _subscription = _posts
        .deleteEverywhere(_postId)
        .listen(
          (steps) => emit(
            state.copyWith(
              status: ViewStatus.ready,
              steps: steps,
              failure: () => null,
            ),
          ),
          onError: (Object error) => emit(
            state.copyWith(
              status: ViewStatus.failure,
              failure: () =>
                  error is AppFailure ? error : UnknownFailure(error),
            ),
          ),
        );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
