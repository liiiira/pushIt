import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/app/app_repositories.dart';
import 'package:pushit/data/fake/fixtures/fixture_ids.dart';
import 'package:pushit/data/fake/scenario.dart';
import 'package:pushit/features/library/presentation/pages/edit_everywhere_page.dart';

import '../../../../helpers/helpers.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester, {
    String postId = FixtureIds.morningBroll,
    Scenario scenario = Scenario.populated,
  }) async {
    await tester.pumpApp(
      EditEverywherePage(postId: postId),
      repositories: repositoryProvidersOf(testDependencies(scenario: scenario)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('loads the post into the form', (tester) async {
    await pumpPage(tester);
    expect(find.text('Morning b-roll'), findsOneWidget);
    expect(find.text('Apply to 1 platform'), findsOneWidget);
  });

  testWidgets('an unknown post says it no longer exists', (tester) async {
    await pumpPage(tester, postId: 'missing');
    expect(find.text('This post no longer exists.'), findsOneWidget);
  });
}
