import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/data/fake/fixtures/fixture_ids.dart';
import 'package:pushit/data/fake/fixtures/fixture_posts.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/presentation/cubit/delete_confirm_cubit.dart';
import 'package:pushit/features/library/presentation/cubit/delete_result_cubit.dart';
import 'package:pushit/features/library/presentation/views/delete_confirm_view.dart';
import 'package:pushit/features/library/presentation/views/delete_result_view.dart';

import '../../../../helpers/helpers.dart';

class _MockConfirmCubit extends MockCubit<DeleteConfirmState>
    implements DeleteConfirmCubit;

class _MockResultCubit extends MockCubit<DeleteResultState>
    implements DeleteResultCubit;

final Post _broll = fixturePosts(testNow)
    .firstWhere((p) => p.id == FixtureIds.morningBroll);

const _mixed = [
  DeletionStep(
    platform: PlatformId.youtube,
    method: DeleteMethod.automatic,
    outcome: DeletionOutcome.removed,
  ),
  DeletionStep(
    platform: PlatformId.tiktok,
    method: DeleteMethod.assisted,
    outcome: DeletionOutcome.awaitingUser,
  ),
  DeletionStep(
    platform: PlatformId.facebook,
    method: DeleteMethod.automatic,
    outcome: DeletionOutcome.failed,
  ),
];

void main() {
  group('F6 delete confirmation', () {
    late _MockConfirmCubit cubit; // fresh for each test

    setUp(() => cubit = _MockConfirmCubit());

    Future<void> pump(
      WidgetTester tester, {
      TestLayout? layout,
      MockGoRouter? router,
    }) async {
      when(
        () => cubit.state,
      ).thenReturn(DeleteConfirmState(status: ViewStatus.ready, post: _broll));
      await tester.pumpApp(
        BlocProvider<DeleteConfirmCubit>.value(
          value: cubit,
          child: const DeleteConfirmView(),
        ),
        layout: layout,
        router: router,
      );
    }

    testAcrossLayouts('lists how each platform is deleted', (
      tester,
      layout,
    ) async {
      await pump(tester, layout: layout);
      expect(find.text('Delete everywhere'), findsOneWidget);
      expect(
        find.text(
          'This removes "Morning b-roll" from pushIt and from every '
          'platform below. It cannot be undone.',
        ),
        findsOneWidget,
      );
      expect(find.text('Deleted automatically'), findsOneWidget);
      expect(
        find.text('You delete it in TikTok. We open the video for you.'),
        findsOneWidget,
      );
      expect(find.text('Delete from 3 platforms'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('confirming replaces it with the result screen', (
      tester,
    ) async {
      final router = MockGoRouter();
      when(() => router.pushReplacement<Object?>(any()))
          .thenAnswer((_) async => null);
      await pump(tester, router: router);
      await tester.tap(find.text('Delete from 3 platforms'));
      verify(
        () => router.pushReplacement<Object?>(
          RoutePaths.libraryPostDeleteResultFor(FixtureIds.morningBroll),
        ),
      ).called(1);
    });
  });

  group('F7 delete result', () {
    late _MockResultCubit cubit; // fresh for each test

    setUp(() => cubit = _MockResultCubit());

    Future<void> pump(
      WidgetTester tester,
      DeleteResultState state, {
      TestLayout? layout,
      MockGoRouter? router,
    }) async {
      when(() => cubit.state).thenReturn(state);
      await tester.pumpApp(
        BlocProvider<DeleteResultCubit>.value(
          value: cubit,
          child: const DeleteResultView(postId: FixtureIds.morningBroll),
        ),
        layout: layout,
        router: router,
      );
    }

    testAcrossLayouts('shows each platform and what is left to do', (
      tester,
      layout,
    ) async {
      await pump(
        tester,
        const DeleteResultState(status: ViewStatus.ready, steps: _mixed),
        layout: layout,
      );
      expect(find.text('Deleting'), findsOneWidget);
      expect(
        find.text('1 of 3 removed. 2 need your attention.'),
        findsOneWidget,
      );
      expect(find.text('Removed'), findsOneWidget);
      expect(find.text('Waiting for you'), findsOneWidget);
      expect(find.text('Open TikTok'), findsOneWidget);
      expect(find.text('Failed'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });

    testAcrossLayouts('while running', (tester, layout) async {
      await pump(
        tester,
        DeleteResultState(
          status: ViewStatus.ready,
          steps: [_mixed.first.copyWith(outcome: DeletionOutcome.pending)],
        ),
        layout: layout,
      );
      expect(find.text('Deleting from 1 platform…'), findsOneWidget);
    });

    testAcrossLayouts('once complete', (tester, layout) async {
      await pump(
        tester,
        DeleteResultState(status: ViewStatus.ready, steps: [_mixed.first]),
        layout: layout,
      );
      expect(find.text('Removed from every platform.'), findsOneWidget);
    });

    testWidgets('actions: open the app, retry, done', (tester) async {
      final router = MockGoRouter();
      when(() => router.push<Object?>(any())).thenAnswer((_) async => null);
      when(() => router.go(any())).thenReturn(null);
      await pump(
        tester,
        const DeleteResultState(status: ViewStatus.ready, steps: _mixed),
        router: router,
      );

      await tester.tap(find.text('Open TikTok'));
      verify(
        () => router.push<Object?>(
          RoutePaths.assistedDeleteFor(FixtureIds.morningBroll, 'tiktok'),
        ),
      ).called(1);

      await tester.tap(find.text('Retry'));
      verify(() => cubit.retryTapped()).called(1);

      await tester.tap(find.text('Done'));
      verify(() => router.go(RoutePaths.library)).called(1);
    });
  });
}
