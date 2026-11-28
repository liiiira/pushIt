import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';

part 'delete_confirm_state.dart';

/// F6: the post to delete, loaded once.
class DeleteConfirmCubit extends Cubit<DeleteConfirmState> {
  new({required this._postId, required this._posts})
    : super(const DeleteConfirmState());

  final String _postId;
  final PostsRepository _posts;
  StreamSubscription<Post>? _subscription;

  void started() {
    emit(state.copyWith(status: ViewStatus.loading, failure: () => null));
    unawaited(_subscription?.cancel());
    _subscription = _posts
        .watchPost(_postId)
        .listen(
          (post) {
            unawaited(_subscription?.cancel());
            emit(state.copyWith(status: ViewStatus.ready, post: () => post));
          },
          onError: (Object error) {
            unawaited(_subscription?.cancel());
            emit(
              state.copyWith(
                status: ViewStatus.failure,
                failure: () =>
                    error is AppFailure ? error : UnknownFailure(error),
              ),
            );
          },
        );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
