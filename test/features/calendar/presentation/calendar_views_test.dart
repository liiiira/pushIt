import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/data/fake/fixtures/fixture_ids.dart';
import 'package:pushit/data/fake/fixtures/fixture_posts.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:pushit/features/calendar/presentation/views/calendar_view.dart';
import 'package:pushit/features/calendar/presentation/widgets/post_actions_sheet.dart';

import '../../../helpers/helpers.dart';

class _MockCalendar extends MockCubit<CalendarState> implements CalendarCubit;

final List<Post> _posts = fixturePosts(testNow)
    .where((p) => !p.isDraft)
    .toList();

final CalendarState _today = CalendarState(
  status: ViewStatus.ready,
  posts: _posts,
  selectedDay: DateTime(2026, 11, 12),
);

void main() {
  late _MockCalendar cubit; // fresh for each test

  setUp(() {
    cubit = _MockCalendar();
    when(() => cubit.cancelTapped(any())).thenAnswer((_) async {});
  });

  Future<void> pump(
    WidgetTester tester,
    Widget child,
    CalendarState state, {
    TestLayout? layout,
    MockGoRouter? router,
  }) {
    when(() => cubit.state).thenReturn(state);
    return tester.pumpApp(
      BlocProvider<CalendarCubit>.value(value: cubit, child: child),
      layout: layout,
      router: router,
      repositories: [
        RepositoryProvider<Clock>.value(value: FixedClock(testNow)),
      ],
    );
  }

  testAcrossLayouts('E1: the day, its posts and their status', (
    tester,
    layout,
  ) async {
    await pump(tester, const CalendarView(), _today, layout: layout);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('November'), findsOneWidget);
    expect(find.text('Thursday 12 · 4 posts'), findsOneWidget);
    expect(find.text('09:00'), findsOneWidget);
    expect(find.text('Published · 3 platforms'), findsOneWidget);
    expect(find.text('Failed on TikTok'), findsOneWidget);
    expect(find.text('Scheduled · 3 platforms'), findsOneWidget);
    expect(find.text('Assisted · Instagram'), findsOneWidget);
  });

  testAcrossLayouts('E2: the week, day by day', (tester, layout) async {
    await pump(
      tester,
      const CalendarView(),
      _today.copyWith(mode: CalendarMode.week),
      layout: layout,
    );
    expect(find.text('9 to 15 Nov'), findsOneWidget);
    expect(find.text('Desk cable fix'), findsOneWidget);
    expect(find.text('Mic test · failed'), findsOneWidget);
    expect(find.text('Nothing scheduled'), findsWidgets);
  });

  testAcrossLayouts('E3: an empty day', (tester, layout) async {
    await pump(
      tester,
      const CalendarView(),
      _today.copyWith(selectedDay: DateTime(2026, 11, 10)),
      layout: layout,
    );
    expect(find.text('Nothing on Tuesday 10'), findsOneWidget);
    expect(find.text('New post'), findsOneWidget);
  });

  testAcrossLayouts('E4: reschedule, edit or cancel', (tester, layout) async {
    final studio = _posts.firstWhere((p) => p.id == FixtureIds.studioTour);
    await pump(
      tester,
      Scaffold(body: PostActionsSheet(post: studio)),
      _today,
      layout: layout,
    );
    expect(find.text('Scheduled · today 19:00 · 3 platforms'), findsOneWidget);
    expect(find.text('Reschedule'), findsOneWidget);
    expect(find.text('Edit post'), findsOneWidget);
    expect(find.text('Cancel post'), findsOneWidget);
    expect(
      find.text('You can change or cancel a post until publishing starts.'),
      findsOneWidget,
    );
  });

  group('interactions', () {
    testWidgets('tapping a scheduled post opens E4', (tester) async {
      await pump(tester, const CalendarView(), _today);
      await tester.tap(find.text('Studio tour, part 2'));
      await tester.pumpAndSettle();
      expect(find.text('Reschedule'), findsOneWidget);
    });

    testWidgets('tapping a published post opens it', (tester) async {
      final router = MockGoRouter();
      when(() => router.push<Object?>(any())).thenAnswer((_) async => null);
      await pump(tester, const CalendarView(), _today, router: router);
      await tester.tap(find.text('Morning b-roll'));
      verify(
        () => router.push<Object?>(
          RoutePaths.libraryPostFor(FixtureIds.morningBroll),
        ),
      ).called(1);
    });

    testWidgets('tapping a day and the tabs', (tester) async {
      await pump(tester, const CalendarView(), _today);
      await tester.tap(find.text('10'));
      verify(() => cubit.daySelected(DateTime(2026, 11, 10))).called(1);
      await tester.tap(find.text('Week'));
      verify(() => cubit.modeChanged(CalendarMode.week)).called(1);
    });

    testWidgets('cancelling asks first', (tester) async {
      final studio = _posts.firstWhere((p) => p.id == FixtureIds.studioTour);
      await pump(
        tester,
        Scaffold(body: PostActionsSheet(post: studio)),
        _today,
      );
      await tester.tap(find.text('Cancel post'));
      await tester.pumpAndSettle();
      expect(find.text('Cancel this post?'), findsOneWidget);
      await tester.tap(find.text('Cancel the post'));
      await tester.pumpAndSettle();
      verify(() => cubit.cancelTapped(FixtureIds.studioTour)).called(1);
    });
  });
}
