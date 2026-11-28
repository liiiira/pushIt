import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';

part 'assisted_state.dart';

/// G2 (post on an assisted platform) and G3 (delete there).
class AssistedCubit extends Cubit<AssistedState> {
  new({
    required this._postId,
    required this._platform,
    required this._mode,
    required this._posts,
  }) : super(const AssistedState());

  /// How long "Remind me" waits.
  static const Duration snooze = Duration(minutes: 30);

  final String _postId;
  final PlatformId? _platform;
  final AssistedMode _mode;
  final PostsRepository _posts;
  StreamSubscription<Post>? _subscription;

  AssistedMode get mode => _mode;

  void started() {
    if (_platform == null) {
      emit(
        state.copyWith(
          status: ViewStatus.failure,
          failure: () => const NotFoundFailure(),
        ),
      );
      return;
    }
    emit(state.copyWith(status: ViewStatus.loading));
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

  /// The view copied the caption (G2) and opened the platform: those
  /// steps are done.
  void openTapped() => emit(
    state.copyWith(
      ticked: {
        ...state.ticked,
        ...switch (_mode) {
          AssistedMode.post => const {0, 1},
          AssistedMode.delete => const {0},
        },
      },
    ),
  );

  /// The creator ticks or unticks a step by hand.
  void stepToggled(int step) {
    final ticked = {...state.ticked};
    if (!ticked.remove(step)) ticked.add(step);
    emit(state.copyWith(ticked: ticked));
  }

  /// "I posted it" / "I deleted it".
  Future<void> confirmTapped() => _run(
    () => _posts.confirmAssisted(_postId, _platform!),
    AssistedOutcome.done,
  );

  /// "Remind me in 30 min" (G2).
  Future<void> remindTapped() => _run(
    () => _posts.snoozeAssisted(_postId, _platform!, snooze),
    AssistedOutcome.snoozed,
  );

  void actionFailureShown() => emit(state.copyWith(actionFailure: () => null));

  Future<void> _run(
    Future<void> Function() action,
    AssistedOutcome outcome,
  ) async {
    try {
      await action();
      emit(state.copyWith(outcome: outcome));
    } on Object catch (error) {
      emit(
        state.copyWith(
          actionFailure: () =>
              error is AppFailure ? error : UnknownFailure(error),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
