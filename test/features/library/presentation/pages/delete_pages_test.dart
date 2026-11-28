import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/app/app_repositories.dart';
import 'package:pushit/data/fake/fixtures/fixture_ids.dart';
import 'package:pushit/data/fake/scenario.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/presentation/pages/delete_confirm_page.dart';
import 'package:pushit/features/library/presentation/pages/delete_result_page.dart';

import '../../../../helpers/helpers.dart';

void main() {
  testWidgets('F6 against the fakes', (tester) async {
    await tester.pumpApp(
      const DeleteConfirmPage(postId: FixtureIds.morningBroll),
      repositories: repositoryProvidersOf(testDependencies()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Delete from 3 platforms'), findsOneWidget);
  });

  testWidgets('F7 against the fakes: assisted platforms wait for you', (
    tester,
  ) async {
    final deps = testDependencies();
    await tester.pumpApp(
      const DeleteResultPage(postId: FixtureIds.morningBroll),
      repositories: repositoryProvidersOf(deps),
    );
    await tester.pumpAndSettle();
    expect(find.text('Open Instagram'), findsOneWidget);
    expect(find.text('Open TikTok'), findsOneWidget);

    await deps.posts.confirmAssisted(
      FixtureIds.morningBroll,
      PlatformId.instagram,
    );
    await deps.posts.confirmAssisted(
      FixtureIds.morningBroll,
      PlatformId.tiktok,
    );
    await tester.pumpAndSettle();
    expect(find.text('Removed from every platform.'), findsOneWidget);
  });

  testWidgets('F7 offline: automatic platforms fail', (tester) async {
    await tester.pumpApp(
      const DeleteResultPage(postId: FixtureIds.morningBroll),
      repositories: repositoryProvidersOf(
        testDependencies(scenario: Scenario.offline),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
  });
}
