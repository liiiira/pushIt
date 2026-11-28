import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/composer/domain/schedule_editor.dart';

part 'schedule_sheet_state.dart';

/// D9 (one time) and D10 (per platform): picks when the post goes out.
class ScheduleSheetCubit extends Cubit<ScheduleSheetState> {
  new({
    required Set<PlatformId> platforms,
    required DateTime now,
    ScheduleChoice? initial,
  }) : super(ScheduleSheetState.from(platforms, now: now, initial: initial));

  void modeChanged(ScheduleMode mode) => emit(state.copyWith(mode: mode));

  void platformTapped(PlatformId platform) =>
      emit(state.copyWith(editing: platform));

  void daySelected(DateTime day) => _update((at) => withDay(at, day));

  void timeShifted(int quarters) =>
      _update((at) => shiftQuarters(at, quarters));

  void _update(DateTime Function(DateTime) change) {
    final editing = state.editing;
    if (state.mode == ScheduleMode.oneTime || editing == null) {
      emit(state.copyWith(oneTime: change(state.oneTime)));
      return;
    }
    emit(
      state.copyWith(
        times: {
          ...state.times,
          editing: change(state.times[editing] ?? state.oneTime),
        },
      ),
    );
  }
}
