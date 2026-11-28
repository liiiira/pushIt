import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/domain/edit_plan.dart';

part 'edit_everywhere_state.dart';

/// F5: edit the title and caption on every platform that allows it.
class EditEverywhereCubit extends Cubit<EditEverywhereState> {
  new({required this._postId, required this._posts})
    : super(const EditEverywhereState());

  final String _postId;
  final PostsRepository _posts;

  StreamSubscription<Post>? _subscription;

  /// Loads the post once; later changes must not overwrite the edits.
  void started() {
    emit(state.copyWith(status: ViewStatus.loading, failure: () => null));
    unawaited(_subscription?.cancel());
    _subscription = _posts
        .watchPost(_postId)
        .listen(
          (post) {
            unawaited(_subscription?.cancel());
            emit(
              state.copyWith(
                status: ViewStatus.ready,
                post: () => post,
                title: post.title,
                caption: post.caption,
              ),
            );
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

  void titleChanged(String title) => emit(state.copyWith(title: title));

  void captionChanged(String caption) => emit(state.copyWith(caption: caption));

  Future<void> applyTapped() async {
    final post = state.post;
    if (post == null || !state.canApply) return;
    emit(state.copyWith(isSubmitting: true, actionFailure: () => null));
    try {
      final results = await _posts.editEverywhere(
        _postId,
        title: state.title != post.title ? state.title.trim() : null,
        caption: state.caption != post.caption ? state.caption.trim() : null,
      );
      emit(state.copyWith(isSubmitting: false, results: () => results));
    } on Object catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          actionFailure: () =>
              error is AppFailure ? error : UnknownFailure(error),
        ),
      );
    }
  }

  /// The view showed [EditEverywhereState.actionFailure].
  void actionFailureShown() => emit(state.copyWith(actionFailure: () => null));

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
