import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';

part 'drafts_state.dart';

/// D12 and D1's Drafts tab: the saved drafts.
class DraftsCubit extends Cubit<DraftsState> {
  new({required this._posts}) : super(const DraftsState());

  final PostsRepository _posts;
  StreamSubscription<List<Post>>? _subscription;

  void started() {
    emit(state.copyWith(status: ViewStatus.loading, failure: () => null));
    unawaited(_subscription?.cancel());
    _subscription = _posts.watchPosts().listen(
      (posts) {
        final drafts = posts.where((p) => p.isDraft).toList();
        emit(
          state.copyWith(
            status: drafts.isEmpty ? ViewStatus.empty : ViewStatus.ready,
            drafts: drafts,
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

  Future<void> discardTapped(String draftId) => _posts.discardDraft(draftId);

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
