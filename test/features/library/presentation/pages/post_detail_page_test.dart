import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/app/app_repositories.dart';
import 'package:pushit/data/dependencies.dart';
import 'package:pushit/data/fake/fixtures/fixture_ids.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/presentation/pages/post_detail_page.dart';

import '../../../../helpers/helpers.dart';

void main() {
  Future<Dependencies> pumpMicTest(WidgetTester tester) async {
    final deps = testDependencies();
    await tester.pumpApp(
      const PostDetailPage(postId: FixtureIds.micTest),
      repositories: repositoryProvidersOf(deps),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Reconnect and retry'));
    await tester.tap(find.text('Reconnect and retry'));
    await tester.pumpAndSettle();
    return deps;
  }

  Future<TargetStatus> tiktokStatus(Dependencies deps) async =>
      (await deps.posts.watchPost(FixtureIds.micTest).firstWhere((_) => true))
          .targetFor(PlatformId.tiktok)!
          .status;

  testWidgets('F4: the reconnect prompt, then the retry', (tester) async {
    final deps = await pumpMicTest(tester);
    expect(find.text('Reconnect TikTok'), findsOneWidget);

    await tester.tap(find.text('Reconnect'));
    await tester.pumpAndSettle();

    expect(find.text('Failed on TikTok'), findsNothing);
    final accounts = await tester.runAsync(
      () => deps.accounts.watchAccounts().firstWhere((_) => true),
    );
    expect(
      accounts!.firstWhere((a) => a.platform == PlatformId.tiktok).health,
      AccountHealth.connected,
    );
    expect(
      await tester.runAsync(() => tiktokStatus(deps)),
      TargetStatus.published,
    );
  });

  testWidgets('F4: Later changes nothing', (tester) async {
    await pumpMicTest(tester);
    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();
    expect(find.text('Failed on TikTok'), findsOneWidget);
  });
}
