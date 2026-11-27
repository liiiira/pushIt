import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/data/fake/fixtures/fixture_ids.dart';
import 'package:pushit/data/fake/fixtures/fixture_posts.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/domain/library_filter.dart';
import 'package:pushit/features/library/presentation/cubit/library_cubit.dart';
import 'package:pushit/features/library/presentation/views/library_view.dart';

import '../../../../helpers/helpers.dart';

class _MockLibraryCubit extends MockCubit<LibraryState> implements LibraryCubit;

final DateTime _now = DateTime(2026, 11, 12, 15, 48);
final List<Post> _library = fixturePosts(_now).where((p) => !p.isDraft).toList()
  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

void main() {
  late _MockLibraryCubit cubit; // fresh for each test

  setUp(() => cubit = _MockLibraryCubit());

  Future<void> pump(
    WidgetTester tester,
    TestLayout layout,
    LibraryState state, {
    MockGoRouter? router,
  }) async {
    when(() => cubit.state).thenReturn(state);
    await tester.pumpApp(
      BlocProvider<LibraryCubit>.value(
        value: cubit,
        child: const LibraryView(),
      ),
      layout: layout,
      router: router,
      repositories: [RepositoryProvider<Clock>.value(value: FixedClock(_now))],
    );
  }

  testAcrossLayouts('F1: lists every post with its status line', (
    tester,
    layout,
  ) async {
    await pump(
      tester,
      layout,
      LibraryState(status: ViewStatus.ready, posts: _library),
    );

    expect(find.text('Library'), findsWidgets);
    for (final label in ['All', 'Scheduled', 'Published', 'Failed']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Studio tour, part 2'), findsOneWidget);
    expect(find.text('Scheduled · today 19:00'), findsOneWidget);
    expect(find.text('Mic test'), findsOneWidget);
    expect(find.text('Failed on TikTok · today 13:30'), findsOneWidget);
    expect(find.text('Morning b-roll'), findsOneWidget);
    expect(find.text('Published · 8,204 views'), findsOneWidget);
  });

  testAcrossLayouts('F1: a filter with no match says so', (
    tester,
    layout,
  ) async {
    await pump(
      tester,
      layout,
      LibraryState(
        status: ViewStatus.ready,
        posts: _library.where((p) => p.id == FixtureIds.studioTour).toList(),
        filter: LibraryFilter.failed,
      ),
    );
    expect(find.text('Nothing here yet.'), findsOneWidget);
  });

  testAcrossLayouts('F2: empty library invites a first post', (
    tester,
    layout,
  ) async {
    await pump(tester, layout, const LibraryState(status: ViewStatus.empty));
    expect(find.text('No videos yet'), findsOneWidget);
    expect(find.text('New post'), findsOneWidget);
  });

  testAcrossLayouts('I2: loading shows skeleton rows', (tester, layout) async {
    await pump(tester, layout, const LibraryState(status: ViewStatus.loading));
    expect(find.byKey(const ValueKey('library-skeleton')), findsOneWidget);
  });

  testAcrossLayouts('I3: a failure offers a retry', (tester, layout) async {
    await pump(
      tester,
      layout,
      const LibraryState(status: ViewStatus.failure, failure: NetworkFailure()),
    );
    expect(find.text('Something went wrong'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    verify(() => cubit.retryTapped()).called(1);
  });

  group('interactions', () {
    final layout = testLayouts.first;

    testWidgets('tapping a filter tells the cubit', (tester) async {
      await pump(
        tester,
        layout,
        LibraryState(status: ViewStatus.ready, posts: _library),
      );
      await tester.tap(find.text('Failed'));
      verify(() => cubit.filterChanged(LibraryFilter.failed)).called(1);
    });

    testWidgets('tapping a post opens it', (tester) async {
      final router = MockGoRouter();
      when(() => router.push<Object?>(any())).thenAnswer((_) async => null);
      await pump(
        tester,
        layout,
        LibraryState(status: ViewStatus.ready, posts: _library),
        router: router,
      );
      await tester.tap(find.text('Mic test'));
      verify(
        () =>
            router.push<Object?>(RoutePaths.libraryPostFor(FixtureIds.micTest)),
      ).called(1);
    });

    testWidgets('New post opens the composer', (tester) async {
      final router = MockGoRouter();
      when(() => router.push<Object?>(any())).thenAnswer((_) async => null);
      await pump(
        tester,
        layout,
        const LibraryState(status: ViewStatus.empty),
        router: router,
      );
      await tester.tap(find.text('New post'));
      verify(() => router.push<Object?>(RoutePaths.compose)).called(1);
    });
  });
}
