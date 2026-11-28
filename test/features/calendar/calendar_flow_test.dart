import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/app.dart';
import 'package:pushit/app/router/app_redirect.dart';
import 'package:pushit/app/router/app_router.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/data/fake/scenario.dart';

import '../../helpers/helpers.dart';

Future<void> _openCalendar(
  WidgetTester tester, {
  Scenario scenario = Scenario.populated,
}) async {
  final router = buildAppRouter(
    access: ValueNotifier(const AppAccess(isOnboarded: true, isSignedIn: true)),
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    PushItApp(
      dependencies: testDependencies(scenario: scenario),
      preferences: InMemoryAppPreferences(),
      router: router,
    ),
  );
  await tester.pumpAndSettle();
  router.go(RoutePaths.calendar);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('E1 → E4: cancel a scheduled post', (tester) async {
    await _openCalendar(tester);
    expect(find.text('Thursday 12 · 4 posts'), findsOneWidget);

    await tester.tap(find.text('Studio tour, part 2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel post'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel the post'));
    await tester.pumpAndSettle();

    expect(find.text('Thursday 12 · 3 posts'), findsOneWidget);
    expect(find.text('Studio tour, part 2'), findsNothing);
  });

  testWidgets('E1 → E3: an empty day', (tester) async {
    await _openCalendar(tester);
    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();
    expect(find.text('Nothing on Tuesday 10'), findsOneWidget);
  });

  testWidgets('firstUse: today is empty', (tester) async {
    await _openCalendar(tester, scenario: Scenario.firstUse);
    expect(find.text('Nothing on Thursday 12'), findsOneWidget);
  });
}
