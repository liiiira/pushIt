import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/app.dart';
import 'package:pushit/app/router/app_redirect.dart';
import 'package:pushit/app/router/app_router.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/data/fake/scenario.dart';

import '../../helpers/helpers.dart';

const _signedIn = AppAccess(isOnboarded: true, isSignedIn: true);

Future<GoRouter> _pumpApp(
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
  return router;
}

void main() {
  testWidgets('D1 → D2: the picked video uploads, then Continue', (
    tester,
  ) async {
    await _pumpApp(tester);
    expect(find.text('Use this video'), findsOneWidget);

    await tester.tap(find.text('Use this video'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Uploading studio_tour_p2.mp4'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Uploaded'), findsOneWidget);
    expect(find.text('studio_tour_p2.mp4 is ready.'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Text per platform'), findsOneWidget);
  });

  testWidgets('offline: the upload pauses (D3)', (tester) async {
    await _pumpApp(tester, scenario: Scenario.offline);
    await tester.tap(find.text('Use this video'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Upload paused'), findsOneWidget);
    expect(find.text('Retry now'), findsOneWidget);
  });

  testWidgets('the Drafts tab resumes a draft in the composer', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.text('Drafts · 2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unboxing the lav mic'));
    await tester.pumpAndSettle();
    expect(find.text('Text per platform'), findsOneWidget);
  });

  testWidgets('D4: closing saves the post as a draft', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.text('Use this video'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Text per platform'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Saved to drafts'), findsOneWidget);
  });
}
