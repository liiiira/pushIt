import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/data/dependencies.dart';
import 'package:pushit/data/fake/scenario.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/presentation/pages/library_page.dart';

import '../../../../helpers/helpers.dart';

void main() {
  final now = DateTime(2026, 11, 12, 15, 48);

  Future<void> pumpPage(WidgetTester tester, Scenario scenario) async {
    final deps = Dependencies.fake(
      scenario: scenario,
      clock: FixedClock(now),
      latency: Duration.zero,
    );
    await tester.pumpApp(
      const LibraryPage(),
      repositories: [
        RepositoryProvider<Clock>.value(value: deps.clock),
        RepositoryProvider<PostsRepository>.value(value: deps.posts),
      ],
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
