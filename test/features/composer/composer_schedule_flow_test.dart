import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/app.dart';
import 'package:pushit/app/router/app_redirect.dart';
import 'package:pushit/app/router/app_router.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/data/fake/scenario.dart';

import '../../helpers/helpers.dart';

const _signedIn = AppAccess(isOnboarded: true, isSignedIn: true);

/// Opens the composer, uploads the first gallery video and goes to D8.
Future<void> _toCheck(
  WidgetTester tester, {
  Scenario scenario = Scenario.populated,
}) async {
  final router = buildAppRouter(access: ValueNotifier(_signedIn));
  addTearDown(router.dispose);
  await tester.pumpWidget(
    PushItApp(
      dependencies: testDependencies(scenario: scenario),
      preferences: InMemoryAppPreferences(),
      router: router,
    ),
  );
  await tester.pumpAndSettle();
  router.go(RoutePaths.compose);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Use this video'));
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Schedule'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('D8 → D9 → D13: schedule on the ready platforms', (tester) async {
    await _toCheck(tester);

    // Studio tour (1:42) defaults to YouTube, Instagram and TikTok; TikTok's
    // session expired and has no privacy yet.
    expect(find.text('Check'), findsOneWidget);
    expect(find.text('Ready'), findsNWidgets(2));
    expect(find.text('Sign in again to post'), findsOneWidget);
    expect(find.text('2 problems to fix before scheduling.'), findsOneWidget);

    await tester.tap(find.text('Continue with 2 platforms'));
    await tester.pumpAndSettle();
    expect(find.text('When'), findsOneWidget);
    expect(find.text('17:00'), findsOneWidget);

    await tester.tap(find.text('Set time'));
    await tester.pumpAndSettle();
    expect(find.text('Scheduled'), findsOneWidget);
    expect(
      find.text(
        'Thu 12 Nov at 17:00 on YouTube. Instagram is assisted, so we '
        'will remind you at 17:00.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('View in calendar'));
    await tester.pumpAndSettle();
    expect(find.text('Scheduled'), findsNothing);
  });

  testWidgets('the D8 fixes: reconnect, then choose privacy', (tester) async {
    await _toCheck(tester);
    await tester.tap(find.text('Reconnect'));
    await tester.pumpAndSettle();
    expect(find.text('Reconnect TikTok'), findsOneWidget);
    await tester.tap(find.text('Reconnect').last);
    await tester.pumpAndSettle();
    expect(find.text('1 problem to fix before scheduling.'), findsOneWidget);

    await tester.tap(find.text('Choose'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Everyone'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Ready to schedule.'), findsOneWidget);
    expect(find.text('Continue with 3 platforms'), findsOneWidget);
  });

  testWidgets('freeLimit: scheduling opens the limit sheet (H3)', (
    tester,
  ) async {
    await _toCheck(tester, scenario: Scenario.freeLimit);
    await tester.tap(find.textContaining('Continue with'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set time'));
    await tester.pumpAndSettle();
    expect(find.text('Save as draft'), findsOneWidget);
  });
}
