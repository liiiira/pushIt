import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/data/fake/fixtures/fixture_posts.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/calendar/presentation/cubit/calendar_cubit.dart';

class _MockPosts extends Mock implements PostsRepository;

final DateTime _now = DateTime(2026, 11, 12, 15, 48);
final List<Post> _all = fixturePosts(_now);

void main() {
  late _MockPosts posts; // fresh for each test

  setUp(() {
    posts = _MockPosts();
    when(() => posts.watchPosts()).thenAnswer((_) => Stream.value(_all));
  });

  CalendarCubit build() => CalendarCubit(posts: posts, clock: FixedClock(_now));

  test('starts on today, in Day mode', () {
    final state = build().state;
    expect(state.selectedDay, DateTime(2026, 11, 12));
    expect(state.mode, CalendarMode.day);
  });

  blocTest<CalendarCubit, CalendarState>(
    'started loads every post but drafts',
    build: build,
    act: (cubit) => cubit.started(),
    skip: 1,
    verify: (cubit) {
      expect(cubit.state.status, ViewStatus.ready);
      expect(cubit.state.posts.any((p) => p.isDraft), isFalse);
      expect(cubit.state.dayEntries, hasLength(4));
    },
  );

  blocTest<CalendarCubit, CalendarState>(
    'a load failure is a failure',
    setUp: () =>
        when(() => posts.watchPosts())
            .thenAnswer((_) => Stream.error(const NetworkFailure())),
    build: build,
    act: (cubit) => cubit.started(),
    verify: (cubit) => expect(cubit.state.status, ViewStatus.failure),
  );

  blocTest<CalendarCubit, CalendarState>(
    'picking a day shows it in Day mode',
    build: build,
    seed: () => CalendarState(
      selectedDay: DateTime(2026, 11, 12),
      mode: CalendarMode.week,
    ),
    act: (cubit) => cubit.daySelected(DateTime(2026, 11, 10, 8)),
    expect: () => [CalendarState(selectedDay: DateTime(2026, 11, 10))],
  );

  blocTest<CalendarCubit, CalendarState>(
    'reschedule and cancel go to the posts repository',
    setUp: () {
      when(() => posts.reschedule('p1', SameTime(DateTime(2026, 11, 13, 9))))
          .thenAnswer((_) async => _all.first);
      when(() => posts.cancel('p1')).thenAnswer((_) async {});
    },
    build: build,
    act: (cubit) async {
      await cubit.rescheduleTapped('p1', SameTime(DateTime(2026, 11, 13, 9)));
      await cubit.cancelTapped('p1');
    },
    verify: (_) {
      verify(() => posts.reschedule('p1', SameTime(DateTime(2026, 11, 13, 9))))
          .called(1);
      verify(() => posts.cancel('p1')).called(1);
    },
  );

  blocTest<CalendarCubit, CalendarState>(
    'a refused action is reported once',
    setUp: () =>
        when(() => posts.cancel('p1')).thenThrow(const ValidationFailure()),
    build: build,
    act: (cubit) async {
      await cubit.cancelTapped('p1');
      expect(cubit.state.actionFailure, const ValidationFailure());
      cubit.actionFailureShown();
    },
    verify: (cubit) => expect(cubit.state.actionFailure, isNull),
  );

  test('unawaited close does not throw', () async {
    final cubit = build()..started();
    unawaited(cubit.close());
  });
}
