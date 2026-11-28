import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/calendar/domain/calendar_rules.dart';

part 'calendar_state.dart';

/// E1–E4: posts by day and by week, with reschedule and cancel.
class CalendarCubit extends Cubit<CalendarState> {
  new({required this._posts, required Clock clock})
    : super(CalendarState(selectedDay: dateOnly(clock.now())));

  final PostsRepository _posts;
  StreamSubscription<List<Post>>? _subscription;

  void started() {
    emit(state.copyWith(status: ViewStatus.loading, failure: () => null));
    unawaited(_subscription?.cancel());
    _subscription = _posts.watchPosts().listen(
      (posts) => emit(
        state.copyWith(
          status: ViewStatus.ready,
          posts: posts.where((p) => !p.isDraft).toList(),
          failure: () => null,
        ),
      ),
      onError: (Object error) => emit(
        state.copyWith(
          status: ViewStatus.failure,
          failure: () => error is AppFailure ? error : UnknownFailure(error),
        ),
      ),
    );
  }

  /// Shows [day] in Day mode (E1, or E3 when empty).
  void daySelected(DateTime day) =>
      emit(state.copyWith(selectedDay: dateOnly(day), mode: CalendarMode.day));

  void modeChanged(CalendarMode mode) => emit(state.copyWith(mode: mode));

  Future<void> rescheduleTapped(String postId, ScheduleChoice choice) =>
      _run(() => _posts.reschedule(postId, choice));

  Future<void> cancelTapped(String postId) => _run(() => _posts.cancel(postId));

  void actionFailureShown() => emit(state.copyWith(actionFailure: () => null));

  Future<void> _run(Future<Object?> Function() action) async {
    try {
      await action();
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
