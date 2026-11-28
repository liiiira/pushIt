import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/app/app_repositories.dart';
import 'package:pushit/data/fake/scenario.dart';
import 'package:pushit/features/library/presentation/pages/library_page.dart';

import '../../../../helpers/helpers.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester, Scenario scenario) async {
    await tester.pumpApp(
      const LibraryPage(),
      repositories: repositoryProvidersOf(testDependencies(scenario: scenario)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('populated: shows the fixture posts', (tester) async {
    await pumpPage(tester, Scenario.populated);
    expect(find.text('Studio tour, part 2'), findsOneWidget);
    expect(find.text('Unboxing the lav mic'), findsNothing, reason: 'draft');
  });

  testWidgets('firstUse: shows F2', (tester) async {
    await pumpPage(tester, Scenario.firstUse);
    expect(find.text('No videos yet'), findsOneWidget);
  });

  testWidgets('error: shows I3', (tester) async {
    await pumpPage(tester, Scenario.error);
    expect(find.text('Something went wrong'), findsOneWidget);
  });
}
