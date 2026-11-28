import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/composer/domain/schedule_editor.dart';
import 'package:pushit/features/composer/presentation/cubit/schedule_sheet_cubit.dart';

final DateTime _now = DateTime(2026, 11, 12, 15, 48);
const Set<PlatformId> _platforms = {PlatformId.youtube, PlatformId.tiktok};

void main() {
  group('schedule editor rules', () {
    test('the default is an hour from now, on the next quarter', () {
      expect(defaultScheduleTime(_now), DateTime(2026, 11, 12, 17));
      expect(
        defaultScheduleTime(DateTime(2026, 11, 12, 15)),
        DateTime(2026, 11, 12, 16),
      );
    });

    test('seven days from today', () {
      final days = scheduleDays(_now);
      expect(days, hasLength(7));
      expect(days.first, DateTime(2026, 11, 12));
      expect(days.last, DateTime(2026, 11, 18));
    });

    test('withDay keeps the time; shiftQuarters moves by 15 minutes', () {
      final at = DateTime(2026, 11, 12, 19);
      expect(withDay(at, DateTime(2026, 11, 17)), DateTime(2026, 11, 17, 19));
      expect(shiftQuarters(at, -1), DateTime(2026, 11, 12, 18, 45));
      expect(shiftQuarters(at, 2), DateTime(2026, 11, 12, 19, 30));
    });
  });

  group('ScheduleSheetCubit', () {
    ScheduleSheetCubit build({ScheduleChoice? initial}) =>
        ScheduleSheetCubit(platforms: _platforms, now: _now, initial: initial);

    test('starts from the default time, one time for all', () {
      final state = build().state;
      expect(state.mode, ScheduleMode.oneTime);
      expect(state.oneTime, DateTime(2026, 11, 12, 17));
      expect(state.choice, SameTime(DateTime(2026, 11, 12, 17)));
      expect(state.problem, isNull);
    });

    test('starts from a per-platform choice', () {
      final choice = PerPlatform({
        PlatformId.youtube: DateTime(2026, 11, 12, 19),
        PlatformId.tiktok: DateTime(2026, 11, 12, 20, 30),
      });
      final state = build(initial: choice).state;
      expect(state.mode, ScheduleMode.perPlatform);
      expect(state.editing, PlatformId.youtube);
      expect(state.choice, choice);
    });

    blocTest<ScheduleSheetCubit, ScheduleSheetState>(
      'one time: day and time move together for every platform',
      build: build,
      act: (cubit) => cubit
        ..daySelected(DateTime(2026, 11, 17))
        ..timeShifted(8),
      verify: (cubit) =>
          expect(cubit.state.choice, SameTime(DateTime(2026, 11, 17, 19))),
    );

    blocTest<ScheduleSheetCubit, ScheduleSheetState>(
      'per platform: each platform keeps its own time',
      build: build,
      act: (cubit) => cubit
        ..modeChanged(ScheduleMode.perPlatform)
        ..platformTapped(PlatformId.tiktok)
        ..timeShifted(2),
      verify: (cubit) => expect(
        cubit.state.choice,
        PerPlatform({
          PlatformId.youtube: DateTime(2026, 11, 12, 17),
          PlatformId.tiktok: DateTime(2026, 11, 12, 17, 30),
        }),
      ),
    );

    blocTest<ScheduleSheetCubit, ScheduleSheetState>(
      'a time in the past is a problem',
      build: build,
      act: (cubit) => cubit.timeShifted(-6),
      verify: (cubit) => expect(cubit.state.problem, ScheduleProblem.inThePast),
    );
  });
}
