import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/app.dart';
import 'package:pushit/app/router/app_redirect.dart';
import 'package:pushit/app/router/app_router.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/data/fake/fixtures/fixture_ids.dart';

import '../../helpers/helpers.dart';

Future<GoRouter> _pumpApp(WidgetTester tester) async {
  final router = buildAppRouter(
    access: ValueNotifier(const AppAccess(isOnboarded: true, isSignedIn: true)),
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    PushItApp(
      dependencies: testDependencies(),
      preferences: InMemoryAppPreferences(),
      router: router,
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('G2: I posted it publishes the assisted platform', (
    tester,
  ) async {
    final router = await _pumpApp(tester);
    router.go(RoutePaths.libraryPostFor(FixtureIds.behindTheDesk));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Instagram'));
    expect(find.textContaining('Scheduled'), findsWidgets);

    unawaited(
      router.push(
        RoutePaths.assistedFor(FixtureIds.behindTheDesk, 'instagram'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('I posted it'));
    await tester.pumpAndSettle();

    expect(find.text('Assisted posting'), findsNothing);
    expect(find.textContaining('Published'), findsWidgets);
  });

  testWidgets('F7 → G3 → back: the TikTok delete is confirmed', (tester) async {
    final router = await _pumpApp(tester);
    router.go(RoutePaths.libraryPostDeleteResultFor(FixtureIds.morningBroll));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open TikTok'));
    await tester.pumpAndSettle();
    expect(find.text('Remove Morning b-roll from TikTok'), findsOneWidget);

    await tester.tap(find.text('I deleted it'));
    await tester.pumpAndSettle();
    expect(find.text('Open TikTok'), findsNothing);
    expect(find.text('Open Instagram'), findsOneWidget);
  });
}
