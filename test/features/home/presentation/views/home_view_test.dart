import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/app/app_repositories.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/core/design_system/widgets/error_state_view.dart';
import 'package:pushit/core/design_system/widgets/skeleton_list.dart';
import 'package:pushit/data/dependencies.dart';
import 'package:pushit/data/fake/fake_database.dart';
import 'package:pushit/data/fake/scenario.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/home/presentation/pages/home_page.dart';

import '../../../../helpers/helpers.dart';

/// Pumps Home on [dependencies], signed in as the fixture user.
Future<void> _pump(
  WidgetTester tester,
  Dependencies dependencies, {
  TestLayout? layout,
  MockGoRouter? router,
}) async {
  unawaited(dependencies.auth.signInWithGoogle());
  await tester.pumpApp(
    const HomePage(),
    layout: layout,
    router: router,
    repositories: repositoryProvidersOf(dependencies),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testAcrossLayouts('B1: next post, reconnect alert and last 7 days', (
    tester,
    layout,
  ) async {
    await _pump(tester, testDependencies(), layout: layout);

    for (final text in [
      'pushIt',
      'LB',
      'Next post · today',
      '19:00',
      'in 3 h 12 min',
      'Studio tour, part 2',
      '1:42 · 3 platforms',
      'TikTok needs reconnecting',
      'Fix',
      'Last 7 days · 4 accounts',
      '12,480',
      '1,932',
      '214',
      'Views',
      'Likes',
      'Comments',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.byTooltip('Activity'), findsOneWidget);
  });

  testAcrossLayouts('B2: three steps to the first post', (
    tester,
    layout,
  ) async {
    await _pump(
      tester,
      testDependencies(scenario: Scenario.firstUse),
      layout: layout,
    );

    for (final text in [
      'Next post',
      '--:--',
      'Nothing scheduled yet',
      'Three steps to your first post',
      'Create your account',
      'Schedule a video',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.text('Connect an account'), findsNWidgets(2));
    expect(find.text('Last 7 days · 0 accounts'), findsNothing);
    expect(
      tester.getSemantics(find.text('Create your account')),
      isSemantics(
        label: 'Create your account',
        isChecked: true,
        hasCheckedState: true,
      ),
    );
  });

  testWidgets('B2 offers to schedule once an account is connected', (
    tester,
  ) async {
    final dependencies = testDependencies(scenario: Scenario.firstUse);
    unawaited(
      dependencies.accounts.connect(PlatformId.youtube, AccountMode.automatic),
    );
    await _pump(tester, dependencies);

    expect(find.text('Schedule a video'), findsNWidgets(2));
    expect(find.text('Connect an account'), findsOneWidget);
  });

  testWidgets('B1 with nothing to come', (tester) async {
    final dependencies = testDependencies();
    final posts = _MockPosts();
    final published = (await tester.runAsync(
      () => dependencies.posts.watchPosts().first,
    ))!.where((post) => post.status == PostStatus.published).toList();
    when(posts.watchPosts).thenAnswer((_) => Stream.value(published));
    unawaited(dependencies.auth.signInWithGoogle());
    await tester.pumpApp(
      const HomePage(),
      repositories: [
        ...repositoryProvidersOf(dependencies),
        RepositoryProvider<PostsRepository>.value(value: posts),
      ],
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('--:--'), findsOneWidget);
    expect(find.text('Nothing scheduled yet'), findsOneWidget);
    expect(find.text('Three steps to your first post'), findsNothing);
    expect(find.text('Views'), findsOneWidget);
  });

  testAcrossLayouts('I2: skeletons while loading', (tester, layout) async {
    final dependencies = Dependencies.fake(
      scenario: Scenario.slow,
      clock: FixedClock(testNow),
    );
    await tester.pumpApp(
      const HomePage(),
      layout: layout,
      repositories: repositoryProvidersOf(dependencies),
    );
    await tester.pump();

    expect(find.byType(SkeletonList), findsOneWidget);

    await tester.pump(FakeDatabase.defaultLatencyFor(Scenario.slow));
    await tester.pump();
    expect(find.byType(SkeletonList), findsNothing);
  });

  testAcrossLayouts('I3: the error state, and retry', (tester, layout) async {
    await _pump(
      tester,
      testDependencies(scenario: Scenario.error),
      layout: layout,
    );

    expect(find.byType(ErrorStateView), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump();
    expect(find.byType(ErrorStateView), findsOneWidget);
  });

  testWidgets('Fix asks, then reconnects the account', (tester) async {
    await _pump(tester, testDependencies());

    await tester.tap(find.text('Fix'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'TikTok signed this account out. One scheduled post will fail '
        'unless you reconnect before today, 19:00.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Reconnect'));
    await tester.pumpAndSettle();

    expect(find.text('TikTok needs reconnecting'), findsNothing);
  });

  testWidgets('opens activity, settings and the next post', (tester) async {
    final router = MockGoRouter();
    when(() => router.push<Object?>(any())).thenAnswer((_) async => null);
    final dependencies = testDependencies();
    await _pump(tester, dependencies, router: router);
    final next = (await tester.runAsync(
      () => dependencies.posts.watchPosts().first,
    ))!.firstWhere((post) => post.title == 'Studio tour, part 2');

    await tester.tap(find.byTooltip('Activity'));
    verify(() => router.push<Object?>(RoutePaths.activity)).called(1);

    await tester.tap(find.bySemanticsLabel('Settings'));
    verify(() => router.push<Object?>(RoutePaths.settings)).called(1);

    await tester.tap(find.text('Studio tour, part 2'));
    verify(() => router.push<Object?>(RoutePaths.libraryPostFor(next.id)))
        .called(1);
  });

  testWidgets('B2 opens add account', (tester) async {
    final router = MockGoRouter();
    when(() => router.push<Object?>(any())).thenAnswer((_) async => null);
    await _pump(
      tester,
      testDependencies(scenario: Scenario.firstUse),
      router: router,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Connect an account'));

    verify(() => router.push<Object?>(RoutePaths.addAccount)).called(1);
  });
}

class _MockPosts extends Mock implements PostsRepository;
