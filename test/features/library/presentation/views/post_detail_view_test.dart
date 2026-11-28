import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/core/design_system/widgets/skeleton_list.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/data/fake/fixtures/fixture_ids.dart';
import 'package:pushit/data/fake/fixtures/fixture_posts.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/presentation/cubit/post_detail_cubit.dart';
import 'package:pushit/features/library/presentation/views/post_detail_view.dart';

import '../../../../helpers/helpers.dart';

class _MockPostDetailCubit extends MockCubit<PostDetailState>
    implements PostDetailCubit;

Post _fixture(String id) => fixturePosts(testNow).firstWhere((p) => p.id == id);

void main() {
  late _MockPostDetailCubit cubit; // fresh for each test

  setUpAll(() => registerFallbackValue(PlatformId.youtube));

  setUp(() {
    cubit = _MockPostDetailCubit();
    when(() => cubit.retryTapped(any())).thenAnswer((_) async {});
    when(() => cubit.reconnectAndRetryTapped(any())).thenAnswer((_) async {});
  });

  Future<void> pump(
    WidgetTester tester,
    TestLayout layout,
    PostDetailState state, {
    MockGoRouter? router,
  }) async {
    when(() => cubit.state).thenReturn(state);
    await tester.pumpApp(
      BlocProvider<PostDetailCubit>.value(
        value: cubit,
        child: const PostDetailView(),
      ),
      layout: layout,
      router: router,
      repositories: [
        RepositoryProvider<Clock>.value(value: FixedClock(testNow)),
      ],
    );
  }

  testAcrossLayouts('F3: a published post with its statistics', (
    tester,
    layout,
  ) async {
    await pump(
      tester,
      layout,
      PostDetailState(
        status: ViewStatus.ready,
        post: _fixture(FixtureIds.morningBroll),
        showsStatistics: true,
      ),
    );

    expect(find.text('Post'), findsOneWidget);
    expect(find.text('Morning b-roll'), findsOneWidget);
    expect(find.text('Published Thu 12 Nov, 09:00'), findsOneWidget);
    expect(find.text('First light in the studio, no talking.'), findsOneWidget);
    expect(find.text('8,204'), findsOneWidget);
    expect(find.text('1,310'), findsOneWidget);
    expect(find.text('96'), findsOneWidget);
    expect(find.text('Published · 5,120 views · 702 likes'), findsOneWidget);
    expect(find.text('Statistics refreshed 2 h ago.'), findsOneWidget);
    expect(find.text('Edit everywhere'), findsOneWidget);
    expect(find.text('Delete everywhere'), findsOneWidget);
    expect(find.text('Failed on TikTok'), findsNothing);
  });

  testAcrossLayouts('F3: without statistics on the plan', (
    tester,
    layout,
  ) async {
    await pump(
      tester,
      layout,
      PostDetailState(
        status: ViewStatus.ready,
        post: _fixture(FixtureIds.morningBroll),
      ),
    );
    expect(find.text('8,204'), findsNothing);
    expect(find.text('Published · 09:00'), findsNWidgets(3));
  });

  testAcrossLayouts('F4: a failed platform offers reconnect and retry', (
    tester,
    layout,
  ) async {
    await pump(
      tester,
      layout,
      PostDetailState(
        status: ViewStatus.ready,
        post: _fixture(FixtureIds.micTest),
        showsStatistics: true,
      ),
    );

    expect(find.text('Mic test'), findsOneWidget);
    expect(find.text('Failed on TikTok'), findsOneWidget);
    expect(
      find.text(
        'TikTok signed this account out. Reconnect it, then retry. '
        'The video will not be posted twice.',
      ),
      findsOneWidget,
    );
    expect(find.text('Processing'), findsOneWidget);
    expect(find.text('Failed · session expired'), findsOneWidget);
    expect(find.byTooltip('Retry on TikTok'), findsOneWidget);
    expect(find.byTooltip('Open on YouTube'), findsOneWidget);
    expect(find.text('Reconnect and retry'), findsOneWidget);
  });

  testAcrossLayouts('loading', (tester, layout) async {
    await pump(
      tester,
      layout,
      const PostDetailState(status: ViewStatus.loading),
    );
    expect(find.byType(SkeletonList), findsOneWidget);
  });

  testAcrossLayouts('a deleted post says so', (tester, layout) async {
    await pump(
      tester,
      layout,
      const PostDetailState(
        status: ViewStatus.failure,
        failure: NotFoundFailure(),
      ),
    );
    expect(find.text('This post no longer exists.'), findsOneWidget);
  });

  group('interactions', () {
    final layout = testLayouts.first;

    testWidgets('retry and reconnect-and-retry call the cubit', (tester) async {
      await pump(
        tester,
        layout,
        PostDetailState(
          status: ViewStatus.ready,
          post: _fixture(FixtureIds.micTest),
        ),
      );
      await tester.ensureVisible(find.byTooltip('Retry on TikTok'));
      await tester.tap(find.byTooltip('Retry on TikTok'));
      verify(() => cubit.retryTapped(PlatformId.tiktok)).called(1);

      await tester.ensureVisible(find.text('Reconnect and retry'));
      await tester.tap(find.text('Reconnect and retry'));
      verify(() => cubit.reconnectAndRetryTapped(PlatformId.tiktok)).called(1);
    });

    testWidgets('edit and delete open their screens', (tester) async {
      final router = MockGoRouter();
      when(() => router.push<Object?>(any())).thenAnswer((_) async => null);
      await pump(
        tester,
        layout,
        PostDetailState(
          status: ViewStatus.ready,
          post: _fixture(FixtureIds.morningBroll),
        ),
        router: router,
      );
      await tester.tap(find.text('Edit everywhere'));
      verify(
        () => router.push<Object?>(
          RoutePaths.libraryPostEditFor(FixtureIds.morningBroll),
        ),
      ).called(1);
      await tester.tap(find.text('Delete everywhere'));
      verify(
        () => router.push<Object?>(
          RoutePaths.libraryPostDeleteFor(FixtureIds.morningBroll),
        ),
      ).called(1);
    });

    testWidgets('a failed action shows a message once', (tester) async {
      whenListen(
        cubit,
        Stream.value(
          PostDetailState(
            status: ViewStatus.ready,
            post: _fixture(FixtureIds.micTest),
            actionFailure: const NetworkFailure(),
          ),
        ),
        initialState: PostDetailState(
          status: ViewStatus.ready,
          post: _fixture(FixtureIds.micTest),
        ),
      );
      await tester.pumpApp(
        BlocProvider<PostDetailCubit>.value(
          value: cubit,
          child: const PostDetailView(),
        ),
        repositories: [
          RepositoryProvider<Clock>.value(value: FixedClock(testNow)),
        ],
      );
      await tester.pump();
      expect(find.text('That did not work. Try again.'), findsOneWidget);
      verify(() => cubit.actionFailureShown()).called(1);
    });
  });
}
