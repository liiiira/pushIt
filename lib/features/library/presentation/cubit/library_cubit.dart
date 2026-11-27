import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/domain/library_filter.dart';

part 'library_state.dart';

/// F1–F2: every post (drafts aside), filtered by tab.
class LibraryCubit extends Cubit<LibraryState> {
  new({required this._posts}) : super(const LibraryState());

  final PostsRepository _posts;
  StreamSubscription<List<Post>>? _subscription;

  void started() {
    emit(state.copyWith(status: ViewStatus.loading, failure: () => null));
    unawaited(_subscription?.cancel());
    _subscription = _posts.watchPosts().listen(
      (posts) {
        final library = posts.where((p) => !p.isDraft).toList();
        emit(
          state.copyWith(
            status: library.isEmpty ? ViewStatus.empty : ViewStatus.ready,
            posts: library,
            failure: () => null,
          ),
        );
      },
      onError: (Object error) => emit(
        state.copyWith(
          status: ViewStatus.failure,
          failure: () => error is AppFailure ? error : UnknownFailure(error),
        ),
      ),
    );
  }

  void retryTapped() => started();

  void filterChanged(LibraryFilter filter) =>
      emit(state.copyWith(filter: filter));

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
