import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/plans/plans.dart';

import '../../../../helpers/helpers.dart';

final _usage = Usage(
  postsThisMonth: 10,
  connectedAccounts: 3,
  resetsOn: DateTime(2026, 12),
);

/// Opens the sheet from a button and keeps what it resolves to.
Future<LimitReachedChoice? Function()> _open(
  WidgetTester tester, {
  TestLayout? layout,
}) async {
  LimitReachedChoice? choice;
  await tester.pumpApp(
    Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () async => choice = await showLimitReachedSheet(
              context: context,
              plan: freePlan,
              usage: _usage,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
    layout: layout,
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return () => choice;
}

void main() {
  testAcrossLayouts('H3: says the limit, when it resets and what removes it', (
    tester,
    layout,
  ) async {
    final choice = await _open(tester, layout: layout);

    expect(
      find.text('You have scheduled 10 of 10 videos this month'),
      findsOneWidget,
    );
    expect(
      find.text(
        'The Free plan schedules 10 videos a month. It resets on '
        '1 December. Pro removes the limit.',
      ),
      findsOneWidget,
    );
    expect(find.text('Save as draft'), findsOneWidget);

    await tester.tap(find.text(r'See Pro, $6 a month'));
    await tester.pumpAndSettle();
    expect(choice(), LimitReachedChoice.seePlans);
  });

  testWidgets('resolves to saveDraft on Save as draft', (tester) async {
    final choice = await _open(tester);

    await tester.tap(find.text('Save as draft'));
    await tester.pumpAndSettle();

    expect(choice(), LimitReachedChoice.saveDraft);
    expect(find.text('Save as draft'), findsNothing);
  });

  testWidgets('resolves to dismissed when closed', (tester) async {
    final choice = await _open(tester);

    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();

    expect(choice(), LimitReachedChoice.dismissed);
  });
}
