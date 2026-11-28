import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/app/app_repositories.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/core/design_system/widgets/empty_state_view.dart';
import 'package:pushit/core/design_system/widgets/error_state_view.dart';
import 'package:pushit/core/design_system/widgets/skeleton_list.dart';
import 'package:pushit/data/dependencies.dart';
import 'package:pushit/data/fake/fake_database.dart';
import 'package:pushit/data/fake/scenario.dart';
import 'package:pushit/features/activity/presentation/pages/activity_page.dart';

import '../../../../helpers/helpers.dart';

Future<void> _pump(
  WidgetTester tester,
  Dependencies dependencies, {
  TestLayout? layout,
}) async {
  await tester.pumpApp(
    const ActivityPage(),
    layout: layout,
    repositories: repositoryProvidersOf(dependencies),
  );
  await tester.pump();
}

void main() {
  testAcrossLayouts('B3: grouped by day, with Retry on a failure', (
    tester,
    layout,
  ) async {
    await _pump(tester, testDependencies(), layout: layout);

    expect(find.text('Activity'), findsOneWidget);
    for (final text in [
      'Today',
      'Mic test failed on TikTok',
      'Session expired · 13:31',
      'Morning b-roll published',
      '3 platforms · 09:02',
      'Yesterday',
      'TikTok needs reconnecting',
      'Before your next post · 18:45',
      'Lighting test published',
      '2 platforms · 18:32',
      'Earlier',
      'Desk cable fix published',
      '1 platform · Mon 9 Nov, 12:02',
      'Activity is kept for 30 days.',
    ]) {
      await tester.scrollUntilVisible(find.text(text), 100);
      expect(find.text(text), findsOneWidget, reason: text);
    }
  });

  testWidgets('Retry posts again and goes away', (tester) async {
    await _pump(tester, testDependencies());

    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Retry'), findsNothing);
    expect(find.text('Mic test failed on TikTok'), findsOneWidget);
  });

  testAcrossLayouts('B3 empty: nothing happened yet', (tester, layout) async {
    await _pump(
      tester,
      testDependencies(scenario: Scenario.firstUse),
      layout: layout,
    );

    expect(find.byType(EmptyStateView), findsOneWidget);
    expect(find.text('No activity yet'), findsOneWidget);
  });

  testAcrossLayouts('I2: skeletons while loading', (tester, layout) async {
    await _pump(
      tester,
      Dependencies.fake(scenario: Scenario.slow, clock: FixedClock(testNow)),
      layout: layout,
    );

    expect(find.byType(SkeletonList), findsOneWidget);
    await tester.pump(FakeDatabase.defaultLatencyFor(Scenario.slow));
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
}
